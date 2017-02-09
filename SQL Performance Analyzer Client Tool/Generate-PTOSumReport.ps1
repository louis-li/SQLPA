[cmdletbinding()]
param (
    $InstanceName = "Localhost",
    $Database = "SQLPTOSummary",    
    [Parameter(Mandatory=$True)]
	$BeforeDatabase,
	[Parameter(Mandatory=$True)]
    $AfterDatabase,
	[Parameter(Mandatory=$True)]
    $CurrentLocation,
    [switch]$DropExisting = $true
)


#region Create-DataTable,ConvertTo-Table, Upload-Data


####################### 
function Get-SqlType 
{ 
    param([string]$TypeName) 
 
    switch ($TypeName)  
    { 
        'Boolean' {[Data.SqlDbType]::Bit} 
        'Byte[]' {[Data.SqlDbType]::VarBinary} 
        'Byte'  {[Data.SQLDbType]::VarBinary} 
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
    Write-Error $message
}
  
} #Create-DataTable

#######################
function Get-Type
{
    param($type)

$types = @(
'System.Boolean',
'System.Byte[]',
'System.Byte',
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
                            write-host $property -ForegroundColor Green
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
        Write-Output @(,($dt))
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
        continue
    }

} #Upload-Data

#endregion

#region Import Counters
function Import-Counters
{
    Trap {
        Write-Log "$(Get-Date) - Import Counters failed --> $($_.exception.message)"
        Write-Log "$(Get-Date) - Import Counters failed --> $($_.exception.StackTrace)"
        Continue;
    }
    $CounterValueTable = "CounterValues"
    Write-Log "$(Get-Date) - Read Counter File: 'counters.csv'"

    $CounterList = Import-Csv -Path (Join-Path $CurrentLocation "counters.csv")

    #Save CounterList
    $DatabaseTable = ConvertTo-Table -InputObject $CounterList
    Create-DataTable -ServerInstance $InstanceName -Database $Database -TableName "CounterList" -DataTable $DatabaseTable
    Upload-Data -ServerInstance $InstanceName -Database $Database -TableName "CounterList" -Data $DatabaseTable -ErrorAction Stop

    #Generate scripts
    $Script = ';With cteCounters As (Select null  as DatabaseName,null as CounterName,null as DisplayName,null as RecordIndex,null as CounterValue'

    foreach ($counter in $CounterList)
    {
        if ([string]::IsNullOrEmpty($counter.CounterValue)) {$CounterValue = "CounterValue"} else {$CounterValue = $Counter.CounterValue}
        if ([string]::IsNullOrEmpty($counter.DisplayName)) {$DisplayName = $counter.CounterName} else {$DisplayName = $Counter.DisplayName}
        $WhereString = "Where CounterName = '$($counter.CounterName)'"
        if (![string]::IsNullOrEmpty($counter.InstanceName)) {$WhereString += " AND InstanceName='$($Counter.InstanceName)'"} 
        if (![string]::IsNullOrEmpty($counter.ObjectName)) {$WhereString += " AND ObjectName='$($Counter.ObjectName)'"} 

        $Script += "`nUNION ALL`nselect '$($SelectedDbs[0].Name)',CounterName,'$DisplayName',RecordIndex,$CounterValue 
    from [$($SelectedDbs[0].Name)].dbo.counterdata d inner join [$($SelectedDbs[0].Name)].dbo.CounterDetails dt
    On d.CounterID = dt.counterID`n$WhereString"

        for ($idx = 1; $idx -le $SelectedDbs.Count - 1;$Idx ++)
        {
            $script += "`nUNION ALL
    select '$($SelectedDbs[$idx].Name)',CounterName,'$DisplayName' as DisplayName,RecordIndex,$CounterValue 
    from [$($SelectedDbs[$idx].Name)].dbo.counterdata d inner join [$($SelectedDbs[$idx].Name)].dbo.CounterDetails dt
	    On d.CounterID = dt.counterID`n$WhereString"
        }
    }

    $script += ") Select * Into $Database.dbo.$CounterValueTable From cteCounters Where DatabaseName IS NOT NULL"
    $AggrScript = "If Exists (Select * from tempdb.sys.tables where name = 'tmpCounters') DROP TABLE tempdb.dbo.tmpCounters
    ;With counters as (select DatabaseName, CounterName, DisplayName, min(countervalue) as MinValue,max(countervalue) as MaxValue
    , avg(countervalue) as AvgValue
    from dbo.$CounterValueTable`nGroup by DatabaseName,CounterName, DisplayName) 
    Select * into tempdb.dbo.tmpCounters From counters Where CounterName IS NOT NULL AND DatabaseName = "

    #Errors when using script directly, save it to file and execute file
    $SqlFile = Join-Path $CurrentLocation -ChildPath "tmpLoadCounter.sql"
    $Script | Out-File $SqlFile
    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[0].Name -InputFile $SqlFile  | Out-Null

    #Process Aggregation
    $Tablename = "CounterAggr"
    $CreateAggrScript = "Create Table dbo.$Tablename
    (
    DatabaseName varchar(200)
    ,CounterName varchar(200)
    ,DisplayName varchar(200)
    ,MinValue_1 decimal(19,1)
    ,MaxValue_1 decimal(19,1)
    ,AvgValue_1 decimal(19,1)"

    for ($idx = 2; $idx -le $SelectedDbs.Count;$Idx ++)
    {
        $CreateAggrScript += "`n,MinValue_$idx decimal(19,4)
    ,MaxValue_$idx decimal(19,1)
    ,AvgValue_$idx decimal(19,1)"
    }

    $CreateAggrScript +=",id int identity)"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $CreateAggrScript  | Out-Null

    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query ($AggrScript+ "'$($SelectedDbs[0].Name)'") | Out-Null

    $Counters = Invoke-Sqlcmd -ServerInstance $InstanceName -Database master -Query "Select * from tempdb.dbo.tmpCounters"

    Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $Tablename -Data $Counters

    for ($idx = 2; $idx -le $SelectedDbs.Count;$Idx ++)
    {
        Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query ($AggrScript+ "'$($SelectedDbs[$idx-1].Name)'") | Out-Null

        $Updatescript = "Update dbo.$Tablename
        Set minValue_$idx = tc.minValue,
        maxValue_$idx = tc.maxValue,
        avgValue_$idx = tc.avgValue 
        FROM dbo.$Tablename c inner join tempdb.dbo.tmpCounters tc on c.CounterName = tc.CounterName"

        Invoke-Sqlcmd -ServerInstance $InstanceName -Database $database -Query $Updatescript | Out-Null

    }
}
#endregion

function Import-CpuTime
{
    #Process Aggregation
    $Tablename = "CpuTime"

    #Define Create Script
    $Script = "With cteCpuTime as (
    select sum(c_cpu_time) as cpu_time from xel.sql_batch_completed
    UNION ALL
    select sum(c_cpu_time) from [xel].[rpc_completed]
    )
    Select db_name() as DatabaseName,sum(cpu_Time)/1000000 as cput_time_s from cteCpuTime"

    $Data = Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[0].Name  -Query $Script -QueryTimeout 0
    $DatabaseTable = ConvertTo-Table -InputObject $Data
    Create-DataTable -ServerInstance $InstanceName -Database $Database -TableName $Tablename -DataTable $DatabaseTable

    Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $Tablename -Data $Data
 
    for ($idx = 2; $idx -le $SelectedDbs.Count;$Idx ++)
    {
   
        $Data = Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[$idx-1].Name  -Query $Script -QueryTimeout 0

        Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $Tablename -Data $Data

    }
}

