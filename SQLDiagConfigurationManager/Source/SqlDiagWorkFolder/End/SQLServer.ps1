$server = New-Object "Microsoft.SqlServer.Management.Smo.Server" $InstanceName

#Linked Servers
#$LinkedServerFile = Join-Path -Path $DataFolder -ChildPath "LinkedServers.csv"
#$Server.LinkedServers | Export-Csv -NoTypeInformation -Path $LinkedServerFile

#databases
$DbFile = Join-Path -Path $DataFolder -ChildPath "Databases.csv"
$server.Databases | Export-Csv -NoTypeInformation -Path $DbFile

#Plan Guides for all databases
$server.Databases | 
    ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query "select db_name() as DatabaseName, * from sys.plan_guides"} | 
        Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "PlanGuides")

#Query store plans for all databases
if ($server.VersionMajor -ge 13)
{
    $server.Databases | 
        ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query "select * from sys.query_store_plan"} | 
            Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "QueryStorePlan")
    $server.Databases | 
        ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query "select * from sys.query_store_query"} | 
            Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "QueryStoreQuery")
    $server.Databases | 
        ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query "select * from sys.query_store_runtime_stats"} | 
            Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "QueryStoreRuntimeStats")
    $server.Databases | 
        ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query "select * from sys.query_store_query_text"} | 
            Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "QueryStoreQueryText")
    $server.Databases | 
        ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query "select * from sys.query_store_runtime_stats_interval"} | 
            Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "QueryStoreRuntimeStatsInterval")
    $server.Databases | 
        ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query "select * from sys.database_query_store_options"} | 
            Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "DatabaseQueryStoreOptions")
}

#Log Files
#$ErrorActionPreference='SilentlyContinue'
#$server.Databases | ForEach-Object {$_.LogFiles} | Export-Clixml (Join-Path -Path $DataFolder -ChildPath "LogFiles")

#Data Files
#$server.Databases | ForEach-Object {$_.FileGroups | ForEach-Object {$_.Files} } | Export-Clixml (Join-Path -Path $DataFolder -ChildPath "DataFiles")

#Tables
$Tables = ($server.Databases) | ForEach-Object {$_.Tables }
Export-Csv -InputObject $Tables (Join-Path -Path $DataFolder -ChildPath "Tables.csv") -NoTypeInformation

#Triggers
$Server.Triggers |Export-Csv (Join-Path -Path $DataFolder -ChildPath "Triggers.csv") -NoTypeInformation

#Database Triggers
$SqlCmd = "
select 
	db_name() as DatabaseName, 
	schema_name(o.schema_id) + '.' + o.name as Parent,
	te.type_desc as Trigger_type, 
	t.Object_id,t.Create_date,t.Modify_date,Is_disabled,Is_not_for_replication,
	Is_instead_of_Trigger,t.Name, t.is_ms_shipped
from sys.triggers t
	inner join sys.objects o on t.parent_id = o.object_id
	inner join sys.trigger_events te on t.object_id = te.object_id"

$server.Databases | 
    ForEach-Object {Invoke-Sqlcmd -ServerInstance $InstanceName -Database $_.Name -Query $SqlCmd }| 
        Export-Clixml -Depth 1 -Path (Join-Path -Path $DataFolder -ChildPath "DatabaseTriggers")

#Configuration
$server.Configuration.Properties | Export-Csv (Join-Path -Path $DataFolder -ChildPath "SystemConfiguration.csv") -NoTypeInformation

#CPU
$server.AffinityInfo.CPUS | Export-Csv (Join-Path -Path $DataFolder -ChildPath "CPUS.csv") -NoTypeInformation

#NUMA
$server.AffinityInfo.NUMANODES | Export-Csv (Join-Path -Path $DataFolder -ChildPath "NumaNodes.csv") -NoTypeInformation

