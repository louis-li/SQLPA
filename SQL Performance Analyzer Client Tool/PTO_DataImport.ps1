[cmdletbinding()]
param (
    [Parameter(Mandatory=$True)]
    $InstanceName = "Localhost",
    [Parameter(Mandatory=$True)]
    $DatabaseName,
    [Parameter(Mandatory=$True)]
    $CollectedDataFolder,
    [Parameter(Mandatory=$True)]
	$CurrentLocation,
    [switch]$ProcessAll = $true,
    [switch]$DropExisting = $false
)

#region function declaration
$AutoStatsByDbScript = {
    param([string]$InstanceName,
    [string]$Database
    ) 
	$Script = "
	select d.Name,c_object_id,i.schemaName,i.objectName,i.indexName, sum(c_duration) as duration
	into xel.auto_stats_by_db
	from xel.auto_stats a
		Inner Join dbo.Databases d on a.c_database_id = d.id
		Left JOin dbo.Indexes i on a.c_object_id = i.objectID  and i.DatabaseName = d.Name
	group by d.Name,c_object_id,i.schemaName,i.objectName,i.indexName
	order by d.Name, duration,i.schemaName,i.objectName,i.indexName desc
	GO"

	Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $Script
}
$LoadXeScript = {
    param([string]$InstanceName,
    [string]$Database,
    [string]$CurrentLocation,
    [string]$DataFolder
    ) 
    function Write-Log($LogMsg)
    {
        if ($CurrentLocation -ne $null)
        {
            $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
        }
    }
    Write-Log "$(Get-Date) - Importing Extended Event"

    $QueryPostExecutionTableScript = "Create Schema xel;
    GO
	CREATE TABLE [xel].[query_post_execution_showplan](
		[e_Imported_File_Id] [bigint] NULL,
		[e_Time_Of_Event] [smalldatetime] NULL,
		[e_Time_Of_Event_utc] [datetime2](7) NULL,
		[e_Time_Of_Event_local] [datetime2](7) NULL,
		[c_source_database_id] [bigint] NULL,
		[c_object_type] [nvarchar](max) NULL,
		[c_object_id] [int] NULL,
		[c_nest_level] [int] NULL,
		[c_cpu_time] [decimal](38, 0) NULL,
		[c_duration] [decimal](38, 0) NULL,
		[c_estimated_rows] [int] NULL,
		[c_estimated_cost] [int] NULL,
		[c_serial_ideal_memory_kb] [decimal](38, 0) NULL,
		[c_requested_memory_kb] [decimal](38, 0) NULL,
		[c_used_memory_kb] [decimal](38, 0) NULL,
		[c_ideal_memory_kb] [decimal](38, 0) NULL,
		[c_granted_memory_kb] [decimal](38, 0) NULL,
		[c_dop] [bigint] NULL,
		[c_object_name] [nvarchar](max) NULL,
		[c_showplan_xml] varchar(max) NULL,
		[c_database_name] [nvarchar](max) NULL,
		[a_attach_activity_id] [nvarchar](max) NULL,
		[a_attach_activity_id_xfer] [nvarchar](max) NULL,
		[a_callstack] [varbinary](max) NULL,
		[a_callstack_debugcmd] [nvarchar](max) NULL,
		[a_session_id] [int] NULL,
		[a_sql_text] [nvarchar](max) NULL,
		[a_query_hash] [decimal](38, 0) NULL,
		[a_query_hash_bin] [varbinary](max) NULL
	)
	GO
	CREATE TABLE [xel].[wait_info](
	[e_Imported_File_Id] [bigint] NULL,
	[e_Time_Of_Event] [smalldatetime] NULL,
	[e_Time_Of_Event_utc] [datetime2](7) NULL,
	[e_Time_Of_Event_local] [datetime2](7) NULL,
	[c_wait_type] [nvarchar](max) NULL,
	[c_opcode] [nvarchar](max) NULL,
	[c_duration] [decimal](38, 0) NULL,
	[c_signal_duration] [decimal](38, 0) NULL,
	[a_callstack] [varbinary](max) NULL,
	[a_callstack_debugcmd] [nvarchar](max) NULL,
	[a_attach_activity_id] [nvarchar](max) NULL,
	[a_attach_activity_id_xfer] [nvarchar](max) NULL,
	[a_session_id] [int] NULL,
	[a_sql_text] [nvarchar](max) NULL,
	[a_query_hash] [decimal](38, 0) NULL,
	[a_query_hash_bin] [varbinary](max) NULL
	)
	GO
	CREATE TABLE [xel].[wait_info_external](
	[e_Imported_File_Id] [bigint] NULL,
	[e_Time_Of_Event] [smalldatetime] NULL,
	[e_Time_Of_Event_utc] [datetime2](7) NULL,
	[e_Time_Of_Event_local] [datetime2](7) NULL,
	[c_wait_type] [nvarchar](max) NULL,
	[c_opcode] [nvarchar](max) NULL,
	[c_duration] [decimal](38, 0) NULL,
	[a_callstack] [varbinary](max) NULL,
	[a_callstack_debugcmd] [nvarchar](max) NULL,
	[a_attach_activity_id] [nvarchar](max) NULL,
	[a_attach_activity_id_xfer] [nvarchar](max) NULL,
	[a_session_id] [int] NULL,
	[a_sql_text] [nvarchar](max) NULL,
	[a_query_hash] [decimal](38, 0) NULL,
	[a_query_hash_bin] [varbinary](max) NULL
	)
	GO
	CREATE TABLE [xel].[sql_statement_completed](
	[e_Imported_File_Id] [bigint] NULL,
	[e_Time_Of_Event] [smalldatetime] NULL,
	[e_Time_Of_Event_utc] [datetime2](7) NULL,
	[e_Time_Of_Event_local] [datetime2](7) NULL,
	[c_duration] [bigint] NULL,
	[c_cpu_time] [decimal](38, 0) NULL,
	[c_physical_reads] [decimal](38, 0) NULL,
	[c_logical_reads] [decimal](38, 0) NULL,
	[c_writes] [decimal](38, 0) NULL,
	[c_row_count] [decimal](38, 0) NULL,
	[c_last_row_count] [decimal](38, 0) NULL,
	[c_line_number] [int] NULL,
	[c_offset] [int] NULL,
	[c_offset_end] [int] NULL,
	[c_statement] [nvarchar](max) NULL,
	[c_parameterized_plan_handle] [varbinary](max) NULL,
	[a_callstack] [varbinary](max) NULL,
	[a_callstack_debugcmd] [nvarchar](max) NULL,
	[a_attach_activity_id] [nvarchar](max) NULL,
	[a_attach_activity_id_xfer] [nvarchar](max) NULL,
	[a_session_id] [int] NULL,
	[a_sql_text] [nvarchar](max) NULL,
	[a_query_hash] [decimal](38, 0) NULL,
	[a_query_hash_bin] [varbinary](max) NULL
	)
	GO
	CREATE TABLE [xel].[sp_statement_completed](
	[e_Imported_File_Id] [bigint] NULL,
	[e_Time_Of_Event] [smalldatetime] NULL,
	[e_Time_Of_Event_utc] [datetime2](7) NULL,
	[e_Time_Of_Event_local] [datetime2](7) NULL,
	[c_source_database_id] [bigint] NULL,
	[c_object_id] [int] NULL,
	[c_object_type] [nvarchar](max) NULL,
	[c_duration] [bigint] NULL,
	[c_cpu_time] [decimal](38, 0) NULL,
	[c_physical_reads] [decimal](38, 0) NULL,
	[c_logical_reads] [decimal](38, 0) NULL,
	[c_writes] [decimal](38, 0) NULL,
	[c_row_count] [decimal](38, 0) NULL,
	[c_last_row_count] [decimal](38, 0) NULL,
	[c_nest_level] [int] NULL,
	[c_line_number] [int] NULL,
	[c_offset] [int] NULL,
	[c_offset_end] [int] NULL,
	[c_object_name] [nvarchar](max) NULL,
	[c_statement] [nvarchar](max) NULL,
	[a_callstack] [varbinary](max) NULL,
	[a_callstack_debugcmd] [nvarchar](max) NULL,
	[a_attach_activity_id] [nvarchar](max) NULL,
	[a_attach_activity_id_xfer] [nvarchar](max) NULL,
	[a_session_id] [int] NULL,
	[a_sql_text] [nvarchar](max) NULL,
	[a_query_hash] [decimal](38, 0) NULL,
	[a_query_hash_bin] [varbinary](max) NULL
	)
	GO
	CREATE TABLE [xel].[missing_column_statistics](
	[e_Imported_File_Id] [bigint] NULL,
	[e_Time_Of_Event] [smalldatetime] NULL,
	[e_Time_Of_Event_utc] [datetime2](7) NULL,
	[e_Time_Of_Event_local] [datetime2](7) NULL,
	[c_column_list] [nvarchar](max) NULL,
	[a_callstack] [varbinary](max) NULL,
	[a_callstack_debugcmd] [nvarchar](max) NULL,
	[a_attach_activity_id] [nvarchar](max) NULL,
	[a_attach_activity_id_xfer] [nvarchar](max) NULL,
	[a_session_id] [int] NULL,
	[a_sql_text] [nvarchar](max) NULL,
	[a_query_hash] [decimal](38, 0) NULL,
	[a_query_hash_bin] [varbinary](max) NULL
	)
	GO
	CREATE TABLE [xel].[unmatched_filtered_indexes](
	[e_Imported_File_Id] [bigint] NULL,
	[e_Time_Of_Event] [smalldatetime] NULL,
	[e_Time_Of_Event_utc] [datetime2](7) NULL,
	[e_Time_Of_Event_local] [datetime2](7) NULL,
	[c_compile_time] [bit] NULL,
	[c_unmatched_database_name] [nvarchar](max) NULL,
	[c_unmatched_schema_name] [nvarchar](max) NULL,
	[c_unmatched_table_name] [nvarchar](max) NULL,
	[c_unmatched_index_name] [nvarchar](max) NULL,
	[a_callstack] [varbinary](max) NULL,
	[a_callstack_debugcmd] [nvarchar](max) NULL,
	[a_attach_activity_id] [nvarchar](max) NULL,
	[a_attach_activity_id_xfer] [nvarchar](max) NULL,
	[a_session_id] [int] NULL,
	[a_sql_text] [nvarchar](max) NULL,
	[a_query_hash] [decimal](38, 0) NULL,
	[a_query_hash_bin] [varbinary](max) NULL
	)"	

    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $QueryPostExecutionTableScript
    $XeLoader = Join-Path -Path $CurrentLocation -ChildPath  "Lib\xEvent\XELoader.exe"
    $msg = & $XeLoader -D"$DataFolder" -S"$InstanceName" -d"$database" -IRowStore
	#Write-Log "$(Get-Date) - Result: $msg"
    #Transform data after load
    $xEventScript = "
		CREATE TABLE [xel].[plan_affecting_convert](
			[e_Imported_File_Id] [bigint] NULL,
			[e_Time_Of_Event] [smalldatetime] NULL,
			[e_Time_Of_Event_utc] [datetime2](7) NULL,
			[e_Time_Of_Event_local] [datetime2](7) NULL,
			[c_compile_time] [bit] NULL,
			[c_convert_issue] [nvarchar](max) NULL,
			[c_expression] [nvarchar](max) NULL,
			[a_attach_activity_id] [nvarchar](max) NULL,
			[a_attach_activity_id_xfer] [nvarchar](max) NULL,
			[a_sql_text] [nvarchar](max) NULL,
			[a_query_hash] [decimal](38, 0) NULL,
			[a_query_hash_bin] [varbinary](max) NULL
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
		GO
		CREATE TABLE [xel].[optimizer_timeout](
			[e_Imported_File_Id] [bigint] NULL,
			[e_Time_Of_Event] [smalldatetime] NULL,
			[e_Time_Of_Event_utc] [datetime2](7) NULL,
			[e_Time_Of_Event_local] [datetime2](7) NULL,
			[c_timeout_type] [nvarchar](max) NULL,
			[c_optimizer_timeout_task_number] [decimal](38, 0) NULL,
			[a_attach_activity_id] [nvarchar](max) NULL,
			[a_attach_activity_id_xfer] [nvarchar](max) NULL,
			[a_sql_text] [nvarchar](max) NULL,
			[a_query_hash] [decimal](38, 0) NULL,
			[a_query_hash_bin] [varbinary](max) NULL
		) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
		GO
        IF Exists (SELECT * FROM sys.tables WHERE Object_Name(OBject_id) = 'expensive_query_raw' AND SCHEMA_NAME(Schema_id) ='xel')
	        DROP TABLE [xel].[expensive_query_raw]

        CREATE TABLE [xel].[expensive_query_raw](
	        [cpu_time] [decimal](19,4) NULL,
		    [duration] [decimal](19,4) NULL,
		    [physical_reads] [bigint] NULL,
		    [logical_reads] [bigint] NULL,
		    [writes] [bigint] NULL,
		    [row_count] [bigint] NULL,
	        [executions] [int] NULL,
	        [sql_text] [nvarchar](max) NULL,
	        [query_hash] [varbinary](40) NULL,
	        [query_id] [bigint]  identity
        ) 
        GO

        ;with cte as (
        select c_cpu_time as cpu_time,a_query_hash as query_hash,c_batch_text as sql_text
		    ,c_duration,c_physical_reads,c_logical_reads, c_writes, c_row_count
		    ,a_attach_activity_id as attach_activity_id
        from xel.sql_batch_completed
        where c_cpu_time > 0
        union all
        select c_cpu_time, a_query_hash,c_statement
		    ,c_duration,c_physical_reads,c_logical_reads, c_writes, c_row_count
		    , a_attach_activity_id
        from xel.rpc_completed
        where c_cpu_time > 0
        ) 
        INSERT INTO xel.expensive_query_raw
        Select sum(cpu_time) as cpu_time,sum(c_duration) as duration, sum(c_physical_reads) as physical_reads
	    ,sum(c_logical_reads) as logical_reads,sum(c_writes) as writes,sum(c_row_count) as row_count
	    ,count(*) as executions,sql_text,query_hash
        from cte
        group by sql_text,query_hash
        order by sum(cpu_time) desc
        GO
		Create table xel.allActivities
		(
			[Event] varchar(50),
			[ActivityID]  char(36),
			e_Time_Of_Event_Local datetime2(7),
			duration bigint
		);
		Create clustered columnstore index cci_allActivities on xel.allActivities
		GO 
		with cte as 
		(
			Select 
					'plan_affecting_convert' as event
					, left(a_attach_activity_id, 36) as ActivityID
					, e_Time_Of_Event_local
					, 0 as duration
			From  
					[xel].[plan_affecting_convert] p 
			UNION ALL
			Select 
					'page_split'
					, left(a_attach_activity_id, 36) as ActivityID
					, e_Time_Of_Event_local
					, 0 as duration
			From  
					[xel].transaction_log p 
			UNION ALL
			Select 
					'rpc_completed'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration as duration
			From  
					[xel].rpc_completed p UNION ALL
			Select 
					'auto_stats'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration as duration
			From  
					[xel].auto_stats p 
			UNION ALL
			Select 
					'blocked_process_report'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration as duration
			From  
					[xel].blocked_process_report p 
			UNION ALL
			Select 
					'hash_warning'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0 as duration
			From  
					[xel].hash_warning p 
			UNION ALL
			Select 
					'missing_join_predicate'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0 as duration
			From  
					[xel].missing_join_predicate p 
			UNION ALL
			Select
					'optimizer_timeout'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0 as duration
			From  
					[xel].optimizer_timeout p 
			UNION ALL
			Select 
					'query_post_execution_showplan'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration as duration
			From  
					[xel].query_post_execution_showplan p 
			UNION ALL
			Select 
					'sort_warning'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0 as duration
			From 
					[xel].sort_warning p 
			UNION ALL
			Select 
					'sql_batch_completed'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration as duration
			From 
					[xel].sql_batch_completed p 
			UNION ALL
			Select 
					'xml_deadlock_report'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0 as duration
			From  
					[xel].xml_deadlock_report p 
			UNION ALL
			Select 
					'missing_column_statistics'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0 as duration
			From  
					xel.missing_column_statistics
			UNION ALL
			Select 
					'database_file_size_change'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration
			From  
					xel.database_file_size_change
			UNION ALL
			Select 
					'sql_statement_completed'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration
			From  
					xel.sql_statement_completed
			UNION ALL
			Select 
					'sp_statement_completed'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration
			From  
					xel.sp_statement_completed
			UNION ALL
			Select 
					'unmatched_filtered_indexes'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_compile_time
			From  
					xel.unmatched_filtered_indexes
			UNION ALL
			Select 
					'databases_log_growth'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0
			From  
					xel.databases_log_growth
			UNION ALL
			Select 
					'latch_suspend_warning'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0
			From  
					xel.latch_suspend_warning
			UNION ALL
			Select 
					'bitmap_disabled_warning'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0
			From  
					xel.bitmap_disabled_warning
			UNION ALL
			Select 
					'execution_warning'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,c_duration
			From  
					xel.execution_warning
			UNION ALL
			Select 
					'batch_hash_table_build_bailout'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0
			From  
					xel.batch_hash_table_build_bailout
			UNION ALL
			Select 
					'exchange_spill'
					, left(a_attach_activity_id, 36) as ActivityID
					,e_Time_Of_Event_local
					,0
			From  
					xel.exchange_spill
			UNION ALL
			Select 
				'wait_info'
				, left(a_attach_activity_id, 36) as ActivityID
				,e_Time_Of_Event_local
				,c_duration
			From  
				xel.wait_info p 
			UNION ALL
			Select 
				'wait_info_external'
				, left(a_attach_activity_id, 36) as ActivityID
				,e_Time_Of_Event_local
				,c_duration
			From  
				xel.wait_info_external p 
			)
		Insert into xel.allActivities
		Select * from cte 
		GO"
    $msg = Sqlcmd -S $InstanceName -d $database -Q $xEventScript  -I
    Write-Log "$(Get-Date) - Generate xel.expensive_query_raw Result: $msg"
    }

$CalculateStartTime = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
function Write-Log($LogMsg)
{
    if ($CurrentLocation -ne $null)
    {
        $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
    }
}
	$sql = "With cte as (
		select e_Time_Of_Event_local as [Completed Time]
			, c_batch_text as [Sql Text]
			, c_cpu_time as [CPU Time]
			, c_duration as [Duration]
			, c_physical_reads as [Physical Reads]
			, c_logical_reads as [Logical Reads]
			, c_writes as [Writes]
			, c_row_count as [Row Count]
			, a_attach_activity_id
		from xel.sql_batch_completed
		union all
		select e_Time_Of_Event_local, c_statement,c_cpu_time
			,c_duration,c_physical_reads,c_logical_reads, c_writes, c_row_count
			,a_attach_activity_id
		from xel.rpc_completed
	)
	select min(e.e_Time_Of_Event_local) as [Start Time],c.[Completed Time], c.[Sql Text],c.[CPU Time], c.[Duration],c.[Physical Reads],c.[Logical Reads], c.[Writes], c.[Row Count], c.a_attach_activity_id
	Into xel.QueryHist
	from cte c inner  join xel.allActivities e on left(c.a_attach_activity_id,36) = e.ActivityID
	group by c.[Completed Time], c.[Sql Text],c.[CPU Time], c.[Duration],c.[Physical Reads],c.[Logical Reads], c.[Writes], c.[Row Count], c.a_attach_activity_id
	order by c.[Completed Time]"
    $msg = Sqlcmd -S $InstanceName -d $database -Q $sql  -I
    Write-Log "$(Get-Date) - Calculate start time of all queries. Result: $msg"

}

