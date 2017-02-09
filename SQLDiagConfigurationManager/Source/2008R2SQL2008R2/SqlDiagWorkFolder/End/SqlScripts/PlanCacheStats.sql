  SELECT CONVERT (varchar(30), getdate(), 126) AS 'runtime',*  from 
    (select  objtype, sum(cast(size_in_bytes as bigint) /cast(1024.00 as decimal(38,2)) /1024.00) 'Cache_Size_MB' , count_big (*) 'Entry_Count', isnull(db_name(cast (value as int)),'mssqlsystemresource') 'db name'
	  from  sys.dm_exec_cached_plans AS p CROSS APPLY sys.dm_exec_plan_attributes ( plan_handle ) as t 
      where attribute='dbid'
      group by  isnull(db_name(cast (value as int)),'mssqlsystemresource'), objtype )  t
    order by Entry_Count desc
