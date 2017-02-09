Create Table AllTraceFlags(TraceFlag int primary key, [Description] varchar(max));
GO
Insert into AllTraceFlags Values
(174,'TF174 increases the number of plan cache entries, see KB 3026083')
,(634,'TF634 disables the background columnstore compression task')
,(661,'TF661 disables the ghost cleanup background task] http://support.microsoft.com/kb/920093 ')
,(845,'TF845 supports locking pages in memory in SQL Server Standard Editions]')
,(834,'TF834 (Large Page Support for BP) is discouraged when Columnstore Indexes are used] http://support.microsoft.com/kb/920093')
,(1117,'TF1117 autogrows all files at the same time and affects all databases')
,(1118,'TF1118 forces uniform extent allocations instead of mixed page allocations http://support.microsoft.com/kb/328551')
,(1211,'TF1211 disables lock escalation based on memory pressure, or based on number of locks, increasing the amount of locks held')
,(1224,'TF1224 disables lock escalation based on the number of locks, and only escalates locks under memory pressure, increasing the amount of locks held')
,(1229,'TF1229 disables lock partitioning, which is a locking mechanism optimization on 16+ CPU servers http://blogs.msdn.com/b/psssql/archive/2012/08/31/strange-sch-s-sch-m-deadlock-on-machines-with-16-or-more-schedulers.aspx')
,(1236,'When the number of locks (resource type = DATABASE) for a specific database exceeds a certain threshold, you experience the following performance problems:Elevated values occur for LOCK_HASH spinlock count. Queries or operations that require database locks take a long time to be completed. https://support.microsoft.com/en-us/kb/2926217')
,(2330,'TF2330 supresses data collection into sys.dm_db_index_usage_stats, which can lead to a non-yielding condition in SQL 2005 http://support.microsoft.com/default.aspx?scid=kb;en-US;2003031')
,(2335,'TF2335 generates plans that are more conservative in terms of memory consumption when executing a query. Recommended when server has more than 100GB of memory --http://support.microsoft.com/kb/2413549/en-us')
,(2371,'TF2371 changes the fixed rate of the 20pct threshold for update statistics into a dynamic percentage rate http://blogs.msdn.com/b/saponsqlserver/archive/2011/09/07/changes-to-automatic-update-statistics-in-sql-server-traceflag-2371.aspx')
,(2389,'Ascending Keys and Auto Quick Corrected Statistics https://blogs.msdn.microsoft.com/ianjo/2006/04/24/ascending-keys-and-auto-quick-corrected-statistics/')
,(2390,'Ascending Keys and Auto Quick Corrected Statistics https://blogs.msdn.microsoft.com/ianjo/2006/04/24/ascending-keys-and-auto-quick-corrected-statistics/')
,(3226,'By default, every successful backup operation adds an entry in the SQL Server error log and in the system event log. If you create very frequent log backups, these success messages accumulate quickly, resulting in huge error logs in which finding other messages is problematic. With this trace flag, you can suppress these log entries. This is useful if you are running frequent log backups and if none of your scripts depend on those entries. https://msdn.microsoft.com/en-us/library/ms188396.aspx')
,(4135,'TF4135 supports fixes and enhancements on the query optimizer')
,(4136,'TF4136 disables the parameter sniffing process, which is equivalent to adding an OPTIMIZE FOR UNKNOWN hint to each query which references a parameter --http://support.microsoft.com/kb/980653/en-us')
,(4137,'TF4137 supports fixes and enhancements on the query optimizer http://support.microsoft.com/kb/2658214')
,(4199,'TF4199 supports fixes and enhancements on the query optimizer http://support.microsoft.com/kb/2801413')
,(7471,'TF7471 is a global trace flag and can be specified as a startup parameter by using the dbcc traceon (7471,-1) or the -T7471 option in the command line argument.Running multiple UPDATE STATISTICS for different statistics on a single table concurrently is available. https://support.microsoft.com/en-us/kb/3156157')
,(8015,'TF8015 ignores NUMA detection http://blogs.msdn.com/b/psssql/archive/2010/04/02/how-it-works-soft-numa-i-o-completion-thread-lazy-writer-workers-and-memory-nodes.aspx')
,(8032,'change the size of the cache https://support.microsoft.com/en-us/kb/2964518')
,(8048,'TF8048 changes memory grants on NUMA from NODE based partitioning to CPU based partitioning.Consider enabling TF8048 to change memory grants on NUMA from NODE based partitioning to CPU based partitioning. Look in dm_os_wait_stats and dm_os_spin_stats for wait types (CMEMTHREAD and SOS_SUSPEND_QUEUE). http://blogs.msdn.com/b/psssql/archive/2011/09/01/sql-server-2008-2008-r2-on-newer-machines-with-more-than-8-cpus-presented-per-numa-node-may-need-trace-flag-8048.aspx')
,(9024,'In AlwaysOn Availability Groups the log write waits counter for the log buffer on the SQL Server instance has a high value. You will also notice high values for CMEMTHREAD and WRITELOG wait types in dynamic management views (DMVs). Additionally, mini dump files are generated. https://support.microsoft.com/en-us/kb/2809338')
GO

