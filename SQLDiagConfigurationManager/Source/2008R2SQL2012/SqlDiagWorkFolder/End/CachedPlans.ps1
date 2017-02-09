$SqlCmd = "
DECLARE @sqlmajorver int,@sqlminorver int, @sqlbuild int


SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);
SELECT @sqlminorver = CONVERT(int, (@@microsoftversion / 0x10000) & 0xff);
SELECT @sqlbuild = CONVERT(int, @@microsoftversion & 0xffff);

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmp_dm_exec_query_stats')) 
DROP TABLE #tmp_dm_exec_query_stats;

IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#tmp_dm_exec_query_stats')) 
CREATE TABLE #tmp_dm_exec_query_stats ([plan_id] [int] NOT NULL IDENTITY(1, 1),
	[sql_handle] [varbinary](64) NOT NULL,
	[statement_start_offset] [int] NOT NULL,
	[statement_end_offset] [int] NOT NULL,
	[plan_generation_num] [bigint] NOT NULL,
	[plan_handle] [varbinary](64) NOT NULL,
	[creation_time] [datetime] NOT NULL,
	[last_execution_time] [datetime] NOT NULL,
	[execution_count] [bigint] NOT NULL,
	[total_worker_time] [bigint] NOT NULL,
	[last_worker_time] [bigint] NOT NULL,
	[min_worker_time] [bigint] NOT NULL,
	[max_worker_time] [bigint] NOT NULL,
	[total_physical_reads] [bigint] NOT NULL,
	[last_physical_reads] [bigint] NOT NULL,
	[min_physical_reads] [bigint] NOT NULL,
	[max_physical_reads] [bigint] NOT NULL,
	[total_logical_writes] [bigint] NOT NULL,
	[last_logical_writes] [bigint] NOT NULL,
	[min_logical_writes] [bigint] NOT NULL,
	[max_logical_writes] [bigint] NOT NULL,
	[total_logical_reads] [bigint] NOT NULL,
	[last_logical_reads] [bigint] NOT NULL,
	[min_logical_reads] [bigint] NOT NULL,
	[max_logical_reads] [bigint] NOT NULL,
	[total_clr_time] [bigint] NOT NULL,
	[last_clr_time] [bigint] NOT NULL,
	[min_clr_time] [bigint] NOT NULL,
	[max_clr_time] [bigint] NOT NULL,
	[total_elapsed_time] [bigint] NOT NULL,
	[last_elapsed_time] [bigint] NOT NULL,
	[min_elapsed_time] [bigint] NOT NULL,
	[max_elapsed_time] [bigint] NOT NULL,
	--2008 only
	[query_hash] [binary](8) NULL,
	[query_plan_hash] [binary](8) NULL,
	--2008R2 only
	[total_rows] bigint NULL,
	[last_rows] bigint NULL,
	[min_rows] bigint NULL,
	[max_rows] bigint NULL)

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#dm_exec_query_stats')) 
DROP TABLE #dm_exec_query_stats;

IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#dm_exec_query_stats')) 
CREATE TABLE #dm_exec_query_stats ([plan_id] [int] NOT NULL IDENTITY(1, 1),
	[sql_handle] [varbinary](64) NOT NULL,
	[statement_start_offset] [int] NOT NULL,
	[statement_end_offset] [int] NOT NULL,
	[plan_generation_num] [bigint] NOT NULL,
	[plan_handle] [varbinary](64) NOT NULL,
	[creation_time] [datetime] NOT NULL,
	[last_execution_time] [datetime] NOT NULL,
	[execution_count] [bigint] NOT NULL,
	[total_worker_time] [bigint] NOT NULL,
	[last_worker_time] [bigint] NOT NULL,
	[min_worker_time] [bigint] NOT NULL,
	[max_worker_time] [bigint] NOT NULL,
	[total_physical_reads] [bigint] NOT NULL,
	[last_physical_reads] [bigint] NOT NULL,
	[min_physical_reads] [bigint] NOT NULL,
	[max_physical_reads] [bigint] NOT NULL,
	[total_logical_writes] [bigint] NOT NULL,
	[last_logical_writes] [bigint] NOT NULL,
	[min_logical_writes] [bigint] NOT NULL,
	[max_logical_writes] [bigint] NOT NULL,
	[total_logical_reads] [bigint] NOT NULL,
	[last_logical_reads] [bigint] NOT NULL,
	[min_logical_reads] [bigint] NOT NULL,
	[max_logical_reads] [bigint] NOT NULL,
	[total_clr_time] [bigint] NOT NULL,
	[last_clr_time] [bigint] NOT NULL,
	[min_clr_time] [bigint] NOT NULL,
	[max_clr_time] [bigint] NOT NULL,
	[total_elapsed_time] [bigint] NOT NULL,
	[last_elapsed_time] [bigint] NOT NULL,
	[min_elapsed_time] [bigint] NOT NULL,
	[max_elapsed_time] [bigint] NOT NULL,
	--2008 only
	[query_hash] [binary](8) NULL,
	[query_plan_hash] [binary](8) NULL,
	--2008R2 only
	[total_rows] bigint NULL,
	[last_rows] bigint NULL,
	[min_rows] bigint NULL,
	[max_rows] bigint NULL,
	--end
	[query_plan] [xml] NULL,
	[text] [nvarchar](MAX) COLLATE database_default NULL,
	[text_filtered] [nvarchar](MAX) COLLATE database_default NULL)

