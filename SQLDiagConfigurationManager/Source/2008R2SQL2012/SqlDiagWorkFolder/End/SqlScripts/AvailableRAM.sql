declare @ts bigint;
SELECT @ts = ms_ticks FROM sys.dm_os_sys_info (NOLOCK);

SELECT 
	Dateadd(ms, -1 * (@ts - t1.TIMESTAMP), Getdate()) as TimeStamp,
	t1.record.value('(./Record/ResourceMonitor/Notification)[1]', 'varchar(255)') as Notification,
	t1.record.value('(./Record/MemoryRecord/TotalPhysicalMemory)[1]', 'bigint')/1024 as TotalRAMInMB, 
	t1.record.value('(./Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint')/1024 as AvailableRAMInMb,
	t1.record.value('(./Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint')/1024 AS [Avail_VAS_MB],
	t1.record.value('(./Record/MemoryRecord/TotalPageFile)[1]', 'bigint')/1024 AS [Total_Pagefile_MB],
	t1.record.value('(./Record/MemoryRecord/AvailablePageFile)[1]', 'bigint')/1024 AS [Avail_Pagefile_MB]
FROM (SELECT MAX([TIMESTAMP]) AS [TIMESTAMP], CONVERT(xml, record) AS record 
	FROM sys.dm_os_ring_buffers (NOLOCK)
	WHERE ring_buffer_type = N'RING_BUFFER_RESOURCE_MONITOR'
		--AND record LIKE '%RESOURCE_MEMPHYSICAL%'
	GROUP BY record) AS t1

Union All

SELECT 
	Getdate(),system_memory_state_desc,total_physical_memory_kb/1024, available_physical_memory_kb/1024, 0,total_page_file_kb / 1014,available_page_file_kb /1024
FROM sys.dm_os_sys_memory
order by 
	TIMESTAMP