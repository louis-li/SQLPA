param ($ServerInstance = 'localhost',
    $InternalOutFileName,
    $OutputFileName)

$ServerInstance > $InternalOutFileName
$OutputFileName >> $InternalOutFileName

$GetTimeScript = "SELECT  TOP 10 [total_worker_time]/[execution_count] as [Time]
FROM sys.dm_exec_query_stats qs (NOLOCK)
	ORDER BY [total_worker_time]/[execution_count] DESC"

$AvgTime = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -query $GetTimeScript

$xEventScript = "
IF EXISTS (SELECT * FROM sys.server_event_sessions  where name = 'SQLDiag')
DROP EVENT SESSION [SQLDiag] ON SERVER
GO
CREATE EVENT SESSION [SQLDiag] ON SERVER 
ADD EVENT sqlserver.auto_stats(SET collect_database_name=(0)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.batch_hash_table_build_bailout(
    ACTION(sqlserver.query_hash,sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.bitmap_disabled_warning(
    ACTION(sqlserver.query_hash,sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.blocked_process_report,
ADD EVENT sqlserver.database_file_size_change,
ADD EVENT sqlserver.databases_log_growth,
ADD EVENT sqlserver.exchange_spill(
    ACTION(sqlserver.query_hash,sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.execution_warning(
    ACTION(sqlserver.query_hash)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.hash_warning(
    ACTION(sqlserver.query_hash,sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.latch_suspend_warning(
    ACTION(sqlserver.query_hash)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.missing_column_statistics(
    ACTION(sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.missing_join_predicate(
    ACTION(sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.optimizer_timeout(
    ACTION(sqlserver.query_hash)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION(sqlserver.sql_text)
    WHERE (([package0].[divides_by_uint64]([package0].[counter],(100)) 
			AND [package0].[greater_than_uint64]([cpu_time],(0))
			OR [cpu_time]>($($AvgTime[-1].Time))) 
		AND [package0].[equal_boolean]([sqlserver].[is_system],(0)) 
		)),
ADD EVENT sqlserver.rpc_completed(
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.transaction_log(
    ACTION(sqlserver.query_hash)
    WHERE ([operation]=(11))),
ADD EVENT sqlserver.unmatched_filtered_indexes(
    ACTION(sqlserver.query_hash,sqlserver.sql_text)
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(SET filename=N'$OutputFileName',max_file_size=(256))
WITH (MAX_MEMORY=200800 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=10 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_CPU,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


ALTER EVENT SESSION [SQLDiag] ON SERVER STATE = START
GO
"
$xEventScript >> $InternalOutFileName
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -query $xEventScript