IF @sqlmajorver = 9
BEGIN
	--CPU 
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
	--FROM sys.dm_exec_query_stats qs (NOLOCK) 
	--ORDER BY qs.total_worker_time DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.total_worker_time DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.total_worker_time DESC');
	--IO
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.total_logical_reads DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.total_logical_reads DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.total_logical_reads DESC');
	--Recompiles
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.plan_generation_num DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.plan_generation_num DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.plan_generation_num DESC');
END
ELSE IF @sqlmajorver = 10 AND (@sqlminorver = 0 OR (@sqlminorver = 50 AND @sqlbuild < 2500))
BEGIN
	--CPU 
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.total_worker_time DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.total_worker_time DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.total_worker_time DESC');
	--IO
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.total_logical_reads DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.total_logical_reads DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.total_logical_reads DESC');
	--Recompiles
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.plan_generation_num DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.plan_generation_num DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.plan_generation_num DESC');
END
ELSE IF (@sqlmajorver = 10 AND @sqlminorver = 50 AND @sqlbuild >= 2500) OR @sqlmajorver > 10
BEGIN
	--CPU 
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.total_worker_time DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.total_worker_time DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.total_worker_time DESC');
	--IO
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.total_logical_reads DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.total_logical_reads DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.total_logical_reads DESC');
	--Recompiles
	INSERT INTO #tmp_dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows])
	--EXEC ('SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
	--FROM sys.dm_exec_query_stats qs (NOLOCK)
	--ORDER BY qs.plan_generation_num DESC');
	EXEC (';WITH XMLNAMESPACES (DEFAULT ''http://schemas.microsoft.com/sqlserver/2004/07/showplan''), 
TopSearch AS (SELECT DISTINCT TOP 1000 [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
FROM sys.dm_exec_query_stats qs (NOLOCK)
ORDER BY qs.plan_generation_num DESC),
TopFineSearch AS (SELECT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows],ix.query(''.'') AS StmtSimple
FROM TopSearch ts
OUTER APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
CROSS APPLY qp.query_plan.nodes(''//StmtSimple'') AS p(ix))
SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
FROM TopFineSearch tfs
CROSS APPLY StmtSimple.nodes(''//Object'') AS o(obj)
WHERE obj.value(''@Database'',''sysname'') NOT IN (''[master]'',''[mssqlsystemresource]'')
ORDER BY tfs.plan_generation_num DESC');
END;

-- Remove duplicates before inserting XML
IF @sqlmajorver = 9
BEGIN
	INSERT INTO #dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time])
	SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time]
	FROM #tmp_dm_exec_query_stats;
END
ELSE IF @sqlmajorver = 10 AND (@sqlminorver = 0 OR (@sqlminorver = 50 AND @sqlbuild < 2500))
BEGIN
	INSERT INTO #dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash])
	SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash]
	FROM #tmp_dm_exec_query_stats;
END
ELSE IF (@sqlmajorver = 10 AND @sqlminorver = 50 AND @sqlbuild >= 2500) OR @sqlmajorver > 10
BEGIN
	INSERT INTO #dm_exec_query_stats ([sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows])
	SELECT DISTINCT [sql_handle],[statement_start_offset],[statement_end_offset],[plan_generation_num],[plan_handle],[creation_time],[last_execution_time],[execution_count],[total_worker_time],[last_worker_time],[min_worker_time],[max_worker_time],[total_physical_reads],[last_physical_reads],[min_physical_reads],[max_physical_reads],[total_logical_writes],[last_logical_writes],[min_logical_writes],[max_logical_writes],[total_logical_reads],[last_logical_reads],[min_logical_reads],[max_logical_reads],[total_clr_time],[last_clr_time],[min_clr_time],[max_clr_time],[total_elapsed_time],[last_elapsed_time],[min_elapsed_time],[max_elapsed_time],[query_hash],[query_plan_hash],[total_rows],[last_rows],[min_rows],[max_rows]
	FROM #tmp_dm_exec_query_stats;
END;

UPDATE #dm_exec_query_stats
SET 
	[text] = Convert(nvarchar(max),st.[text])
	,text_filtered = SUBSTRING(st.[text], 
		qs.statement_start_offset/2 +1 ,
		((CASE WHEN qs.statement_end_offset = -1 THEN DATALENGTH(st.[text]) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1 )
FROM #dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st

UPDATE #dm_exec_query_stats
SET query_plan = qp.query_plan
FROM #dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp

-- Delete own queries
DELETE FROM #dm_exec_query_stats
WHERE CAST(query_plan AS NVARCHAR(MAX)) LIKE '%UPDATE #dm_exec_query_stats%';

IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#dm_exec_query_stats')) 
DROP TABLE tempdb.dbo.dm_exec_query_stats;

Select * into tempdb.dbo.dm_exec_query_stats from #dm_exec_query_stats
"

Invoke-Sqlcmd -ServerInstance $instancename -Query $SqlCmd -QueryTimeout 65535

bcp "tempdb.dbo.dm_exec_query_stats" out (Join-Path -Path $DataFolder -ChildPath "CachedPlan.out") -n -T -S $instancename

<#
$SqlCmd = "
;WITH xmlnamespaces (default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
ObjectList as (
Select 
	Op.value('(*/Object/@Database)[1]','varchar(128)') AS [Database]
	,Op.value('(*/Object/@Schema)[1]','varchar(128)') AS [Schema]
	,Op.value('(*/Object/@Table)[1]','varchar(128)') AS [Object]
    From tempdb.dbo.dm_exec_query_stats qs
	cross apply qs.query_plan.nodes('/ShowPlanXML/BatchSequence/Batch//RelOp')  RelOp(op)
)
Select 
	substring([Database],2,len([database])-2) as [Database]
	,substring([Schema],2,len([Schema])-2) as [Schema]
	,substring([Object],2,len([Object])-2) as [Object]
from ObjectList o 
Where [Database] IS NOT NULL 
	and [Schema] <> '[sys]'
	and [Database] <> '[tempdb]'
"
$Tables = Invoke-Sqlcmd -ServerInstance $InstanceName -Query $SqlCmd

$Tables | Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "QueryPlanObjects")

$urns = foreach ($Table in $Tables) { $server.Databases[$Table.Database].Tables| Where-Object {$_.Schema -eq $Table.Schema -and $_.Name -eq $Table.Object} }

# Create a Scripter object and set the required scripting options.
$scripter = New-Object Microsoft.SqlServer.Management.SMO.Scripter ($InstanceName)
$scripter.Options.WithDependencies = $true
$scripter.Options.IncludeIfNotExists = $true
$scripter.Options.Statistics = $true
$scripter.Options.Indexes = $true
$scripter.Options.OptimizerData = $true

# Script table
$scripter.Script($urns) | Out-File (Join-Path -Path $DataFolder -ChildPath "QueryPlanObjectsCreation.sql")
 #>