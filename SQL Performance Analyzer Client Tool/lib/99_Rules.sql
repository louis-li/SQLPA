
--Create Analysis Rules
If (NOT EXISTS (Select * from sys.schemas Where name = 'Analysis'))
Begin
	Exec sp_executesql N'Create Schema Analysis'
End
Go

IF (EXISTS (Select * from sys.tables Where name = 'Evaluation' and schema_id=Schema_id('Analysis')))
Begin
	Drop Table Analysis.Evaluation
End
Create Table Analysis.Evaluation(
	Id int primary key,
	[CurrentValue] varchar(128),
	[Threshold] varchar(128),
	[Result] varchar(10),
	[Description] varchar(2000)
)
GO

IF (EXISTS (Select * from sys.tables Where name = 'Rules' and schema_id=Schema_id('Analysis')))
Begin
	Drop Table Analysis.Rules
End
Create Table Analysis.Rules (
	Id int identity primary key, 
	[Description] varchar(2000),
	[CurrentValue] varchar(max),
	[Operator] varchar(20),
	[Threshold] varchar(max),
	[Enabled] bit Default 0
)
Go

Insert Into Analysis.Rules ([Description],[CurrentValue],[Operator],[Threshold])
Values
--MAXDOP
('MAXDOP value needs to be less or equal to the number of CPUs per NUMA node','(Select RunValue from dbo.SystemConfiguration Where Number = 1539)','<=','(Select top 1 Count(*) from dbo.CPUS	Group by NumaNodeID	order by Count(*) Desc)')
,('MAXDOP value should be greater than 0','(Select RunValue from dbo.SystemConfiguration 	Where Number = 1539)','>','0')
--Server Memory settings
,('MAX Server Memory needs to be using non-default value','dbo.ufnSysCfgInt(''max server memory (MB)'')','<','2147483647')
,('Min Server Memory needs to be using non-default value','dbo.ufnSysCfgInt(''min server memory (MB)'')','>','16')
,('MAX Server Memory should be greater than Min server memeory','dbo.ufnSysCfgInt(''max server memory (MB)'')','>','dbo.ufnSysCfgInt(''min server memory (MB)'')')
,('Available Memory should be greater than  5%','100*dbo.ufnAvailablePhysicalMemInMb()/dbo.ufnTotalPhysicalMemInMb()','>=','5')
,('Available Memory should be greater than high memory threshold','dbo.ufnAvailablePhysicalMemInMb()','>','192')
,('MAX Server Memory + Thread Stack memory < System physical memory - 2GB','dbo.ufnSysCfgInt(''min server memory (MB)'') + dbo.ufnThreadStackMem()','<','dbo.ufnTotalPhysicalMemInMb() -2048')
--Optimize for Ad Hoc Queries
,('Optimized for Ad Hoc Workloads should be enabled','dbo.ufnSysCfgInt(''optimize for ad hoc workloads'')','=','1')
--Other system configuration setting
,('Allow update is not supported','dbo.ufnSysCfgInt(''allow updates'')','=','0')
,('AdHoc Distributed Queries should be disabled','dbo.ufnSysCfgInt(''Ad Hoc Distributed Queries'')','=','0')
,('AWE setting deprecated','ISNULL(dbo.ufnSysCfgInt(''awe enabled''),0)','=','0')
,('Affinity Mask & Affinity IO Mask should not be overlapping','dbo.ufnSysCfgAffinMaskAndAffinIoMask()','=','''OK''')
,('Backup Compression should be enabled','dbo.ufnSysCfgInt(''backup compression default'')','=','1')
,('Blocked Process Threshold should be greater than 5 seconds','dbo.ufnSysCfgBlockedProcessThreshold()','=','''OK''')
,('Cross DB ownership chaining','dbo.ufnSysCfgInt(''cross db ownership chaining'')','=','0')
,('Default trace','dbo.ufnSysCfgInt(''default trace enabled'')','=','1')
,('Index create memory (KB) should be less than min query memory','dbo.ufnSysCfgIndexCreateMem()','=','''OK''')
,('Lightweight pooling is not enabled (experiental)','dbo.ufnSysCfgInt(''lightweight pooling'')','=','1') --Bob Dorr mentioned lightweight pooling should be turned on
,('Locks configuration is not default value','dbo.ufnSysCfgInt(''locks'')','=','0')
,('Max worker thread is less than 2048','dbo.ufnSysCfgInt(''max worker threads'')','<','2048')
,('Min memory per query(KB) is not default value','dbo.ufnSysCfgInt(''min memory per query (KB)'')','=','1024')
,('Network packet size (B) has been changed from default value','dbo.ufnSysCfgInt(''network packet size (B)'')','=','4096')
,('Ole automation procedures is not using default value','dbo.ufnSysCfgInt(''Ole Automation Procedures'')','=','0')
,('Priority Boost is not using default value','dbo.ufnSysCfgInt(''priority boost'')','=','0')
,('Query wait (s) has been changed fro default value','dbo.ufnSysCfgInt(''query wait (s)'')','=','-1')
,('Recovery Interval (min) has been changed fro default value','dbo.ufnSysCfgInt(''recovery interval (min)'')','=','0')
,('Fill factor (%)  has been changed fro default value','dbo.ufnSysCfgInt(''fill factor (%)'')','=','0')
,('remote admin connect enabled in cluster, disabled in standalone','dbo.ufnSysCfgRAC()','<>','''Should enable''')
,('Remote query timeout  has been changed fro default value','dbo.ufnSysCfgInt(''remote query timeout (s)'')','=','600')
,('Startup Stored Procedures  has been changed fro default value','dbo.ufnSysCfgInt(''scan for startup procs'')','=','0')
,('xp_cmdshell should be disabled','dbo.ufnSysCfgInt(''xp_cmdshell'')','=','0')
--Lock Page In Memory
,('Lock Page In Memory is not granted to service account','(Select Column1 from dbo.LPIM)','=','1')
--Instance File Initialization
,('Instance File Initialization is not granted to service account','(Select Deviation from dbo.IFI)','=','''[OK]''')
--PowerPlan
,('Power Plan is not high performance', '(Select [Plan] from dbo.PowerPlan Where [Current] = ''True'')','=','''High performance''')
--IO stall
,('IO stall - latency should be less than 20 ms','(Select Count(*) from dbo.iostall Where io_stall_ms > 20 or io_stall_read_ms > 20 or io_stall_write_ms > 20)','=','0')
,('IO pending requests found ','(Select count(*) from sys.objects where object_name(object_id) = ''IOPendingRequest'')','>','0')
--File Growth setting & file growth log
,('File Growth should not be percentage','(Select Count(*) from dbo.databaseFiles Where is_percent_growth = ''True'')','=','0')
,('File Growth should be less or equal than 1GB','(Select Count(*) from dbo.databaseFiles Where growth > 1048576)','=','0')
--Statistics settings
,('Auto create statistics should be enabled','(Select Count(*) from dbo.databases Where AutoCreateStatisticsEnabled = ''False'')','=','0')
,('Auto update statistics should be enabled','(Select Count(*) from dbo.databases Where AutoUpdateStatisticsEnabled = ''False'')','=','0')
,('When Auto update statistics async is enabled, autoupdatestat should also be enabled','(Select Count(*) from dbo.databases Where AutoUpdateStatisticsAsync = ''True'' AND AutoUpdateStatisticsEnabled=''False'')','=','0')
,('Statistics Sampling Rate too low','(Select Count(*) from dbo.statisticssamplerate)','>','0')
--Auto close, auto shrink
,('Auto Close should be disabled','(Select Count(*) from dbo.databases Where AutoClose <> ''False'')','=','0')
,('Auto Shrink should be disabled','(Select  Count(*) from dbo.databases Where AutoShrink <> ''False'')','=','0')
--Compability check
,('Compability Level should be same as instance version','dbo.ufnCompLevelCheck()','=','0')
--Parameterization forced
,('Parameterization should be default','(select Count(*) from dbo.databases Where IsParameterizationForced=''True'')','=','0')
--Indirect checkpoint
,('Indirect checkpoint should be OFF in OLTP systems. Check for high Background writer pages/sec counter','(select Count(*) from dbo.databases where TargetRecoveryTime>0)','=','0')
--Disk Alignment
,('Disk mis-alignment has been found','(Select Count(*) from dbo.DiskPartition Where Convert(bigint,StartingOffset) < 65536)','=','0')
--Disk Block Size
,('Disk block size is not initialized as 64K','(Select Count(*) from dbo.DiskBlockSize Where BlockSize <> 65536)','=','0')
--Disk Fragmentation
,('Disk Fragmentation found','(Select Count(*) from dbo.DiskFragmentation Where DefragRecommended = ''True'')','=','0')
--Tracr flags
,('TF845 is not needed for SQL2012+','dbo.ufnTF845()','IS','NULL')
,('TF834 (Large Page Support) is not discouraged when using Column Store Index','dbo.ufnTF834()','IS','NULL')
,('TF1211 disables lock escalation','dbo.ufnTFExists(1211)','IS','NULL')
,('TF1224 disables lock escalation','dbo.ufnTFExists(1224)','IS','NULL')
,('TF1229 disables lock partitioning','dbo.ufnTFExists(1229)','IS','NULL')
,('TF2335 should not be used with less than 100GB RAM','dbo.ufnTFExists(2335)','IS','NULL')
,('TF4135 should be used','dbo.ufnTF4135()','IS','NULL')
,('TF4136 disables parameter sniffing','dbo.ufnTFExists(4136)','IS','NULL')
,('TF4199 should be used instead of 4135','dbo.ufnTF4199()','IS','NULL')
,('TF8015 ignores NUMA detection','dbo.ufnTFExists(8015)','IS','NULL')
,('TF8048 Consider enabling TF8048 to change memory grants on NUMA from NODE based partitioning to CPU based partitioning. Look in dm_os_wait_stats and dm_os_spin_stats for wait types (CMEMTHREAD and SOS_SUSPEND_QUEUE).','dbo.ufnTF8048()','=','0')
,('Consider enabling TF2371','dbo.ufnTFExists(2371)','IS NOT','NULL')
,('Consider enabling TF4199','dbo.ufnTFExists(4199)','IS NOT','NULL')
--Traces
,('Default trace is running','(Select count(*) from dbo.traces Where id = 1 and status = 1)','=','1')
,('No other traces than default trace are running','(Select count(*) from dbo.traces Where status = 1)','=','1')
,('System Extended Event is running','dbo.ufnXeEvent(''system_health'')','=','1')
,('System HADR Extended Event is running','dbo.ufnXeEventHA()','=','''OK''')
,('No blocking Extended Event ','dbo.ufnBlockingXeEvent()','=','0')
,('sp_server_diagnostics session is running','dbo.ufnXeEvent(''sp_server_diagnostics session'')','=','1')
,('No user objects in master database','(select count(*) from dbo.UserObjectInMaster)','=','0')
,('User database should have same collation as instance','(select count(*) from dbo.databases where collation <> (Select collation from dbo.SqlServer))','=','0')
,('Sparse files should only belong to a Database Snapshot','(select count(*) from dbo.DatabaseFiles df inner join dbo.databases d on df.database_id = d.id where is_sparse = ''True'' and d.IsDatabaseSnapshot = ''False'')','=','0')
--VLF
,('# of VLFs should be less than 50','(select count(*) from dbo.vlfs where Actual_VLFs > 50)','=','0')
--Database files
,('User database data file and log file should be on different drives','(Select count(*) from dbo.ufnDataLogOnSameDriveList())','=','0')
,('Database file and backup folder should be on different drives','dbo.ufnDatabasefileBackupOnSameDrive()','=','0')
,('Database file and tempdb should be on different drives','dbo.ufnUserDbTempdbOnSameDrive()','=','0')
--number of logs files per database
,('Only 1 log file needed','(select count(*) as counts from dbo.DatabaseFiles where type_desc = ''LOG'' Group by database_id Having count(*) > 1)','IS','NULL')
--Tempdb
,('Tempdb should be on other drives than C','dbo.ufnTempdbNotOnCDrive()','=','0')
,('Number of Tempdb data files is less than or equal to number of cpus','(select count(*) from dbo.DatabaseFiles where database_id=2 and type = 0)','<','(select count(*) from dbo.cpus)')
,('Number of Tempdb data files is less than or equal to 12','(select count(*) from dbo.DatabaseFiles where database_id=2 and type = 0)','<','12')
,('Tempdb data file sizes should be same','(select count(distinct size) from dbo.DatabaseFiles where database_id =2 and type = 0)','=','1')
,('Tempdb initial size should match actual fize size or larger','(select count(*) from dbo.DatabaseFiles f inner join dbo.tempdbfilesize t on f.database_id = 2 and f.file_id = t.file_id and f.size < t.size)','=','0')
,('All tempdb files should have same size growth','(select count(distinct growth) from dbo.DatabaseFiles where database_id = 2 and type = 0)','=','1')
--Worker thread exhaustion
,('Check for Possible worker thread exhaustion, consider increase max worker thread if it happens','(select count(*)  from DmOsScheduler WHERE parent_node_id < 64 AND scheduler_id < 2 and work_queue_count > 0)', '=','0')
--Blocking
--,('Scaning for blocking','(Select count(*) from dbo.blocking)','=','0')
--Plan Cache 
,('Single used plan size should be less than multiple used plan size','(select cast(size_mb as int) from dbo.plancacheuse where type =''Single_Used_Plan'')','<','(select cast(size_mb as int) from dbo.plancacheuse where type = ''Multiple_Used_Plan'')')
--Query hint
,('Scan for query hints','(select count(*) from dbo.vwCachedplan where IsQueryhinted > 0 )','=','0')
,('Scan for User Defined Functions - using a scalar UDF that may inhibit parallelism','(select count(*) from dbo.vwCachedplan where UseUDF > 0 )','=','0')
,('Scan for Missing Indexes','(select count(*) from dbo.vwCachedplan where MissingIndexes > 0 )','=','0')
,('Scan for Implicit Conversion - queries performing implicit conversions where an Index Scan is present','(select count(*) from dbo.vwCachedplan where ImplicitConversion > 0 )','=','0')
,('Scan for cursor','(select count(*) from dbo.vwCachedplan where CursorPresent > 0 )','=','0')
,('Scan for No Join condition- queries is being executed without a JOIN predicate','(select count(*) from dbo.vwCachedplan where NoJoin > 0 )','=','0')
,('Scan for Column with no Stats','(select count(*) from dbo.vwCachedplan where ColumnsWithNoStatistics > 0 )','=','0')
,('Scan for Spill to Tempdb - HASH or SORT operation that have spilt to tempDB','(select count(*) from dbo.vwCachedplan where SpillToTempDb > 0 )','=','0')
,('Scan for Plan Affecting Convert - implicit conversions that can be affecting the choice of seek plans','(select count(*) from dbo.vwCachedplan where PlanAffectingConvert > 0 )','=','0')
,('Scan for Plan Affecting Convert - conversions that can be affecting cardinality estimates','(select count(*) from dbo.vwCachedplan where PlanAffectingConvertCE > 0 )','=','0')
,('Scan for Unmatched Index - queries issued an unmatched indexes warning, where an index could not be used due to parameterization','(select count(*) from dbo.vwCachedplan where UnmatchedIndex > 0 )','=','0')
,('Scan for queries using old cadinality estimator','(select count(*) from dbo.cachedplan where cast(query_plan as nvarchar(max)) like ''%CardinalityEstimationModelVersion="70"%'')','=','0')
--Hypothetical Objects
,('Scan for hypothetical objects','(select count(*) from sys.tables where name = ''HypotheticalObjects'' and type=''U'')','=','0')
--Fragmented Indexes
,('Fragmented index found ','(select count(*) from dbo.IndexFragmentation where cast(fragmentation as numeric )> 10.0 and page_count > 8)','=','0')
,('Duplicate indexes found','(select count(*) from dbo.vwDupIndex)','=','0')
--,('Redundent indexes','(select count(*) from dbo.vwRedundentIndexes)','=','0')
,('Non-default fill factor for indexes','(select count(*) from dbo.Indexes where fill_factor > 0 and fill_factor < 100)','=','0')
,('Disabled Index','(select count(*) from dbo.Indexes where is_disabled =''True'')','=','0')
,('Non-unique clustered index','(select count(*) from sys.indexes where index_id = 1 and is_unique = 0)','=','0')
--Error Log
,('A significant part of sql server process memory has been paged out','(select count(*) from dbo.ErrorLog where text like ''  A significant part of sql server process memory has been paged out.%'')','=','0')
,('SQL Server has encountered % longer than 15 seconds','(select count(*) from dbo.ErrorLog where text like ''  SQL Server has encountered % longer than 15 seconds %'')','=','0')
,('New queries assigned to process on Node % have not been picked up by a worker thread in the last 60 seconds','(select count(*) from dbo.ErrorLog where text like ''  New queries assigned to process on Node % have not been picked up by a worker thread in the last '')','=','0')
--Counters
,('Counter Alert: %Priviledged Time more than 20%','(select count(*) from dbo.ufnCounterCheck(''\Process(sqlservr)\% Privileged Time'',null) where Value > .2)','=','0')
,('Counter Alert: A ratio of more than 1 freespace scan for every 10 batch requests','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Access Methods\FreeSpace Scans/sec'',''\SQLServer:SQL Statistics\Batch Requests/sec'') where Value > .1)','=','0')
,('Counter Alert: A ratio of more than 1 page split for every 20 batch requests','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Access Methods\Page Splits/sec'',''\SQLServer:SQL Statistics\Batch Requests/sec'') where Value > .05)','=','0')
,('Counter Alert: A ratio of more than 1 workfile created for every 20 batch requests','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Access Methods\Workfiles Created/sec'',''\SQLServer:SQL Statistics\Batch Requests/sec'') where Value > .05)','=','0')
,('Counter Alert: Less than 97 percent buffer cache hit ratio','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Buffer cache hit ratio'',null) where Value <= 97)','=','0')
,('Counter Alert: Greater than 20 Lazy Writes per second','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Lazy writes/sec'',null) where Value > 20)','=','0')
,('Counter Alert: A ratio of more than 1 page lookup for every 100 batch requests','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Page lookups/sec'',''\SQLServer:SQL Statistics\Batch Requests/sec'') where Value > .01)','=','0')
,('Counter Alert: Greater than 90 page writes per second','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Page writes/sec'',null) where Value > 90)','=','0')
,('Counter Alert: Greater than 2 logouts per second - this may indicate that applications are not correctly using connection pooling','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:General Statistics\Logouts/sec'',null) where Value > 2)','=','0')
,('Counter Alert: Greater than 0 memory grants pending','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Memory Manager\Memory Grants Pending'',null) where Value > 0)','=','0')
,('Counter Alert: Greater than 1000 batch requests per second','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:SQL Statistics\Batch Requests/sec'',null) where Value > 1000)','=','0')
,('Counter Alert: A ratio of more than 1 SQL Compilation for every 10 Batch Requests per second','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:SQL Statistics\SQL Compilations/sec'',''\SQLServer:SQL Statistics\Batch Requests/sec'') where Value > 0.1)','=','0')
,('Counter Alert: A ratio of more than 1 SQL Re-Compilation for every 10 SQL Compilations','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:SQL Statistics\SQL Re-Compilations/sec'',''\SQLServer:SQL Statistics\SQL Compilations/sec'') where Value > .1)','=','0')
,('Counter Alert: A ratio of more than 500 lock requests for every batch request','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Locks(_Total)\Lock Requests/sec'',''\SQLServer:SQL Statistics\Batch Requests/sec'') where Value > 500)','=','0')
,('Counter Alert: Lock Waits Greater than 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Locks(*)\Lock Waits/sec'',null) where Value > 0)','=','0')
,('Counter Alert: Lock Timeout Greater than 1','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Locks(*)\Lock Timeouts/sec'',null) where Value > 1)','=','0')
,('Counter Alert: Total latch wait time is above 500 milliseconds per each second on average','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Latches\Total Latch Wait Time (ms)'',null) where Value > 500)','=','0')
,('Counter Alert: SQL Server is using more than 80% of AVG CPU usage','(select count(*) from dbo.ufnCounterCheck(''\Process(sqlservr)\% Processor Time'',null) where Value > 80)','=','0')
,('Counter Alert: Log Flush Wait Time - Near 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Databases(*)\Log Flush Wait Time'',null) where Value > 0)','=','0')
,('Counter Alert: Percent Log Used - Less than 80%','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Databases(*)\Percent Log Used'',null) where Value < 80)','=','0')
,('Counter Alert: Deprecated Usage - Near 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Deprecated Features(*)\Usage'',null) where Value > 0)','=','0')
,('Counter Alert: SQL Errors > 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:SQL Errors(*)\Errors/sec'',null) where Value > 0)','=','0')
,('Counter Alert: Foreign Pages is Greater Than 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Node(*)\Foreign pages'',null) where Value > 0)','=','0')
,('Counter Alert: Less than 70% (700 seconds by default) of the Page Life Expectancy Baseline (Buffer Node)','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Node(*)\Page life expectancy'',null) where Value < 700)','=','0')
,('Counter Alert: Less than 30% (300 seconds by default) of the Buffer Pool Extension Page Unreferenced Time Baseline','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager(*)\Extension page unreferenced time'',null) where Value < 300)','=','0')
,('Counter Alert: A ratio of more than 1 forwarded record for every 10 batch requests','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Access Methods\Forwarded Records/sec'',''\SQLServer:SQL Statistics\Batch Requests/sec'') where Value > 0.1)','=','0')
,('Counter Alert: Greater than 20 Worktables created per second','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Access Methods\Worktables Created/sec'',null) where Value > 20)','=','0')
,('Counter Alert: Less than 640 Free Pages','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Free pages'',null) where Value < 640)','=','0')
,('Counter Alert: Less than 70% (700 seconds by default) of the Page Life Expectancy Baseline (Buffer Manager)','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Page life expectancy'',null) where Value < 700)','=','0')
,('Counter Alert: Greater than 90 page reads per second','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Page reads/sec'',null) where Value > 90)','=','0')
,('Counter Alert: Greater than 2 logins per second - this may indicate that applications are not correctly using connection pooling','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:General Statistics\Logins/sec'',null) where Value > 2)','=','0')
,('Counter Alert: A ratio of more than 1 SQL Full Scan for every 1000 Index Searches','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Access Methods\Index Searches/sec'',''\SQLServer:Access Methods\Full Scans/sec'') where Value > 0.001)','=','0')
,('Counter Alert: Lock Requests/sec Greater than 1000','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Locks(*)\Lock Requests/sec'',NULL) where Value > 1000)','=','0')
,('Counter Alert: Average lock wait time is above 500 milliseconds per each second on average','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Locks(*)\Lock Wait Time (ms)'',NULL) where Value > 500)','=','0')
,('Counter Alert: Deadlocks Greater than 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Locks(*)\Number of Deadlocks/sec'',NULL) where Value > 0)','=','0')
,('Counter Alert: Latch wait is more than 10 milliseconds on average','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Latches\Latch Waits/sec'',''\SQLServer:Latches\Total Latch Wait Time (ms)'') where Value > 10)','=','0')
,('Counter Alert: Log Flush Waits/sec Near 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Databases(*)\Log Flush Waits/sec'',NULL) where Value > 0)','=','0')
,('Counter Alert: Log Growths Near 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Databases(*)\Log Growths'',NULL) where Value > 0)','=','0')
,('Counter Alert: Log Shrinks Near 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Databases(*)\Log Shrinks'',NULL) where Value > 0)','=','0')
,('Counter Alert: Free list stalls/sec > 2','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Free list stalls/sec'',NULL) where Value > 2)','=','0')
,('Counter Alert: Less than 20% of Page Reads/sec','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Readahead pages/sec'',''\SQLServer:Buffer Manager\Page reads/sec'') where Value > .2)','=','0')
,('Counter Alert: Attention Rate Greater Than 0','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:SQL Statistics\SQL Attention rate'',NULL) where Value > .2)','=','0')
,('Counter Alert: Less than 90% Worktables from Cache Ratio','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Access Methods\Worktables From Cache Ratio'',NULL) where Value < 90)','=','0')
,('Counter Alert: Greater than 0 outstanding IOs','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:Buffer Manager\Extension outstanding IO counter'',NULL) where Value > 0)','=','0')
,('Counter Alert: Less than 5120 Free Pages','(select count(*) from dbo.ufnCounterCheck(''\SQLServer:\SQLServer:Buffer Manager\Extension free pages'',NULL) where Value < 5120)','=','0')
,('Counter Alert: High ratio of Used to Target Resource Group Memory','(select count(*) from dbo.ufnIMResourcePoolStats(''\SQLServer:Resource Pool Stats(*)\Used memory (KB)'',''\SQLServer:Resource Pool Stats(*)\Target memory (KB)'') where Value > Threshold)','=','0')
--Chimney
--Page splits
--IO queue
--CPU queue
--Stats update > 1second

