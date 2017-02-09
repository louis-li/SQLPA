DECLARE @dbid int, @dbname VARCHAR(1000), @ErrorMessage VARCHAR(MAX)
DECLARE @sqlcmd NVARCHAR(max)

CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)


IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblHypObj'))
DROP TABLE #tblHypObj;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblHypObj'))
CREATE TABLE #tblHypObj ([DBName] sysname, [Schema] VARCHAR(100), [Table] VARCHAR(255), [Object] VARCHAR(255), [Type] VARCHAR(10));

UPDATE #tmpdbs0
SET isdone = 0;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [state] <> 0 OR [dbid] = 2;

UPDATE #tmpdbs0
SET isdone = 1
WHERE [role] = 2 AND secondary_role_allow_connections = 0;

IF (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
BEGIN	
	WHILE (SELECT COUNT(id) FROM #tmpdbs0 WHERE isdone = 0) > 0
	BEGIN
		SELECT TOP 1 @dbname = [dbname], @dbid = [dbid] FROM #tmpdbs0 WHERE isdone = 0
		SET @sqlcmd = 'USE ' + QUOTENAME(@dbname) + ';
SELECT ''' + @dbname + ''' AS [DBName], QUOTENAME(t.name), QUOTENAME(o.[name]), i.name, ''INDEX'' FROM sys.indexes i 
INNER JOIN sys.objects o ON o.[object_id] = i.[object_id] 
INNER JOIN sys.tables AS mst ON mst.[object_id] = i.[object_id]
INNER JOIN sys.schemas AS t ON t.[schema_id] = mst.[schema_id]
WHERE i.is_hypothetical = 1
UNION ALL
SELECT ''' + @dbname + ''' AS [DBName], QUOTENAME(t.name), QUOTENAME(o.[name]), s.name, ''STATISTICS'' FROM sys.stats s 
INNER JOIN sys.objects o (NOLOCK) ON o.[object_id] = s.[object_id]
INNER JOIN sys.tables AS mst (NOLOCK) ON mst.[object_id] = s.[object_id]
INNER JOIN sys.schemas AS t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
WHERE (s.name LIKE ''hind_%'' OR s.name LIKE ''_dta_stat%'') AND auto_created = 0
AND s.name NOT IN (SELECT name FROM ' + QUOTENAME(@dbname) + '.sys.indexes)'

		BEGIN TRY
			INSERT INTO #tblHypObj
			EXECUTE sp_executesql @sqlcmd
		END TRY
		BEGIN CATCH
			SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
			SELECT @ErrorMessage = 'Hypothetical objects subsection - Error raised in TRY block in database ' + @dbname +'. ' + ERROR_MESSAGE()
			RAISERROR (@ErrorMessage, 16, 1);
		END CATCH
		
		UPDATE #tmpdbs0
		SET isdone = 1
		WHERE [dbid] = @dbid
	END
END;
	
Select * from #tblHypObj