function Import-ExpensiveQueries
{
    #Process Aggregation
    $Tablename = "ExpensiveQueries"

    #Define Create Script
    #$Script = "select top 10 db_name() as DatabaseName,row_number,cpu_time/1000000 as cpu_time_s,executions,sql_text from [xel].[expensive_query] order by cpu_time desc"
	$script = "Select db_name() as DatabaseName,query_id,cpu_time/1000000 as cpu_time_s,executions,sql_text,percentage * 10000.00 as percentage from xel.expensive_query_stats_cpu"
    $Data = Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[0].Name  -Query $Script -QueryTimeout 0
    $DatabaseTable = ConvertTo-Table -InputObject $Data
    Create-DataTable -ServerInstance $InstanceName -Database $Database -TableName $Tablename -DataTable $DatabaseTable -MaxLength 0

    Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $Tablename -Data $Data
 
    for ($idx = 2; $idx -le $SelectedDbs.Count;$Idx ++)
    {
   
        $Data = Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[$idx-1].Name  -Query $Script -QueryTimeout 0

        Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $Tablename -Data $Data

    }


    $vwScript = "Create View vwQueryCompare
    AS Select q1.databaseName as database_1,q2.databaseName as database_2, q1.query_id as ID,q1.sql_text as sql_text_1,q2.sql_text as sql_text_2
		,q1.cpu_time_s as cpu_time_s_1,q2.cpu_time_s as cpu_time_s_2
		,q1.executions as executions_1,q2.executions as executions_2
		, q1.cpu_time_s*1.0/q1.executions as avg_cpu_time_1
		, q2.cpu_time_s*1.0/q2.executions as avg_cpu_time_2 
		, q1.percentage as percentage_1
		, q2.percentage as percentage_2
	from dbo.ExpensiveQueries q1 Inner Join dbo.ExpensiveQueries q2 on q1.query_id=q2.query_id
    Where q1.DatabaseName = '$($SelectedDbs[0].Name)'
    And q2.DatabaseName = '$($SelectedDbs[1].Name)'"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database  -Query $vwScript
}

