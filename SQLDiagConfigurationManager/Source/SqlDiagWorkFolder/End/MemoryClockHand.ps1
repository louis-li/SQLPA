$ScriptV11 = "		SELECT mcch.name, mcch.[type], 
	mcch.clock_hand, mcch.clock_status, SUM(mcch.rounds_count) AS rounds_count,
	SUM(mcch.removed_all_rounds_count) AS cache_entries_removed_all_rounds, 
	SUM(mcch.removed_last_round_count) AS cache_entries_removed_last_round,
	SUM(mcch.updated_last_round_count) AS cache_entries_updated_last_round,
	SUM(mcc.pages_kb) AS cache_pages_kb,
	SUM(mcc.pages_in_use_kb) AS cache_pages_in_use_kb,
	SUM(mcc.entries_count) AS cache_entries_count, 
	SUM(mcc.entries_in_use_count) AS cache_entries_in_use_count, 
	CASE WHEN mcch.last_tick_time BETWEEN -2147483648 AND 2147483647 AND si.ms_ticks BETWEEN -2147483648 AND 2147483647 THEN DATEADD(ms, mcch.last_tick_time - si.ms_ticks, GETDATE()) 
		WHEN mcch.last_tick_time/1000 BETWEEN -2147483648 AND 2147483647 AND si.ms_ticks/1000 BETWEEN -2147483648 AND 2147483647 THEN DATEADD(s, (mcch.last_tick_time/1000) - (si.ms_ticks/1000), GETDATE()) 
		ELSE NULL END AS last_clock_hand_move
FROM sys.dm_os_memory_cache_counters mcc (NOLOCK)
INNER JOIN sys.dm_os_memory_cache_clock_hands mcch (NOLOCK) ON mcc.cache_address = mcch.cache_address
CROSS JOIN sys.dm_os_sys_info si (NOLOCK)
WHERE mcch.rounds_count > 0
GROUP BY mcch.name, mcch.[type], mcch.clock_hand, mcch.clock_status, mcc.pages_kb, mcc.pages_in_use_kb, mcch.last_tick_time, si.ms_ticks, mcc.entries_count, mcc.entries_in_use_count
ORDER BY SUM(mcch.removed_all_rounds_count) DESC, mcch.[type];"

$ScriptV10 = "		SELECT mcch.name, mcch.[type], 
	mcch.clock_hand, mcch.clock_status, SUM(mcch.rounds_count) AS rounds_count,
	SUM(mcch.removed_all_rounds_count) AS cache_entries_removed_all_rounds, 
	SUM(mcch.removed_last_round_count) AS cache_entries_removed_last_round,
	SUM(mcch.updated_last_round_count) AS cache_entries_updated_last_round,
	SUM(mcc.single_pages_kb) AS cache_single_pages_kb,
	SUM(mcc.multi_pages_kb) AS cache_multi_pages_kb,
	SUM(mcc.single_pages_in_use_kb) AS cache_single_pages_in_use_kb,
	SUM(mcc.multi_pages_in_use_kb) AS cache_multi_pages_in_use_kb,
	SUM(mcc.entries_count) AS cache_entries_count, 
	SUM(mcc.entries_in_use_count) AS cache_entries_in_use_count, 
	CASE WHEN mcch.last_tick_time BETWEEN -2147483648 AND 2147483647 AND si.ms_ticks BETWEEN -2147483648 AND 2147483647 THEN DATEADD(ms, mcch.last_tick_time - si.ms_ticks, GETDATE()) 
		WHEN mcch.last_tick_time/1000 BETWEEN -2147483648 AND 2147483647 AND si.ms_ticks/1000 BETWEEN -2147483648 AND 2147483647 THEN DATEADD(s, (mcch.last_tick_time/1000) - (si.ms_ticks/1000), GETDATE()) 
		ELSE NULL END AS last_clock_hand_move
FROM sys.dm_os_memory_cache_counters mcc (NOLOCK)
INNER JOIN sys.dm_os_memory_cache_clock_hands mcch (NOLOCK) ON mcc.cache_address = mcch.cache_address
CROSS JOIN sys.dm_os_sys_info si (NOLOCK)
WHERE mcch.rounds_count > 0
GROUP BY mcch.name, mcch.[type], mcch.clock_hand, mcch.clock_status, mcc.single_pages_kb, mcc.multi_pages_kb, mcc.single_pages_in_use_kb, mcc.multi_pages_in_use_kb, mcch.last_tick_time, si.ms_ticks, mcc.entries_count, mcc.entries_in_use_count
ORDER BY SUM(mcch.removed_all_rounds_count) DESC, mcch.[type];"

if ($server.VersionMajor -ge 11)
{
    Invoke-Sqlcmd -ServerInstance $InstanceName -Query $ScriptV11
}
else
{
    Invoke-Sqlcmd -ServerInstance $InstanceName -Query $ScriptV10
}