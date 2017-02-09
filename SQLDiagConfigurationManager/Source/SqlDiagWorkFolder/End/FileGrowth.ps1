$SqlScript = 'select value from ::fn_trace_getinfo(1) where traceid = 1 and property = 2'
$trcfile = Invoke-SqlCmd -ServerInstance $InstanceName -Query $SqlScript
$logfolder = Split-Path $trcfile.value -Parent

#Copy errorlogs
Copy-Item -Path (Join-Path -Path $logfolder -ChildPath "ERRORLOG*") -Destination $DataFolder

#Keep a copy of default trace for further analysis
Copy-Item -Path (Join-Path -Path $logfolder -ChildPath "log_*.trc") -Destination $DataFolder

#Keep a copy of system health event for further analysis
Copy-Item -Path (Join-Path -Path $logfolder -ChildPath "system_health_*.xel") -Destination $DataFolder