function Import-Waits
{
    #Process Aggregation
    $Tablename = "Waits"
    $AggrTablename = "WaitsAggr"
    $CreateScript = "Create Table dbo.$Tablename
    (
    Updated bit DEFAULT 0
    ,Waits_1 varchar(200)
    ,Percentage_1 decimal(5,3) DEFAULT 0
    "

    for ($idx = 2; $idx -le $SelectedDbs.Count;$Idx ++)
    {
        $CreateScript += "`n,Waits_$idx varchar(200)
    ,Percentage_$idx decimal(5,3)  DEFAULT 0"
    }

    $CreateScript +=",id int identity)"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $CreateScript  | Out-Null

    #Insert 10 empty records
    for ($i = 0; $i -lt 10;$i++) { Invoke-SqlCmd -ServerInstance $InstanceName -Database $Database -Query "Insert into dbo.$Tablename (Waits_1) Values(null)"  | Out-Null}
    $WaitScript = "Select WaitType,Percentage from dbo.WaitStats Order By Percentage" 
    for ($idx = 1; $idx -le $SelectedDbs.Count;$Idx ++)
    {
        $Updatescript = ";WITH cteWaits as (select row_number() Over (Order BY cast(percentage as decimal(5,3)) desc) as id, Waittype,percentage 
            from dbo.waitstats)
        Update $Database.dbo.$Tablename
        Set Waits_$idx = w.WaitType,
        Percentage_$idx = w.Percentage,
        Updated = 1
        FROM $Database.dbo.$Tablename c inner join cteWaits w on c.id = w.id"

        Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[$idx-1].Name -Query $Updatescript | Out-Null

    }

    #Aggr
    $CreateAggrScript = "Create Table dbo.$AggrTablename
    (
    DatabaseName varchar(200)
    ,Wait_S decimal(19,2) 
    ,Resource_S decimal(19,2) 
    ,Signal_S decimal(19,2) 
    ,WaitCount decimal(19,2) )"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $CreateAggrScript | Out-Null
    $InsertScript = "INSERT INTO $Database.dbo.$AggrTablename select db_name(),SUM(CAST(wait_s AS Decimal(19,4))) as Wait_S,SUM(CAST(Resource_S AS Decimal(19,4))) As Resource_S,SUM(CAST(Signal_S AS Decimal(19,4))) AS Signal_S, SUM(CAST(WaitCount AS BIGINT)) AS WaitCount from dbo.waitstats"
    foreach ($db in $SelectedDbs)
    {
        Invoke-Sqlcmd -ServerInstance $InstanceName -Database $db.Name -Query $InsertScript | Out-Null
    
    }
}

