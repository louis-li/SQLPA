CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)

DECLARE /*@dbid int,*/ @query VARCHAR(1000)/*, @dbname VARCHAR(1000)*/, @count int, @count_used int, @logsize DECIMAL(20,1), @usedlogsize DECIMAL(20,1), @avgvlfsize DECIMAL(20,1)
DECLARE @potsize DECIMAL(20,1), @n_iter int, @n_iter_final int, @initgrow DECIMAL(20,1), @n_init_iter int
DECLARE @dbid int, @dbname VARCHAR(1000)
DECLARE @sqlcmd NVARCHAR(max), @params NVARCHAR(500), @sqlmajorver int

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#log_info1'))
DROP TABLE #log_info1;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#log_info1'))
CREATE TABLE #log_info1 (dbname VARCHAR(100), 
	Actual_log_size_MB DECIMAL(20,1), 
	Used_Log_size_MB DECIMAL(20,1),
	Potential_log_size_MB DECIMAL(20,1), 
	Actual_VLFs int,
	Used_VLFs int,
	Avg_VLF_size_KB DECIMAL(20,1),
	Potential_VLFs int, 
	Growth_iterations int,
	Log_Initial_size_MB DECIMAL(20,1),
	File_autogrow_MB DECIMAL(20,1))
	
IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#log_info2'))
DROP TABLE #log_info2;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#log_info2'))
CREATE TABLE #log_info2 (dbname VARCHAR(100), 
	Actual_VLFs int, 
	VLF_size_KB DECIMAL(20,1), 
	growth_iteration int)
		
UPDATE #tmpdbs0
SET isdone = 0;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [state] <> 0;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [role] = 2 AND secondary_role_allow_connections = 0;
	
