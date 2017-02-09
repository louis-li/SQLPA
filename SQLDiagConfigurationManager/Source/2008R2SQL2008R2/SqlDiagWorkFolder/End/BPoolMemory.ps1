$ScriptV12 = "SELECT 
	COUNT_BIG(DISTINCT page_id)*8/1024 AS total_pages_MB, 
	CASE database_id WHEN 32767 THEN 'ResourceDB' ELSE DB_NAME(database_id) END AS database_name,
	SUM(row_count)/COUNT_BIG(DISTINCT page_id) AS avg_row_count_per_page, 
	SUM(CONVERT(BIGINT, free_space_in_bytes))/COUNT_BIG(DISTINCT page_id) AS avg_free_space_bytes_per_page,
	is_in_bpool_extension,numa_node,AVG(read_microsec) AS avg_read_microsec
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id, numa_node, is_in_bpool_extension
ORDER BY total_pages_MB DESC;"

$ScriptV11 = "SELECT 
	COUNT_BIG(DISTINCT page_id)*8/1024 AS total_pages_MB, 
	CASE database_id WHEN 32767 THEN 'ResourceDB' ELSE DB_NAME(database_id) END AS database_name,
	SUM(row_count)/COUNT_BIG(DISTINCT page_id) AS avg_row_count_per_page, 
	SUM(CONVERT(BIGINT, free_space_in_bytes))/COUNT_BIG(DISTINCT page_id) AS avg_free_space_bytes_per_page,
	numa_node,AVG(read_microsec) AS avg_read_microsec
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id, numa_node
ORDER BY total_pages_MB DESC;"

$ScriptV10 = "SELECT 
	COUNT_BIG(DISTINCT page_id)*8/1024 AS total_pages_MB, 
	CASE database_id WHEN 32767 THEN 'ResourceDB' ELSE DB_NAME(database_id) END AS database_name,
	SUM(row_count)/COUNT_BIG(DISTINCT page_id) AS avg_row_count_per_page, 
	SUM(CONVERT(BIGINT, free_space_in_bytes))/COUNT_BIG(DISTINCT page_id) AS avg_free_space_bytes_per_page,
	numa_node
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id, numa_node
ORDER BY total_pages_MB DESC;"

Switch ($server.VersionMajor) 
{
    12 { Invoke-SqlCmd -ServerInstance $InstanceName -Query $ScriptV12; Break;}
    11 { Invoke-SqlCmd -ServerInstance $InstanceName -Query $ScriptV11; Break;}
    10 { Invoke-SqlCmd -ServerInstance $InstanceName -Query $ScriptV10; Break;}
}