$GenerateFixScript = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
function Write-Log($LogMsg)
{
    if ($CurrentLocation -ne $null)
    {
        $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
    }
}
#Create Fix folder
Write-Log "$(Get-Date) - Generating Fix Scripts"

$FixScriptFolder = Join-Path $DataFolder -ChildPath "FixScripts"
if (!(Test-Path $FixScriptFolder))
{
    New-Item $FixScriptFolder -type directory | Out-Null

}

#Drop disabled indexes
try {
    Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database `
        -Query "select * from dbo.indexes where is_disabled = 1" -ErrorAction Stop |
        foreach { "Drop Index [$($_.IndexName)] on [$($_.DatabaseName)].[$($_.SchemaName)].[$($_.objectName)];`n GO" } |
            Out-File (Join-Path $FixScriptFolder -ChildPath "DropDisabledIndexes.sql")
}
catch {
    Write-Log "Generate DropDisabledIndex.sql fail."
	Write-Log $_
}
#Drop duplicate indexes
try {
$sql =";with cte as (
select databaseID,objectID, max(indexid) as max_indexid ,AllColsOrdered
from dbo.vwDupIndex
group by databaseID,objectID, AllColsOrdered
)
select case when cte.max_indexid = i.indexid then 1 else 0 end as should_drop
	, databasename
	,schemaName
	,ObjectName
	,IndexName 
	,i.AllColsOrdered
from cte inner join vwDupIndex i 
	on cte.databaseID = i.databaseID and cte.objectID = i.objectID
	and cte.AllColsOrdered = i.AllColsOrdered
order by i.databaseid, i.SCHEMAName,i.objectname,i.AllColsOrdered, i.indexid
"
Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sql -ErrorAction Stop |`
    foreach { `
		if ($_.should_drop -eq 1) {"--Drop Index [$($_.IndexName)] on [$($_.DatabaseName)].[$($_.SchemaName)].[$($_.objectName)];`nGO" }
		else {"Drop Index [$($_.IndexName)] on [$($_.DatabaseName)].[$($_.SchemaName)].[$($_.objectName)];`nGO"} } |`
        Out-File (Join-Path $FixScriptFolder -ChildPath "DropDuplicateIndexes.sql")
}
catch {
    Write-Log "Generate DropDuplicateIndexes.sql fail."
	Write-Log $_
}

#Index rebuild
try {
Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database -ErrorAction Stop `
    -Query "With cte as (Select distinct d.database_name, i.schema_name,i.Object_name, i.index_name from dbo.IndexFragmentation i inner join dbo.DatabaseFiles d on i.database_id = d.database_id ) Select 'ALTER INDEX ' + CASE WHEN index_name ='' THEN 'ALL' ELSE '[' + index_name +']' END + ' ON [' + database_name + '].[' + schema_name + '].[' +object_name +'] REBUILD' as sql_text  from cte Order By database_name, schema_name,object_name,index_name;`nGO" |
    foreach { "$($_.sql_text);`nGO" } |
        Out-File (Join-Path $FixScriptFolder -ChildPath "IndexRebuild.sql")
}
catch {
    Write-Log "Generate IndexRebuild.sql fail."
	Write-Log $_
}
#Update Statistics
try {
Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database -ErrorAction Stop -Query "select distinct DatabaseName, schemaName, tableName from dbo.Stats" |
    foreach { "Update Statistics [$($_.DatabaseName)].[$($_.schemaName)].[$($_.tablename)] WITH FULLSCAN;`nGO" } |
        Out-File (Join-Path $FixScriptFolder -ChildPath "UpdateStatistics.sql")
}
catch {
    Write-Log "Generate UpdateStatistics.sql fail. Could be caused by no data."
	Write-Log $_
}

try {
Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database -ErrorAction Stop -Query "select distinct DatabaseName, schemaName, tableName from dbo.Stats" |
    foreach { "Update Statistics [$($_.DatabaseName)].[$($_.schemaName)].[$($_.tablename)] ;`nGO" } |
        Out-File (Join-Path $FixScriptFolder -ChildPath "UpdateStatistics_light.sql")
}
catch {
    Write-Log "Generate UpdateStatistics.sql fail. Could be caused by no data."
	Write-Log $_
}
#Re-able foreign key constraints
try {
Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database -ErrorAction Stop -Query "select * from dbo.UntrustedConstraints" |
    foreach { "ALTER TABLE [$($_.database_name)].[$($_.schema_name)].[$($_.table_name)] WITH CHECK CHECK CONSTRAINT [$($_.constraint_name)];`nGO" } |
        Out-File (Join-Path $FixScriptFolder -ChildPath "EnableUntrustedFKs.sql")
}
catch {
    Write-Log "Generate EnableUntrustedFKs.sql fail.Could be caused by no data."
	Write-Log $_
}

#Create Index
$Sql = "select left(replace(replace(replace('Create Index nci_' 
    + [table] + '_'+EqualityColumns+ InequalityColumns + '_' 
    + IncludeColumns,'[',''),']',''),',','_'),128) +' ON ' 
    + [database] + '.' + [schema] + '.' + [Table] +' (' 
    +EqualityColumns+InequalityColumns+')' 
    +IIF(IncludeColumns='','',' Include ('+IncludeColumns+')') 
    +' -- Plan #:'+ cast(QueryPlanName as varchar(10)) + ' Impact:' + cast(Impact as varchar(10)) as Statement
from qp.MissingIndexes
order by [database], [schema], [table]"
(Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $Sql).Statement | Out-File (Join-Path $FixScriptFolder -ChildPath "CreateIndex.sql")

#Get Indexes from Allocation Units
$Sql = "select d.Name,c_alloc_unit_id, count(*) as occurrence
from 
    xel.transaction_log l 
	   Inner Join dbo.Databases d on l.c_database_id = d.id
group by d.Name, c_alloc_unit_id
order by d.Name,occurrence desc"
$data = Invoke-sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $Sql

$alloc_unit = $data | select Name -Unique | `
    SELECT Name, @{Name="AllocUnit";Expression={($data | Where-Object Name -eq $_.Name).c_alloc_unit_id -join ','}}

$alloc_unit | `
ForEach-Object {"USE $($_.Name)`nSELECT schema_name(o.schema_id), o.name AS table_name,p.index_id, i.name AS index_name , au.type_desc AS allocation_type, au.data_pages, partition_number
FROM sys.allocation_units AS au
    JOIN sys.partitions AS p ON au.container_id = p.partition_id
    JOIN sys.objects AS o ON p.object_id = o.object_id
    JOIN sys.indexes AS i ON p.index_id = i.index_id AND i.object_id = p.object_id
WHERE au.allocation_unit_id in ($($_.AllocUnit));`nGO`n"} | Out-File (Join-Path $FixScriptFolder -ChildPath "ListIndexesFromAllocUnit.sql")

Write-Log "$(Get-Date) - Generating Fix Scripts Completed."
}

$LoadTraceScript = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
    function Write-Log($LogMsg)
    {
        if ($CurrentLocation -ne $null)
        {
            $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
        }
    }
	Write-Log "$(Get-Date) - Loading Default trace"

    $DataTable = "DefaultTrace"

    $DefaultTraceFiles = Join-Path -Path $DataFolder -ChildPath "*.trc"

    $CreateSqlScript = "CREATE TABLE [dbo].[DefaultTrace](
	[TextData] varchar(max) NULL,
	[BinaryData] varbinary(max) NULL,
	[DatabaseID] [int] NULL,
	[TransactionID] [bigint] NULL,
	[LineNumber] [int] NULL,
	[NTUserName] [nvarchar](256) NULL,
	[NTDomainName] [nvarchar](256) NULL,
	[HostName] [nvarchar](256) NULL,
	[ClientProcessID] [int] NULL,
	[ApplicationName] [nvarchar](256) NULL,
	[LoginName] [nvarchar](256) NULL,
	[SPID] [int] NULL,
	[Duration] [bigint] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[CPU] [int] NULL,
	[Permissions] [bigint] NULL,
	[Severity] [int] NULL,
	[EventSubClass] [int] NULL,
	[ObjectID] [int] NULL,
	[Success] [int] NULL,
	[IndexID] [int] NULL,
	[IntegerData] [int] NULL,
	[ServerName] [nvarchar](256) NULL,
	[EventClass] [int] NULL,
	[ObjectType] [int] NULL,
	[NestLevel] [int] NULL,
	[State] [int] NULL,
	[Error] [int] NULL,
	[Mode] [int] NULL,
	[Handle] [int] NULL,
	[ObjectName] [nvarchar](256) NULL,
	[DatabaseName] [nvarchar](256) NULL,
	[FileName] [nvarchar](256) NULL,
	[OwnerName] [nvarchar](256) NULL,
	[RoleName] [nvarchar](256) NULL,
	[TargetUserName] [nvarchar](256) NULL,
	[DBUserName] [nvarchar](256) NULL,
	[LoginSid] [image] NULL,
	[TargetLoginName] [nvarchar](256) NULL,
	[TargetLoginSid] [image] NULL,
	[ColumnPermissions] [int] NULL,
	[LinkedServerName] [nvarchar](256) NULL,
	[ProviderName] [nvarchar](256) NULL,
	[MethodName] [nvarchar](256) NULL,
	[RowCounts] [bigint] NULL,
	[RequestID] [int] NULL,
	[XactSequence] [bigint] NULL,
	[EventSequence] [bigint] NULL,
	[BigintData1] [bigint] NULL,
	[BigintData2] [bigint] NULL,
	[GUID] [uniqueidentifier] NULL,
	[IntegerData2] [int] NULL,
	[ObjectID2] [bigint] NULL,
	[Type] [int] NULL,
	[OwnerID] [int] NULL,
	[ParentName] [nvarchar](256) NULL,
	[IsSystem] [int] NULL,
	[Offset] [int] NULL,
	[SourceDatabaseID] [int] NULL,
	[SqlHandle] [image] NULL,
	[SessionLoginName] [nvarchar](256) NULL,
	[PlanHandle] [image] NULL,
	[GroupID] [int] NULL
    )"

    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $CreateSqlScript -QueryTimeout 0
    Foreach ($DefaultTraceFile in (Get-ChildItem $DefaultTraceFiles -Recurse))
    {
        $QueryString = "Insert Into dbo.$DataTable Select * FROM fn_trace_gettable('$DefaultTraceFile',1)"
        $msg = Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $QueryString -QueryTimeout 0
		Write-Log "$(Get-Date) - Load Default Trace Result: $msg"

    }
}

