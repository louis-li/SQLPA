SELECT 'Single_Used_Plan' as [Type], SUM(CAST(size_in_bytes AS bigint))/1024/1024 AS Size_MB, Count(*) as Total_Plans
FROM sys.dm_exec_cached_plans (NOLOCK)
WHERE cacheobjtype LIKE '%Plan%' AND usecounts = 1
UNION ALL
SELECT 'Multiple_Used_Plan' as [Type], SUM(CAST(size_in_bytes AS bigint))/1024/1024 AS Size_MB, Count(*) as Total_Plans
FROM sys.dm_exec_cached_plans (NOLOCK)
WHERE cacheobjtype LIKE '%Plan%' AND usecounts > 1