#Count Column Store Indexes
$server.Databases | Foreach {
    $SqlCmd = "SELECT Count(*) as Number
FROM $($_.Name).sys.indexes AS i (NOLOCK)
INNER JOIN $($_.Name).sys.objects AS o (NOLOCK) ON o.[object_id] = i.[object_id]
INNER JOIN $($_.Name).sys.tables AS mst (NOLOCK) ON mst.[object_id] = i.[object_id]
INNER JOIN $($_.Name).sys.schemas AS t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
WHERE i.[type] IN (5,6,7) -- 5 = Clustered columnstore; 6 = Nonclustered columnstore; 7 = Nonclustered hash"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Query $SqlCmd -QueryTimeout 0 

}|Measure-Object -Sum -Property number|Select Sum | 
    Export-Csv (Join-Path -Path $DataFolder -ChildPath "CSIUsed.csv") -NoTypeInformation

#Untrusted constraints
$server.databases | Foreach { $SqlCmd ="
        USE $($_.Name)
        SELECT 
	        db_id() AS [databaseID], 
	        db_name() AS [database_name], 
	        o.[schema_id], t.name AS [schema_name], 
	        mst.[object_id], mst.name AS [table_name], 
	        FKC.name AS [constraint_name], 
	        'ForeignKey' As [constraint_type]
        FROM sys.foreign_keys FKC (NOLOCK)
        INNER JOIN sys.objects o (NOLOCK) ON FKC.parent_object_id = o.[object_id]
        INNER JOIN sys.tables mst (NOLOCK) ON mst.[object_id] = o.[object_id]
        INNER JOIN sys.schemas t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
        WHERE 
	        o.type = 'U' 
	        AND FKC.is_not_trusted = 1 
	        AND FKC.is_not_for_replication = 0
        GROUP BY 
	        o.[schema_id], mst.[object_id], FKC.name, t.name, mst.name
        UNION ALL
        SELECT 
	        db_id() AS [databaseID], 
	        db_name() AS [database_name], 
	        t.[schema_id], t.name AS [schema_name], 
	        mst.[object_id], mst.name AS [table_name], 
	        CC.name AS [constraint_name], 'Check' As [constraint_type]
        FROM sys.check_constraints CC (NOLOCK)
        INNER JOIN sys.objects o (NOLOCK) ON CC.parent_object_id = o.[object_id]
        INNER JOIN sys.tables mst (NOLOCK) ON mst.[object_id] = o.[object_id]
        INNER JOIN sys.schemas t (NOLOCK) ON t.[schema_id] = mst.[schema_id]
        WHERE o.type = 'U' AND CC.is_not_trusted = 1 AND CC.is_not_for_replication = 0 AND CC.is_disabled = 0
        GROUP BY t.[schema_id], mst.[object_id], CC.name, t.name, mst.name
        ORDER BY mst.name, [constraint_name];
    "
    Invoke-Sqlcmd -ServerInstance $InstanceName -Query $SqlCmd -QueryTimeout 0 
    } |     Export-Csv (Join-Path -Path $DataFolder -ChildPath "UntrustedConstraints.csv") -NoTypeInformation

#Scan for query hints
<#
$server.databases | Foreach { $SqlCmd = "USE $($_.name);
        SELECT db_id(), ss.name AS [Schema_Name], so.name AS [Object_Name], 
        so.type_desc--,qh.hint
        FROM sys.sql_modules sm
        INNER JOIN sys.objects so ON sm.[object_id] = so.[object_id]
        INNER JOIN sys.schemas ss ON so.[schema_id] = ss.[schema_id]
        --inner join dbo.QueryHints qh on sm.[definition] like '%'+ qh.hint +'%'"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Query $SqlCmd -QueryTimeout 0 
    } |     Export-CLixml (Join-Path -Path $DataFolder -ChildPath "QueryHint") -Depth 1
#>

$ErrorActionPreference = 'Continue'
#Return SQL Server
$server | SELECT *