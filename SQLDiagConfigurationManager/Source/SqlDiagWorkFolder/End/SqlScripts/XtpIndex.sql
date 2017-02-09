DECLARE @dbid int, @dbname VARCHAR(1000), @ErrorMessage VARCHAR(MAX)
DECLARE @sqlcmd NVARCHAR(max), @params NVARCHAR(500)
DECLARE @sqlmajorver int,@sqlminorver int, @sqlbuild int
DECLARE @ixfragscanmode NVARCHAR(1000) = 'Limited'


IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmpdbs0'))
DROP TABLE #tmpdbs0;
CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);
	
	DECLARE @objectid int, @indexid int, @partition_nr int, @type_desc NVARCHAR(60)
	DECLARE @ColumnStoreGetIXSQL NVARCHAR(2000), @ColumnStoreGetIXSQL_Param NVARCHAR(1000), @HasInMem bit
	DECLARE @schema_name VARCHAR(100), @table_name VARCHAR(300), @KeyCols VARCHAR(4000), @distinctCnt bigint, @OptimBucketCnt bigint

	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tmpIPS_CI'))
	DROP TABLE tempdb.dbo.tmpIPS_CI;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tmpIPS_CI'))
	CREATE TABLE tempdb.dbo.tmpIPS_CI ([database_id] int, [object_id] int, [index_id] int, [partition_number] int, fragmentation DECIMAL(18,3), [page_count] bigint, [size_MB] DECIMAL(26,3), record_count bigint, delta_store_hobt_id bigint, row_group_id int , [state] tinyint, state_description VARCHAR(60),
		CONSTRAINT PK_IPS_CI1 PRIMARY KEY CLUSTERED(database_id, [object_id], [index_id], [partition_number], row_group_id));

	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tmpXIS'))
	DROP TABLE tempdb.dbo.tmpXIS;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tmpXIS'))
	CREATE TABLE tempdb.dbo.tmpXIS (
		[database_id] int, [object_id] int, [schema_name] VARCHAR(100) COLLATE database_default, 
		[table_name] VARCHAR(300) COLLATE database_default, [index_id] int, 
		[index_name] VARCHAR(300) COLLATE database_default, type_desc NVARCHAR(60), 
		total_bucket_count bigint, empty_bucket_count bigint, avg_chain_length bigint, 
		max_chain_length bigint, KeyCols VARCHAR(4000) COLLATE database_default, 
		DistinctCnt bigint NULL, OptimBucketCnt bigint NULL, isdone bit, 
		CONSTRAINT PK_tmpXIS1 PRIMARY KEY CLUSTERED(database_id, [object_id], [index_id]));

	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tmpXNCIS'))
	DROP TABLE tempdb.dbo.tmpXNCIS;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tmpXNCIS'))
	CREATE TABLE tempdb.dbo.tmpXNCIS (
		[database_id] int, [object_id] int, [schema_name] VARCHAR(100) COLLATE database_default, 
		[table_name] VARCHAR(300) COLLATE database_default, [index_id] int, 
		[index_name] VARCHAR(300) COLLATE database_default, type_desc NVARCHAR(60), 
		delta_pages bigint, internal_pages bigint, leaf_pages bigint, page_update_count bigint, 
		page_update_retry_count bigint, page_consolidation_count bigint, 
		page_consolidation_retry_count bigint, page_split_count bigint, 
		page_split_retry_count bigint, key_split_count bigint, key_split_retry_count bigint, 
		page_merge_count bigint, page_merge_retry_count bigint, key_merge_count bigint, 
		key_merge_retry_count bigint, scans_started bigint, scans_retries bigint, 
		CONSTRAINT PK_tmpXNCIS1 PRIMARY KEY CLUSTERED(database_id, [object_id], [index_id]));

	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tblWorking'))
	DROP TABLE tempdb.dbo.tblWorking;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.tblWorking'))
	CREATE TABLE tempdb.dbo.tblWorking (database_id int, [database_name] NVARCHAR(255), [object_id] int, [object_name] NVARCHAR(255), index_id int, index_name NVARCHAR(255), [schema_name] NVARCHAR(255), partition_number int, [type] tinyint, type_desc NVARCHAR(60), is_done bit)
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

			INSERT INTO tempdb.dbo.tblWorking
			EXEC sp_executesql @sqlcmd;

			IF @sqlmajorver >= 12
			BEGIN
				SELECT @sqlcmd = 'SELECT @HasInMemOUT = ISNULL((SELECT TOP 1 1 FROM [' + DB_NAME(@dbid) + '].sys.filegroups FG where FG.[type] = ''FX''), 0)'
				SET @params = N'@HasInMemOUT bit OUTPUT';
				EXECUTE sp_executesql @sqlcmd, @params, @HasInMemOUT=@HasInMem OUTPUT

				IF @HasInMem = 1
				BEGIN
					INSERT INTO tempdb.dbo.tmpIPS_CI ([database_id], [object_id], [index_id], [partition_number], fragmentation, [page_count], [size_MB], record_count, delta_store_hobt_id, row_group_id, [state], state_description)		
					EXECUTE sp_executesql @ColumnStoreGetIXSQL, @ColumnStoreGetIXSQL_Param, @dbid_In = @dbid, @objectid_In = @objectid, @indexid_In = @indexid, @partition_nr_In = @partition_nr;

					RAISERROR (@ErrorMessage, 10, 1) WITH NOWAIT;

					SET @sqlcmd = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