$LoadErrorLogScript = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
	function Get-SqlType 
	{ 
		param([string]$TypeName) 
 
		switch ($TypeName)  
		{ 
			'Boolean' {[Data.SqlDbType]::Bit} 
			'Byte[]' {[Data.SqlDbType]::VarChar} 
			'Byte'  {[Data.SQLDbType]::VarChar} 
			'Datetime'  {[Data.SQLDbType]::DateTime} 
			'Decimal' {[Data.SqlDbType]::Decimal} 
			'Double' {[Data.SqlDbType]::Float} 
			'Guid' {[Data.SqlDbType]::UniqueIdentifier} 
			'Int16'  {[Data.SQLDbType]::SmallInt} 
			'Int32'  {[Data.SQLDbType]::Int} 
			'Int64' {[Data.SqlDbType]::BigInt} 
			'UInt16'  {[Data.SQLDbType]::SmallInt} 
			'UInt32'  {[Data.SQLDbType]::Int} 
			'UInt64' {[Data.SqlDbType]::BigInt} 
			'Single' {[Data.SqlDbType]::Decimal}
			default {[Data.SqlDbType]::VarChar} 
		} 
     
	} #Get-SqlType

	function Get-Type
	{
		param($type)

	$types = @(
	'System.Boolean',
	#'System.Byte[]',
	#'System.Byte',
	'System.Char',
	'System.Datetime',
	'System.Decimal',
	'System.Double',
	'System.Guid',
	'System.Int16',
	'System.Int32',
	'System.Int64',
	'System.Single',
	'System.UInt16',
	'System.UInt32',
	'System.UInt64')

		if ( $types -contains $type ) {
			Write-Output "$type"
		}
		else {
			Write-Output 'System.String'
        
		}
	} #Get-Type

	function Create-DataTable 
	{ 
 
		[CmdletBinding()] 
		param( 
		[Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
		[Parameter(Position=1, Mandatory=$true)] [string]$Database, 
		[Parameter(Position=2, Mandatory=$false)] [string]$Schema = 'dbo', 
		[Parameter(Position=3, Mandatory=$true)] [String]$TableName, 
		[Parameter(Position=4, Mandatory=$true)] [System.Data.DataTable]$DataTable, 
		[Parameter(Position=5, Mandatory=$false)] [string]$Username, 
		[Parameter(Position=6, Mandatory=$false)] [string]$Password, 
		[ValidateRange(0,8000)] 
		[Parameter(Position=7, Mandatory=$false)] [Int32]$MaxLength=1000,
		[Parameter(Position=8, Mandatory=$false)] [switch]$AsScript
		) 
 
	 try {
		if($Username) 
		{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $ServerInstance,$Username,$Password } 
		else 
		{ $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $ServerInstance } 
     
		$con.Connect() 
 
		$server = new-object ("Microsoft.SqlServer.Management.Smo.Server") $con 
		$db = $server.Databases[$Database] 
		$table = new-object ("Microsoft.SqlServer.Management.Smo.Table") $db, $TableName 
		$Table.schema = $Schema

		$SchemaExists = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "Select 1 where exists(select * from $Database.sys.schemas where name ='$Schema')"

		#Create new table is it doesn't exist
		if ($SchemaExists -eq $null)
		{
			Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Query "Create Schema $Schema"
		}
 
		foreach ($column in $DataTable.Columns) 
		{ 
			$sqlDbType = [Microsoft.SqlServer.Management.Smo.SqlDataType]"$(Get-SqlType $column.DataType.Name)" 
			if ($sqlDbType -eq 'VarBinary' -or $sqlDbType -eq 'VarChar') 
			{ 
				if ($MaxLength -gt 0) 
				{$dataType = new-object ("Microsoft.SqlServer.Management.Smo.DataType") $sqlDbType, $MaxLength}
				else
				{ $sqlDbType  = [Microsoft.SqlServer.Management.Smo.SqlDataType]"$(Get-SqlType $column.DataType.Name)Max"
				  $dataType = new-object ("Microsoft.SqlServer.Management.Smo.DataType") $sqlDbType
				}
			} 
			else 
			{ $dataType = new-object ("Microsoft.SqlServer.Management.Smo.DataType") $sqlDbType } 
			$col = new-object ("Microsoft.SqlServer.Management.Smo.Column") $table, $column.ColumnName, $dataType 
			$col.Nullable = $column.AllowDBNull 
			$table.Columns.Add($col) 
		} 
 
		if ($AsScript) {
			$table.Script()
		}
		else {
			$table.Create()
		}

	}
	catch {
		$message = $_.Exception.GetBaseException().Message
		Write-Log $message
	}
  
	} #Create-DataTable

	function ConvertTo-Table
	{
		[CmdletBinding()]
		param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject,
			[switch]$AllAsString
		)

		Begin
		{
			$dt = new-object Data.datatable  
			$First = $true 
		}
		Process
		{
			foreach ($object in $InputObject)
			{
				$DR = $DT.NewRow()  
				foreach($property in $object.PsObject.get_properties())
				{  
					if ($first)
					{  
						$Col =  new-object Data.DataColumn  
						$Col.ColumnName = $property.Name.ToString()  
						if ($property.value)
						{
							if ($property.value -isnot [System.DBNull]) {
								if ($AllAsString) {
									$Col.DataType = [System.Type]::GetType("System.String")
								} else {
									$Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)")
								}
							 }
						}
						$DT.Columns.Add($Col)
					}  
					if ($property.Gettype().IsArray) {
						$DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1
					}  
				   else {
						if (($property.value -ne $null) -and ($property.value.Gettype().IsArray))
						{
							try
							{
								$stringarray = $false;
								foreach ($v in $property.value) {
									if ($v -eq $null -or $v.gettype().Name -eq "String" -or $v.gettype().Name -eq "XmlElement") 
										{$stringarray = $true}
								}

								if ($stringarray)
								{
									foreach ($c in $property.Value) 
									{ 
										if ($c -ne $null)
										{$string += $c.ToString() + ","}
									}
								} else {
									$string = "0x"
									foreach ($c in $property.Value) { $string += [Convert]::ToString($c,16).ToUpper().PadLeft(2,"0")}
								}
								$DR.Item($property.Name) = $string
							}
							catch {
								Write-Log $property
								Write-Log $_
							}
						} else {
							$DR.Item($property.Name) = $property.value
						}
					}
				}  
				$DT.Rows.Add($DR)  
				$First = $false
			}
		} 
     
		End
		{
			@(,($dt))
		}

	} #ConvertTo-Table

	function Upload-Data
	{
		[CmdletBinding()]
		param(
		[Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance,
		[Parameter(Position=1, Mandatory=$true)] [string]$Database,
		[Parameter(Position=2, Mandatory=$true)] [string]$TableName,
		[Parameter(Position=3, Mandatory=$true)] $Data,
		[Parameter(Position=4, Mandatory=$false)] [string]$Username,
		[Parameter(Position=5, Mandatory=$false)] [string]$Password,
		[Parameter(Position=6, Mandatory=$false)] [Int32]$BatchSize=50000,
		[Parameter(Position=7, Mandatory=$false)] [Int32]$QueryTimeout=0,
		[Parameter(Position=8, Mandatory=$false)] [Int32]$ConnectionTimeout=15
		)
    
		$conn=new-object System.Data.SqlClient.SQLConnection

		if ($Username)
		{ $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout }
		else
		{ $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout }

		$conn.ConnectionString=$ConnectionString

		try
		{
			$conn.Open()
			$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
			$bulkCopy.DestinationTableName = $tableName
			$bulkCopy.BatchSize = $BatchSize
			$bulkCopy.BulkCopyTimeout = $QueryTimeOut
			$bulkCopy.WriteToServer($Data)
			$conn.Close()
		}
		catch
		{
			$ex = $_.Exception
			Write-Error "$ex.Message"
			Write-Log $_
			continue
		}

	} #Upload-Data

    function Write-Log($LogMsg)
    {
        if ($CurrentLocation -ne $null)
        {
            $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
        }
    }
    Write-Log "$(Get-Date) - Loading Error Logs"
	Import-Module SQLPS
    $DataTable = "ErrorLog"

    $ErrorLogFiles = Join-Path -Path $DataFolder -ChildPath "ERRORLOG*"
    $Errors = Foreach ($ErrorLogFile in (Get-ChildItem $ErrorLogFiles -Recurse))
    {
        (Get-Content $ErrorLogFile -ReadCount 10000).Split([Environment]::NewLine)  | 
            Where-Object {
                $_ -match 'SQL Server has encountered .+longer than 15 seconds.+' -or `
                $_ -match 'A significant part of sql server process memory has been paged out.+' -or `
                $_ -match 'Deadlock encountered' -or `
                $_ -match 'Error: .+'
             } |
             Select @{Name="Filename";Expression = {$ErrorLogFile.BaseName + $ErrorLogFile.Extension}},
                @{Name='LogDate'; Expression = {$_.Substring(0,22)}},
                @{Name='ProcessInfo'; Expression = {$_.Substring(22,11)}},
                @{Name='Text'; Expression = {$_.Substring(33,$_.length-33)}}
    }

    if ($Errors -ne $null)
    {

        $ErrorDataTable = ConvertTo-Table -InputObject $Errors
        Create-DataTable -ServerInstance $InstanceName -Database $Database -TableName $DataTable -DataTable $ErrorDataTable
        Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $DataTable -Data $ErrorDataTable
    }

}

$LoadPalTemplateScript = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
    function Write-Log($LogMsg)
    {
        if ($CurrentLocation -ne $null)
        {
            $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
        }
    }
    Write-Log "$(Get-Date) - Loading Performance Cunters"

	$PAL_template_file = JOIN-PATH $CurrentLocation -ChildPath "SQLServer2014.xml"
	$SqlCmd = "
	declare @xml xml
	SELECT @Xml = CONVERT(XML, BulkColumn) 
	FROM OPENROWSET(BULK '$PAL_template_file', SINGLE_BLOB) AS x;

	;With cte as (
	select 
		a.value('(./@NAME)[1]','varchar(128)') as Name
		,a.value('(./@ENABLED)[1]','varchar(128)') as ENABLED
		,a.value('(./@PRIMARYDATASOURCE)[1]','varchar(128)') as PRIMARYDATASOURCE
		,a.value('(./DATASOURCE)[1]/@EXPRESSIONPATH','varchar(128)') as DATASOURCE1
		,a.value('(./DATASOURCE)[2]/@EXPRESSIONPATH','varchar(128)') as DATASOURCE2

		,a.value('(./THRESHOLD/@NAME)[1]','varchar(2000)') as THRESHOLD
		,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.value('(./DESCRIPTION)[1]','varchar(max)'),'<BR>',''),'<B>',''),'</B>',''),'<LI>',''),'</IL>','') as DESCRIPTION
	from @xml.nodes('/PAL/ANALYSIS') pa(a)
	)
	--,
	--cte1 as (
	--Select *,
	--	right(Datasource1,len(Datasource1) -charIndex('\',right(Datasource1,len(Datasource1)-1)) - 1) as COUNTER1
	--	,right(Datasource2,len(Datasource2) -charIndex('\',right(Datasource2,len(Datasource2)-1)) - 1) as COUNTER2
	--From cte)
	select *
		,'''' + DATASOURCE1 + '''' + Case when DATASOURCE2 is not null then ',''' + DATASOURCE2 + '''' ELSE '' END as COUNTERLIST
	INTO pal_Counters
	from cte
	"
	Invoke-Sqlcmd -ServerInstance $instancename -Database $Database -Query $SqlCmd -QueryTimeout 0
}

$LoadPerformanceDataScript = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
    function Write-Log($LogMsg)
    {
        if ($CurrentLocation -ne $null)
        {
            $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
        }
    }
    #This needs ODBC connection with DSN name "PerfCounters"
    #The registery key is saved under helper folder
    #2016 09 11: Use PowerShell to setup ODBC for connections, no longer need ODBC reg file
    #3 tables will be created:
    #select * from dbo.counterdata
    #select * from dbo.counterdetails
    #select * from dbo.DisplayTOID
	try
	{
	# When using .Net, ODBC32 is used instead of ODBC64
    Set-ItemProperty 'HKLM:\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources' -Name PerfCounters -Value "SQL Server"
	if (!(Test-Path 'HKLM:\SOFTWARE\ODBC\ODBC.INI\PerfCounters\'))
	{
		New-Item 'HKLM:\SOFTWARE\ODBC\ODBC.INI\PerfCounters\'
	}    
	Set-ItemProperty 'HKLM:\SOFTWARE\ODBC\ODBC.INI\PerfCounters\' -Name Database -Value $Database
    Set-ItemProperty 'HKLM:\SOFTWARE\ODBC\ODBC.INI\PerfCounters\' -Name Driver -Value "C:\Windows\system32\SQLSRV32.dll"
    Set-ItemProperty 'HKLM:\SOFTWARE\ODBC\ODBC.INI\PerfCounters\' -Name Server -Value $InstanceName
    Set-ItemProperty 'HKLM:\SOFTWARE\ODBC\ODBC.INI\PerfCounters\' -Name LastUser -Value "administrator"
    Set-ItemProperty 'HKLM:\SOFTWARE\ODBC\ODBC.INI\PerfCounters\' -Name Trusted_Connection -Value "Yes"

 #   Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\ODBC Data Sources' -Name PerfCounters -Value "SQL Server"
	#if (!(Test-Path 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\PerfCounters\'))
	#{
	#	New-Item 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\PerfCounters\'
	#}
 #   Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\PerfCounters\' -Name Database -Value $Database
 #   Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\PerfCounters\' -Name Driver -Value "C:\Windows\system32\SQLSRV32.dll"
 #   Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\PerfCounters\' -Name Server -Value $InstanceName
 #   Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\PerfCounters\' -Name LastUser -Value "administrator"
 #   Set-ItemProperty 'HKLM:\SOFTWARE\Wow6432NODE\ODBC\ODBC.INI\PerfCounters\' -Name Trusted_Connection -Value "Yes"
    $msg = relog.exe "$DataFolder\SQLDIAG.BLG" -f sql -o SQL:PerfCounters!1stRun
	Write-Log "$(Get-Date) - Relog Result: $msg"
	}
	catch
	{
		Write-Log "$(Get-Date) - Load PerfCounters failed: $_. Delete the database and try this application using Run As Administrator."

	}
}

$LoadDmvScript = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
    function Write-Log($LogMsg)
    {
        if ($CurrentLocation -ne $null)
        {
            $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
        }
    }
    Write-Log "$(Get-Date) - Loading Query Plans"

    $CreateTable = "
    CREATE TABLE [dbo].[CachedPlan](
	    [plan_id] [int] IDENTITY(1,1) NOT NULL,
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
	    [query_hash] [binary](8) NULL,
	    [query_plan_hash] [binary](8) NULL,
	    [total_rows] [bigint] NULL,
	    [last_rows] [bigint] NULL,
	    [min_rows] [bigint] NULL,
	    [max_rows] [bigint] NULL,
	    [query_plan] [xml] NULL,
	    [text] [nvarchar](max) NULL,
	    [text_filtered] [nvarchar](max) NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

    GO"

    $DataSourceFolder = Join-Path -Path $DataFolder -ChildPath "Data"
    Invoke-Sqlcmd -ServerInstance $instancename -Database $Database -Query $CreateTable -QueryTimeout 0
    Write-Log "$(Get-Date) - bcp `"$database.dbo.CachedPlan`" in `"$DataSourceFolder\CachedPlan.out`" -T -n -S $instancename"
    $msg = bcp "$database.dbo.CachedPlan" in "$DataSourceFolder\CachedPlan.out" -T -n -S $instancename
	Write-Log "$(Get-Date) - Loading Query Plans returned: $msg";
    Write-Log "$(Get-Date) - Loading Query Plans - Completed."
}

$ExportDmvScript = {
param([string]$InstanceName,
[string]$Database,
[string]$CurrentLocation,
[string]$DataFolder
) 
    function Write-Log($LogMsg)
    {
        if ($CurrentLocation -ne $null)
        {
            $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
        }
    }
    Write-Log "$(Get-Date) - Exporting DMV plans"

    $Plans = Invoke-SqlCmd -ServerInstance $InstanceName -Database $Database  -query "select top 10 ROW_NUMBER() over (order by [total_worker_time] desc) as rn, plan_id,query_plan from vwCachedPlan Order by [total_worker_time] Desc" -MaxCharLength 2147483647

    #Generate .sqlplan files on disk
    $PlanPath = Join-Path $DataFolder -ChildPath "DmvQueryPlans"
    if (!(Test-Path $PlanPath))
    {
        New-Item $PlanPath -type directory | Out-null
    }

    $Plans | Foreach-Object {$_.query_plan | Out-File -FilePath (Join-Path $planpath "$($_.rn)_$($_.plan_id).sqlplan") }
    Write-Log "$(Get-Date) - Exporting DMV plans - Completed."
}
#endregion
#region Create-DataTable,ConvertTo-Table, Upload-Data

function Get-SqlType 
{ 
    param([string]$TypeName) 
 
    switch ($TypeName)  
    { 
        'Boolean' {[Data.SqlDbType]::Bit} 
        'Byte[]' {[Data.SqlDbType]::VarChar} 
        'Byte'  {[Data.SQLDbType]::VarChar} 
        'Datetime'  {[Data.SQLDbType]::DateTime} 
        'Decimal' {[Data.SqlDbType]::Decimal} 
        'Double' {[Data.SqlDbType]::Float} 
        'Guid' {[Data.SqlDbType]::UniqueIdentifier} 
        'Int16'  {[Data.SQLDbType]::SmallInt} 
        'Int32'  {[Data.SQLDbType]::Int} 
        'Int64' {[Data.SqlDbType]::BigInt} 
        'UInt16'  {[Data.SQLDbType]::SmallInt} 
        'UInt32'  {[Data.SQLDbType]::Int} 
        'UInt64' {[Data.SqlDbType]::BigInt} 
        'Single' {[Data.SqlDbType]::Decimal}
        default {[Data.SqlDbType]::VarChar} 
    } 
     
} #Get-SqlType

function Get-Type
{
    param($type)

$types = @(
'System.Boolean',
#'System.Byte[]',
#'System.Byte',
'System.Char',
'System.Datetime',
'System.Decimal',
'System.Double',
'System.Guid',
'System.Int16',
'System.Int32',
'System.Int64',
'System.Single',
'System.UInt16',
'System.UInt32',
'System.UInt64')

    if ( $types -contains $type ) {
        Write-Output "$type"
    }
    else {
        Write-Output 'System.String'
        
    }
} #Get-Type

function Create-DataTable 
{ 
 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$false)] [string]$Schema = 'dbo', 
    [Parameter(Position=3, Mandatory=$true)] [String]$TableName, 
    [Parameter(Position=4, Mandatory=$true)] [System.Data.DataTable]$DataTable, 
    [Parameter(Position=5, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=6, Mandatory=$false)] [string]$Password, 
    [ValidateRange(0,8000)] 
    [Parameter(Position=7, Mandatory=$false)] [Int32]$MaxLength=1000,
    [Parameter(Position=8, Mandatory=$false)] [switch]$AsScript
    ) 
 
 try {
    if($Username) 
    { $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $ServerInstance,$Username,$Password } 
    else 
    { $con = new-object ("Microsoft.SqlServer.Management.Common.ServerConnection") $ServerInstance } 
     
    $con.Connect() 
 
    $server = new-object ("Microsoft.SqlServer.Management.Smo.Server") $con 
    $db = $server.Databases[$Database] 
    $table = new-object ("Microsoft.SqlServer.Management.Smo.Table") $db, $TableName 
    $Table.schema = $Schema

    $SchemaExists = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "Select 1 where exists(select * from $Database.sys.schemas where name ='$Schema')"

    #Create new table is it doesn't exist
    if ($SchemaExists -eq $null)
    {
        Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Query "Create Schema $Schema"
    }
 
    foreach ($column in $DataTable.Columns) 
    { 
        $sqlDbType = [Microsoft.SqlServer.Management.Smo.SqlDataType]"$(Get-SqlType $column.DataType.Name)" 
        if ($sqlDbType -eq 'VarBinary' -or $sqlDbType -eq 'VarChar') 
        { 
            if ($MaxLength -gt 0) 
            {$dataType = new-object ("Microsoft.SqlServer.Management.Smo.DataType") $sqlDbType, $MaxLength}
            else
            { $sqlDbType  = [Microsoft.SqlServer.Management.Smo.SqlDataType]"$(Get-SqlType $column.DataType.Name)Max"
              $dataType = new-object ("Microsoft.SqlServer.Management.Smo.DataType") $sqlDbType
            }
        } 
        else 
        { $dataType = new-object ("Microsoft.SqlServer.Management.Smo.DataType") $sqlDbType } 
        $col = new-object ("Microsoft.SqlServer.Management.Smo.Column") $table, $column.ColumnName, $dataType 
        $col.Nullable = $column.AllowDBNull 
        $table.Columns.Add($col) 
    } 
 
    if ($AsScript) {
        $table.Script()
    }
    else {
        $table.Create()
    }

}
catch {
    $message = $_.Exception.GetBaseException().Message
    Write-Log $message
}
  
} #Create-DataTable

