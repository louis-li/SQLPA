DECLARE @dbid int, @dbname VARCHAR(1000), @ErrorMessage VARCHAR(MAX)
DECLARE @sqlcmd NVARCHAR(max), @params NVARCHAR(500)
DECLARE @sqlmajorver int,@sqlminorver int, @sqlbuild int
DECLARE @ixfragscanmode NVARCHAR(1000) = 'Limited'

CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);
	
	DECLARE @objectid int, @indexid int, @partition_nr int, @type_desc NVARCHAR(60)

	DECLARE @schema_name VARCHAR(100), @table_name VARCHAR(300), @KeyCols VARCHAR(4000), @distinctCnt bigint, @OptimBucketCnt bigint
	
	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmpIPS'))
	DROP TABLE #tmpIPS;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmpIPS'))
	CREATE TABLE #tmpIPS ([database_id] int, [object_id] int, [index_id] int, [partition_number] int, fragmentation DECIMAL(18,3), [page_count] bigint, [size_MB] DECIMAL(26,3), record_count bigint, forwarded_record_count int NULL,
		CONSTRAINT PK_IPS PRIMARY KEY CLUSTERED(database_id, [object_id], [index_id], [partition_number]));

	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblWorking'))
	DROP TABLE #tblWorking;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblWorking'))
	CREATE TABLE #tblWorking (database_id int, [database_name] NVARCHAR(255), [object_id] int, [object_name] NVARCHAR(255), index_id int, index_name NVARCHAR(255), [schema_name] NVARCHAR(255), partition_number int, [type] tinyint, type_desc NVARCHAR(60), is_done bit)
	-- type 0 = Heap; 1 = Clustered; 2 = Nonclustered; 3 = XML; 4 = Spatial; 5 = Clustered columnstore; 6 = Nonclustered columnstore; 7 = Nonclustered hash

	UPDATE #tmpdbs0
	SET isdone = 0;

	UPDATE #tmpdbs0
	SET isdone = 1
	WHERE [state] <> 0 OR [dbid] < 5;

	UPDATE #tmpdbs0
	SET isdone = 1
	WHERE [role] = 2 AND secondary_role_allow_connections = 0;


	IF EXISTS (SELECT TOP 1 id FROM #tmpdbs0 WHERE isdone = 0)
	BEGIN
		WHILE (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
		BEGIN
			SELECT TOP 1 @dbid = [dbid] FROM #tmpdbs0 WHERE isdone = 0
			SELECT @sqlcmd = 'SELECT ' + CONVERT(VARCHAR(10), @dbid) + ', ''' + DB_NAME(@dbid) + ''', si.[object_id], mst.[name], si.index_id, si.name, t.name, sp.partition_number, si.[type], si.type_desc, 0
FROM [' + DB_NAME(@dbid) + '].sys.indexes si
INNER JOIN [' + DB_NAME(@dbid) + '].sys.partitions sp ON si.[object_id] = sp.[object_id] AND si.index_id = sp.index_id
INNER JOIN [' + DB_NAME(@dbid) + '].sys.tables AS mst ON mst.[object_id] = si.[object_id]
INNER JOIN [' + DB_NAME(@dbid) + '].sys.schemas AS t ON t.[schema_id] = mst.[schema_id]
WHERE mst.is_ms_shipped = 0 AND ' + CASE WHEN @sqlmajorver <= 11 THEN ' si.[type] <= 2;' ELSE ' si.[type] IN (0,1,2,5,6,7);' END

			INSERT INTO #tblWorking
			EXEC sp_executesql @sqlcmd;

	
			UPDATE #tmpdbs0
			SET isdone = 1
			WHERE [dbid] = @dbid;
		END
	END;

	IF (SELECT COUNT(*) FROM #tblWorking WHERE is_done = 0 AND [type] <= 2) > 0
	BEGIN
		WHILE (SELECT COUNT(*) FROM #tblWorking WHERE is_done = 0 AND [type] <= 2) > 0
		BEGIN
			SELECT TOP 1 @dbid = database_id, @objectid = [object_id], @indexid = index_id, @partition_nr = partition_number
			FROM #tblWorking WHERE is_done = 0 AND [type] <= 2
			
			INSERT INTO #tmpIPS
			SELECT ps.database_id, ps.[object_id], ps.index_id, ps.partition_number, SUM(ps.avg_fragmentation_in_percent), SUM(ps.page_count), 
				CAST((SUM(ps.page_count)*8)/1024 AS DECIMAL(26,3)) AS [size_MB], ps.record_count, ps.forwarded_record_count -- for heaps
			FROM sys.dm_db_index_physical_stats(@dbid, @objectid, @indexid , @partition_nr, @ixfragscanmode) AS ps
			WHERE /*ps.index_id > 0 -- ignore heaps
				AND */ps.index_level = 0 -- leaf-level nodes only
				AND ps.alloc_unit_type_desc = 'IN_ROW_DATA'
			GROUP BY ps.database_id, ps.[object_id], ps.index_id, ps.partition_number, ps.record_count, ps.forwarded_record_count
			Having  SUM(ps.page_count) > 8 AND SUM(ps.avg_fragmentation_in_percent) > 5
			OPTION (MAXDOP 2);
			
			UPDATE #tblWorking
			SET is_done = 1
			WHERE database_id = @dbid AND [object_id] = @objectid AND index_id = @indexid AND partition_number = @partition_nr
		END
	END;

Select w.schema_name, w.Object_name,w.index_name,i.*  from 
	#tmpIPS i 
		Inner join #tblWorking w on i.database_id = w.database_id and i.object_id = w.object_id and i.index_id = w.index_id