Create Table QueryHints
(
Id int identity primary key,
Hint nvarchar(200) not null
)
GO
Insert into QueryHints Values 
('HASH GROUP')
,('ORDER GROUP')
,('LOOP JOIN')
,('HASH JOIN')
,('MERGE JOIN')
,('EXPAND VIEWS')
,('OPTION (FAST ')
,('FORCE ORDER')
,('IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX')
,('KEEP PLAN')   
,('KEEPFIXED PLAN')
,('MAX_GRANT_PERCENT')
,('MIN_GRANT_PERCENT')
,('OPTION (MAXDOP ')   
,('MAXRECURSION')
,('NO_PERFORMANCE_SPOOL')
,('OPTIMIZE FOR (') 
,('OPTIMIZE FOR UNKNOWN')
,('PARAMETERIZATION SIMPLE')
,('PARAMETERIZATION FORCED')
,('OPTION (RECOMPILE')
,('ROBUST PLAN')
,('USE PLAN N''')
,('TABLE HINT')
GO

Create View vwCachedPlan
As

select cp.*
,(Select count(*) 
	from dbo.queryhints qh 
	where cp.[text]  like '%'+ qh.hint +'%') as IsQueryHinted
,Case when cast(cp.query_plan as nvarchar(max)) like '%UserDefinedFunction%' 
	Then 1 ELSE 0 END as UseUDF
,Case when cast(cp.query_plan as nvarchar(max)) like '%MissingIndexGroup%' 
	Then 1 ELSE 0 END as MissingIndexes
,Case when cast(cp.query_plan as nvarchar(max)) like '%CONVERT_IMPLICIT%' 
	And cast(cp.query_plan as nvarchar(max)) like '%Index Scan%' 
	Then 1 ELSE 0 END as ImplicitConversion
,Case when cast(cp.query_plan as nvarchar(max)) like '%<CursorType%' 
	Then 1 ELSE 0 END as CursorPresent
,Case when cast(cp.query_plan as nvarchar(max)) like '%<Warnings NoJoinPredicate="true"%' 
	Then 1 ELSE 0 END as NoJoin
,Case when cast(cp.query_plan as nvarchar(max)) like '%<Warnings ColumnsWithNoStatistics%' 
	Then 1 ELSE 0 END as ColumnsWithNoStatistics
,Case when cast(cp.query_plan as nvarchar(max)) like '%<SpillToTempDb SpillLevel%' 
	Then 1 ELSE 0 END as SpillToTempDb
,Case when cast(cp.query_plan as nvarchar(max)) like '%<PlanAffectingConvert ConvertIssue="Seek Plan" Expression="CONVERT_IMPLICIT%' 
	Then 1 ELSE 0 END as PlanAffectingConvert
,Case when cast(cp.query_plan as nvarchar(max)) like '%<PlanAffectingConvert ConvertIssue="Cardinality Estimate%' 
	Then 1 ELSE 0 END as PlanAffectingConvertCE
,Case when cast(cp.query_plan as nvarchar(max)) like '%<Warnings UnmatchedIndexes="true"%' 
	Then 1 ELSE 0 END as UnmatchedIndex