function ConvertTo-Table
{
    [CmdletBinding()]
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject,
        [switch]$AllAsString
    )

    Begin
    {
        $dt = new-object Data.datatable  
        $First = $true 
    }
    Process
    {
        foreach ($object in $InputObject)
        {
            $DR = $DT.NewRow()  
            foreach($property in $object.PsObject.get_properties())
            {  
                if ($first)
                {  
                    $Col =  new-object Data.DataColumn  
                    $Col.ColumnName = $property.Name.ToString()  
                    if ($property.value)
                    {
                        if ($property.value -isnot [System.DBNull]) {
                            if ($AllAsString) {
                                $Col.DataType = [System.Type]::GetType("System.String")
                            } else {
                                $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)")
                            }
                         }
                    }
                    $DT.Columns.Add($Col)
                }  
                if ($property.Gettype().IsArray) {
                    $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1
                }  
               else {
                    if (($property.value -ne $null) -and ($property.value.Gettype().IsArray))
                    {
                        try
                        {
                            $stringarray = $false;
                            foreach ($v in $property.value) {
                                if ($v -eq $null -or $v.gettype().Name -eq "String" -or $v.gettype().Name -eq "XmlElement") 
                                    {$stringarray = $true}
                            }

                            if ($stringarray)
                            {
                                foreach ($c in $property.Value) 
                                { 
                                    if ($c -ne $null)
                                    {$string += $c.ToString() + ","}
                                }
                            } else {
                                $string = "0x"
                                foreach ($c in $property.Value) { $string += [Convert]::ToString($c,16).ToUpper().PadLeft(2,"0")}
                            }
                            $DR.Item($property.Name) = $string
                        }
                        catch {
                            Write-Log $property
							Write-Log $_
                        }
                    } else {
                        $DR.Item($property.Name) = $property.value
                    }
                }
            }  
            $DT.Rows.Add($DR)  
            $First = $false
        }
    } 
     
    End
    {
        @(,($dt))
    }

} #ConvertTo-Table

function Upload-Data
{
    [CmdletBinding()]
    param(
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance,
    [Parameter(Position=1, Mandatory=$true)] [string]$Database,
    [Parameter(Position=2, Mandatory=$true)] [string]$TableName,
    [Parameter(Position=3, Mandatory=$true)] $Data,
    [Parameter(Position=4, Mandatory=$false)] [string]$Username,
    [Parameter(Position=5, Mandatory=$false)] [string]$Password,
    [Parameter(Position=6, Mandatory=$false)] [Int32]$BatchSize=50000,
    [Parameter(Position=7, Mandatory=$false)] [Int32]$QueryTimeout=0,
    [Parameter(Position=8, Mandatory=$false)] [Int32]$ConnectionTimeout=15
    )
    
    $conn=new-object System.Data.SqlClient.SQLConnection

    if ($Username)
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout }
    else
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout }

    $conn.ConnectionString=$ConnectionString

    try
    {
        $conn.Open()
        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
        $bulkCopy.DestinationTableName = $tableName
        $bulkCopy.BatchSize = $BatchSize
        $bulkCopy.BulkCopyTimeout = $QueryTimeOut
        $bulkCopy.WriteToServer($Data)
        $conn.Close()
    }
    catch
    {
        $ex = $_.Exception
        Write-Error "$ex.Message"
		Write-Log $_
        continue
    }

} #Upload-Data

#endregion

