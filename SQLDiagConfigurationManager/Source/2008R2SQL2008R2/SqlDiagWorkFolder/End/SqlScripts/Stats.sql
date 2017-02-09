CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)

DECLARE @dbid int, @dbname VARCHAR(1000), @ErrorMessage VARCHAR(MAX)
DECLARE @sqlcmd NVARCHAR(max), @params NVARCHAR(500)
DECLARE @sqlmajorver int,@sqlminorver int, @sqlbuild int

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);
SELECT @sqlminorver = CONVERT(int, (@@microsoftversion / 0x10000) & 0xff);
SELECT @sqlbuild = CONVERT(int, @@microsoftversion & 0xffff);

UPDATE #tmpdbs0
SET isdone = 0;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [state] <> 0 OR [dbid] < 5;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [role] = 2 AND secondary_role_allow_connections = 0;

DECLARE @dbcmptlevel int

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblStatsUpd'))
DROP TABLE #tblStatsUpd;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblStatsUpd'))
CREATE TABLE #tblStatsUpd ([DatabaseName] sysname, [databaseID] int, objectID int, schemaName VARCHAR(100), [tableName] VARCHAR(250), last_updated DATETIME, [rows] bigint, modification_counter bigint, [stats_id] int, [stat_name] VARCHAR(255), auto_created bit, user_created bit, has_filter bit NULL, filter_definition NVARCHAR(MAX) NULL, unfiltered_rows bigint, steps int)

IF (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
BEGIN	
	WHILE (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
	BEGIN
		SELECT TOP 1 @dbname = [dbname], @dbid = [dbid], @dbcmptlevel = [compatibility_level] FROM #tmpdbs0 WHERE isdone = 0
		IF ((@sqlmajorver = 10 AND @sqlminorver = 50 AND @sqlbuild >= 4000) OR (@sqlmajorver = 11 AND @sqlbuild >= 3000) OR @sqlmajorver > 11) AND @dbcmptlevel > 80
		BEGIN
			SET @sqlcmd = 'USE ' + QUOTENAME(@dbname) + ';
SELECT DISTINCT ''' + @dbname + ''' AS [DatabaseName], ''' + CONVERT(VARCHAR(12),@dbid) + ''' AS [databaseID], mst.[object_id] AS objectID, t.name AS schemaName, OBJECT_NAME(mst.[object_id]) AS tableName, 
	sp.last_updated, sp.[rows], sp.modification_counter, ss.[stats_id], ss.name AS [stat_name], ss.auto_created, ss.user_created, ss.has_filter, ss.filter_definition, sp.unfiltered_rows, sp.steps
FROM sys.objects AS o
	INNER JOIN sys.tables AS mst ON mst.[object_id] = o.[object_id]
	INNER JOIN sys.schemas AS t ON t.[schema_id] = mst.[schema_id]
	INNER JOIN sys.stats AS ss ON ss.[object_id] = mst.[object_id]
	CROSS APPLY sys.dm_db_stats_properties(ss.[object_id], ss.[stats_id]) AS sp
WHERE sp.[rows] > 0
	AND	((sp.[rows] <= 500 AND sp.modification_counter >= 500)
		OR (sp.[rows] > 500 AND sp.modification_counter >= (500 + sp.[rows] * 0.20)))'
		END
		ELSE
		BEGIN
			SET @sqlcmd = 'USE ' + QUOTENAME(@dbname) + ';
SELECT DISTINCT ''' + @dbname + ''' AS [DatabaseName], ''' + CONVERT(VARCHAR(12),@dbid) + ''' AS [databaseID], mst.[object_id] AS objectID, t.name AS schemaName, OBJECT_NAME(mst.[object_id]) AS tableName, 
	STATS_DATE(mst.[object_id], ss.stats_id) AS last_updated, SUM(p.[rows]) AS [rows], si.rowmodctr AS modification_counter, ss.stats_id, ss.name AS [stat_name], ss.auto_created, ss.user_created, NULL, NULL, NULL, NULL
FROM sys.sysindexes AS si
	INNER JOIN sys.objects AS o ON si.id = o.[object_id]
	INNER JOIN sys.tables AS mst ON mst.[object_id] = o.[object_id]
	INNER JOIN sys.schemas AS t ON t.[schema_id] = mst.[schema_id]
	INNER JOIN sys.stats AS ss ON ss.[object_id] = o.[object_id]
	INNER JOIN sys.partitions AS p ON p.[object_id] = ss.[object_id]
	LEFT JOIN sys.indexes i ON si.id = i.[object_id] AND si.indid = i.index_id
WHERE o.type <> ''S'' AND i.name IS NOT NULL
GROUP BY mst.[object_id], t.name, rowmodctr, ss.stats_id, ss.name, ss.auto_created, ss.user_created
HAVING SUM(p.[rows]) > 0
	AND	((SUM(p.[rows]) <= 500 AND rowmodctr >= 500)
		OR (SUM(p.[rows]) > 500 AND rowmodctr >= (500 + SUM(p.[rows]) * 0.20)))'
		END

		BEGIN TRY
			INSERT INTO #tblStatsUpd
			EXECUTE sp_executesql @sqlcmd
		END TRY
		BEGIN CATCH
			SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
			SELECT @ErrorMessage = 'Statistics update subsection - Error raised in TRY block in database ' + @dbname +'. ' + ERROR_MESSAGE()
			RAISERROR (@ErrorMessage, 16, 1);
		END CATCH
		
		UPDATE #tmpdbs0
		SET isdone = 1
		WHERE [dbid] = @dbid
	END
END;

Select * from  #tblStatsUpd