from 
	CachedPlan cp 
Go


Create View vwDupIndex
As
SELECT I.* FROM dbo.Indexes I INNER JOIN dbo.Indexes I2 ON I.[databaseID] = I2.[databaseID] AND I.[objectID] = I2.[objectID] AND I.[indexID] <> I2.[indexID] 
	AND I.[KeyCols] = I2.[KeyCols] AND (I.IncludedCols = I2.IncludedCols OR (I.IncludedCols IS NULL AND I2.IncludedCols IS NULL))
	AND ((I.filter_definition = I2.filter_definition) OR (I.filter_definition IS NULL AND I2.filter_definition IS NULL))
GO

Create Function dbo.ufnNumberOfCpusPerNuma()
Returns Int
As
Begin
	Declare @number int
	Select @number = Count(*) from dbo.CPUS	Group by NumaNodeID	order by Count(*) Desc

	Return @number
End
GO

Create Function ufnMAXDOP()
Returns Int
AS
Begin
	Declare @return int
	Select @return = RunValue from dbo.SystemConfiguration 	Where Number = 1539 -- max degree of parallelism
	Return @return
End
GO

Create Function ufnThreadStackMem()
Returns Bigint
As
Begin
	Declare @return bigint,@NumberofThread int

	--Thread stack:Get Worker Thread * 2MB 
	select @NumberOfThread = max_workers_count from dbo.DmOsSysInfo

	Select @return = @NumberOfThread * 2 --MB
	Return @return
End
GO

Create Function ufnAvailablePhysicalMemInMb()
Returns Bigint
As
Begin
	Declare @return bigint

	Select @return =  available_physical_memory_kb /1024 from dbo.DmOsSysMem
	Return @return
End
GO

Create Function ufnTotalPhysicalMemInMb()
Returns Bigint
As
Begin
	Declare @return bigint

	Select @return = total_physical_memory_kb /1024 from dbo.DmOsSysMem

	Return @return
End
GO


Create Function dbo.ufnCompLevelCheck()
Returns int
As
Begin
	Declare @return int,@level varchar(10)

	Select @level = 'Version' + VersionMajor+VersionMinor from dbo.SqlServer

	Select @return = Count(*) from dbo.databases
	Where CompatibilityLevel <> @level

	Return @return	
End
GO

Create Function dbo.ufnTF845()
Returns int
As
Begin
	Declare @return int

	If (Exists (Select * from dbo.SqlServer Where VersionMajor >=11) and (exists (select * from sys.tables where name='TraceFlag')))
		select @return = TraceFlag from dbo.traceflag Where TraceFlag = 845
	Return @return	
End
GO

Create Function dbo.ufnTF834()
Returns int
As
Begin
	Declare @return int

	If (exists (select * from sys.tables where name='TraceFlag')
		and (exists (select * from dbo.csiused where sum > 0)))
		select @return = TraceFlag from dbo.traceflag Where TraceFlag = 834
	Return @return	
End
GO


Create Function dbo.ufnTFExists(@TF int)
Returns int
As
Begin
	Declare @return int

	If (exists (select * from sys.tables where name='TraceFlag'))
		select @return = TraceFlag from dbo.traceflag Where TraceFlag = @TF
	Return @return	
End
GO
Create Function dbo.ufnTF4135()
Returns int
As
Begin
	Declare @return int, @sqlmajorver int, @sqlminorver int,@sqlbuild int

	If (exists (select * from sys.tables where name='TraceFlag'))
	Begin
		select @sqlmajorver = VersionMajor,@sqlminorver=VersionMinor,@sqlbuild = BuildNumber From dbo.SqlServer
		if (@sqlmajorver = 10 and @sqlminorver = 0 and (@sqlbuild >= 1787 and @sqlbuild < 1818 or  @sqlbuild >= 2531 and @sqlbuild < 2766) 
			or @sqlmajorver = 10 and @sqlminorver = 50 and (@sqlbuild >= 1600 and @sqlbuild <1702))
		select @return = TraceFlag from dbo.traceflag Where TraceFlag = 4199 and global = 1
	End
	Return @return	