function Load-QueryPlan
{
param(
    $ServerInstance = "Localhost",
    $Schema = "dbo",
    $Database = "SQLPTO",
    $Table1 = "query_post_execution_showplan_new",
    $Table2 = "QueryPlanClearned"

)
try
{
	$XmlPlans = Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database  -query "select * from [xel].[query_post_execution_showplan]" -MaxCharLength 2147483647 -QueryTimeout 0 -ErrorAction Stop
}
catch
{
	Write-Log "$_"
}
Write-Log "$(Get-Date) - Total Plans: $($XmlPlans.count)"

#[System.Xml.XmlNamespaceManager]$nsm = $PlanXml.NameTable
#$nsm.AddNamespace('df', "http://schemas.microsoft.com/sqlserver/2004/07/showplan")
$Querydata = $XmlPlans | `
    Select @{Name="name";Expression={'query_post_execution_showplan'}} `
        ,@{Name="timestamp";Expression={$_.e_Time_Of_Event_local}} `
        ,@{Name="source_database_id";Expression={$_.c_source_database_id}} `
        ,@{Name="object_type";Expression={$_.c_object_type}} `
        ,@{Name="cpu_time";Expression={$_.c_cpu_time}} `
        ,@{Name="object_id";Expression={$_.c_object_id}} `
        ,@{Name="nest_level";Expression={$_.c_nest_level}} `
        ,@{Name="duration";Expression={$_.c_duration}} `
        ,@{Name="estimated_rows";Expression={$_.c_estimated_rows}} `
        ,@{Name="estimated_cost";Expression={$_.c_estimated_cost}} `
        ,@{Name="object_name";Expression={$_.c_object_name}} `
        ,@{Name="query_hash";Expression={([xml]$_.c_showplan_xml).SelectSingleNode('//@QueryHash').Value}} `
        ,@{Name="queryplan_hash";Expression={([xml]$_.c_showplan_xml).SelectSingleNode('//@QueryPlanHash').Value}} `
        ,@{Name="showplan_xml";Expression={$_.c_showplan_xml}} `
        ,@{Name="sql_text";Expression={$_.a_sql_text}} `
        ,@{Name="database_name";Expression={$_.c_database_name}} `
        ,@{Name="attach_activity_id";Expression={$_.a_attach_activity_id}}
try {
		$sql = "CREATE TABLE [xel].[query_post_execution_showplan_new](
				[name] [varchar](max) NULL,
				[timestamp] [datetime] NULL,
				[source_database_id] [bigint] NULL,
				[object_type] [varchar](max) NULL,
				[cpu_time] [decimal](18, 0) NULL,
				[object_id] [int] NULL,
				[nest_level] [int] NULL,
				[duration] [decimal](18, 0) NULL,
				[estimated_rows] [int] NULL,
				[estimated_cost] [int] NULL,
				[object_name] [varchar](max) NULL,
				[query_hash] [varchar](max) NULL,
				[queryplan_hash] [varchar](max) NULL,
				[showplan_xml] [varchar](max) NULL,
				[sql_text] [varchar](max) NULL,
				[database_name] [varchar](max) NULL,
				[attach_activity_id] [varchar](max) NULL
			)"
		Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sql -QueryTimeout 0
		$QueryPlanTable = ConvertTo-Table -InputObject $Querydata -ErrorAction Stop
		#Create-DataTable -ServerInstance $InstanceName -Database $Database -Schema $Schema  -TableName $Table1 -DataTable $QueryPlanTable -MaxLength 0 -ErrorAction Stop
		Upload-Data -ServerInstance $InstanceName -Database $Database -TableName "$Schema.$Table1" -Data $QueryPlanTable -ErrorAction Stop
}
catch 
{
	Write-Log $_
}
$QueryplanScript = "
select sum(cpu_time) as total_cpu_time
	, sum(duration) as total_duration_time
    , count(*) as execution_counts
	, queryplan_hash
    , max(query_hash) as query_hash
	, max(sql_text) as sql_text
	, max(showplan_xml) as showplan_xml
	, ROW_NUMBER() over (order by sum(cpu_time) desc) as plan_id
Into [$Schema].[$Table2]
from [$Schema].[$Table1] q 
group by queryplan_hash
order by plan_id"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $QueryplanScript -QueryTimeout 0
}

function Analyze-ExpensiveQueries
{
param(
    $ServerInstance = "Localhost",
    $Database = "SQLPTO"
)
$sql = ";with cte as (
	select c_cpu_time as cpu_time,a_query_hash as query_hash
		,c_batch_text as sql_text
		,a_attach_activity_id as attach_activity_id
	from xel.sql_batch_completed
	union all
	select c_cpu_time, a_query_hash,c_statement
		, a_attach_activity_id
	from xel.rpc_completed)
	Select min(qc.plan_id) as plan_id,min(eq.query_id) as query_id
	into xel.plan_query_map
	from cte inner join xel.query_post_execution_showplan_new p 
		on left(cte.attach_activity_id,36) = left(p.attach_activity_id,36)
		inner join xel.queryplancleaned qc on p.sql_text = qc.sql_text
		inner join xel.expensive_query_raw eq on eq.sql_text = cte.sql_text
	Where cte.sql_text NOT IN ('exec sp_reset_connection')
	group by cte.sql_text ,p.sql_text
	GO

	;With cte as (
	select min(q.sql_text) as sql_text, sum(cpu_time) as cpu_time
		, sum(executions) as executions, min(query_hash) as query_hash
		, sum(duration) as duration,sum(physical_reads) as physical_reads
		,sum(logical_reads) as logical_reads, sum(writes) as writes, sum(row_count) as row_count
		, min(q.query_id) as min_row_number, pqm.plan_id, count(*) as number_of_queries
	from xel.expensive_query_raw q inner join xel.plan_query_map pqm on q.query_id = pqm.query_id
	group by pqm.plan_id
	union all 
	select sql_text,cpu_time,executions,query_hash, duration, physical_reads,logical_reads,writes, row_count,query_id,0,1
	from xel.expensive_query_raw q 
	where q.query_id NOT IN (Select query_id from xel.plan_query_map)
	)
	Select sql_text, cpu_time, executions,duration,physical_reads,logical_reads,writes,row_count, query_hash,ROW_NUMBER() over (order by cpu_time desc) as query_id,plan_id, number_of_queries
	INTO xel.expensive_query
	From cte
	Order by cpu_time desc
	GO
	select cast('cpu' as varchar(20)) as category, query_id, ROW_NUMBER() over (order by query_id) as rate
	into xel.expensive_query_combined
	from xel.expensive_query 
	where query_id <= 10

	Insert into xel.expensive_query_combined
	select top 10 'duration', query_id, ROW_NUMBER() over (order by duration desc)
	from xel.expensive_query
	order by duration desc
    
	Insert into xel.expensive_query_combined
	select top 10 'physical_reads', query_id, ROW_NUMBER() over (order by physical_reads desc)
	from xel.expensive_query
	order by physical_reads desc    

	Insert into xel.expensive_query_combined
	select top 10 'logical_reads', query_id, ROW_NUMBER() over (order by logical_reads desc)
	from xel.expensive_query
	order by logical_reads desc    

	Insert into xel.expensive_query_combined
	select top 10 'row_count', query_id, ROW_NUMBER() over (order by row_count desc)
	from xel.expensive_query
	order by row_count desc  
	GO
	Insert into xel.expensive_query_combined
	select top 10 'writes', query_id, ROW_NUMBER() over (order by writes desc)
	from xel.expensive_query
	order by writes desc    
	GO
	;with cte as (
	select c_cpu_time as cpu_time,a_query_hash as query_hash,c_batch_text as sql_text, a_attach_activity_id as attach_activity_id
	from xel.sql_batch_completed
	union all
	select c_cpu_time, a_query_hash,c_statement, a_attach_activity_id
	from xel.rpc_completed)
	select eq.query_id,cte.attach_activity_id 
	Into xel.expensive_query_attach_activity_id
	from cte
		inner join xel.expensive_query eq on cte.sql_text = eq.sql_text
	where
		eq.query_id in (select query_id from xel.expensive_query_combined)
	GO

	select q.query_id,cte.event,sum(cte.duration) as total_duration,count(*) as occurrence
	into xel.expensive_query_events 
	from xel.allActivities cte inner join xel.expensive_query_attach_activity_id q 
	on cte.ActivityID = left(q.attach_activity_id,36)
	group by q.query_id,cte.event
	GO
	   

	select q.query_id,cte.ActivityID,max(cte.duration) as total_duration,count(distinct q.attach_activity_id) as number_of_events
	into xel.expensive_query_activities
	from xel.allActivities cte inner join xel.expensive_query_attach_activity_id q 
	on cte.ActivityID = left(q.attach_activity_id,36)
	group by q.query_id,cte.activityID
	GO
		
	;With cte as (
		Select cpu_time,duration, physical_reads, logical_reads, row_count
			, writes, executions,query_id,sql_text,cast(query_id as varchar(6)) as Name
		From 
			xel.expensive_query eq
		Where query_id <= 10
		union all
		Select sum(cpu_time),sum(duration), sum(physical_reads), sum(logical_reads), sum(row_count)
			, sum(writes),sum(executions),999999,'All other queries','Others'
		From 
			xel.expensive_query eq
		Where
			query_id > 10
		)
	Select query_id, sql_text
		, cpu_time * 1.0/1000000 as cpu_time_s
		, duration * 1.0/1000000 as duration_time_s
		, physical_reads
		, logical_reads
		, row_count
		, writes
		, executions
		, cpu_time/(Select sum(cpu_time) from cte) as percentage
		, cpu_time*1.0/executions/1000000 as avg_cpu_time_s
		, duration*1.0/executions/1000000 as avg_duration_time_s
		, physical_reads*1.0/executions as avg_physical_reads
		, logical_reads*1.0/executions as avg_logical_reads
		, row_count*1.0/executions as avg_row_count
		, writes*1.0/executions as avg_writes
	Into xel.expensive_query_stats_cpu
	From cte 
	GO

	;With cte as (
	Select cpu_time,duration, physical_reads, logical_reads, row_count
		, writes, executions,eq.query_id,eqc.rate,sql_text,cast(eq.query_id as varchar(6)) as Name
	From 
		xel.expensive_query eq 
		inner join xel.expensive_query_combined eqc on eq.query_id = eqc.query_id and category = 'duration' 
	union all
	Select sum(cpu_time),sum(duration), sum(physical_reads), sum(logical_reads), sum(row_count)
		, sum(writes),sum(executions),999999,11,'All other queries','Others'
	From 
		xel.expensive_query eq
	Where
		query_id not in (select query_id from xel.expensive_query_combined where category = 'duration')
	)
	Select query_id, rate, sql_text
		, cpu_time * 1.0/1000000 as cpu_time_s
		, duration * 1.0/1000000 as duration_time_s
		, physical_reads
		, logical_reads
		, row_count
		, writes
		, executions
		, duration/(Select sum(duration) from cte) as percentage
		, cpu_time*1.0/executions/1000000 as avg_cpu_time_s
		, duration*1.0/executions/1000000 as avg_duration_time_s
		, physical_reads*1.0/executions as avg_physical_reads
		, logical_reads*1.0/executions as avg_logical_reads
		, row_count*1.0/executions as avg_row_count
		, writes*1.0/executions as avg_writes
	Into xel.expensive_query_stats_duration
	From cte 
	GO

	;With cte as (
	Select cpu_time,duration, physical_reads, logical_reads, row_count
		, writes, executions,eq.query_id,eqc.rate,sql_text,cast(eq.query_id as varchar(6)) as Name
	From 
		xel.expensive_query eq 
		inner join xel.expensive_query_combined eqc on eq.query_id = eqc.query_id and category = 'physical_reads' 
	union all
	Select sum(cpu_time),sum(duration), sum(physical_reads), sum(logical_reads), sum(row_count)
		, sum(writes),sum(executions),999999,11,'All other queries','Others'
	From 
		xel.expensive_query eq
	Where
		query_id not in (select query_id from xel.expensive_query_combined where category = 'physical_reads')
	)
	Select query_id, rate, sql_text
		, cpu_time * 1.0/1000000 as cpu_time_s
		, duration * 1.0/1000000 as duration_time_s
		, physical_reads
		, logical_reads
		, row_count
		, writes
		, executions
		, physical_reads *1.0 /(Select sum(physical_reads) from cte) as percentage
		, cpu_time*1.0/executions/1000000 as avg_cpu_time_s
		, duration*1.0/executions/1000000 as avg_duration_time_s
		, physical_reads*1.0/executions as avg_physical_reads
		, logical_reads*1.0/executions as avg_logical_reads
		, row_count*1.0/executions as avg_row_count
		, writes*1.0/executions as avg_writes
	Into xel.expensive_query_stats_physical_reads
	From cte 
	GO

	;With cte as (
	Select cpu_time,duration, physical_reads, logical_reads, row_count
		, writes, executions,eq.query_id,eqc.rate,sql_text,cast(eq.query_id as varchar(6)) as Name
	From 
		xel.expensive_query eq 
		inner join xel.expensive_query_combined eqc on eq.query_id = eqc.query_id and category = 'logical_reads' 
	union all
	Select sum(cpu_time),sum(duration), sum(physical_reads), sum(logical_reads), sum(row_count)
		, sum(writes),sum(executions),999999,11,'All other queries','Others'
	From 
		xel.expensive_query eq
	Where
		query_id not in (select query_id from xel.expensive_query_combined where category = 'logical_reads')
	)
	Select query_id, rate, sql_text
		, cpu_time * 1.0/1000000 as cpu_time_s
		, duration * 1.0/1000000 as duration_time_s
		, physical_reads
		, logical_reads
		, row_count
		, writes
		, executions
		, logical_reads*1.0/(Select sum(logical_reads) from cte) as percentage
		, cpu_time*1.0/executions/1000000 as avg_cpu_time_s
		, duration*1.0/executions/1000000 as avg_duration_time_s
		, physical_reads*1.0/executions as avg_physical_reads
		, logical_reads*1.0/executions as avg_logical_reads
		, row_count*1.0/executions as avg_row_count
		, writes*1.0/executions as avg_writes
	Into xel.expensive_query_stats_logical_reads
	From cte 
	GO

	;With cte as (
	Select cpu_time,duration, physical_reads, logical_reads, row_count
		, writes, executions,eq.query_id,eqc.rate,sql_text,cast(eq.query_id as varchar(6)) as Name
	From 
		xel.expensive_query eq 
		inner join xel.expensive_query_combined eqc on eq.query_id = eqc.query_id and category = 'row_count' 
	union all
	Select sum(cpu_time),sum(duration), sum(physical_reads), sum(logical_reads), sum(row_count)
		, sum(writes),sum(executions),999999,11,'All other queries','Others'
	From 
		xel.expensive_query eq
	Where
		query_id not in (select query_id from xel.expensive_query_combined where category = 'row_count')
	)
	Select query_id, rate, sql_text
		, cpu_time * 1.0/1000000 as cpu_time_s
		, duration * 1.0/1000000 as duration_time_s
		, physical_reads
		, logical_reads
		, row_count
		, writes
		, executions
		, row_count*1.0/(Select sum(row_count) from cte) as percentage
		, cpu_time*1.0/executions/1000000 as avg_cpu_time_s
		, duration*1.0/executions/1000000 as avg_duration_time_s
		, physical_reads*1.0/executions as avg_physical_reads
		, logical_reads*1.0/executions as avg_logical_reads
		, row_count*1.0/executions as avg_row_count
		, writes*1.0/executions as avg_writes
	Into xel.expensive_query_stats_row_count
	From cte 
	GO
	
	;With cte as (
	Select cpu_time,duration, physical_reads, logical_reads, row_count
		, writes, executions,eq.query_id,eqc.rate,sql_text,cast(eq.query_id as varchar(6)) as Name
	From 
		xel.expensive_query eq 
		inner join xel.expensive_query_combined eqc on eq.query_id = eqc.query_id and category = 'writes' 
	union all
	Select sum(cpu_time),sum(duration), sum(physical_reads), sum(logical_reads), sum(row_count)
		, sum(writes),sum(executions),999999,11,'All other queries','Others'
	From 
		xel.expensive_query eq
	Where
		query_id not in (select query_id from xel.expensive_query_combined where category = 'writes')
	)
	Select query_id, rate, sql_text
		, cpu_time * 1.0/1000000 as cpu_time_s
		, duration * 1.0/1000000 as duration_time_s
		, physical_reads
		, logical_reads
		, row_count
		, writes
		, executions
		, writes*1.0/(Select sum(writes) from cte) as percentage
		, cpu_time*1.0/executions/1000000 as avg_cpu_time_s
		, duration*1.0/executions/1000000 as avg_duration_time_s
		, physical_reads*1.0/executions as avg_physical_reads
		, logical_reads*1.0/executions as avg_logical_reads
		, row_count*1.0/executions as avg_row_count
		, writes*1.0/executions as avg_writes
	Into xel.expensive_query_stats_writes
	From cte 
	GO

	Create Function ufn_ListQueryActivity(@attach_activity_id varchar(200))
    RETURNS @QueryActivity TABLE
    (
	    [event] varchar(50),
	    sql_text nvarchar(max),
	    attach_id varchar(200),
	    activity_id INT,
	    [EventData] nvarchar(max),
		duration bigint
    )
    AS
    BEGIN
    ;With cteID AS (
    Select LEFT(@attach_activity_id, CHARINDEX('[', @attach_activity_id) -1) AS attach_id
    )
    INSERT INTO @QueryActivity
    Select 
	    'plan_affecting_convert' as event
	    , p.a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,c_expression as [EventData]
		,0 as duration
    From  
	    [xel].[plan_affecting_convert] p INNER JOIN cteID s
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'page_split'
	    , null
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT(c_context,':',c_alloc_unit_id)
		,0 as duration
    From  
	    [xel].transaction_log p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'rpc_completed'
	    , c_statement as sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('cpu_time=',c_cpu_time,' dur=',c_duration,' phy_r=',c_physical_reads,' log_r=',c_logical_reads,' write=',c_writes,' row_count=',c_row_count,' result=',c_result)
		,c_duration as duration
    From  
	    [xel].rpc_completed p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'auto_stats'
	    , p.a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('objid=',c_object_id,' idxid=',c_index_id,' statistics_list=',c_statistics_list)
		,c_duration as duration
    From  
	    [xel].auto_stats p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'blocked_process_report'
	    , null
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,null 
		,c_duration as duration
    From  
	    [xel].blocked_process_report p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'hash_warning'
	    , p.a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('hash_warn_type=',c_hash_warning_type,' query_operation_node_id=',c_query_operation_node_id,' recursion_level=',c_recursion_level)
		,0 as duration
    From  
	    [xel].hash_warning p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'missing_join_predicate'
	    , p.a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    , null
		,0 as duration
    From  
	    [xel].missing_join_predicate p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select
	    'optimizer_timeout'
	    , null
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,null 
		,0 as duration
    From  
	    [xel].optimizer_timeout p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'query_post_execution_showplan'
	    , p.a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,cast(c_showPlan_xml as nvarchar(max))
		,c_duration as duration
    From  
	    [xel].query_post_execution_showplan p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'sort_warning'
	    , p.a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('sort_warn_type=',c_sort_warning_type)
		,0 as duration
    From 
	    [xel].sort_warning p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'sql_batch_completed'
	    , c_batch_text as sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('cpu_time=',c_cpu_time,' dur=',c_duration,' phy_r=',c_physical_reads,' log_r=',c_logical_reads,' write=',c_writes,' row_count=',c_row_count,' result=',c_result)
		,c_duration as duration
    From 
	    [xel].sql_batch_completed p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    UNION ALL
    Select 
	    'xml_deadlock_report'
	    , null
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    , null
		,0 as duration
    From  
	    [xel].xml_deadlock_report p Inner Join cteID s 
	    ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'missing_column_statistics'
	    , p.a_sql_text as sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('column_list=',c_column_list)
		,0 as duration
	From  
		xel.missing_column_statistics p Inner Join cteID s 
			ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'database_file_size_change'
	    , p.a_sql_text as sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('DB name:',c_database_name,' Db ID:',c_database_id,' File ID:',c_file_id,' File Type:',c_file_type,' Is Automatic:',c_is_automatic,' Total Size(KB):',c_total_size_kb,' Size Changed:', c_size_change_kb,' Filename:',c_file_name)
		,c_duration
	From  
		xel.database_file_size_change p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'sql_statement_completed'
	    , p.c_statement as sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT(' Dur:',c_duration,' CPU:',c_cpu_time,' Phy IO:',c_physical_reads,' Log IO:',c_logical_reads,' Write:',c_writes,' Row #:',c_row_count,' Last row count:', c_last_row_count,' Line #:',c_line_number,' Offset:', c_offset, ' Offset End:',c_offset_end)
		,c_duration
	From  
		xel.sql_statement_completed p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'sp_statement_completed'
	    , p.c_statement as sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Db Id:',c_source_database_id,' Obj id',c_object_id, ' Obj Type:',c_object_type,' Dur:',c_duration,' CPU:',c_cpu_time,' Phy IO:',c_physical_reads,' Log IO:',c_logical_reads,' Write:',c_writes,' Row #:',c_row_count,' Last row count:', c_last_row_count,' Line #:',c_line_number,' Offset:', c_offset, ' Offset End:',c_offset_end)
		,c_duration
	From  
		xel.sp_statement_completed p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'unmatched_filtered_indexes'
	    , null
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Compile Time:',c_compile_time,' Db Name:',c_unmatched_database_name, ' Schema Name:',c_unmatched_schema_name,' Table name:',c_unmatched_table_name,' Idx name:',c_unmatched_index_name)
		,c_compile_time
	From  
		xel.unmatched_filtered_indexes p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'databases_log_growth'
	    , null
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Count:',c_count,' Db ID:',c_database_id)
		,0
	From  
		xel.databases_log_growth p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'latch_suspend_warning'
	    , a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Address:',c_address,' Mode:',c_mode, ' Class:', c_class, ' Keep Count:', c_keep_count, ' Shared count:',c_shared_count, ' Update count:', c_update_count,' Exclusive count:',c_exclusive_count, ' Destroy count:', c_destroy_count, ' Has waiters:', c_has_waiters, ' Is superlatch:', c_is_superlatch, ' Is poisoned:', c_is_poisoned, ' Dur:', c_duration, ' Db id:',c_database_id, ' File ID:', c_file_id, ' Page Id:',c_page_id, ' Task Owner:',c_task_owner,' Cont. Wait:', c_continue_wait)
		,c_duration
	From  
		xel.latch_suspend_warning p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'bitmap_disabled_warning'
	    , a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Query operation node id:',c_query_operation_node_id)
		,0
	From  
		xel.bitmap_disabled_warning p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'execution_warning'
	    , a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Dur:',c_duration, ' Warning Type:', c_warning_type, ' Server Mem Grants:', cast(c_server_memory_grants as nvarchar(max)))
		,c_duration
	From  
		xel.execution_warning p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id	
	UNION ALL
	Select 
		'batch_hash_table_build_bailout'
	    , a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Node Id:',c_node_id, ' Mem limit(KB):', c_memory_limit_kb)
		,0
	From  
		xel.batch_hash_table_build_bailout p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'exchange_spill'
	    , a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Query Operation Node ID:',c_query_operation_node_id, ' Opcode:', c_opcode)
		,0
	From  
		xel.exchange_spill p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'wait_info'
	    , a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Wait type:',c_wait_type, ' Opcode:', c_opcode, ' Dur:', c_duration, ' Signal Dur:', c_signal_duration)
		,c_duration
	From  
		xel.wait_info p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
	UNION ALL
	Select 
		'wait_info_external'
	    , a_sql_text
	    , s.attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as ActivityID
	    ,CONCAT('Wait type:',c_wait_type, ' Opcode:', c_opcode, ' Dur:', c_duration)
		,c_duration
	From  
		xel.wait_info_external p Inner Join cteID s 
		ON LEFT(p.a_attach_activity_id, CHARINDEX('[', p.a_attach_activity_id) -1) = s.attach_id
    order by ActivityID 
    RETURN
    END
	GO
	
	;With cteTopQueryActivity AS 
    (select a.query_id
    , ActivityID 
    , number_of_events
    , total_duration
    , ROW_NUMBER() over (partition by a.query_id order by total_duration desc) as [rank]
	from xel.expensive_query_activities a 
	where a.query_id in (Select query_id from xel.expensive_query) 
	), cteTop10Query as
	(
		Select query_id,ActivityID,number_of_events,total_duration from cteTopQueryActivity
		where rank =1
	),activity as 
	(    Select 
	    'plan_affecting_convert' as event
	    , p.a_sql_text
	    , s.ActivityID as attach_id
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) as Activity_ID
	    ,c_expression as [EventData]
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].[plan_affecting_convert] p INNER JOIN cteTop10Query s
	    ON LEFT(p.a_attach_activity_id,36) = s.ActivityID
    UNION ALL
    Select 
	    'page_split'
	    , null
	    , s.ActivityID
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT(c_context,':',c_alloc_unit_id)
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].transaction_log p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'rpc_completed'
	    , c_statement as sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('cpu_time=',c_cpu_time,' dur=',c_duration,' phy_r=',c_physical_reads,' log_r=',c_logical_reads,' write=',c_writes,' row_count=',c_row_count,' result=',c_result)
		,c_duration as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].rpc_completed p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'auto_stats'
	    , p.a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('objid=',c_object_id,' idxid=',c_index_id,' statistics_list=',c_statistics_list)
		,c_duration as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].auto_stats p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'blocked_process_report'
	    , null
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,null 
		,c_duration as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].blocked_process_report p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'hash_warning'
	    , p.a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('hash_warn_type=',c_hash_warning_type,' query_operation_node_id=',c_query_operation_node_id,' recursion_level=',c_recursion_level)
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].hash_warning p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'missing_join_predicate'
	    , p.a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    , null
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].missing_join_predicate p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select
	    'optimizer_timeout'
	    , null
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,null 
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].optimizer_timeout p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'query_post_execution_showplan'
	    , p.a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,cast(c_showPlan_xml as nvarchar(max))
		,c_duration as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].query_post_execution_showplan p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'sort_warning'
	    , p.a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('sort_warn_type=',c_sort_warning_type) -- 2012 RTM doesn't support this ,' query_operation_node_id=',c_query_operation_node_id)
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From 
	    [xel].sort_warning p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'sql_batch_completed'
	    , c_batch_text as sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('cpu_time=',c_cpu_time,' dur=',c_duration,' phy_r=',c_physical_reads,' log_r=',c_logical_reads,' write=',c_writes,' row_count=',c_row_count,' result=',c_result)
		,c_duration as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From 
	    [xel].sql_batch_completed p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
    UNION ALL
    Select 
	    'xml_deadlock_report'
	    , null
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT)
	    , null
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
    From  
	    [xel].xml_deadlock_report p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'missing_column_statistics'
	    , p.a_sql_text as sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('column_list=',c_column_list)
		,0 as duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.missing_column_statistics p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'database_file_size_change'
	    , p.a_sql_text as sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('DB name:',c_database_name,' Db ID:',c_database_id,' File ID:',c_file_id,' File Type:',c_file_type,' Is Automatic:',c_is_automatic,' Total Size(KB):',c_total_size_kb,' Size Changed:', c_size_change_kb,' Filename:',c_file_name)
		,c_duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.database_file_size_change p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'sql_statement_completed'
	    , p.c_statement as sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT)
	    ,CONCAT(' Dur:',c_duration,' CPU:',c_cpu_time,' Phy IO:',c_physical_reads,' Log IO:',c_logical_reads,' Write:',c_writes,' Row #:',c_row_count,' Last row count:', c_last_row_count,' Line #:',c_line_number,' Offset:', c_offset, ' Offset End:',c_offset_end)
		,c_duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.sql_statement_completed p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'sp_statement_completed'
	    , p.c_statement as sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT)
	    ,CONCAT('Db Id:',c_source_database_id,' Obj id',c_object_id, ' Obj Type:',c_object_type,' Dur:',c_duration,' CPU:',c_cpu_time,' Phy IO:',c_physical_reads,' Log IO:',c_logical_reads,' Write:',c_writes,' Row #:',c_row_count,' Last row count:', c_last_row_count,' Line #:',c_line_number,' Offset:', c_offset, ' Offset End:',c_offset_end)
		,c_duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.sp_statement_completed p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'unmatched_filtered_indexes'
	    , null
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT)
	    ,CONCAT('Compile Time:',c_compile_time,' Db Name:',c_unmatched_database_name, ' Schema Name:',c_unmatched_schema_name,' Table name:',c_unmatched_table_name,' Idx name:',c_unmatched_index_name)
		,c_compile_time
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.unmatched_filtered_indexes p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'databases_log_growth'
	    , null
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT)
	    ,CONCAT('Count:',c_count,' Db ID:',c_database_id)
		,0
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.databases_log_growth p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'latch_suspend_warning'
	    , a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT)
	    ,CONCAT('Address:',c_address,' Mode:',c_mode, ' Class:', c_class, ' Keep Count:', c_keep_count, ' Shared count:',c_shared_count, ' Update count:', c_update_count,' Exclusive count:',c_exclusive_count, ' Destroy count:', c_destroy_count, ' Has waiters:', c_has_waiters, ' Is superlatch:', c_is_superlatch, ' Is poisoned:', c_is_poisoned, ' Dur:', c_duration, ' Db id:',c_database_id, ' File ID:', c_file_id, ' Page Id:',c_page_id, ' Task Owner:',c_task_owner,' Cont. Wait:', c_continue_wait)
		,c_duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.latch_suspend_warning p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'bitmap_disabled_warning'
	    , a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('Query operation node id:',c_query_operation_node_id)
		,0
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.bitmap_disabled_warning p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'execution_warning'
	    , a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('Dur:',c_duration, ' Warning Type:', c_warning_type, ' Server Mem Grants:', cast(c_server_memory_grants as nvarchar(max)))
		,c_duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.execution_warning p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'batch_hash_table_build_bailout'
	    , a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('Node Id:',c_node_id, ' Mem limit(KB):', c_memory_limit_kb)
		,0
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.batch_hash_table_build_bailout p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'exchange_spill'
	    , a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('Query Operation Node ID:',c_query_operation_node_id, ' Opcode:', c_opcode)
		,0
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.exchange_spill p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'wait_info'
	    , a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('Wait type:',c_wait_type, ' Opcode:', c_opcode, ' Dur:', c_duration, ' Signal Dur:', c_signal_duration)
		,c_duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.wait_info p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	UNION ALL
	Select 
		'wait_info_external'
	    , a_sql_text
	    , s.activityid
	    ,CAST(Replace(RIGHT(a_attach_activity_id, CHARINDEX('[', REVERSE(a_attach_activity_id))-1),']','')  AS INT) 
	    ,CONCAT('Wait type:',c_wait_type, ' Opcode:', c_opcode, ' Dur:', c_duration)
		,c_duration
		,s.query_id
		,s.number_of_events
		,s.total_duration
	From  
		xel.wait_info_external p Inner Join cteTop10Query s 
	    ON LEFT(p.a_attach_activity_id, 36) = s.activityid
	)
    Select
	    query_id
	    , activity_id
	    , [event]
	    , EventData
	    , attach_id
		, duration
    INTO xel.expensive_query_detailed_events
    From 
	    activity
    Order By
	    query_id,activity_id"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sql -QueryTimeout 0
}

#region Analyze Query Plan

function Get-ParentStmtId($b)
{
    if ($b.StatementId -eq $null)
    {
        if ($b.ParentNode -ne $null)
            { Get-ParentStmtId($b.ParentNode) }
        else {
            $Global:StatementId = 0
            $Global:StatementCompId = 0
        }
    } else {
        $Global:StatementId = $b.StatementId;
        $Global:StatementCompId = $b.StatementCompId;
    }
}

function Select-Operator([string]$QueryPlanName)
{
    foreach ($b in $PlanXml.SelectNodes("//df:RelOp",$nsm))
    {
        Get-ParentStmtId ($b);
        $b | `
            Select @{Name='QueryPlanName';Expression={$QueryPlanName}} `
            , @{Name="StatementId";Expression={[int]$StatementId}} `
            , @{Name="StatementCompId";Expression={[int]$StatementCompId}}  `
            , PhysicalOp `
            , @{Name="EstimatedTotalSubtreeCost";Expression={[float]$_.EstimatedTotalSubtreeCost}} `
            , EstimateRows `
            , AvgRowSize `
            , @{Name="Database";Expression={$_.ChildNodes.Object.Database}} `
            , @{Name="Schema";Expression={$_.ChildNodes.Object.Schema}} `
            , @{Name="Table";Expression={$_.ChildNodes.Object.Table}} `
            , @{Name="Index";Expression={$_.ChildNodes.Object.Index}} `
            , @{Name="WarningXml";Expression={$_.Warnings.InnerXml}} `
            , @{Name="SpillToTempDb";Expression={$_.Warnings.SpillToTempDb.SpillLevel}} `
            , @{Name="ImplicitConversion";Expression={$_.ComputeScalar.DefinedValues.DefinedValue.ScalarOperator.ScalarString}} `
            , @{Name="UserDefinedFunction";Expression={$_.SelectNodes(".//df:UserDefinedFunction",$nsm).FunctionName}} `
            , EstimateCPU , EstimateIO `
            , EstimateRebinds `
            , EstimateRewinds `
            , @{Name="ActualRows";Expression={$_.RunTimeInformation.RunTimeCountersPerThread.ActualRows }} `
            , @{Name="ActualRebinds";Expression={$_.RunTimeInformation.RunTimeCountersPerThread.ActualRebinds}} `
            , @{Name="ActualRewinds";Expression={$_.RunTimeInformation.RunTimeCountersPerThread.ActualRewinds}} `
            , @{Name="ActualExecutions";Expression={$_.RunTimeInformation.RunTimeCountersPerThread.ActualExecutions}} `
            , @{Name="ActualEndOfScans";Expression={$_.RunTimeInformation.RunTimeCountersPerThread.ActualEndOfScans}} `
            , EstimatedExecutionMode `
            , TableCardinality `
            , LogicalOp `
            , NodeId `
            , Parallel `
            , @{Name="Thread";Expression={$_.RunTimeInformation.RunTimeCountersPerThread.Thread}} `
            , @{Name="ColumnReference";Expression={$_.IndexScan.DefinedValues.DefinedValue.ColumnReference.Column -join ","}} `
            , @{Name="RangeColumn";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.Prefix.RangeColumns.ColumnReference.column}} `
            , @{Name="ScanType_Prefix";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.Prefix.ScanType}} `
            , @{Name="ScalarString_Prefix";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.Prefix.RangeExpressions.ScalarOperator.ScalarString -join ","}} `
            , @{Name="StartRangeColumn";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.StartRange.RangeColumns.ColumnReference.column}} `
            , @{Name="ScanType_StartRange";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.StartRange.ScanType}} `
            , @{Name="ScalarString_StartRange";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.StartRange.RangeExpressions.ScalarOperator.ScalarString -join ","}} `
            , @{Name="EndRangeColumn";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.EndRange.RangeColumns.ColumnReference.column}} `
            , @{Name="ScanType_EndRange";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.EndRange.ScanType}} `
            , @{Name="ScalarString_EndRange";Expression={$_.IndexScan.SeekPredicates.SeekPredicateNew.SeekKeys.EndRange.RangeExpressions.ScalarOperator.ScalarString -join ","}} 

     } 

 
}

