IF EXISTS (SELECT * FROM sys.server_event_sessions  where name = 'SQLDiag')
DROP EVENT SESSION [SQLDiag] ON SERVER
GO
CREATE EVENT SESSION [SQLDiag] ON SERVER 

ADD EVENT sqlos.wait_info
(
	ACTION (sqlserver.database_id,sqlserver.sql_text,sqlserver.session_id,sqlserver.tsql_stack)
),
ADD EVENT sqlserver.databases_log_growth,
ADD EVENT sqlserver.rpc_completed(
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_statement_completed(
    WHERE ([sqlserver].[is_system]=(0)))
ADD TARGET package0.asynchronous_file_target(SET filename=N'$(XEFileName)',max_file_size=(256))
WITH (MAX_MEMORY=200800 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=10 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=PER_CPU,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


ALTER EVENT SESSION [SQLDiag] ON SERVER STATE = START
GO