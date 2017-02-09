DECLARE @IOCnt tinyint
IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblPendingIOReq'))
DROP TABLE #tblPendingIOReq;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblPendingIOReq'))
CREATE TABLE #tblPendingIOReq (io_completion_request_address varbinary(8), io_handle varbinary(8), io_type VARCHAR(7), io_pending bigint,	io_pending_ms_ticks bigint, scheduler_address varbinary(8));

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblPendingIO'))
DROP TABLE #tblPendingIO;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblPendingIO'))
CREATE TABLE #tblPendingIO (database_id int, [file_id] int, [DBName] sysname, [logical_file_name] NVARCHAR(255), [type_desc] NVARCHAR(60),
	[physical_location] NVARCHAR(260), io_stall_min int, io_stall_read_min int, io_stall_write_min int, avg_read_latency_ms int,
	avg_write_latency_ms int, io_stall_read_pct int, io_stall_write_pct int, sampled_HH int, 
	io_stall_pct_of_overall_sample int, io_completion_request_address varbinary(8), io_handle varbinary(8), io_type VARCHAR(7), io_pending bigint,	io_pending_ms_ticks bigint, scheduler_address varbinary(8),
	scheduler_id int, pending_disk_io_count int, work_queue_count bigint);

SET @IOCnt = 1
WHILE @IOCnt < 5
BEGIN
	INSERT INTO #tblPendingIOReq
	SELECT io_completion_request_address, io_handle, io_type, io_pending, io_pending_ms_ticks, scheduler_address
	FROM sys.dm_io_pending_io_requests;

	IF (SELECT COUNT(io_pending) FROM #tblPendingIOReq WHERE io_type = 'disk') > 1
	BREAK

	WAITFOR DELAY '00:00:01' -- wait 1s between pooling

	SET @IOCnt = @IOCnt + 1
END;

IF (SELECT COUNT(io_pending) FROM #tblPendingIOReq WHERE io_type = 'disk') > 0
BEGIN
	INSERT INTO #tblPendingIO
	SELECT DISTINCT f.database_id, f.[file_id], DB_NAME(f.database_id) AS database_name, f.name AS logical_file_name, f.type_desc, 
		CAST (CASE 
			-- Handle UNC paths (e.g. '\\fileserver\readonlydbs\dept_dw.ndf')
			WHEN LEFT (LTRIM (f.physical_name), 2) = '\\' 
				THEN LEFT (LTRIM (f.physical_name),CHARINDEX('\',LTRIM(f.physical_name),CHARINDEX('\',LTRIM(f.physical_name), 3) + 1) - 1)
				-- Handle local paths (e.g. 'C:\Program Files\...\master.mdf') 
				WHEN CHARINDEX('\', LTRIM(f.physical_name), 3) > 0 
				THEN UPPER(LEFT(LTRIM(f.physical_name), CHARINDEX ('\', LTRIM(f.physical_name), 3) - 1))
			ELSE f.physical_name
		END AS NVARCHAR(255)) AS physical_location,
		fs.io_stall/1000/60 AS io_stall_min, 
		fs.io_stall_read_ms/1000/60 AS io_stall_read_min, 
		fs.io_stall_write_ms/1000/60 AS io_stall_write_min,
		(fs.io_stall_read_ms / (1.0 + fs.num_of_reads)) AS avg_read_latency_ms,
		(fs.io_stall_write_ms / (1.0 + fs.num_of_writes)) AS avg_write_latency_ms,
		((fs.io_stall_read_ms/1000/60)*100)/(CASE WHEN fs.io_stall/1000/60 = 0 THEN 1 ELSE fs.io_stall/1000/60 END) AS io_stall_read_pct, 
		((fs.io_stall_write_ms/1000/60)*100)/(CASE WHEN fs.io_stall/1000/60 = 0 THEN 1 ELSE fs.io_stall/1000/60 END) AS io_stall_write_pct,
		ABS((fs.sample_ms/1000)/60/60) AS 'sample_HH', 
		((fs.io_stall/1000/60)*100)/(ABS((fs.sample_ms/1000)/60))AS 'io_stall_pct_of_overall_sample',
		pio.io_completion_request_address, pio.io_handle, pio.io_type, pio.io_pending,
		pio.io_pending_ms_ticks, pio.scheduler_address, os.scheduler_id, os.pending_disk_io_count, os.work_queue_count
	FROM #tblPendingIOReq AS pio 
	INNER JOIN sys.dm_io_virtual_file_stats (NULL,NULL) AS fs ON fs.file_handle = pio.io_handle
	INNER JOIN sys.dm_os_schedulers AS os ON pio.scheduler_address = os.scheduler_address
	INNER JOIN sys.master_files AS f ON fs.database_id = f.database_id AND fs.[file_id] = f.[file_id];
END;

Select * from #tblPendingIO