function WriteTo-Database($Data,$ServerInstance,$Database,[string]$Schema,[string]$Tablename)
{
    if ($data -ne $null) {
        
    $DataTable = ConvertTo-Table -InputObject $Data 
    $TblExists = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query "Select 1 where exists(select * from sys.tables where object_id = object_id('$Schema.$Tablename'))"

    #Create new table is it doesn't exist
    if ($TblExists -eq $null)
    {
        Create-DataTable -ServerInstance $ServerInstance -Database $Database -Schema $Schema -TableName $Tablename -DataTable $DataTable -MaxLength 0
    }

    Upload-Data -ServerInstance $ServerInstance -Database $Database -TableName "$Schema.$Tablename" -Data $DataTable
    }
}

function Analyze-QueryPlan([xml]$PlanXml, $PlanName, $ServerInstance, $Database)
{

    [System.Xml.XmlNamespaceManager]$nsm = $PlanXml.NameTable
    #$nsm.AddNamespace($null, "http://schemas.microsoft.com/sqlserver/2004/07/showplan")
    $Schema = "qp"
    $nsm.AddNamespace('df', "http://schemas.microsoft.com/sqlserver/2004/07/showplan")
    
    $outputFile = Join-Path $CurrentLocation -ChildPath "Results\$PlanName.xlsx"

    $statements = $Planxml.ShowPlanXML.SelectNodes("//df:StmtSimple",$nsm) | `
        Select @{Name="QueryPlanName";Expression={$PlanName}} `
        , @{Name="Tag";Expression={"StmtSimple"}} `
        , @{Name="StatementId";Expression={[int]$_.StatementId}} `
        , @{Name="StatementCompID";Expression={[int]$_.StatementCompID}} `
        , StatementEstRows `
        , StatementOptmEarlyAbortReason `
        , StatementOptmLevel `
        , @{Name="StatementSubTreeCost";Expression={[float]$_.StatementSubTreeCost}} `
        , StatementText `
        , @{Name = "PlanAffectingConvert";Expression={$_.QueryPlan.Warnings.PlanAffectingConvert.ConvertIssue}} `
        , @{Name = "TableVariable";Expression={[Regex]::Match($_.SelectNodes(".//df:Object",$nsm).Table,"^\[(\@.*\]$").Groups[1].Value}} `
        , @{Name = "UnmatchedIndexes";Expression={$_.QueryPlan.Warnings.UnmatchedIndexes}} `
        , @{Name = "QueryPlanWarnings";Expression={$_.QueryPlan.Warnings.InnerXml}} `
        , @{Name = "MissingIndexes";Expression={$_.QueryPlan.MissingIndexes.MissingIndexGroup.Impact}} `
        , QueryHash `
	    , QueryPlanHash `
        , @{Name =  'DOP';Expression={$_.QueryPlan.DegreeOfParallelism}} `
        , @{Name =  'MemoryGrant';Expression={$_.QueryPlan.MemoryGrant}} `
        , @{Name =  'NonParallelPlanReason';Expression={$_.QueryPlan.NonParallelPlanReason}} `
        , @{Name =  'CachedPlanSize';Expression={$_.QueryPlan.CachedPlanSize}} `
        , @{Name =  'CompileTime';Expression={$_.QueryPlan.CompileTime}} `
        , @{Name =  'CompileCPU';Expression={$_.QueryPlan.CompileCPU}} `
        , @{Name =  'CompileMemory';Expression={$_.QueryPlan.CompileMemory}} `
        , @{Name =  'SerialRequiredMemory';Expression={$_.QueryPlan.MemoryGrantInfo.SerialRequiredMemory}} `
        , @{Name =  'SerialDesiredMemory';Expression={$_.QueryPlan.MemoryGrantInfo.SerialDesiredMemory}} `
        , @{Name =  'RequiredMemory';Expression={$_.QueryPlan.MemoryGrantInfo.RequiredMemory}} `
        , @{Name =  'DesiredMemory';Expression={$_.QueryPlan.MemoryGrantInfo.DesiredMemory}} `
        , @{Name =  'RequestedMemory';Expression={$_.QueryPlan.MemoryGrantInfo.RequestedMemory}} `
        , @{Name =  'GrantWaitTime';Expression={$_.QueryPlan.MemoryGrantInfo.GrantWaitTime}} `
        , @{Name =  'GrantedMemory';Expression={$_.QueryPlan.MemoryGrantInfo.GrantedMemory}} `
        , @{Name =  'MaxUsedMemory';Expression={$_.QueryPlan.MemoryGrantInfo.MaxUsedMemory}} `
        , @{Name =  'EstimatedAvailableMemoryGrant';Expression={$_.QueryPlan.OptimizerHardwareDependentProperties.EstimatedAvailableMemoryGrant}} `
        , @{Name =  'EstimatedPagesCached';Expression={$_.QueryPlan.OptimizerHardwareDependentProperties.EstimatedPagesCached}} `
        , @{Name =  'EstimatedAvailableDegreeOfParallelism';Expression={$_.QueryPlan.OptimizerHardwareDependentProperties.EstimatedAvailableDegreeOfParallelism}} `
        , @{Name =  'Parameter';Expression={$_.QueryPlan.ParameterList.ColumnReference.Column + '=' + $_.QueryPlan.ParameterList.ColumnReference.ParameterCompiledValue + '\' + $_.QueryPlan.ParameterList.ColumnReference.ParameterRuntimeValue }} `
        , @{Name =  'QueryPlanXml';Expression={[xml]$_.OuterXml}}

    if ($GenerateExcelFile)
    { 
        $statements |  & $ExportXlsFilename  -Path $outputFile -WorkSheetName "Statements" 
    } else {
        WriteTo-Database -Data $statements -ServerInstance $ServerInstance -Database $Database -Schema $Schema -Tablename "Statements"
    }

    #Stored Proc  StmtCond
    $StmtCondList = $Planxml.ShowPlanXML.SelectNodes("//df:StmtCond",$nsm) 
    if ($StmtCondList -ne $null)
    {
        $StmtCond = $StmtCondList | `
        Select @{Name="QueryPlanName";Expression={$PlanName}} `
        , @{Name="Tag";Expression={"StmtCond"}} `
        , @{Name="StatementId";Expression={[int]$_.StatementId}} `
        , @{Name="StatementCompID";Expression={[int]$_.StatementCompID}} `
        , StatementEstRows `
        , StatementOptmEarlyAbortReason `
        , StatementOptmLevel `
        , @{Name="StatementSubTreeCost";Expression={[decimal]$_.StatementSubTreeCost}} `
        , StatementText `
        , @{Name = "PlanAffectingConvert";Expression={$_.QueryPlan.Warnings.PlanAffectingConvert.ConvertIssue}} `
        , @{Name = "TableVariable";Expression={[Regex]::Match($_.SelectNodes(".//df:Object",$nsm).Table,"^\[(\@.*\]$").Groups[1].Value}} `
        , @{Name = "UnmatchedIndexes";Expression={$_.QueryPlan.Warnings.UnmatchedIndexes}} `
        , @{Name = "QueryPlanWarnings";Expression={$_.QueryPlan.Warnings.InnerXml}} `
        , QueryHash `
	    , QueryPlanHash `
        , @{Name =  'DOP';Expression={$_.QueryPlan.DegreeOfParallelism}} `
        , @{Name =  'NonParallelPlanReason';Expression={$_.QueryPlan.NonParallelPlanReason}} `
        , @{Name =  'CachedPlanSize';Expression={$_.QueryPlan.CachedPlanSize}} `
        , @{Name =  'CompileTime';Expression={$_.QueryPlan.CompileTime}} `
        , @{Name =  'CompileCPU';Expression={$_.QueryPlan.CompileCPU}} `
        , @{Name =  'CompileMemory';Expression={$_.QueryPlan.CompileMemory}} `
        , @{Name =  'SerialRequiredMemory';Expression={$_.QueryPlan.MemoryGrantInfo.SerialRequiredMemory}} `
        , @{Name =  'SerialDesiredMemory';Expression={$_.QueryPlan.MemoryGrantInfo.SerialDesiredMemory}} `
        , @{Name =  'EstimatedAvailableMemoryGrant';Expression={$_.QueryPlan.OptimizerHardwareDependentProperties.EstimatedAvailableMemoryGrant}} `
        , @{Name =  'EstimatedPagesCached';Expression={$_.QueryPlan.OptimizerHardwareDependentProperties.EstimatedPagesCached}} `
        , @{Name =  'EstimatedAvailableDegreeOfParallelism';Expression={$_.QueryPlan.OptimizerHardwareDependentProperties.EstimatedAvailableDegreeOfParallelism}} `
        , @{Name =  'Parameter';Expression={$_.QueryPlan.ParameterList.ColumnReference.Column + '=' + $_.QueryPlan.ParameterList.ColumnReference.ParameterCompiledValue + '\' + $_.QueryPlan.ParameterList.ColumnReference.ParameterRuntimeValue }} 

        if ($GenerateExcelFile)
        { 
            $StmtCond |  & $ExportXlsFilename  -Path $outputFile -WorkSheetName "Statements" 
        } else {
            WriteTo-Database -Data $StmtCond -ServerInstance $ServerInstance -Database $Database  -Schema $Schema -Tablename "Statements"
        }
    }
    #Cursor        

    $cursorList = $Planxml.ShowPlanXML.SelectNodes("//df:StmtCursor",$nsm);
    if ($cursorList -ne $null)
    {
        $cursors = $cursorList | `
            Select @{Name="QueryPlanName";Expression={$PlanName}} ` `
            , @{Name="StatementId";Expression={[int]$_.StatementId}} `
            , @{Name="StatementCompID";Expression={[int]$_.StatementCompID}} `
            , StatementText `
            , @{Name =  'CachedPlanSize';Expression={$_.CursorPlan.Operation.QueryPlan.CachedPlanSize}} `
            , @{Name =  'CompileTime';Expression={$_.CursorPlan.Operation.QueryPlan.CompileTime}} `
            , @{Name =  'CompileCPU';Expression={$_.CursorPlan.Operation.QueryPlan.CompileCPU}} `
            , @{Name =  'CompileMemory';Expression={$_.CursorPlan.Operation.QueryPlan.CompileMemory}} `
            , @{Name =  'CursorName';Expression={$_.CursorPlan.CursorName}} `
            , @{Name =  'CursorActualType';Expression={$_.CursorPlan.CursorActualType}} `
            , @{Name =  'CursorRequestedType';Expression={$_.CursorPlan.CursorRequestedType}} `
            , @{Name =  'CursorConcurrency';Expression={$_.CursorPlan.CursorConcurrency}} `
            , @{Name =  'ForwardOnly';Expression={$_.CursorPlan.ForwardOnly}} `
            , @{Name =  'Parameter';Expression={$_.CursorPlan.Operation.QueryPlan.ParameterList.ColumnReference.Column + '=' + $_.CursorPlan.Operation.QueryPlan.ParameterList.ColumnReference.ParameterCompiledValue + '\' + $_.CursorPlan.Operation.QueryPlan.ParameterList.ColumnReference.ParameterRuntimeValue}} 

        if ($GenerateExcelFile)
        { 
            $cursors |  & $ExportXlsFilename  -Path $outputFile -WorkSheetName "StmtCursor" -Append
        } else {
            WriteTo-Database -Data $cursors -ServerInstance $ServerInstance -Database $Database  -Schema $Schema -Tablename "StmtCursor"
        }
    }

    #Missing Index
    $MI = @();
    foreach ($MIList in $PlanXml.SelectNodes("//df:MissingIndexGroup",$nsm))
    {
         Get-ParentStmtId ($MIList);   
            $MI += $MIList | `
            Select @{Name="QueryPlanName";Expression={$PlanName}} ` `
            , @{Name="StatementId";Expression={[int]$StatementId}} `
            , @{Name="StatementCompId";Expression={[int]$StatementCompId}} `
            , @{Name="Database";Expression={$_.MissingIndex.Database}} `
            , @{Name="Schema";Expression={$_.MissingIndex.Schema}} `
            , @{Name="Table";Expression={$_.MissingIndex.Table}} `
            , @{Name="StatementText";Expression={$_.ParentNode.ParentNode.ParentNode.StatementText}} `
            , Impact `
            , @{Name="EqualityColumns";Expression={($_.MissingIndex.ColumnGroup | Where Usage -eq "EQUALITY" | Select @{Name="Column";Expression={$_.Column.Name}}).Column -join "," }} `
            , @{Name="InequalityColumns";Expression={($_.MissingIndex.ColumnGroup | Where Usage -eq "INEQUALITY" | Select @{Name="Column";Expression={$_.Column.Name}}).Column -join ","}} `
            , @{Name="IncludeColumns";Expression={($_.MissingIndex.ColumnGroup | Where Usage -eq "INCLUDE" | Select @{Name="Column";Expression={$_.Column.Name}}).Column -join "," }} 
    }

    if ($GenerateExcelFile)
    { 
        $MI |  & $ExportXlsFilename  -Path $outputFile -WorkSheetName "MissingIndexes" -Append
    } else {
        WriteTo-Database -Data $MI -ServerInstance $ServerInstance -Database $Database  -Schema $Schema -Tablename "MissingIndexes"
    }

    #Operators
    $Operators = Select-Operator -QueryPlanName $PlanName

    if ($GenerateExcelFile)
    { 
        $Operators |  & $ExportXlsFilename  -Path $outputFile -WorkSheetName "Operators" -Append
    } else {
        WriteTo-Database -Data $Operators -ServerInstance $ServerInstance -Database $Database -Schema $Schema -Tablename "Operators" 
    }

    #Predicate
    $Predicate = @();
    foreach ($PredicateList in $PlanXml.SelectNodes("//df:Predicate",$nsm))
    {
         Get-ParentStmtId ($PredicateList);   
            $Predicate += $PredicateList | `
            Select @{Name="QueryPlanName";Expression={$PlanName}} ` `
            , @{Name="StatementId";Expression={[int]$StatementId}} `
            , @{Name="StatementCompId";Expression={[int]$StatementCompId}} `
            , @{Name='WhereClause';Expression={$_.SelectNodes("./df:ScalarOperator[@ScalarString]",$nsm).ScalarString}} `
            , @{Name='Database';Expression={$_.SelectNodes(".//df:ColumnReference[@Database]",$nsm).Database}} `
            , @{Name='Schema';Expression={$_.SelectNodes(".//df:ColumnReference[@Column]",$nsm).Schema}} `
            , @{Name='Table';Expression={$_.SelectNodes(".//df:ColumnReference[@Column]",$nsm).Table}} `
            , @{Name='Columns';Expression={$_.SelectNodes(".//df:ColumnReference[@Column]",$nsm).Column}} `
            , @{Name='WildcardPattern';Expression={if (($_.SelectNodes(".//df:Logical[@Operation='OR']/df:ScalarOperator/df:Identifier/df:ColumnReference/df:ScalarOperator/df:Compare[@CompareOp='IS']/df:ScalarOperator/df:Identifier/df:ColumnReference",$nsm).Column -match '@.*') `
                -and ($_.SelectNodes(".//df:Logical[@Operation='OR']/df:ScalarOperator/df:Identifier/df:ColumnReference/df:ScalarOperator/df:Compare[@CompareOp='IS']/df:ScalarOperator/df:Const[@ConstValue='NULL']",$nsm) -ne $null)) {1} else {0}}} `
            , @{Name='DataTypeMismatch';Expression={if ($_.SelectNodes(".//df:Convert",$nsm) -ne $null) {1} else {0} }} `
            , @{Name='NegativeOp';Expression={if ($_.SelectNodes(".//df:Compare[@CompareOp='NE']",$nsm) -ne $null) {1} else {0} }} `
            , @{Name="Predicate";Expression={$_.OuterXml}}
    }

    if ($GenerateExcelFile)
    { 
        $Predicate |  & $ExportXlsFilename  -Path $outputFile -WorkSheetName "Predicates" -Append
    } else {
        WriteTo-Database -Data $Predicate -ServerInstance $ServerInstance -Database $Database -Schema $Schema -Tablename "Predicates" 
    }
}
#endregion

#region Load data

function Load-Data($DataSourceFolder)
{
    Write-Log "$(Get-Date) - Loading Data - $DataSourceFolder"
    $XeLoader = Join-Path -Path $CurrentLocation -ChildPath  "Lib\xEvent\XELoader.exe"
    $msg = & $XeLoader -D"$DataSourceFolder" -S"$InstanceName" -d"$database" -s"health"

    Foreach ($DataFile in (Get-ChildItem $DataSourceFolder))
    {
        $data = $null
        try {
        switch -Wildcard ($DataFile.FullName)
        {
            "*.csv" { $data = Import-Csv $DataFile.FullName;continue;}
            "*.trc" { continue;}
            "*.out" { continue;}
            "*.sql" { continue;}
            "*ERRORLOG*" { continue;}
            "*.xel" { continue; }
            default { $data = Import-Clixml $DataFile.FullName}
        }
    
        if ($data -ne $null)
        {

            $DataTable = ConvertTo-Table -InputObject $data -AllAsString
            Create-DataTable -ServerInstance $InstanceName -Database $Database -TableName $DataFile.BaseName -DataTable $DataTable -MaxLength 4000
            Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $DataFile.BaseName -Data $DataTable -ErrorAction Stop
        }
        }
        catch {
            Write-Log "Error Importing $($DataFile.FullName)"
            Write-Log $_
        }
    }
    Write-Log "$(Get-Date) - Loading Data - $DataSourceFolder - Completed."
}

Function Load-SnapshotData
{
	Write-Log "$(Get-Date) - Loading Snapshot Data - $DataSourceFolder"
    #Local snapshot data
    $SnapshotSchemaName = 'Snapshot'

    $SnapshotRootFolder = Join-Path -Path $DataFolder -ChildPath "SnapshotData"
    foreach  ($SnapshotFolder in (Get-ChildItem $SnapshotRootFolder -Directory))
    {
        foreach ($SnapshotDataFile in (Get-Childitem $($SnapshotFolder.FullName) -File))
        {
            $data = Import-Clixml $SnapshotDataFile.FullName
            if ($data -ne $null)
            {
                $DataTable = ConvertTo-Table -InputObject $data -AllAsString
                $TableExists = Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query "Select 1 From sys.tables where schema_id('$SnapshotSchemaName') =schema_id and name = '$($SnapshotDataFile.BaseName)'"
                If ($TableExists -eq $null)
                {
                    #Create Table if not exists
                    Create-DataTable -ServerInstance $InstanceName -Database $Database -Schema $SnapshotSchemaName -TableName $SnapshotDataFile.BaseName -DataTable $DataTable -MaxLength 0
                
                    #Add additional column for timestamp
                    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query "ALTER TABLE [Snapshot].[$($SnapshotDataFile.BaseName)] ADD [Timestamp] VARCHAR(15) NULL" | Out-Null
                }

                Try
                {
					if ($DataTable -ne $null)
					{
						#Load data into table
						Upload-Data -ServerInstance $InstanceName -Database $Database -TableName "$SnapshotSchemaName.$($SnapshotDataFile.BaseName)" -Data $DataTable -ErrorAction Stop
						#Update Timestamp
						Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query "UPDATE  [$SnapshotSchemaName].[$($SnapshotDataFile.BaseName)] SET [timestamp]='$(Split-Path $SnapshotFolder -Leaf)' WHERE [timestamp] IS NULL" | Out-Null
					}
                }
                catch {
                    Write-Log "Error Importing $($SnapshotDataFile.FullName)"
                    Write-Log $_
                }
            }
        }
    }
	Write-Log "$(Get-Date) - Loading Snapshot Data - Completed."
}

#endregion

function Write-Log($LogMsg)
{
    if ($CurrentLocation -ne $null)
    {
        $LogMsg | Out-File (Join-Path $CurrentLocation "DataLoading.log") -Append
    }
}

Function Start-AnalyzeQueryPlan
{
    $SchemaName = "xel"
    $Table1name = "query_post_execution_showplan_new"
    $Table2name = "queryplancleaned"
    Write-Log "$(Get-Date) - Loading Query Plans"
    $returnMsg = Load-QueryPlan -ServerInstance $InstanceName -Database $Database -Schema $SchemaName -Table1 $Table1name -Table2 $Table2name 
	Write-Log "$(Get-Date) - Load-QueryPlan completed: $returnMsg"

    #Analyze Query Plan
    Write-Log "$(Get-Date) - Analyzing Query Plans"
	$Plans = Invoke-SqlCmd -ServerInstance $InstanceName -Database $Database  -query "Select plan_id, showplan_xml from $SchemaName.$Table2name" -MaxCharLength 2147483647

    #Generate .sqlplan files on disk
    $PlanPath = Join-Path $DataFolder -ChildPath "AllQueryPlans"
    if (!(Test-Path $PlanPath))
    {
        New-Item $PlanPath -type directory | Out-null
    }

    #Analyze query plans
    Write-Log "$(Get-Date) - Analyze and export query plans"
    Foreach ($plan in $Plans)
	{
        try {
		    Analyze-QueryPlan -PlanXml $plan.showplan_xml -PlanName $plan.Plan_id  `
			    -ServerInstance $InstanceName -Database $Database;
        }
        catch
        {
            Write-Log "$(Get-Date) - $($plan.Plan_id)"
            Write-Log "$(Get-Date) - $_"
            
        }
		$plan.showplan_xml | Out-File -FilePath (Join-Path $planpath "$($plan.plan_id).sqlplan")
	}

	Write-Log "$(Get-Date) - Loading Query Plans Completed."
}

#region Main 

Import-Module SqlPS -DisableNameChecking

$DataZipFiles = Get-ChildItem (Join-Path -Path $CollectedDataFolder -ChildPath  "SQLDIAG*.zip")

#Check if process all
if ($ProcessAll -eq $false)
{ 
    #Pick the newest 1 when ProcessAll is false
    $DataZipFiles = $DataZipFiles | Sort-Object -Descending -Property LastWriteTime | Select -First 1
}

foreach ($DataZipFile in $DataZipFiles)
{
    $StartTIme = Get-Date

    Write-Log "$(Get-Date) - Start Loading. Source file - $($DataZipFile.BaseName)"
    #Append database name with timestamp from collection
    $Database = $DatabaseName + "_"+ [REGEX]::Match($DataZipFile.BaseName,'\d{4}.*\d{2}.*\d{2}_.*\d{5,6}').value
    #Remove space if exists
    $Database = $Database -replace " ","0"
	$Database = $Database -replace "-",""

    #Extract files
    $ExtractFolder = Split-Path $DataZipFile -Parent
    $DataFolder = Join-Path $ExtractFolder $($DataZipFile.BaseName)
    if (!(Test-Path $DataFolder))
    {
        Add-Type -A System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($DataZipFile , $DataFolder)
    }

    #If database exists, drop it
    $DbExists = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Select 1 where exists(select * from sys.databases where name = '$Database')"

    if ($DbExists -ne $null)
    {
        if ($DropExisting)
        {
            #Drop existing database
            Write-Log "$(Get-Date) - Dropping Existing Database - $Database" 
            Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Alter Database $Database Set Single_User with Rollback immediate; Drop Database $Database"
        }
        else
        {
            #Stop processing
            Write-Log "$(Get-Date) - $Database exists. Analysis will now stop. To drop existing database, use paramter -DropExisting to overwrite existing database`n`n`n"
        }
    }
    else {

    Write-Log "$(Get-Date) - Creating Database - $Database"
	Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Create Database $Database";
    Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Alter Database $Database Set Recovery Simple"

    #Keep source filename
    Write-Log "$(Get-Date) - Writing source file into datbase dbo.SourceFileName table"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query "SELECT '$($DataZipFile.BaseName)' As SourceFileName INTO dbo.SourceFileName" -QueryTimeout 0 | Out-Null

	#Start processing data

    Write-Log "$(Get-Date) - Loading Extended Events"
    Start-Job -Name LoadXeData -ScriptBlock $LoadXeScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder
    Write-Log "$(Get-Date) - Loading Default Traces"
    Start-Job -Name LoadTrace -ScriptBlock $LoadTraceScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder
    Write-Log "$(Get-Date) - Loading Error Logs"
    Start-Job -Name LoadErrorLog -ScriptBlock $LoadErrorLogScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder
    Write-Log "$(Get-Date) - Loading PAL Templates"
    Start-Job -Name LoadPalTemplate -ScriptBlock $LoadPalTemplateScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder
    Write-Log "$(Get-Date) - Loading Performance Counter "
    Start-Job -Name LoadPerfData -ScriptBlock $LoadPerformanceDataScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder
    Write-Log "$(Get-Date) - Loading DMV"
    Start-Job -Name LoadDmv -ScriptBlock $LoadDmvScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder

	Load-Data((Join-Path -Path $DataFolder -ChildPath "Begin"))
	Load-Data((Join-Path -Path $DataFolder -ChildPath "Data"))
	Load-SnapshotData

	Get-Job 'LoadTrace' | Receive-Job | Write-Log "$(Get-Date) - LoadTrace Result: $_"
	Get-Job 'LoadErrorLog' | Receive-Job | Write-Log "$(Get-Date) - LoadErrorLog Result: $_"
	Get-Job 'LoadPalTemplate' | Receive-Job | Write-Log "$(Get-Date) - LoadPalTemplate Result: $_"
	Get-Job 'LoadPerfData' | Receive-Job | Write-Log "$(Get-Date) - LoadPerfData Result: $_"
	Get-Job 'LoadDmv' | Receive-Job | Write-Log "$(Get-Date) - LoadDmv Result: $_"

    #Run Analysis
    Write-Log "$(Get-Date) - Start TSQL Analysis"
    $AnalyzeLibFolder = Join-Path -Path $CurrentLocation -ChildPath  "lib"
    $Scripts = Get-ChildItem -Path $AnalyzeLibFolder -Filter *.sql -Recurse
    ForEach ($script in $Scripts)
    {
        Write-Log "$(Get-Date) - Executing $($script.FullName)"
        #2016-07-19 Invoke-SqlCmd seems to have bugs import XML queries for 5_xEvent.sql, using SqlCmd instead
        #Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -InputFile $script.FullName
        $msg = Sqlcmd -S $InstanceName -d $database -i $Script.FullName -I
	    Write-Log "$(Get-Date) - $script Result: $msg"
    }

	Write-Log "$(Get-Date) - Evaluating policies"
    Start-Job -Name EvalScript -ScriptBlock {Sqlcmd -S $using:InstanceName -d $using:database -Q "Exec uspEvaluate"-I }

    #Generate-FixScript
	Write-Log "$(Get-Date) - Generating Fix Scripts"
    Start-Job -Name GenerateFix -ScriptBlock $GenerateFixScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder

    #Load Query Plan
	#Wait for loading all XEvents before start analyzing query plans
	Get-Job -Name 'LoadXeData' | Wait-Job
	Write-Log "$(Get-Date) - Extended Events loaded"
	Get-Job 'LoadXeData' | Receive-Job | Write-Log "$(Get-Date) - LoadXeData Result: $_"

	Write-Log "$(Get-Date) - Auto Stats by DB"
    Start-Job -Name AutoStatsByDb -ScriptBlock $AutoStatsByDbScript -ArgumentList $InstanceName,$Database

	Write-Log "$(Get-Date) - Load all query and start time"
    Start-Job -Name CalculateStartTime -ScriptBlock $CalculateStartTime -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder

	Start-AnalyzeQueryPlan

	#Load DMV plans
	Write-Log "$(Get-Date) - Loading DMV Plans"
    Start-Job -Name ExportDmv -ScriptBlock $ExportDmvScript -ArgumentList $InstanceName,$Database,$CurrentLocation,$DataFolder

	#Consolidate expensive queries based on plans. Some queries might not have plan dur to sampling ratio
	Analyze-ExpensiveQueries -ServerInstance $InstanceName -Database $Database | Write-Log "$(Get-Date) - Anaylyze-ExpensiveQueries: $_"

	Get-Job | Wait-Job
	Get-Job 'EvalScript' | Receive-Job | Write-Log "$(Get-Date) - EvalScript Result: $_"
	Get-Job 'GenerateFix' | Receive-Job | Write-Log "$(Get-Date) - GenerateFix Result: $_"
	Get-Job 'ExportDmv' | Receive-Job | Write-Log "$(Get-Date) - ExportDmv Result: $_"
	Get-Job 'CalculateStartTime' | Receive-Job | Write-Log "$(Get-Date) - CalculateStartTime Result: $_"


    $EndTime = Get-date;
    Write-Log "$(Get-Date) - ********* Data processing completed. DatabaseN Name: $database Total time used: $(New-TimeSpan -Start $StartTIme -End $EndTime | Select Hours,Minutes,Seconds) ***************`n`n"
    }
}
#endregion Main
