SELECT 
	latch_class, waiting_requests_count,
	wait_time_ms, max_wait_time_ms,
	100.0 * [Wait_time_ms] / SUM (Wait_time_ms) OVER() As [Percentage],
	CAST ((wait_time_ms / waiting_requests_count) AS DECIMAL (14, 4)) AS avg_wait_ms,
	CASE WHEN latch_class LIKE N'ACCESS_METHODS_HOBT_COUNT' 
			OR latch_class LIKE N'ACCESS_METHODS_HOBT_VIRTUAL_ROOT' THEN N'[HoBT - Metadata]'
		WHEN latch_class LIKE N'ACCESS_METHODS_DATASET_PARENT' 
			OR latch_class LIKE N'ACCESS_METHODS_SCAN_RANGE_GENERATOR' 
			OR latch_class LIKE N'NESTING_TRANSACTION_FULL' THEN N'[Parallelism]'
		WHEN latch_class LIKE N'LOG_MANAGER' THEN N'[IO - Log]'
		WHEN latch_class LIKE N'TRACE_CONTROLLER' THEN N'[Trace]'
		WHEN latch_class LIKE N'DBCC_MULTIOBJECT_SCANNER' THEN N'[Parallelism - DBCC CHECK_]'
		WHEN latch_class LIKE N'FGCB_ADD_REMOVE' THEN N'[IO Operations]'
		WHEN latch_class LIKE N'DATABASE_MIRRORING_CONNECTION' THEN N'[Mirroring - Busy]'
		WHEN latch_class LIKE N'BUFFER' THEN N'[Buffer Pool - PAGELATCH or PAGEIOLATCH]'
		ELSE N'[Other]' END AS 'latch_category',
	Row_Number() OVER (Order By [wait_time_ms] DESC) as [RowNum]
FROM sys.dm_os_latch_stats
WHERE wait_time_ms > 0