End
GO

Create Function dbo.ufnTF4199()
Returns int
As
Begin
	Declare @return int, @sqlmajorver int, @sqlminorver int,@sqlbuild int

	If (exists (select * from sys.tables where name='TraceFlag'))
	Begin
		select @sqlmajorver = VersionMajor,@sqlminorver=VersionMinor,@sqlbuild = BuildNumber From dbo.SqlServer
		if (@sqlmajorver = 10 and @sqlminorver = 0 and (@sqlbuild >= 1818 and @sqlbuild < 2531 ) 
			or @sqlmajorver = 10 and @sqlminorver = 50 and (@sqlbuild >=1702))
		select @return = TraceFlag from dbo.traceflag Where TraceFlag = 4135 and global = 1
	End
	Return @return	
End
GO

Create Function dbo.ufnTF8048()
Returns Int
As
Begin
	Declare @return int = 0

	If (exists (select * from sys.tables where name='TraceFlag') and dbo.ufnNumberOfCpusPerNuma() > 8)
	Begin

			--WHEN (0x20 = creation_options & 0x20) THEN 'Global PMO. Cannot be partitioned by CPU/NUMA Node. TF8048 not applicable.'
			--	WHEN (0x40 = creation_options & 0x40) THEN 'Partitioned by CPU. TF8048 not applicable.'
			--	WHEN (0x80 = creation_options & 0x80) THEN 'Partitioned by Node. Use TF8048 to further partition by CPU'
		
		If (Exists(SELECT *  FROM sys.dm_os_memory_objects Where 0x80 = creation_options & 0x80))
				SELECT @return = 1
		
	End
	Return @return	
End
GO

Create Function dbo.ufnSysCfgInt(@name varchar(128))
Returns Bigint
Begin
	Declare @return bigint

	Select @return = RunValue from dbo.SystemConfiguration Where DisplayName =@name
	
	Return @return	
End
GO

Create Function dbo.ufnSysCfgAffinMaskAndAffinIoMask()
Returns varchar(100)
Begin
	Declare @return varchar(100) , @affin int, @affinIO int, @affin64 int,@affinIO64 int

	Select @affin = RunValue from dbo.SystemConfiguration Where DisplayName ='affinity mask'
	Select @affinIO = RunValue from dbo.SystemConfiguration Where DisplayName ='affinity I/O mask'
	Select @affin64 = RunValue from dbo.SystemConfiguration Where DisplayName ='affinity64 mask'
	Select @affinIO64 = RunValue from dbo.SystemConfiguration Where DisplayName ='affinity64 I/O mask'

	Select @return = Case When (@affin & @affinIO <> 0) OR (@affin64 & @affinIO64 <> 0) then 'Overlapping' ELSE 'OK' END

	Return @return	
End
GO

Create Function dbo.ufnSysCfgBlockedProcessThreshold()
Returns varchar(20)
Begin
	Declare @return varchar(20) 

	Select @return = Case when RunValue >0 And RunValue < 5 Then 'Not defaut' ELSE 'OK' END 
	from dbo.SystemConfiguration Where DisplayName ='blocked process threshold (s)'
	
	Return @return	
End
GO

Create Function dbo.ufnSysCfgIndexCreateMem()
Returns varchar(40)
Begin
	Declare @return varchar(20)

	Select @return = Case When RunValue < dbo.ufnSysCfgInt('min memory per query (KB)') Then 'OK' ELSE 'Greater than Min Mem Per Query' END
	from dbo.SystemConfiguration Where DisplayName ='index create memory (KB)'
	
	Return @return	
End
GO

Create Function dbo.ufnSysCfgRAC()
Returns varchar(40)
Begin
	Declare @return varchar(20), @IsCluster varchar(20),@rac int
	Select @IsCluster = IsClustered from SqlServer
	Select @rac =  RunValue from dbo.SystemConfiguration Where DisplayName ='remote admin connections'
	Select @return = Case When @isCluster = 'True' and @rac = 0 Then 'Should enable' END 
	
	
	Return @return	
End
GO

