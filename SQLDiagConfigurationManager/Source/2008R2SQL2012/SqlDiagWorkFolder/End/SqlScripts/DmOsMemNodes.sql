DECLARE  @sqlmajorver int

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);

IF @sqlmajorver > 10
BEGIN
	Exec ('SELECT memory_node_id, virtual_address_space_reserved_kb, virtual_address_space_committed_kb, locked_page_allocations_kb, pages_kb, foreign_committed_kb, shared_memory_reserved_kb, shared_memory_committed_kb, processor_group FROM sys.dm_os_memory_nodes;')
END
ELSE IF @sqlmajorver = 10
BEGIN
	Exec ('SELECT memory_node_id, virtual_address_space_reserved_kb, virtual_address_space_committed_kb, locked_page_allocations_kb, single_pages_kb+ multi_pages_kb as pages_kb, 0 as foreign_committed_kb, shared_memory_reserved_kb, shared_memory_committed_kb, processor_group FROM sys.dm_os_memory_nodes;')
END;