function Import-xEvents
{
    #Process Aggregation
    $Tablename = "xEvents"

    #Define Create Script
    $CreateScript = "Create Table dbo.$Tablename
    (
    WarningType varchar(200)
    ,Ocurrence_1 BIGINT DEFAULT 0
    "

    for ($idx = 2; $idx -le $SelectedDbs.Count;$Idx ++)
    {
        $CreateScript += "`n,Ocurrence_$idx BIGINT DEFAULT 0"
    }

    $CreateScript +=",id int identity)"
    Invoke-Sqlcmd -ServerInstance $InstanceName -Database $Database -Query $CreateScript  | Out-Null

    $Script = "Select 'sql_batch_completed', count(*) as occurrence,1 as analyzed from xel.sql_batch_completed
    UNION ALL
    Select 'rpc_completed', count(*) as occurrence,1 as analyzed from xel.rpc_completed
    UNION ALL
    Select 'page_split', count(*) as occurrence,1 as analyzed from xel.transaction_log
    UNION ALL
    Select 'auto_stats', count(*) as occurrence,1 as analyzed from xel.auto_stats
    UNION ALL
    Select 'blocked_process_report', count(*) as occurrence,1 as analyzed from xel.blocked_process_report
    UNION ALL
    Select 'hash_warning', count(*) as occurrence,1 as analyzed from xel.hash_warning
    UNION ALL
    Select 'missing_join_predicate', count(*) as occurrence,1 as analyzed from xel.missing_join_predicate
    UNION ALL
    Select 'optimizer_timeout', count(*) as occurrence,1 as analyzed from xel.optimizer_timeout
    UNION ALL
    Select 'plan_affecting_convert', count(*) as occurrence,1 as analyzed from xel.plan_affecting_convert
    UNION ALL
    Select 'sort_warning', count(*) as occurrence,1 as analyzed from xel.sort_warning
    UNION ALL
    Select 'xml_deadlock_report', count(*) as occurrence,1 as analyzed from xel.xml_deadlock_report
    Order by occurrence desc"

    $Data = Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[0].Name  -Query $Script -QueryTimeout 0

    Upload-Data -ServerInstance $InstanceName -Database $Database -TableName $Tablename -Data $Data
 
    for ($idx = 2; $idx -le $SelectedDbs.Count;$Idx ++)
    {
        $Updatescript = ";With warning as
        (Select 'sql_batch_completed' as warning_type, count(*) as occurrence,1 as analyzed from xel.sql_batch_completed
    UNION ALL
    Select 'rpc_completed', count(*) as occurrence,1 as analyzed from xel.rpc_completed
    UNION ALL
    Select 'page_split', count(*) as occurrence,1 as analyzed from xel.transaction_log
    UNION ALL
    Select 'auto_stats', count(*) as occurrence,1 as analyzed from xel.auto_stats
    UNION ALL
    Select 'blocked_process_report', count(*) as occurrence,1 as analyzed from xel.blocked_process_report
    UNION ALL
    Select 'hash_warning', count(*) as occurrence,1 as analyzed from xel.hash_warning
    UNION ALL
    Select 'missing_join_predicate', count(*) as occurrence,1 as analyzed from xel.missing_join_predicate
    UNION ALL
    Select 'optimizer_timeout', count(*) as occurrence,1 as analyzed from xel.optimizer_timeout
    UNION ALL
    Select 'plan_affecting_convert', count(*) as occurrence,1 as analyzed from xel.plan_affecting_convert
    UNION ALL
    Select 'sort_warning', count(*) as occurrence,1 as analyzed from xel.sort_warning
    UNION ALL
    Select 'xml_deadlock_report', count(*) as occurrence,1 as analyzed from xel.xml_deadlock_report
    )
        Update $Database.dbo.$Tablename
        Set Ocurrence_$idx = w.occurrence
        FROM $Database.dbo.$Tablename c inner join warning w on c.WarningType = w.warning_type"

        Invoke-Sqlcmd -ServerInstance $InstanceName -Database $SelectedDbs[$idx-1].Name -Query $Updatescript  -QueryTimeout 0 | Out-Null

    }

}

function Write-Log($LogMsg)
{
    if ($CurrentLocation -ne $null)
    {
        $LogMsg | Out-File (Join-Path $CurrentLocation "SummaryReport.log") -Append
    }
}

#region main
Write-Log "$(Get-Date) - Start comparing data captures"
Write-Log "$(Get-Date) - Before Data:$BeforeDatabase"
Write-Log "$(Get-Date) - After Data:$AfterDatabase"
Import-Module SqlPS -DisableNameChecking

#Select databases
#$SelectedDbs = Invoke-Sqlcmd -ServerInstance $InstanceName -Database "master" -Query "Select Name from sys.databases order by Name" |`
#     Out-GridView -PassThru -Title "Select databases to generate summary report" | Sort Name
$SelectedDbs = $BeforeDatabase,$AfterDatabase | Select @{Name="Name";Expression={$_}}
#If database exists, drop it
$DbExists = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Select 1 where exists(select * from sys.databases where name = '$Database')"

if ($DbExists -ne $null)
{
    if ($DropExisting)
    {
        #Drop existing database
        Write-Host "$(Get-Date) - Dropping Existing Database - $Database" -ForegroundColor Green
        Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Alter Database $Database Set Single_User with Rollback immediate; Drop Database $Database"
    }
    else
    {
        #Stop processing
        Write-Host "$(Get-Date) - $Database exists. Analysis will now stop. To drop existing database, use paramter -DropExisting" -ForegroundColor Green
        Return;
    }
}

#Create database
Write-Log "$(Get-Date) - Creating Database - $Database"
Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Create Database $Database" -QueryTimeout 0 | Out-Null
Invoke-Sqlcmd -ServerInstance $InstanceName -Query "Alter Database $Database Set Recovery Simple"

#Save selected database names in database
$DatabaseTable = ConvertTo-Table -InputObject $SelectedDbs
Create-DataTable -ServerInstance $InstanceName -Database $Database -TableName "Databases" -DataTable $DatabaseTable
Upload-Data -ServerInstance $InstanceName -Database $Database -TableName "Databases" -Data $DatabaseTable -ErrorAction Stop


#Load scripts
$Scripts = Get-ChildItem -Path (Join-Path -Path $CurrentLocation -ChildPath  "SummaryReportScripts") -Filter *.ps1 -Recurse

Write-Log "$(Get-Date) - Importing counters"
Write-Log "$(Get-Date) - Current Location $CurrentLocation"
Import-Counters

Write-Log "$(Get-Date) - Importing CPU time"
Import-CpuTime

Write-Log "$(Get-Date) - Importing Expensive Queries"
Import-ExpensiveQueries

Write-Log "$(Get-Date) - Importing Waits"
Import-Waits

Write-Log "$(Get-Date) - Importing Extended Events"
Import-xEvents

Write-Log "$(Get-Date) - Comparison completed. View reports for details"
#endregion