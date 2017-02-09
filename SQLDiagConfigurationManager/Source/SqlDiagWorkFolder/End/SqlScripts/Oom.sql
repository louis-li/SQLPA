	SELECT 
	CASE WHEN x.[TIMESTAMP] BETWEEN -2147483648 AND 2147483647 AND si.ms_ticks BETWEEN -2147483648 AND 2147483647 THEN DATEADD(ms, x.[TIMESTAMP] - si.ms_ticks, GETDATE()) 
		ELSE DATEADD(s, ([TIMESTAMP]/1000) - (si.ms_ticks/1000), GETDATE()) END AS Event_Time,
		record.value('(./Record/OOM/Action)[1]', 'varchar(50)') AS [Action],
		record.value('(./Record/OOM/Resources)[1]', 'int') AS [Resources],
		record.value('(./Record/OOM/Task)[1]', 'varchar(20)') AS [Task],
		record.value('(./Record/OOM/Pool)[1]', 'int') AS [PoolID],
		rgrp.name AS [PoolName],
		record.value('(./Record/MemoryRecord/MemoryUtilization)[1]', 'bigint') AS [MemoryUtilPct],
		record.value('(./Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint')/1024 AS [Total_Physical_Mem_MB],
		record.value('(./Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint')/1024 AS [Avail_Physical_Mem_MB],
		record.value('(./Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint')/1024 AS [Avail_VAS_MB],
		record.value('(./Record/MemoryRecord/TotalPageFile)[1]', 'bigint')/1024 AS [Total_Pagefile_MB],
		record.value('(./Record/MemoryRecord/AvailablePageFile)[1]', 'bigint')/1024 AS [Avail_Pagefile_MB]
	FROM (SELECT [TIMESTAMP], CONVERT(xml, record) AS record 
				FROM sys.dm_os_ring_buffers (NOLOCK)
				WHERE ring_buffer_type = N'RING_BUFFER_OOM') AS x
	CROSS JOIN sys.dm_os_sys_info si (NOLOCK)
	LEFT JOIN sys.resource_governor_resource_pools rgrp (NOLOCK) ON rgrp.pool_id = record.value('(./Record/OOM/Pool)[1]', 'int')
	--WHERE CASE WHEN x.[timestamp] BETWEEN -2147483648 AND 2147483648 THEN DATEADD(ms, x.[timestamp] - si.ms_ticks, GETDATE()) 
	--	ELSE DATEADD(s, (x.[timestamp]/1000) - (si.ms_ticks/1000), GETDATE()) END >= DATEADD(hh, -12, GETDATE())
	ORDER BY 1 DESC;