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

	IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmpXNCIS'))
	DROP TABLE #tmpXNCIS;

	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmpXNCIS'))
	CREATE TABLE #tmpXNCIS (
		[database_id] int, [object_id] int, [schema_name] VARCHAR(100) COLLATE database_default, 
		[table_name] VARCHAR(300) COLLATE database_default, [index_id] int, 
		[index_name] VARCHAR(300) COLLATE database_default, type_desc NVARCHAR(60), 
		delta_pages bigint, internal_pages bigint, leaf_pages bigint, page_update_count bigint, 
		page_update_retry_count bigint, page_consolidation_count bigint, 
		page_consolidation_retry_count bigint, page_split_count bigint, 
		page_split_retry_count bigint, key_split_count bigint, key_split_retry_count bigint, 
		page_merge_count bigint, page_merge_retry_count bigint, key_merge_count bigint, 
		key_merge_retry_count bigint, scans_started bigint, scans_retries bigint 
		CONSTRAINT PK_tmp_XNCIS PRIMARY KEY CLUSTERED(database_id, [object_id], [index_id]));

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


			IF @sqlmajorver >= 12
			BEGIN
				SELECT @sqlcmd = 'SELECT @HasInMemOUT = ISNULL((SELECT TOP 1 1 FROM [' + DB_NAME(@dbid) + '].sys.filegroups FG where FG.[type] = ''FX''), 0)'
				SET @params = N'@HasInMemOUT bit OUTPUT';
				EXECUTE sp_executesql @sqlcmd, @params, @HasInMemOUT=@HasInMem OUTPUT

				IF @HasInMem = 1
				BEGIN


					SET @sqlcmd = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
USE [' + DB_NAME(@dbid) + '];
SELECT ' + CONVERT(NVARCHAR(20), @dbid) + ' AS [database_id],
	xis.[object_id], t.name, o.name, xis.index_id, si.name, si.type_desc,
	xnis.delta_pages, xnis.internal_pages, xnis.leaf_pages, xnis.page_update_count,
	xnis.page_update_retry_count, xnis.page_consolidation_count,
	xnis.page_consolidation_retry_count, xnis.page_split_count, xnis.page_split_retry_count,
	xnis.key_split_count, xnis.key_split_retry_count, xnis.page_merge_count, xnis.page_merge_retry_count,
	xnis.key_merge_count, xnis.key_merge_retry_count,
	xis.scans_started, xis.scans_retries
FROM sys.dm_db_xtp_nonclustered_index_stats AS xnis WITH (NOLOCK)
INNER JOIN sys.dm_db_xtp_index_stats AS xis WITH (NOLOCK) ON xis.[object_id] = xnis.[object_id] AND xis.[index_id] = xnis.[index_id]
INNER JOIN sys.indexes AS si (NOLOCK) ON xis.[object_id] = si.[object_id] AND xis.[index_id] = si.[index_id]
INNER JOIN sys.objects AS o (NOLOCK) ON si.[object_id] = o.[object_id]
INNER JOIN sys.tables AS mst (NOLOCK) ON mst.[object_id] = o.[object_id]
INNER JOIN sys.schemas AS t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
WHERE o.[type] = ''U'''

					BEGIN TRY
						INSERT INTO #tmpXNCIS
						EXECUTE sp_executesql @sqlcmd
					END TRY
					BEGIN CATCH						
						SET @ErrorMessage = '      |-Error ' + CONVERT(VARCHAR(20),ERROR_NUMBER()) + ' has occurred while analyzing nonclustered hash indexes. Message: ' + ERROR_MESSAGE() + ' (Line Number: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ')'
						RAISERROR(@ErrorMessage, 0, 42) WITH NOWAIT;
					END CATCH
				END;

			END;
			
			UPDATE #tmpdbs0
			SET isdone = 1
			WHERE [dbid] = @dbid;
		END
	END;

Select * from #tmpXNCIS
