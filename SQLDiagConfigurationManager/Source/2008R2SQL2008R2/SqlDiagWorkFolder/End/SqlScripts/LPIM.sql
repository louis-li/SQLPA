SELECT 
	CASE WHEN locked_page_allocations_kb > 0 THEN 1 ELSE 0 END 
FROM 
	sys.dm_os_process_memory (NOLOCK)