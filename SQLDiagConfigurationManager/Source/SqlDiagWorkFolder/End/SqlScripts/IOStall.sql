DECLARE @mincol DATETIME, @maxcol DATETIME

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmp_dm_io_virtual_file_stats'))
DROP TABLE #tmp_dm_io_virtual_file_stats;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmp_dm_io_virtual_file_stats'))	
CREATE TABLE [dbo].[#tmp_dm_io_virtual_file_stats]([retrieval_time] [datetime],database_id int, [file_id] int, [DBName] sysname, [logical_file_name] NVARCHAR(255), [type_desc] NVARCHAR(60), 
	[physical_location] NVARCHAR(260),[sample_ms] int,[num_of_reads] bigint,[num_of_bytes_read] bigint,[io_stall_read_ms] bigint,[num_of_writes] bigint,
	[num_of_bytes_written] bigint,[io_stall_write_ms] bigint,[io_stall] bigint,[size_on_disk_bytes] bigint,
	CONSTRAINT PK_dm_io_virtual_file_stats PRIMARY KEY CLUSTERED(database_id, [file_id], [retrieval_time]));

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblIOStall'))
DROP TABLE #tblIOStall;
IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tblIOStall'))
CREATE TABLE #tblIOStall (database_id int, [file_id] int, [DBName] sysname, [logical_file_name] NVARCHAR(255), [type_desc] NVARCHAR(60),
	[physical_location] NVARCHAR(260), size_on_disk_Mbytes int, num_of_reads bigint, num_of_writes bigint, num_of_KBytes_read bigint, num_of_KBytes_written bigint,
	io_stall_ms int, io_stall_read_ms int, io_stall_write_ms int, avg_read_latency_ms int, avg_write_latency_ms int, cumulative_io_stall_read_pct int, 
	cumulative_io_stall_write_pct int, cumulative_sample_HH int, io_stall_pct_of_cumulative_sample int, 		
	CONSTRAINT PK_IOStall PRIMARY KEY CLUSTERED(database_id, [file_id]));

SELECT @mincol = GETDATE()

