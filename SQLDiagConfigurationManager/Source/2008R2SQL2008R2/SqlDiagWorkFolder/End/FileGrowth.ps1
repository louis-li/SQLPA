$SqlScript = 'select value from ::fn_trace_getinfo(1) where traceid = 1 and property = 2'
$trcfile = Invoke-SqlCmd -ServerInstance $InstanceName -Query $SqlScript
$logfolder = Split-Path $trcfile.value -Parent

#Copy errorlogs
Copy-Item -Path (Join-Path -Path $logfolder -ChildPath "ERRORLOG*") -Destination $DataFolder

#Keep a copy of default trace for further analysis
Copy-Item -Path (Join-Path -Path $logfolder -ChildPath "log_*.trc") -Destination $DataFolder

#Generate Auto Grow/Shrink
$AutoGrowScript = "	WITH AutoGrow_CTE (databaseid, [filename], Growth, Duration, StartTime, EndTime)
	AS
	(
	SELECT databaseid, [filename], SUM(IntegerData*8) AS Growth, Duration, StartTime, EndTime--, CASE WHEN EventClass =
	FROM ::fn_trace_gettable('$($trcfile.value)', default)
	WHERE EventClass >= 92 AND EventClass <= 95 AND DATEDIFF(hh,StartTime,GETDATE()) < 72 -- Last 24h
	GROUP BY databaseid, [filename], IntegerData, Duration, StartTime, EndTime
	)
	SELECT 'Information' AS [Category], 'Recorded_Autogrows_Lst72H' AS [Information], DB_NAME(database_id) AS Database_Name, 
		mf.name AS logical_file_name, mf.size*8 / 1024 AS size_MB, mf.type_desc,
		(ag.Growth * 8) AS [growth_KB], CASE WHEN is_percent_growth = 1 THEN 'Pct' ELSE 'MB' END AS growth_type,
		Duration/1000 AS Growth_Duration_ms, ag.StartTime, ag.EndTime
	FROM sys.master_files mf
	LEFT OUTER JOIN AutoGrow_CTE ag ON mf.database_id=ag.databaseid AND mf.name=ag.[filename]
	WHERE ag.Growth > 0 --Only where growth occurred
	GROUP BY database_id, mf.name, mf.size, ag.Growth, ag.Duration, ag.StartTime, ag.EndTime, is_percent_growth, mf.growth, mf.type_desc
	ORDER BY Database_Name, logical_file_name, ag.StartTime;"
Invoke-SqlCmd -ServerInstance $InstanceName -Query $AutoGrowScript