DECLARE @dbid int, @dbname VARCHAR(1000), @ErrorMessage VARCHAR(MAX)
DECLARE @sqlcmd NVARCHAR(max), @params NVARCHAR(500)
DECLARE @sqlmajorver int,@sqlminorver int, @sqlbuild int
DECLARE @ixfragscanmode NVARCHAR(1000) = 'Limited'

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
		CONSTRAINT PK_tmpIPS_CI PRIMARY KEY CLUSTERED(database_id, [object_id], [index_id], [partition_number], row_group_id));

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
			
			UPDATE #tmpdbs0
			SET isdone = 1
			WHERE [dbid] = @dbid;
		END
	END;

	IF (SELECT COUNT(*) FROM tempdb.dbo.tblWorking WHERE is_done = 0 AND type  = 5) > 0
	BEGIN
		WHILE (SELECT COUNT(*) FROM tempdb.dbo.tblWorking WHERE is_done = 0 AND type IN (5,6)) > 0
		BEGIN
			SELECT TOP 1 @dbid = database_id, @objectid = [object_id], @indexid = index_id, @partition_nr = partition_number
			FROM tempdb.dbo.tblWorking WHERE is_done = 0 AND type IN (5,6)
			
			BEGIN TRY
				SELECT @ColumnStoreGetIXSQL = 'SELECT @dbid_In, rg.object_id, rg.index_id, rg.partition_number, SUM((ISNULL(rg.deleted_rows,1)*100)/CASE WHEN rg.total_rows = 0 THEN 1 ELSE rg.total_rows END) AS [fragmentation], SUM(ISNULL(rg.size_in_bytes,1)/1024/8) AS [simulated_page_count], CAST(SUM(rg.size_in_bytes)/1024/1024 AS DECIMAL(26,3)) AS [size_MB], rg.total_rows, rg.delta_store_hobt_id, rg.row_group_id, rg.state, rg.state_description
FROM [' + DB_NAME(@dbid) + '].sys.column_store_row_groups rg 
WHERE rg.object_id = @objectid_In
	AND rg.index_id = @indexid_In
	AND rg.partition_number = @partition_nr_In
	--AND rg.state = 3 -- Only COMPRESSED row groups
GROUP BY rg.object_id, rg.index_id, rg.partition_number, rg.total_rows, rg.delta_store_hobt_id, rg.row_group_id, rg.state, rg.state_description
OPTION (MAXDOP 2)'
				SET @ColumnStoreGetIXSQL_Param = N'@dbid_In int, @objectid_In int, @indexid_In int, @partition_nr_In int';

				INSERT INTO tempdb.dbo.tmpIPS_CI ([database_id], [object_id], [index_id], [partition_number], fragmentation, [page_count], [size_MB], record_count, delta_store_hobt_id, row_group_id, [state], state_description)		
				EXECUTE sp_executesql @ColumnStoreGetIXSQL, @ColumnStoreGetIXSQL_Param, @dbid_In = @dbid, @objectid_In = @objectid, @indexid_In = @indexid, @partition_nr_In = @partition_nr;
			END TRY
			BEGIN CATCH						
				SET @ErrorMessage = '      |-Error ' + CONVERT(VARCHAR(20),ERROR_NUMBER()) + ' has occurred while analyzing columnstore indexes. Message: ' + ERROR_MESSAGE() + ' (Line Number: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ')'
				RAISERROR(@ErrorMessage, 0, 42) WITH NOWAIT;
			END CATCH
			
			UPDATE tempdb.dbo.tblWorking
			SET is_done = 1
			WHERE database_id = @dbid AND [object_id] = @objectid AND index_id = @indexid AND partition_number = @partition_nr
		END
	END;


Select w.schema_name, w.object_name, w.index_id,i.* 
From tempdb.dbo.tmpIPS_CI i
	Inner join tempdb.dbo.tblWorking w on i.database_id = w.database_id and i.object_id = w.object_id
		And i.index_id = w.index_id
