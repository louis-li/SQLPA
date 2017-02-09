CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)

DECLARE @dbid int, @dbname VARCHAR(1000), @ErrorMessage VARCHAR(MAX)
DECLARE @sqlcmd NVARCHAR(max), @params NVARCHAR(500)
DECLARE @sqlmajorver int,@sqlminorver int, @sqlbuild int
DECLARE @dbcmptlevel int

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);
SELECT @sqlminorver = CONVERT(int, (@@microsoftversion / 0x10000) & 0xff);
SELECT @sqlbuild = CONVERT(int, @@microsoftversion & 0xffff);

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblStatsSamp'))
DROP TABLE #tblStatsSamp;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblStatsSamp'))
CREATE TABLE #tblStatsSamp ([DatabaseName] sysname, [databaseID] int, objectID int, schemaName VARCHAR(100), [tableName] VARCHAR(250), last_updated DATETIME, [rows] bigint, modification_counter bigint, [stats_id] int, [stat_name] VARCHAR(255), rows_sampled bigint, auto_created bit, user_created bit, has_filter bit NULL, filter_definition NVARCHAR(MAX) NULL, unfiltered_rows bigint, steps int)

UPDATE #tmpdbs0
SET isdone = 0;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [state] <> 0 OR [dbid] < 5;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [role] = 2 AND secondary_role_allow_connections = 0;
	
IF (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
BEGIN		
	WHILE (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
	BEGIN
		SELECT TOP 1 @dbname = [dbname], @dbid = [dbid], @dbcmptlevel = [compatibility_level] FROM #tmpdbs0 WHERE isdone = 0
		IF @dbcmptlevel > 80
		BEGIN
			SET @sqlcmd = 'USE ' + QUOTENAME(@dbname) + ';
SELECT DISTINCT ''' + @dbname + ''' AS [DatabaseName], ''' + CONVERT(VARCHAR(12),@dbid) + ''' AS [databaseID], mst.[object_id] AS objectID, t.name AS schemaName, OBJECT_NAME(mst.[object_id]) AS tableName, 
sp.last_updated, sp.[rows], sp.modification_counter, ss.[stats_id], ss.name AS [stat_name], sp.rows_sampled, ss.auto_created, ss.user_created, ss.has_filter, ss.filter_definition, sp.unfiltered_rows, sp.steps
FROM sys.objects AS o
INNER JOIN sys.tables AS mst ON mst.[object_id] = o.[object_id]
INNER JOIN sys.schemas AS t ON t.[schema_id] = mst.[schema_id]
INNER JOIN sys.stats AS ss ON ss.[object_id] = mst.[object_id]
CROSS APPLY sys.dm_db_stats_properties(ss.[object_id], ss.[stats_id]) AS sp
WHERE sp.[rows] > 0
AND	CAST((sp.rows_sampled/(sp.[rows]*1.00))*100.0 AS DECIMAL(5,2)) < 25'

			BEGIN TRY
				INSERT INTO #tblStatsSamp
				EXECUTE sp_executesql @sqlcmd
			END TRY
			BEGIN CATCH
				SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
				SELECT @ErrorMessage = 'Statistics sampling subsection - Error raised in TRY block in database ' + @dbname +'. ' + ERROR_MESSAGE()
				RAISERROR (@ErrorMessage, 16, 1);
			END CATCH
		END
			
		UPDATE #tmpdbs0
		SET isdone = 1
		WHERE [dbid] = @dbid
	END
END;

Select * from  #tblStatsSamp;