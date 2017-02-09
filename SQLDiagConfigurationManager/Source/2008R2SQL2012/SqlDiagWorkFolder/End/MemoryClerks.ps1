$ScriptV11 = "SELECT [type] as Alloc_Type,SUM(pages_kb + virtual_memory_committed_kb + shared_memory_committed_kb + awe_allocated_kb) AS Alloc_Mem_KB
FROM sys.dm_os_memory_clerks 
WHERE type IN ('CACHESTORE_COLUMNSTOREOBJECTPOOL','CACHESTORE_CLRPROC','CACHESTORE_OBJCP','CACHESTORE_PHDR','CACHESTORE_SQLCP','CACHESTORE_TEMPTABLES',
'MEMORYCLERK_SQLBUFFERPOOL','MEMORYCLERK_SQLCLR','MEMORYCLERK_SQLGENERAL','MEMORYCLERK_SQLLOGPOOL','MEMORYCLERK_SQLOPTIMIZER',
'MEMORYCLERK_SQLQUERYCOMPILE','MEMORYCLERK_SQLQUERYEXEC','MEMORYCLERK_SQLQUERYPLAN','MEMORYCLERK_SQLSTORENG','MEMORYCLERK_XTP',
'OBJECTSTORE_LOCK_MANAGER','OBJECTSTORE_SNI_PACKET','USERSTORE_DBMETADATA','USERSTORE_OBJPERM')
GROUP BY [type]
UNION ALL
SELECT 'Others' as Alloc_Type,SUM(pages_kb + virtual_memory_committed_kb + shared_memory_committed_kb) AS Alloc_Mem_KB
FROM sys.dm_os_memory_clerks 
WHERE type NOT IN ('CACHESTORE_COLUMNSTOREOBJECTPOOL','CACHESTORE_CLRPROC','CACHESTORE_OBJCP','CACHESTORE_PHDR','CACHESTORE_SQLCP','CACHESTORE_TEMPTABLES',
'MEMORYCLERK_SQLBUFFERPOOL','MEMORYCLERK_SQLCLR','MEMORYCLERK_SQLGENERAL','MEMORYCLERK_SQLLOGPOOL','MEMORYCLERK_SQLOPTIMIZER',
'MEMORYCLERK_SQLQUERYCOMPILE','MEMORYCLERK_SQLQUERYEXEC','MEMORYCLERK_SQLQUERYPLAN','MEMORYCLERK_SQLSTORENG','MEMORYCLERK_XTP',
'OBJECTSTORE_LOCK_MANAGER','OBJECTSTORE_SNI_PACKET','USERSTORE_DBMETADATA','USERSTORE_OBJPERM')"
$ScriptV10 = "SELECT [type] as Alloc_Type,SUM(single_pages_kb + multi_pages_kb + virtual_memory_committed_kb + shared_memory_committed_kb + awe_allocated_kb) AS Alloc_Mem_KB
FROM sys.dm_os_memory_clerks 
WHERE type IN ('CACHESTORE_COLUMNSTOREOBJECTPOOL','CACHESTORE_CLRPROC','CACHESTORE_OBJCP','CACHESTORE_PHDR','CACHESTORE_SQLCP','CACHESTORE_TEMPTABLES',
'MEMORYCLERK_SQLBUFFERPOOL','MEMORYCLERK_SQLCLR','MEMORYCLERK_SQLGENERAL','MEMORYCLERK_SQLLOGPOOL','MEMORYCLERK_SQLOPTIMIZER',
'MEMORYCLERK_SQLQUERYCOMPILE','MEMORYCLERK_SQLQUERYEXEC','MEMORYCLERK_SQLQUERYPLAN','MEMORYCLERK_SQLSTORENG','MEMORYCLERK_XTP',
'OBJECTSTORE_LOCK_MANAGER','OBJECTSTORE_SNI_PACKET','USERSTORE_DBMETADATA','USERSTORE_OBJPERM')
GROUP BY [type]
UNION ALL
SELECT 'Others' as Alloc_Type,SUM(single_pages_kb + multi_pages_kb + virtual_memory_committed_kb + shared_memory_committed_kb) AS Alloc_Mem_KB
FROM sys.dm_os_memory_clerks 
WHERE type NOT IN ('CACHESTORE_COLUMNSTOREOBJECTPOOL','CACHESTORE_CLRPROC','CACHESTORE_OBJCP','CACHESTORE_PHDR','CACHESTORE_SQLCP','CACHESTORE_TEMPTABLES',
'MEMORYCLERK_SQLBUFFERPOOL','MEMORYCLERK_SQLCLR','MEMORYCLERK_SQLGENERAL','MEMORYCLERK_SQLLOGPOOL','MEMORYCLERK_SQLOPTIMIZER',
'MEMORYCLERK_SQLQUERYCOMPILE','MEMORYCLERK_SQLQUERYEXEC','MEMORYCLERK_SQLQUERYPLAN','MEMORYCLERK_SQLSTORENG','MEMORYCLERK_XTP',
'OBJECTSTORE_LOCK_MANAGER','OBJECTSTORE_SNI_PACKET','USERSTORE_DBMETADATA','USERSTORE_OBJPERM')"

Switch ($server.VersionMajor) 
{
    11 { Invoke-SqlCmd -ServerInstance $InstanceName -Query $ScriptV11; Break;}
    10 { Invoke-SqlCmd -ServerInstance $InstanceName -Query $ScriptV10; Break;}
}