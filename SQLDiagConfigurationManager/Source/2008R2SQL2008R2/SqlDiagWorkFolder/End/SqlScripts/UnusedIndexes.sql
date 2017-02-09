
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


UPDATE #tmpdbs1
SET isdone = 0


IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblIxs2'))
DROP TABLE #tblIxs2;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblIxs2'))
CREATE TABLE #tblIxs2 ([databaseID] int, [DatabaseName] sysname, [objectID] int, [schemaName] VARCHAR(100), [objectName] VARCHAR(200), 
	[indexID] int, [indexName] VARCHAR(200), [Hits] bigint NULL, [Reads_Ratio] DECIMAL(5,2), [Writes_Ratio] DECIMAL(5,2),
	user_updates bigint, last_user_seek DATETIME NULL, last_user_scan DATETIME NULL, last_user_lookup DATETIME NULL, 
	last_user_update DATETIME NULL, is_unique bit, [type] tinyint, is_primary_key bit, is_unique_constraint bit, is_disabled bit,
	CONSTRAINT PK_Ixs2 PRIMARY KEY CLUSTERED(databaseID, [objectID], [indexID]))

UPDATE #tmpdbs1
SET isdone = 0;

WHILE (SELECT COUNT(id) FROM #tmpdbs1 WHERE isdone = 0) > 0
BEGIN
	SELECT TOP 1 @dbname = [dbname], @dbid = [dbid] FROM #tmpdbs1 WHERE isdone = 0
	SET @sqlcmd = 'USE ' + QUOTENAME(@dbname) + ';
SELECT ' + CONVERT(VARCHAR(8), @dbid) + ' AS Database_ID, ''' + @dbname + ''' AS Database_Name,
	mst.[object_id] AS objectID, t.name AS schemaName, mst.[name] AS objectName, si.index_id AS indexID, si.[name] AS Index_Name,
	(s.user_seeks + s.user_scans + s.user_lookups) AS [Hits],
	RTRIM(CONVERT(NVARCHAR(10),CAST(CASE WHEN (s.user_seeks + s.user_scans + s.user_lookups) = 0 THEN 0 ELSE CONVERT(REAL, (s.user_seeks + s.user_scans + s.user_lookups)) * 100 /
		CASE (s.user_seeks + s.user_scans + s.user_lookups + s.user_updates) WHEN 0 THEN 1 ELSE CONVERT(REAL, (s.user_seeks + s.user_scans + s.user_lookups + s.user_updates)) END END AS DECIMAL(18,2)))) AS [Reads_Ratio],
	RTRIM(CONVERT(NVARCHAR(10),CAST(CASE WHEN s.user_updates = 0 THEN 0 ELSE CONVERT(REAL, s.user_updates) * 100 /
		CASE (s.user_seeks + s.user_scans + s.user_lookups + s.user_updates) WHEN 0 THEN 1 ELSE CONVERT(REAL, (s.user_seeks + s.user_scans + s.user_lookups + s.user_updates)) END END AS DECIMAL(18,2)))) AS [Writes_Ratio],
	s.user_updates,
	MAX(s.last_user_seek) AS last_user_seek,
	MAX(s.last_user_scan) AS last_user_scan,
	MAX(s.last_user_lookup) AS last_user_lookup,
	MAX(s.last_user_update) AS last_user_update,
	si.is_unique, si.[type], si.is_primary_key, si.is_unique_constraint, si.is_disabled	
FROM sys.indexes AS si (NOLOCK)
INNER JOIN sys.objects AS o (NOLOCK) ON si.[object_id] = o.[object_id]
INNER JOIN sys.tables AS mst (NOLOCK) ON mst.[object_id] = si.[object_id]
INNER JOIN sys.schemas AS t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
INNER JOIN sys.dm_db_index_usage_stats AS s (NOLOCK) ON s.database_id = ' + CONVERT(VARCHAR(8), @dbid) + ' 
	AND s.object_id = si.object_id AND s.index_id = si.index_id
WHERE mst.is_ms_shipped = 0
	--AND OBJECTPROPERTY(o.object_id,''IsUserTable'') = 1 -- sys.tables only returns type U
	AND si.type IN (2,6) 			-- non-clustered and non-clustered columnstore indexes only
	AND si.is_primary_key = 0 		-- no primary keys
	AND si.is_unique_constraint = 0	-- no unique constraints
	--AND si.is_unique = 0 			-- no alternate keys
GROUP BY mst.[object_id], t.[name], mst.[name], si.index_id, si.[name], s.user_seeks, s.user_scans, s.user_lookups, s.user_updates, si.is_unique,
	si.[type], si.is_primary_key, si.is_unique_constraint, si.is_disabled
ORDER BY objectName	
OPTION (MAXDOP 2);'
	BEGIN TRY
		INSERT INTO #tblIxs2
		EXECUTE sp_executesql @sqlcmd
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
		SELECT @ErrorMessage = 'Unused and rarely used indexes subsection - Error raised in TRY block 1 in database ' + @dbname +'. ' + ERROR_MESSAGE()
		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
		
	UPDATE #tmpdbs1
	SET isdone = 1
	WHERE [dbid] = @dbid
END

UPDATE #tmpdbs1
SET isdone = 0;

WHILE (SELECT COUNT(id) FROM #tmpdbs1 WHERE isdone = 0) > 0
BEGIN
	SELECT TOP 1 @dbname = [dbname], @dbid = [dbid] FROM #tmpdbs1 WHERE isdone = 0
	SET @sqlcmd = 'USE ' + QUOTENAME(@dbname) + ';
SELECT ' + CONVERT(VARCHAR(8), @dbid) + ' AS Database_ID, ''' + @dbname + ''' AS Database_Name, 
	si.[object_id] AS objectID, t.name AS schemaName, OBJECT_NAME(si.[object_id], ' + CONVERT(VARCHAR(8), @dbid) + ') AS objectName, si.index_id AS indexID, 
	si.[name] AS Index_Name, 0, 0, 0, 0, NULL, NULL, NULL, NULL,
	si.is_unique, si.[type], si.is_primary_key, si.is_unique_constraint, si.is_disabled
FROM sys.indexes AS si (NOLOCK)
INNER JOIN sys.objects AS so (NOLOCK) ON si.object_id = so.object_id 
INNER JOIN sys.tables AS mst (NOLOCK) ON mst.[object_id] = si.[object_id]
INNER JOIN sys.schemas AS t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
WHERE OBJECTPROPERTY(so.object_id,''IsUserTable'') = 1
	AND mst.is_ms_shipped = 0
	AND si.index_id NOT IN (SELECT s.index_id
		FROM sys.dm_db_index_usage_stats s
		WHERE s.object_id = si.object_id 
			AND si.index_id = s.index_id 
			AND database_id = ' + CONVERT(VARCHAR(8), @dbid) + ')
	AND si.name IS NOT NULL
	AND si.type IN (2,6) 			-- non-clustered and non-clustered columnstore indexes only
	AND si.is_primary_key = 0 		-- no primary keys
	AND si.is_unique_constraint = 0	-- no unique constraints
	--AND si.is_unique = 0 			-- no alternate keys
'

	BEGIN TRY
		INSERT INTO #tblIxs2
		EXECUTE sp_executesql @sqlcmd
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
		SELECT @ErrorMessage = 'Unused and rarely used indexes subsection - Error raised in TRY block 2 in database ' + @dbname +'. ' + ERROR_MESSAGE()
		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH

	UPDATE #tmpdbs1
	SET isdone = 1
	WHERE [dbid] = @dbid
END;

Select * from #tblIxs2