IF (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
BEGIN
	WHILE (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
	BEGIN
		SELECT TOP 1 @dbname = [dbname], @dbid = [dbid] FROM #tmpdbs0 WHERE isdone = 0
			
		IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#log_info3'))
		DROP TABLE #log_info3;
		IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#log_info3'))
		CREATE TABLE #log_info3 (recoveryunitid int NULL,
			fileid tinyint,
			file_size bigint,
			start_offset bigint,
			FSeqNo int,
			[status] tinyint,
			parity tinyint,
			create_lsn numeric(25,0))
		SET @query = 'DBCC LOGINFO (' + '''' + @dbname + ''') WITH NO_INFOMSGS'
		IF @sqlmajorver < 11
		BEGIN
			INSERT INTO #log_info3 (fileid, file_size, start_offset, FSeqNo, [status], parity, create_lsn)
			EXEC (@query)
		END
		ELSE
		BEGIN
			INSERT INTO #log_info3 (recoveryunitid, fileid, file_size, start_offset, FSeqNo, [status], parity, create_lsn)
			EXEC (@query)
		END

		SET @count = @@ROWCOUNT
		SET @count_used = (SELECT COUNT(fileid) FROM #log_info3 l WHERE l.[status] = 2)
		SET @logsize = (SELECT (MIN(l.start_offset) + SUM(l.file_size))/1048576.00 FROM #log_info3 l)
		SET @usedlogsize = (SELECT (MIN(l.start_offset) + SUM(CASE WHEN l.status <> 0 THEN l.file_size ELSE 0 END))/1048576.00 FROM #log_info3 l)
		SET @avgvlfsize = (SELECT AVG(l.file_size)/1024.00 FROM #log_info3 l)

		INSERT INTO #log_info2
		SELECT @dbname, COUNT(create_lsn), MIN(l.file_size)/1024.00,
			ROW_NUMBER() OVER(ORDER BY l.create_lsn) FROM #log_info3 l 
		GROUP BY l.create_lsn 
		ORDER BY l.create_lsn

		DROP TABLE #log_info3;

		-- Grow logs in MB instead of GB because of known issue prior to SQL 2012.
		-- More detail here: http://www.sqlskills.com/BLOGS/PAUL/post/Bug-log-file-growth-broken-for-multiples-of-4GB.aspx
		-- and http://connect.microsoft.com/SQLServer/feedback/details/481594/log-growth-not-working-properly-with-specific-growth-sizes-vlfs-also-not-created-appropriately
		-- or https://connect.microsoft.com/SQLServer/feedback/details/357502/transaction-log-file-size-will-not-grow-exactly-4gb-when-filegrowth-4gb
		IF @sqlmajorver >= 11
		BEGIN
			SET @n_iter = (SELECT CASE WHEN @logsize <= 64 THEN 1
				WHEN @logsize > 64 AND @logsize < 256 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/256, 0)
				WHEN @logsize >= 256 AND @logsize < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/512, 0)
				WHEN @logsize >= 1024 AND @logsize < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/1024, 0)
				WHEN @logsize >= 4096 AND @logsize < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/2048, 0)
				WHEN @logsize >= 8192 AND @logsize < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/4096, 0)
				WHEN @logsize >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/8192, 0)
				END)
			SET @potsize = (SELECT CASE WHEN @logsize <= 64 THEN 1*64
				WHEN @logsize > 64 AND @logsize < 256 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/256, 0)*256
				WHEN @logsize >= 256 AND @logsize < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/512, 0)*512
				WHEN @logsize >= 1024 AND @logsize < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/1024, 0)*1024
				WHEN @logsize >= 4096 AND @logsize < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/2048, 0)*2048
				WHEN @logsize >= 8192 AND @logsize < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/4096, 0)*4096
				WHEN @logsize >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/8192, 0)*8192
				END)
		END
		ELSE
		BEGIN
			SET @n_iter = (SELECT CASE WHEN @logsize <= 64 THEN 1
				WHEN @logsize > 64 AND @logsize < 256 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/256, 0)
				WHEN @logsize >= 256 AND @logsize < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/512, 0)
				WHEN @logsize >= 1024 AND @logsize < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/1024, 0)
				WHEN @logsize >= 4096 AND @logsize < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/2048, 0)
				WHEN @logsize >= 8192 AND @logsize < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/4000, 0)
				WHEN @logsize >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/8000, 0)
				END)
			SET @potsize = (SELECT CASE WHEN @logsize <= 64 THEN 1*64
				WHEN @logsize > 64 AND @logsize < 256 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/256, 0)*256
				WHEN @logsize >= 256 AND @logsize < 1024 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/512, 0)*512
				WHEN @logsize >= 1024 AND @logsize < 4096 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/1024, 0)*1024
				WHEN @logsize >= 4096 AND @logsize < 8192 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/2048, 0)*2048
				WHEN @logsize >= 8192 AND @logsize < 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/4000, 0)*4000
				WHEN @logsize >= 16384 THEN ROUND(CONVERT(FLOAT, ROUND(@logsize, -2))/8000, 0)*8000
				END)
		END
			
		-- If the proposed log size is smaller than current log, and also smaller than 4GB,
		-- and there is less than 512MB of diff between the current size and proposed size, add 1 grow.
		SET @n_iter_final = @n_iter
		IF @logsize > @potsize AND @potsize <= 4096 AND ABS(@logsize - @potsize) < 512
		BEGIN
			SET @n_iter_final = @n_iter + 1
		END
		-- If the proposed log size is larger than current log, and also larger than 50GB, 
		-- and there is less than 1GB of diff between the current size and proposed size, take 1 grow.
		ELSE IF @logsize < @potsize AND @potsize <= 51200 AND ABS(@logsize - @potsize) > 1024
		BEGIN
			SET @n_iter_final = @n_iter - 1
		END

		IF @potsize = 0 
		BEGIN 
			SET @potsize = 64 
		END
		IF @n_iter = 0 
		BEGIN 
			SET @n_iter = 1
		END
			
		SET @potsize = (SELECT CASE WHEN @n_iter < @n_iter_final THEN @potsize + (@potsize/@n_iter) 
				WHEN @n_iter > @n_iter_final THEN @potsize - (@potsize/@n_iter) 
				ELSE @potsize END)
			
		SET @n_init_iter = @n_iter_final
		IF @potsize >= 8192
		BEGIN
			SET @initgrow = @potsize/@n_iter_final
		END
		IF @potsize >= 64 AND @potsize <= 512
		BEGIN
			SET @n_init_iter = 1
			SET @initgrow = 512
		END
		IF @potsize > 512 AND @potsize <= 1024
		BEGIN
			SET @n_init_iter = 1
			SET @initgrow = 1023
		END
		IF @potsize > 1024 AND @potsize < 8192
		BEGIN
			SET @n_init_iter = 1
			SET @initgrow = @potsize
		END

		INSERT INTO #log_info1
		VALUES(@dbname, @logsize, @usedlogsize, @potsize, @count, @count_used, @avgvlfsize, 
			CASE WHEN @potsize <= 64 THEN (@potsize/(@potsize/@n_init_iter))*4
				WHEN @potsize > 64 AND @potsize < 1024 THEN (@potsize/(@potsize/@n_init_iter))*8
				WHEN @potsize >= 1024 THEN (@potsize/(@potsize/@n_init_iter))*16
				END,
			@n_init_iter, @initgrow, 
			CASE WHEN (@potsize/@n_iter_final) <= 1024 THEN (@potsize/@n_iter_final) ELSE 1024 END
			);

		UPDATE #tmpdbs0
		SET isdone = 1
		WHERE [dbid] = @dbid
	END
END;

Select * from #log_info1