INSERT INTO #tmp_dm_io_virtual_file_stats
SELECT @mincol, f.database_id, f.[file_id], DB_NAME(f.database_id), f.name AS logical_file_name, f.type_desc, 
	CAST (CASE 
		-- Handle UNC paths (e.g. '\\fileserver\readonlydbs\dept_dw.ndf')
		WHEN LEFT (LTRIM (f.physical_name), 2) = '\\' 
			THEN LEFT (LTRIM (f.physical_name),CHARINDEX('\',LTRIM(f.physical_name),CHARINDEX('\',LTRIM(f.physical_name), 3) + 1) - 1)
			-- Handle local paths (e.g. 'C:\Program Files\...\master.mdf') 
			WHEN CHARINDEX('\', LTRIM(f.physical_name), 3) > 0 
			THEN UPPER(LEFT(LTRIM(f.physical_name), CHARINDEX ('\', LTRIM(f.physical_name), 3) - 1))
		ELSE f.physical_name
	END AS NVARCHAR(255)) AS physical_location,
	fs.[sample_ms],fs.[num_of_reads],fs.[num_of_bytes_read],fs.[io_stall_read_ms],fs.[num_of_writes],
	fs.[num_of_bytes_written],fs.[io_stall_write_ms],fs.[io_stall],fs.[size_on_disk_bytes]
FROM sys.dm_io_virtual_file_stats (default, default) AS fs
INNER JOIN sys.master_files AS f ON fs.database_id = f.database_id AND fs.[file_id] = f.[file_id]

WAITFOR DELAY '00:00:05' -- wait 5s between pooling

SELECT @maxcol = GETDATE()

INSERT INTO #tmp_dm_io_virtual_file_stats
SELECT @maxcol, f.database_id, f.[file_id], DB_NAME(f.database_id), f.name AS logical_file_name, f.type_desc, 
	CAST (CASE 
		-- Handle UNC paths (e.g. '\\fileserver\readonlydbs\dept_dw.ndf')
		WHEN LEFT (LTRIM (f.physical_name), 2) = '\\' 
			THEN LEFT (LTRIM (f.physical_name),CHARINDEX('\',LTRIM(f.physical_name),CHARINDEX('\',LTRIM(f.physical_name), 3) + 1) - 1)
			-- Handle local paths (e.g. 'C:\Program Files\...\master.mdf') 
			WHEN CHARINDEX('\', LTRIM(f.physical_name), 3) > 0 
			THEN UPPER(LEFT(LTRIM(f.physical_name), CHARINDEX ('\', LTRIM(f.physical_name), 3) - 1))
		ELSE f.physical_name
	END AS NVARCHAR(255)) AS physical_location,
	fs.[sample_ms],fs.[num_of_reads],fs.[num_of_bytes_read],fs.[io_stall_read_ms],fs.[num_of_writes],
	fs.[num_of_bytes_written],fs.[io_stall_write_ms],fs.[io_stall],fs.[size_on_disk_bytes]
FROM sys.dm_io_virtual_file_stats (default, default) AS fs
INNER JOIN sys.master_files AS f ON fs.database_id = f.database_id AND fs.[file_id] = f.[file_id]

;WITH cteFileStats1 AS (SELECT database_id,[file_id],[DBName],[logical_file_name],[type_desc], 
		[physical_location],[sample_ms],[num_of_reads],[num_of_bytes_read],[io_stall_read_ms],[num_of_writes],
		[num_of_bytes_written],[io_stall_write_ms],[io_stall],[size_on_disk_bytes]
	FROM #tmp_dm_io_virtual_file_stats WHERE [retrieval_time] = @mincol),
	cteFileStats2 AS (SELECT database_id,[file_id],[DBName],[logical_file_name],[type_desc], 
		[physical_location],[sample_ms],[num_of_reads],[num_of_bytes_read],[io_stall_read_ms],[num_of_writes],
		[num_of_bytes_written],[io_stall_write_ms],[io_stall],[size_on_disk_bytes]
	FROM #tmp_dm_io_virtual_file_stats WHERE [retrieval_time] = @maxcol)
INSERT INTO #tblIOStall
SELECT t1.database_id, t1.[file_id], t1.[DBName], t1.logical_file_name, t1.type_desc, t1.physical_location,
	t1.size_on_disk_bytes/1024/1024 AS size_on_disk_Mbytes,
	(t2.num_of_reads-t1.num_of_reads) AS num_of_reads, 
	(t2.num_of_writes-t1.num_of_writes) AS num_of_writes,
	(t2.num_of_bytes_read-t1.num_of_bytes_read)/1024 AS num_of_KBytes_read,
	(t2.num_of_bytes_written-t1.num_of_bytes_written)/1024 AS num_of_KBytes_written,
	(t2.io_stall-t1.io_stall) AS io_stall_ms, 
	(t2.io_stall_read_ms-t1.io_stall_read_ms) AS io_stall_read_ms, 
	(t2.io_stall_write_ms-t1.io_stall_write_ms) AS io_stall_write_ms,
	((t2.io_stall_read_ms-t1.io_stall_read_ms) / (1.0 + (t2.num_of_reads-t1.num_of_reads))) AS avg_read_latency_ms,
	((t2.io_stall_write_ms-t1.io_stall_write_ms) / (1.0 + (t2.num_of_writes-t1.num_of_writes))) AS avg_write_latency_ms,
	((t2.io_stall_read_ms)*100)/(CASE WHEN t2.io_stall = 0 THEN 1 ELSE t2.io_stall END) AS cumulative_io_stall_read_pct, 
	((t2.io_stall_write_ms)*100)/(CASE WHEN t2.io_stall = 0 THEN 1 ELSE t2.io_stall END) AS cumulative_io_stall_write_pct,
	ABS((t2.sample_ms/1000)/60/60) AS cumulative_sample_HH, 
	((t2.io_stall/1000/60)*100)/(ABS((t2.sample_ms/1000)/60)) AS io_stall_pct_of_cumulative_sample
FROM cteFileStats1 t1 INNER JOIN cteFileStats2 t2 ON t1.database_id = t2.database_id AND t1.[file_id] = t2.[file_id]

Select * from  #tblIOStall