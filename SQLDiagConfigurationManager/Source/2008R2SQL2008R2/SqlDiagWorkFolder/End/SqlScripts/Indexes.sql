DECLARE @dbid int, @dbname VARCHAR(max), @ErrorMessage VARCHAR(MAX)
DECLARE @sqlcmd NVARCHAR(max), @params NVARCHAR(max)


IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmpdbs0'))
DROP TABLE #tmpdbs0;

CREATE TABLE #tmpdbs0 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(max), [compatibility_level] int, is_read_only bit, [state] tinyint, is_distributor bit, [role] tinyint, [secondary_role_allow_connections] tinyint, is_database_joined bit, is_failover_ready bit, isdone bit);

INSERT INTO #tmpdbs0 ([dbid], [dbname], [compatibility_level], is_read_only, [state], is_distributor, [role], [secondary_role_allow_connections], [isdone])
SELECT database_id, name, [compatibility_level], is_read_only, [state], is_distributor, 1, 1, 0 FROM master.sys.databases (NOLOCK)


CREATE TABLE #tmpdbs1 (id int IDENTITY(1,1), [dbid] int, [dbname] VARCHAR(max), [role] tinyint, [secondary_role_allow_connections] tinyint, isdone bit)

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


UPDATE #tmpdbs1
SET isdone = 0

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblIxs1'))
DROP TABLE #tblIxs1;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblIxs1'))
CREATE TABLE #tblIxs1 ([databaseID] int, [DatabaseName] sysname, [objectID] int, [schemaName] VARCHAR(100), [objectName] VARCHAR(200), 
	[indexID] int, [indexName] VARCHAR(200), [indexType] tinyint, is_primary_key bit, [is_unique_constraint] bit, is_unique bit, is_disabled bit, fill_factor tinyint, is_padded bit, has_filter bit, filter_definition NVARCHAR(max),
	KeyCols VARCHAR(4000), KeyColsOrdered VARCHAR(4000), IncludedCols VARCHAR(4000) NULL, IncludedColsOrdered VARCHAR(4000) NULL, AllColsOrdered VARCHAR(4000) NULL, [KeyCols_data_length_bytes] int,Key_has_GUID bit,
	CONSTRAINT PK_Ixs PRIMARY KEY CLUSTERED(databaseID, [objectID], [indexID]));

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblCode'))
DROP TABLE #tblCode;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblCode'))
CREATE TABLE #tblCode ([DatabaseName] sysname, [schemaName] VARCHAR(100), [objectName] VARCHAR(200), [indexName] VARCHAR(200), type_desc NVARCHAR(60));

UPDATE #tmpdbs1
SET isdone = 0;

WHILE (SELECT COUNT(id) FROM #tmpdbs1 WHERE isdone = 0) > 0
BEGIN
	SELECT TOP 1 @dbname = [dbname], @dbid = [dbid] FROM #tmpdbs1 WHERE isdone = 0
	SET @sqlcmd = 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
USE ' + QUOTENAME(@dbname) + ';
With keys as (
SELECT  ac.name, ic.key_ordinal,i.object_id,i.index_id,is_included_column FROM sys.tables AS st
	INNER JOIN sys.indexes AS i ON st.[object_id] = i.[object_id]
	INNER JOIN sys.index_columns AS ic ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id] 
	INNER JOIN sys.all_columns AS ac ON st.[object_id] = ac.[object_id] AND ic.[column_id] = ac.[column_id]
),
ColType as (
SELECT sty.name, i.object_id, i.index_id, is_included_column, key_ordinal,sc.max_length FROM sys.indexes AS i
	INNER JOIN sys.tables AS t ON t.[object_id] = i.[object_id]
	INNER JOIN sys.schemas ss ON ss.[schema_id] = t.[schema_id]
	INNER JOIN sys.index_columns AS sic ON sic.object_id = i.object_id AND sic.index_id = i.index_id
	INNER JOIN sys.columns AS sc ON sc.object_id = t.object_id AND sc.column_id = sic.column_id
	INNER JOIN sys.types AS sty ON sc.user_type_id = sty.user_type_id
)
SELECT ' + CONVERT(VARCHAR(8), @dbid) + ' AS Database_ID, ''' + @dbname + ''' AS Database_Name
,mst.[object_id] AS objectID, t.name AS schemaName, mst.[name] AS objectName, mi.index_id AS indexID
,mi.[name] AS Index_Name, mi.[type] AS [indexType], mi.is_primary_key, mi.[is_unique_constraint], mi.is_unique, mi.is_disabled
,mi.fill_factor, mi.is_padded, mi.has_filter, mi.filter_definition
,SUBSTRING((Select '','' + name from keys where mi.object_id = keys.object_id and mi.index_id = keys.index_id and keys.is_included_column = 0 Order BY key_ordinal FOR XML PATH('''')), 2, 8000) AS KeyCols
,SUBSTRING((Select '','' + name from keys where mi.object_id = keys.object_id and mi.index_id = keys.index_id and keys.is_included_column = 0 ORDER BY keys.name FOR XML PATH('''')), 2, 8000) AS KeyColsOrdered
,SUBSTRING((Select '','' + name from keys where mi.object_id = keys.object_id and mi.index_id = keys.index_id and keys.is_included_column = 1 ORDER BY key_ordinal FOR XML PATH('''')), 2, 8000) AS IncludedCols
,SUBSTRING((Select '','' + name from keys where mi.object_id = keys.object_id and mi.index_id = keys.index_id and keys.is_included_column = 1	ORDER BY name FOR XML PATH('''')), 2, 8000) AS IncludedColsOrdered
,SUBSTRING((Select '','' + name from keys where mi.object_id = keys.object_id and mi.index_id = keys.index_id ORDER BY name FOR XML PATH('''')), 2, 8000) AS AllColsOrdered
,(SELECT SUM(CASE c.name WHEN ''nvarchar'' THEN c.max_length/2 ELSE c.max_length END) From ColType c
	WHERE mi.[object_id] = c.[object_id] AND mi.index_id = c.index_id AND c.key_ordinal > 0) AS [KeyCols_data_length_bytes]
,(Select Count(name) from ColType c
	WHERE mi.[object_id] = c.[object_id] AND mi.index_id = c.index_id AND c.is_included_column = 0 AND c.name = ''uniqueidentifier'') AS [Key_has_GUID]
FROM sys.indexes AS mi
INNER JOIN sys.tables AS mst ON mst.[object_id] = mi.[object_id]
INNER JOIN sys.schemas AS t ON t.[schema_id] = mst.[schema_id]
WHERE mi.type IN (1,2,5,6) AND mst.is_ms_shipped = 0
ORDER BY objectName
OPTION (MAXDOP 2);'

	BEGIN TRY
		INSERT INTO #tblIxs1
		EXECUTE sp_executesql @sqlcmd
	END TRY
	BEGIN CATCH
		--SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
		--SELECT @ErrorMessage = 'Duplicate or Redundant indexes subsection - Error raised in TRY block in database ' + @dbname +'. ' + ERROR_MESSAGE()
		Print @sqlcmd
		--RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
	
	UPDATE #tmpdbs1
	SET isdone = 1
	WHERE [dbid] = @dbid;
END


Select * from #tblIxs1