Create Function dbo.ufnXeEvent(@name varchar(128))
Returns int
As
Begin
	Declare @return int

	If (exists (select * from sys.tables where name='XeSessions'))
	Begin
		
		select @return =  count(*) from XeSessions where name = @name
	End
	Return @return	
End
GO

Create Function dbo.ufnXeEventHA()
Returns varchar(20)
As
Begin
	Declare @return varchar(20), @hadr varchar(10)

	If (exists (select * from sys.tables where name='XeSessions'))
	Begin
		select @hadr = IsHadrEnabled From dbo.SqlServer 
		select @return =  Case When @hadr = 'True' And (Select count(*) from XeSessions where name = 'AlwaysOn_health') <> 1 
			Then 'Should enable' ELSE 'OK' END
		
	End
	Return @return	
End
GO

Create Function dbo.ufnBlockingXeEvent()
Returns int
As
Begin
	Declare @return int

	If (exists (select * from sys.tables where name='XeSessions'))
	Begin
		
		select @return = count(*) from XeSessions
			where name NOT IN ('system_health','AlwaysOn_health','SQLDiag')
				and buffer_policy_desc = 'block'
	End
	Return @return	
End
GO


Create Function dbo.ufnDataLogOnSameDriveList()
Returns @retTable table
(
	Counts int,
	drive nvarchar(200),
	database_name sysname
)
As
Begin
	
	With Drives As
	(
		select max(v.name) as drive,df.database_name,database_id,type_desc
		from dbo.DatabaseFiles df inner join dbo.DiskVolumes v
			on LEFT(df.physical_name,len(v.name)) = RTRIM(v.name)
		Where database_id NOT IN (1,3,4)
		Group By df.database_name,database_id,type_desc
	), FilesOnSameDrive As 
	(
		Select Count(*) as counts,drive, database_name
		from drives
		Group by drive, database_name
	)
	Insert into @retTable
	Select f.* from FilesOnSameDrive f 
	inner join Drives d on f.drive = d.drive 
		and f.database_name=d.database_name 
		and d.type_desc = 'LOG'
	where f.counts > 1

	Return	
End
GO

Create Function dbo.ufnDatabasefileBackupOnSameDrive()
Returns int
As
Begin
	Declare @return int;

		WITH DataFileDrives AS
		(
		select max(v.name) as drive,df.database_name,database_id,type_desc
		from dbo.DatabaseFiles df inner join dbo.DiskVolumes v
			on LEFT(df.physical_name,len(v.name)) = RTRIM(v.name)
		Where database_id NOT IN (1,3,4)
		Group By df.database_name,database_id,type_desc
		)
		Select @return = count(*)
		From dbo.SqlServer s 
			inner join DataFileDrives d on LEFT(s.BackupDirectory,LEN(d.drive)) = RTRIM(d.drive)
	Return @return	
End
GO


Create Function dbo.ufnUserDbTempdbOnSameDrive()
Returns int
As
Begin
	Declare @return int;

	WITH DataFileDrives AS
	(
		select max(v.name) as drive,df.database_name,database_id,type_desc
		from dbo.DatabaseFiles df inner join dbo.DiskVolumes v
			on LEFT(df.physical_name,len(v.name)) = RTRIM(v.name)
		Where database_id NOT IN (1,3,4) 
		Group By df.database_name,database_id,type_desc
	)
	Select @return = count(*)
	From DataFileDrives d1 
		inner join DataFileDrives d2 on d1.drive = d2.drive
			and d1.database_id = 2
			and d2.database_id <> 2
	Return @return	
End
GO

Create Function dbo.ufnTempdbNotOnCDrive()
Returns int
As
Begin
	Declare @return int;

	WITH DataFileDrives AS
	(
	select max(v.name) as drive,df.database_name,database_id,type_desc
	from dbo.DatabaseFiles df inner join dbo.DiskVolumes v
		on LEFT(df.physical_name,len(v.name)) = RTRIM(v.name)
	Where database_id NOT IN (1,3,4) 
	Group By df.database_name,database_id,type_desc
	)
	Select @return = count(*)
	From DataFileDrives d1 
	where d1.database_id = 2 and d1.drive = 'C:\'
	Return @return	
End
GO