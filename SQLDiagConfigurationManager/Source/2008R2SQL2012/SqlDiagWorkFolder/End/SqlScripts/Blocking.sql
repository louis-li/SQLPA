
SELECT 
	-- blocked
	es.session_id AS blocked_spid,
	es.[status] AS [blocked_spid_status],
	ot.task_state AS [blocked_task_status],
	owt.wait_type AS blocked_spid_wait_type,
	COALESCE(owt.wait_duration_ms, ABS(CONVERT(BIGINT,(DATEDIFF(mi, es.last_request_start_time, GETDATE())))*60)) AS blocked_spid_wait_time_ms,
	--er.total_elapsed_time AS blocked_elapsed_time_ms,
	/* 
		Check sys.dm_os_waiting_tasks for Exchange wait types in http://technet.microsoft.com/en-us/library/ms188743.aspx.
		- Wait Resource e_waitPipeNewRow in CXPACKET waits – Producer waiting on consumer for a packet to fill.
		- Wait Resource e_waitPipeGetRow in CXPACKET waits – Consumer waiting on producer to fill a packet.
	*/
	owt.resource_description AS blocked_spid_res_desc,
	owt.pageid AS blocked_pageid,
	CASE WHEN owt.pageid = 1 OR owt.pageid % 8088 = 0 THEN 'Is_PFS_Page'
		WHEN owt.pageid = 2 OR owt.pageid % 511232 = 0 THEN 'Is_GAM_Page'
		WHEN owt.pageid = 3 OR (owt.pageid - 1) % 511232 = 0 THEN 'Is_SGAM_Page'
		WHEN owt.pageid IS NULL THEN NULL
		ELSE 'Is_not_PFS_GAM_SGAM_page' END AS blocked_spid_res_type,
	(SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		qt.[text],
		NCHAR(1),N'?'),NCHAR(2),N'?'),NCHAR(3),N'?'),NCHAR(4),N'?'),NCHAR(5),N'?'),NCHAR(6),N'?'),NCHAR(7),N'?'),NCHAR(8),N'?'),NCHAR(11),N'?'),NCHAR(12),N'?'),NCHAR(14),N'?'),NCHAR(15),N'?'),NCHAR(16),N'?'),NCHAR(17),N'?'),NCHAR(18),N'?'),NCHAR(19),N'?'),NCHAR(20),N'?'),NCHAR(21),N'?'),NCHAR(22),N'?'),NCHAR(23),N'?'),NCHAR(24),N'?'),NCHAR(25),N'?'),NCHAR(26),N'?'),NCHAR(27),N'?'),NCHAR(28),N'?'),NCHAR(29),N'?'),NCHAR(30),N'?'),NCHAR(31),N'?') 
		AS [text()]
		FROM sys.dm_exec_sql_text(COALESCE(er.sql_handle, ec.most_recent_sql_handle)) AS qt 
		FOR XML PATH(''), TYPE) AS [blocked_batch],
	(SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		SUBSTRING(qt2.text, 
		(CASE WHEN er.statement_start_offset = 0 THEN 0 ELSE er.statement_start_offset/2 END),
		(CASE WHEN er.statement_end_offset = -1 THEN DATALENGTH(qt2.text) ELSE er.statement_end_offset/2 END - (CASE WHEN er.statement_start_offset = 0 THEN 0 ELSE er.statement_start_offset/2 END))),
		NCHAR(1),N'?'),NCHAR(2),N'?'),NCHAR(3),N'?'),NCHAR(4),N'?'),NCHAR(5),N'?'),NCHAR(6),N'?'),NCHAR(7),N'?'),NCHAR(8),N'?'),NCHAR(11),N'?'),NCHAR(12),N'?'),NCHAR(14),N'?'),NCHAR(15),N'?'),NCHAR(16),N'?'),NCHAR(17),N'?'),NCHAR(18),N'?'),NCHAR(19),N'?'),NCHAR(20),N'?'),NCHAR(21),N'?'),NCHAR(22),N'?'),NCHAR(23),N'?'),NCHAR(24),N'?'),NCHAR(25),N'?'),NCHAR(26),N'?'),NCHAR(27),N'?'),NCHAR(28),N'?'),NCHAR(29),N'?'),NCHAR(30),N'?'),NCHAR(31),N'?') 
		AS [text()]
		FROM sys.dm_exec_sql_text(COALESCE(er.sql_handle, ec.most_recent_sql_handle)) AS qt2
		FOR XML PATH(''), TYPE) AS [blocked_statement],
	es.last_request_start_time AS blocked_last_start,
	LEFT (CASE COALESCE(es.transaction_isolation_level, er.transaction_isolation_level)
		WHEN 0 THEN '0-Unspecified' 
		WHEN 1 THEN '1-ReadUncommitted(NOLOCK)' 
		WHEN 2 THEN '2-ReadCommitted' 
		WHEN 3 THEN '3-RepeatableRead' 
		WHEN 4 THEN '4-Serializable' 
		WHEN 5 THEN '5-Snapshot'
		ELSE CONVERT (VARCHAR(30), COALESCE(es.transaction_isolation_level, er.transaction_isolation_level)) + '-UNKNOWN' 
	END, 30) AS blocked_tran_isolation_level,

	-- blocker
	er.blocking_session_id As blocker_spid,
	CASE 
		-- session has an active request, is blocked, but is blocking others or session is idle but has an open tran and is blocking others
		WHEN (er2.session_id IS NULL OR owt.blocking_session_id IS NULL) AND (er.blocking_session_id = 0 OR er.session_id IS NULL) THEN 1
		-- session is either not blocking someone, or is blocking someone but is blocked by another party
		ELSE 0
	END AS is_head_blocker,
	(SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		qt2.[text],
		NCHAR(1),N'?'),NCHAR(2),N'?'),NCHAR(3),N'?'),NCHAR(4),N'?'),NCHAR(5),N'?'),NCHAR(6),N'?'),NCHAR(7),N'?'),NCHAR(8),N'?'),NCHAR(11),N'?'),NCHAR(12),N'?'),NCHAR(14),N'?'),NCHAR(15),N'?'),NCHAR(16),N'?'),NCHAR(17),N'?'),NCHAR(18),N'?'),NCHAR(19),N'?'),NCHAR(20),N'?'),NCHAR(21),N'?'),NCHAR(22),N'?'),NCHAR(23),N'?'),NCHAR(24),N'?'),NCHAR(25),N'?'),NCHAR(26),N'?'),NCHAR(27),N'?'),NCHAR(28),N'?'),NCHAR(29),N'?'),NCHAR(30),N'?'),NCHAR(31),N'?') 
		AS [text()]
		FROM sys.dm_exec_sql_text(COALESCE(er2.sql_handle, ec2.most_recent_sql_handle)) AS qt2 
		FOR XML PATH(''), TYPE) AS [blocker_batch],
	(SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		SUBSTRING(qt2.text, 
		(CASE WHEN er2.statement_start_offset = 0 THEN 0 ELSE er2.statement_start_offset/2 END),
		(CASE WHEN er2.statement_end_offset = -1 THEN DATALENGTH(qt2.text) ELSE er2.statement_end_offset/2 END - (CASE WHEN er2.statement_start_offset = 0 THEN 0 ELSE er2.statement_start_offset/2 END))),
		NCHAR(1),N'?'),NCHAR(2),N'?'),NCHAR(3),N'?'),NCHAR(4),N'?'),NCHAR(5),N'?'),NCHAR(6),N'?'),NCHAR(7),N'?'),NCHAR(8),N'?'),NCHAR(11),N'?'),NCHAR(12),N'?'),NCHAR(14),N'?'),NCHAR(15),N'?'),NCHAR(16),N'?'),NCHAR(17),N'?'),NCHAR(18),N'?'),NCHAR(19),N'?'),NCHAR(20),N'?'),NCHAR(21),N'?'),NCHAR(22),N'?'),NCHAR(23),N'?'),NCHAR(24),N'?'),NCHAR(25),N'?'),NCHAR(26),N'?'),NCHAR(27),N'?'),NCHAR(28),N'?'),NCHAR(29),N'?'),NCHAR(30),N'?'),NCHAR(31),N'?') 
		AS [text()]
		FROM sys.dm_exec_sql_text(COALESCE(er2.sql_handle, ec2.most_recent_sql_handle)) AS qt2 
		FOR XML PATH(''), TYPE) AS [blocker_statement],
	es2.last_request_start_time AS blocker_last_start,
	LEFT (CASE COALESCE(er2.transaction_isolation_level, es.transaction_isolation_level)
		WHEN 0 THEN '0-Unspecified' 
		WHEN 1 THEN '1-ReadUncommitted(NOLOCK)' 
		WHEN 2 THEN '2-ReadCommitted' 
		WHEN 3 THEN '3-RepeatableRead' 
		WHEN 4 THEN '4-Serializable' 
		WHEN 5 THEN '5-Snapshot' 
		ELSE CONVERT (VARCHAR(30), COALESCE(er2.transaction_isolation_level, es.transaction_isolation_level)) + '-UNKNOWN' 
	END, 30) AS blocker_tran_isolation_level,

	-- blocked - other data
	DB_NAME(er.database_id) AS blocked_database, 
	es.[host_name] AS blocked_host,
	es.[program_name] AS blocked_program, 
	es.login_name AS blocked_login,
	CASE WHEN es.session_id = -2 THEN 'Orphaned_distributed_tran' 
		WHEN es.session_id = -3 THEN 'Defered_recovery_tran' 
		WHEN es.session_id = -4 THEN 'Unknown_tran' ELSE NULL END AS blocked_session_comment,
	es.is_user_process AS [blocked_is_user_process],

	-- blocker - other data
	DB_NAME(er2.database_id) AS blocker_database,
	es2.[host_name] AS blocker_host,
	es2.[program_name] AS blocker_program,	
	es2.login_name AS blocker_login,
	CASE WHEN es2.session_id = -2 THEN 'Orphaned_distributed_tran' 
		WHEN es2.session_id = -3 THEN 'Defered_recovery_tran' 
		WHEN es2.session_id = -4 THEN 'Unknown_tran' ELSE NULL END AS blocker_session_comment,
	es2.is_user_process AS [blocker_is_user_process]
