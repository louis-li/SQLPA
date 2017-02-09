DECLARE @ts_now bigint
DECLARE @tblAggCPU TABLE (SQLProc tinyint, SysIdle tinyint, OtherProc tinyint, Minutes tinyint)
SELECT @ts_now = ms_ticks FROM sys.dm_os_sys_info (NOLOCK);

WITH cteCPU (record_id, SystemIdle, SQLProcessUtilization, [timestamp]) AS (SELECT 
		record.value('(./Record/@id)[1]', 'int') AS record_id,
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS SystemIdle,
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS SQLProcessUtilization,
		[TIMESTAMP] FROM (SELECT [TIMESTAMP], CONVERT(xml, record) AS record 
			FROM sys.dm_os_ring_buffers (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
			AND record LIKE '%<SystemHealth>%') AS x
	)
INSERT INTO @tblAggCPU
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 10 
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -10, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 20
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -10, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -20, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 30
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -20, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -30, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 40
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -30, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -40, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 50
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -40, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -50, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 60
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -50, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -60, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 70
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -60, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -70, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 80
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -70, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -80, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 90
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -80, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -90, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 100
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -90, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -100, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 110
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -100, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -110, GETDATE())
UNION ALL 
	SELECT AVG(SQLProcessUtilization), AVG(SystemIdle), 100 - AVG(SystemIdle) - AVG(SQLProcessUtilization), 120
	FROM cteCPU 
	WHERE DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) <= DATEADD(mi, -110, GETDATE()) AND 
		DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) > DATEADD(mi, -120, GETDATE())

SELECT 'Processor_checks' AS [Category], 'Agg_Processor_Usage_last_2h' AS [Information], SQLProc AS [SQL_Process_Utilization], SysIdle AS [System_Idle], OtherProc AS [Other_Process_Utilization], Minutes AS [Time_Slice_min]
FROM @tblAggCPU;
