DECLARE  @sqlmajorver int, @sqlcmd nvarchar(max)

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);

	SET @sqlcmd = 'SELECT ''Information'' AS [Category], ''RG_Workload_Groups'' AS [Information], group_id, name, pool_id, statistics_start_time, total_request_count, total_queued_request_count, 
	active_request_count, queued_request_count, total_cpu_limit_violation_count, total_cpu_usage_ms, max_request_cpu_time_ms, blocked_task_count, total_lock_wait_count, 
	total_lock_wait_time_ms, total_query_optimization_count, total_suboptimal_plan_generation_count, total_reduced_memgrant_count, max_request_grant_memory_kb, 
	active_parallel_thread_count, importance, request_max_memory_grant_percent, request_max_cpu_time_sec, request_memory_grant_timeout_sec, 
	group_max_requests, max_dop' + CASE WHEN @sqlmajorver > 10 THEN ', effective_max_dop' ELSE '' END + ' 
FROM sys.dm_resource_governor_workload_groups'
	EXECUTE sp_executesql @sqlcmd