FROM sys.dm_exec_sessions es
LEFT OUTER JOIN sys.dm_exec_requests er ON es.session_id = er.session_id
LEFT OUTER JOIN sys.dm_exec_connections ec ON es.session_id = ec.session_id
LEFT OUTER JOIN sys.dm_os_tasks ot ON er.session_id = ot.session_id AND er.request_id = ot.request_id
LEFT OUTER JOIN sys.dm_exec_sessions es2 ON er.blocking_session_id = es2.session_id
LEFT OUTER JOIN sys.dm_exec_requests er2 ON es2.session_id = er2.session_id
LEFT OUTER JOIN sys.dm_exec_connections ec2 ON es2.session_id = ec2.session_id
LEFT OUTER JOIN 
(
	-- In some cases (e.g. parallel queries, also waiting for a worker), one thread can be flagged as 
	-- waiting for several different threads.  This will cause that thread to show up in multiple rows 
	-- in our grid, which we don't want.  Use ROW_NUMBER to select the longest wait for each thread, 
	-- and use it as representative of the other wait relationships this thread is involved in. 
	SELECT  waiting_task_address, session_id, exec_context_id, wait_duration_ms, 
		wait_type, resource_address, blocking_task_address, blocking_session_id, 
		blocking_exec_context_id, resource_description,
		CASE WHEN [wait_type] LIKE 'PAGE%' AND [resource_description] LIKE '%:%' THEN CAST(RIGHT([resource_description], LEN([resource_description]) - CHARINDEX(':', [resource_description], LEN([resource_description])-CHARINDEX(':', REVERSE([resource_description])))) AS int)
			ELSE NULL END AS pageid,
		ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
	FROM sys.dm_os_waiting_tasks
	WHERE wait_type <> 'SP_SERVER_DIAGNOSTICS_SLEEP'
) owt ON ot.task_address = owt.waiting_task_address AND owt.row_num = 1
--OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) est
--OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) eqp
WHERE es.session_id <> @@SPID AND es.is_user_process = 1 
	AND ((owt.wait_duration_ms/1000) > 5 OR (er.total_elapsed_time/1000) > 5 OR er.total_elapsed_time IS NULL) --Only report blocks > 5 Seconds plus head blocker
	AND (es.session_id IN (SELECT er3.blocking_session_id FROM sys.dm_exec_requests er3) OR er.blocking_session_id IS NOT NULL)
ORDER BY blocked_spid, is_head_blocker DESC, blocked_spid_wait_time_ms DESC, blocker_spid;


