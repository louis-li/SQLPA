DECLARE @sqlmajorver int,@sqlminorver int, @sqlbuild int

SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);
IF @sqlmajorver >= 12
BEGIN
	SELECT
	OBJECT_NAME([object_id]) AS [Object_Name], memory_consumer_type_desc, [object_id], index_id, 
	allocated_bytes/(1024*1024) AS Allocated_MB, used_bytes/(1024*1024) AS Used_MB, 
	CASE WHEN used_bytes IS NULL THEN 'used_bytes_is_varheap_only' ELSE '''' END AS [Comment]
	FROM sys.dm_db_xtp_memory_consumers
	WHERE [object_id] > 0
END