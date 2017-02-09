
DECLARE @dbid int, @dbname VARCHAR(1000), @sqlcmd NVARCHAR(max), @ErrorMessage NVARCHAR(MAX)

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmpdbs0'))
DROP TABLE #tmpdbs0;
CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)

CREATE TABLE #tmpdbs1 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(1000), [role] tinyint, [secondary_role_allow_connections] tinyint, isdone bit)

-- Ignore MS shipped databases and databases belonging to non-readable AG secondary replicas
INSERT INTO #tmpdbs1 ([dbid], [dbname], [role], [secondary_role_allow_connections], [isdone])
SELECT [dbid], [dbname], [role], [secondary_role_allow_connections], 0 
FROM #tmpdbs0 (NOLOCK) 
WHERE is_read_only = 0 AND [state] = 0 AND [dbid] > 4 AND is_distributor = 0
	AND [role] <> 2 AND (secondary_role_allow_connections <> 0 OR secondary_role_allow_connections IS NULL)
	AND lower([dbname]) NOT IN ('virtualmanagerdb', --Virtual Machine Manager
		'scspfdb', --Service Provider Foundation
		'semanticsdb', --Semantic Search
		'servicemanager','service manager','dwstagingandconfig','dwrepository','dwdatamart','dwasdatabase','omdwdatamart','cmdwdatamart', --SCSM
		'ssodb','bamanalysis','bamarchive','bamalertsapplication','bamalertsnsmain','bamprimaryimport','bamstarschema','biztalkmgmtdb','biztalkmsgboxdb','biztalkdtadb','biztalkruleenginedb','bamprimaryimport','biztalkedidb','biztalkhwsdb','tpm','biztalkanalysisdb','bamprimaryimportsuccessfully', --BizTalk
		'aspstate','aspnet', --ASP.NET
		'mscrm_config', --Dynamics CRM
		'cpsdyn','lcslog','lcscdr','lis','lyss','mgc','qoemetrics','rgsconfig','rgsdyn','rtc','rtcab','rtcab1','rtcdyn','rtcshared','rtcxds','xds', --Lync
		'activitylog','branchdb','clienttracelog','eventlog','listingssettings','servicegroupdb','tservercontroller','vodbackend', --MediaRoom
		'operationsmanager','operationsmanagerdw','operationsmanagerac', --SCOM
		'orchestrator', --Orchestrator
		'sso','wss_search','wss_search_config','sharedservices_db','sharedservices_search_db','wss_content','profiledb', 'social db','sync db',	--Sharepoint
		'susdb', --WSUS
		'projectserver_archive','projectserver_draft','projectserver_published','projectserver_reporting', --Project Server
		'reportserver','reportservertempdb','rsdb','rstempdb', --SSRS
		'fastsearchadmindatabase', --Fast Search
		'ppsmonitoring','ppsplanningservice','ppsplanningsystem', --PerformancePoint Services
		'dynamics', --Dynamics GP
		'microsoftdynamicsax','microsoftdynamicsaxbaseline', --Dynamics AX
		'fimservice','fimsynchronizationservice', --Forefront Identity Manager
		'sbgatewaydatabase','sbmanagementdb', --Service Bus
		'wfinstancemanagementdb','wfmanagementdb','wfresourcemanagementdb' --Workflow Manager
	)
	AND [dbname] NOT LIKE 'repANDtingservice[_]%' --SSRS
	AND [dbname] NOT LIKE 'tfs[_]%' --TFS
	AND [dbname] NOT LIKE 'defaultpowerpivotserviceapplicationdb%' --PowerPivot
	AND [dbname] NOT LIKE 'perfANDmancepoint service[_]%' --PerfANDmancePoint Services
	AND [dbname] NOT LIKE '%database nav%' --Dynamics NAV
	AND [dbname] NOT LIKE '%[_]mscrm' --Dynamics CRM
	AND [dbname] NOT LIKE 'dpmdb[_]%' --DPM
	AND [dbname] NOT LIKE 'sbmessagecontainer%' --Service Bus
	AND [dbname] NOT LIKE 'sma%' --SCSMA
	AND [dbname] NOT LIKE 'releasemanagement%' --TFS Release Management
	AND [dbname] NOT LIKE 'projectwebapp%' --Project Server
	AND [dbname] NOT LIKE 'sms[_]%' AND [dbname] NOT LIKE 'cm[_]%' --SCCM
	AND [dbname] NOT LIKE 'fepdw%' AND [dbname] NOT LIKE 'FEPDB[_]%' --Forefront Endpoint Protection
	--Sharepoint
	AND [dbname] NOT LIKE 'sharepoint[_]admincontent%' AND [dbname] NOT LIKE 'sharepoint[_]config%' AND [dbname] NOT LIKE 'wss[_]content%' AND [dbname] NOT LIKE 'wss[_]search%'
	AND [dbname] NOT LIKE 'sharedservices[_]db%' AND [dbname] NOT LIKE 'sharedservices[_]search[_]db%' AND [dbname] NOT LIKE 'sharedservices[_][_]db%' AND [dbname] NOT LIKE 'sharedservices[_][_]search[_]db%'
	AND [dbname] NOT LIKE 'sharedservicescontent%' AND [dbname] NOT LIKE 'application[_]registry[_]service[_]db%' AND [dbname] NOT LIKE 'search[_]service[_]application[_]propertystANDedb[_]%'
	AND [dbname] NOT LIKE 'subscriptionsettings[_]%' AND [dbname] NOT LIKE 'webanalyticsserviceapplication[_]stagingdb[_]%' AND [dbname] NOT LIKE 'webanalyticsserviceapplication[_]repANDtingdb[_]%'
	AND [dbname] NOT LIKE 'bdc[_]service[_]db[_]%' AND [dbname] NOT LIKE 'managed metadata service[_]%' AND [dbname] NOT LIKE 'perfANDmancepoint service application[_]%' 
	AND [dbname] NOT LIKE 'search[_]service[_]application[_]crawlstANDedb[_]%' AND [dbname] NOT LIKE 'search[_]service[_]application[_]db[_]%' AND [dbname] NOT LIKE 'secure[_]stANDe[_]service[_]db[_]%' AND [dbname] NOT LIKE 'stateservice%' 
	AND [dbname] NOT LIKE 'user profile service application[_]profiledb[_]%' AND [dbname] NOT LIKE 'user profile service application[_]syncdb[_]%' AND [dbname] NOT LIKE 'user profile service application[_]socialdb[_]%' 
	AND [dbname] NOT LIKE 'wANDdautomationservices[_]%' AND [dbname] NOT LIKE 'wss[_]logging%' AND [dbname] NOT LIKE 'wss[_]usageapplication%' AND [dbname] NOT LIKE 'appmng[_]service[_]db%' 
	AND [dbname] NOT LIKE 'search[_]service[_]application[_]analyticsrepANDtingstANDedb[_]%' AND [dbname] NOT LIKE 'search[_]service[_]application[_]linksstANDedb[_]%' AND [dbname] NOT LIKE 'sharepoint[_]logging[_]%' 
	AND [dbname] NOT LIKE 'settingsservicedb%' AND [dbname] NOT LIKE 'sharepoint[_]logging[_]%' AND [dbname] NOT LIKE 'translationservice[_]%' AND [dbname] NOT LIKE 'sharepoint translation services[_]%' AND [dbname] NOT LIKE 'sessionstateservice%' 



IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblFK'))
DROP TABLE #tblFK;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblFK'))
CREATE TABLE #tblFK ([databaseID] int, [DatabaseName] sysname, [constraint_name] VARCHAR(200), [parent_schema_name] VARCHAR(100), 
[parent_table_name] VARCHAR(200), parent_columns VARCHAR(4000), [referenced_schema] VARCHAR(100), [referenced_table_name] VARCHAR(200), referenced_columns VARCHAR(4000),
CONSTRAINT PK_FK PRIMARY KEY CLUSTERED(databaseID, [constraint_name]))
	
UPDATE #tmpdbs1
SET isdone = 0

WHILE (SELECT COUNT(id) FROM #tmpdbs1 WHERE isdone = 0) > 0
BEGIN
	SELECT TOP 1 @dbname = [dbname], @dbid = [dbid] FROM #tmpdbs1 WHERE isdone = 0
SET @sqlcmd = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
USE ' + QUOTENAME(@dbname) + '
;WITH cteFK AS (
SELECT t.name AS [parent_schema_name],
OBJECT_NAME(FKC.parent_object_id) [parent_table_name],
OBJECT_NAME(constraint_object_id) AS [constraint_name],
t2.name AS [referenced_schema],
OBJECT_NAME(referenced_object_id) AS [referenced_table_name],
SUBSTRING((SELECT '','' + RTRIM(COL_NAME(k.parent_object_id,parent_column_id)) AS [data()]
	FROM sys.foreign_key_columns k (NOLOCK)
	INNER JOIN sys.foreign_keys (NOLOCK) ON k.constraint_object_id = [object_id]
		AND k.constraint_object_id = FKC.constraint_object_id
	ORDER BY constraint_column_id
	FOR XML PATH('''')), 2, 8000) AS [parent_columns],
SUBSTRING((SELECT '','' + RTRIM(COL_NAME(k.referenced_object_id,referenced_column_id)) AS [data()]
	FROM sys.foreign_key_columns k (NOLOCK)
	INNER JOIN sys.foreign_keys (NOLOCK) ON k.constraint_object_id = [object_id]
		AND k.constraint_object_id = FKC.constraint_object_id
	ORDER BY constraint_column_id
	FOR XML PATH('''')), 2, 8000) AS [referenced_columns]
FROM sys.foreign_key_columns FKC (NOLOCK)
INNER JOIN sys.objects o (NOLOCK) ON FKC.parent_object_id = o.[object_id]
INNER JOIN sys.tables mst (NOLOCK) ON mst.[object_id] = o.[object_id]
INNER JOIN sys.schemas t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
INNER JOIN sys.objects so (NOLOCK) ON FKC.referenced_object_id = so.[object_id]
INNER JOIN sys.tables AS mst2 (NOLOCK) ON mst2.[object_id] = so.[object_id]
INNER JOIN sys.schemas AS t2 (NOLOCK) ON t2.[schema_id] = mst2.[schema_id]
WHERE o.type = ''U'' AND so.type = ''U''
GROUP BY o.[schema_id],so.[schema_id],FKC.parent_object_id,constraint_object_id,referenced_object_id,t.name,t2.name
),
cteIndexCols AS (
SELECT t.name AS schemaName,
OBJECT_NAME(mst.[object_id]) AS objectName,
SUBSTRING(( SELECT '','' + RTRIM(ac.name) FROM sys.tables AS st
INNER JOIN sys.indexes AS mi ON st.[object_id] = mi.[object_id]
INNER JOIN sys.index_columns AS ic ON mi.[object_id] = ic.[object_id] AND mi.[index_id] = ic.[index_id] 
INNER JOIN sys.all_columns AS ac ON st.[object_id] = ac.[object_id] AND ic.[column_id] = ac.[column_id]
WHERE i.[object_id] = mi.[object_id] AND i.index_id = mi.index_id AND ic.is_included_column = 0
ORDER BY ac.column_id
FOR XML PATH('''')), 2, 8000) AS KeyCols
FROM sys.indexes AS i
INNER JOIN sys.tables AS mst ON mst.[object_id] = i.[object_id]
INNER JOIN sys.schemas AS t ON t.[schema_id] = mst.[schema_id]
WHERE i.[type] IN (1,2,5,6) AND i.is_unique_constraint = 0
AND mst.is_ms_shipped = 0
)
SELECT ' + CONVERT(VARCHAR(8), @dbid) + ' AS Database_ID, ''' + @dbname + ''' AS Database_Name, fk.constraint_name AS constraintName,
fk.parent_schema_name AS schemaName, fk.parent_table_name AS tableName,
REPLACE(fk.parent_columns,'' ,'','','') AS parentColumns, fk.referenced_schema AS referencedSchemaName,
fk.referenced_table_name AS referencedTableName, REPLACE(fk.referenced_columns,'' ,'','','') AS referencedColumns
FROM cteFK fk
WHERE NOT EXISTS (SELECT 1 FROM cteIndexCols ict 
				WHERE fk.parent_schema_name = ict.schemaName
					AND fk.parent_table_name = ict.objectName 
					AND REPLACE(fk.parent_columns,'' ,'','','') = ict.KeyCols);'
	BEGIN TRY
		INSERT INTO #tblFK
		EXECUTE sp_executesql @sqlcmd
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
		SELECT @ErrorMessage = 'Foreign Keys with no Index subsection - Error raised in TRY block in database ' + @dbname +'. ' + ERROR_MESSAGE()
		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH

	UPDATE #tmpdbs1
	SET isdone = 1
	WHERE [dbid] = @dbid
END;
	
Select * from #tblFK