DECLARE  @sqlmajorver int, @sqlcmd nvarchar(max)

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);

	SET @sqlcmd = 'SELECT ''Information'' AS [Category], ''RG_Resource_Pool'' AS [Information], rp.pool_id, name, statistics_start_time, total_cpu_usage_ms, cache_memory_kb, compile_memory_kb, 
	used_memgrant_kb, total_memgrant_count, total_memgrant_timeout_count, active_memgrant_count, active_memgrant_kb, memgrant_waiter_count, max_memory_kb, used_memory_kb, target_memory_kb, 
	out_of_memory_count, min_cpu_percent, max_cpu_percent, min_memory_percent, max_memory_percent' + CASE WHEN @sqlmajorver > 10 THEN ', cap_cpu_percent, rpa.processor_group, rpa.scheduler_mask' ELSE '' END + '
FROM sys.dm_resource_governor_resource_pools rp' + CASE WHEN @sqlmajorver > 10 THEN ' LEFT JOIN sys.dm_resource_governor_resource_pool_affinity rpa ON rp.pool_id = rpa.pool_id' ELSE '' END
	EXECUTE sp_executesql @sqlcmd