USE [' + DB_NAME(@dbid) + '];
SELECT ' + CONVERT(NVARCHAR(20), @dbid) + ' AS [database_id], xis.[object_id], t.name, o.name, xis.index_id, si.name, si.type_desc, xhis.total_bucket_count, xhis.empty_bucket_count, xhis.avg_chain_length, xhis.max_chain_length,
	SUBSTRING((SELECT '','' + ac.name FROM sys.tables AS st
		INNER JOIN sys.indexes AS i ON st.[object_id] = i.[object_id]
		INNER JOIN sys.index_columns AS ic ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id] 
		INNER JOIN sys.all_columns AS ac ON st.[object_id] = ac.[object_id] AND ic.[column_id] = ac.[column_id]
		WHERE si.[object_id] = i.[object_id] AND si.index_id = i.index_id AND ic.is_included_column = 0
		ORDER BY ic.key_ordinal
	FOR XML PATH('''')), 2, 8000) AS KeyCols, NULL, NULL, 0
FROM sys.dm_db_xtp_hash_index_stats AS xhis
INNER JOIN sys.dm_db_xtp_index_stats AS xis ON xis.[object_id] = xhis.[object_id] AND xis.[index_id] = xhis.[index_id] 
INNER JOIN sys.indexes AS si (NOLOCK) ON xis.[object_id] = si.[object_id] AND xis.[index_id] = si.[index_id]
INNER JOIN sys.objects AS o (NOLOCK) ON si.[object_id] = o.[object_id]
INNER JOIN sys.tables AS mst (NOLOCK) ON mst.[object_id] = o.[object_id]
INNER JOIN sys.schemas AS t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
WHERE o.[type] = ''U'''

					BEGIN TRY
						INSERT INTO tempdb.dbo.tmpXIS
						EXECUTE sp_executesql @sqlcmd
					END TRY
					BEGIN CATCH						
						SET @ErrorMessage = '      |-Error ' + CONVERT(VARCHAR(20),ERROR_NUMBER()) + ' has occurred while analyzing hash indexes. Message: ' + ERROR_MESSAGE() + ' (Line Number: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ')'
						RAISERROR(@ErrorMessage, 0, 42) WITH NOWAIT;
					END CATCH

				END;
			END;
			
			UPDATE #tmpdbs0
			SET isdone = 1
			WHERE [dbid] = @dbid;
		END
	END;

	IF EXISTS (SELECT TOP 1 database_id FROM tempdb.dbo.tmpXIS WHERE isdone = 0)
	BEGIN
		WHILE (SELECT COUNT(database_id) FROM tempdb.dbo.tmpXIS WHERE isdone = 0) > 0
		BEGIN
			SELECT TOP 1 @dbid = database_id, @objectid = [object_id], @indexid = [index_id], @schema_name = [schema_name], @table_name = [table_name], @KeyCols = KeyCols FROM tempdb.dbo.tmpXIS WHERE isdone = 0
						
			SELECT @sqlcmd = 'USE ' + QUOTENAME(DB_NAME(@dbid)) + '; SELECT @distinctCntOUT = COUNT(*), @OptimBucketCntOUT = POWER(2,CEILING(LOG(CASE WHEN COUNT(*) = 0 THEN 1 ELSE COUNT(*) END)/LOG(2))) FROM (SELECT DISTINCT ' + @KeyCols + ' FROM ' + @schema_name + '.' + @table_name + ') t1;'

			SET @params = N'@distinctCntOUT bigint OUTPUT, @OptimBucketCntOUT bigint OUTPUT';
			EXECUTE sp_executesql @sqlcmd, @params, @distinctCntOUT=@distinctCnt OUTPUT, @OptimBucketCntOUT=@OptimBucketCnt OUTPUT;
			
			UPDATE tempdb.dbo.tmpXIS
			SET distinctCnt = @distinctCnt, OptimBucketCnt = @OptimBucketCnt, isdone = 1
			WHERE database_id = @dbid AND [object_id] = @objectid AND [index_id] = @indexid;
		END;
	END;

Select * from tempdb.dbo.tmpXIS