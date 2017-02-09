select 
	de.ObjectName,de.CounterName,de.InstanceName
	,cast(cast(CounterDateTime as varchar(19)) as time) as CounterDateTime
	,d.CounterValue
	,'\'+objectname + case when InstanceName is NULL then '' else '(' + InstanceName + ')' end + '\' + CounterName as FullCounterName
	,'\'+objectname + case when InstanceName is NULL then '' else '(*)' end + '\' + CounterName as FullCounterNameWithWildchar
Into dbo.Counters
from 
	dbo.counterdata d inner join dbo.CounterDetails de
		on d.CounterID = de.CounterID
Order By
	de.ObjectName, de.CounterName,de.instancename,d.CounterDateTime
GO

Create Proc uspGetCounters(@counters varchar(max))
AS
BEGIN
	declare @sqlCmd nvarchar(max) = 'Select c1.ObjectName
	,c1.CounterName
	,c1.InstanceName
	,CounterDateTime
	,c1.CounterValue
from dbo.Counters c1 
where c1.countername IN (' + @counters + ') or c1.fullcounternamewithwildchar in (' + @counters + ')'
	print @sqlCmd
	exec sp_executesql @sqlcmd
END
GO

Create Function dbo.ufnCounterCheck(@countername1 nvarchar(128), @countername2 nvarchar(128))
returns @return table
(
	CounterDateTime datetime2,
	Counter1Value float,
	Counter2Value float,
	Value decimal(19,4)
)
AS
BEGIN

If @countername2 IS NOT NULL
Begin
	;With counter1 as 
	(Select ObjectName
		,CounterName
		,InstanceName
		,CounterDateTime
		,CounterValue
		from dbo.Counters  
		where fullcountername = @countername1 or fullcounternamewithwildchar = @countername1)
	,counter2 as 
	(Select ObjectName
		,CounterName
		,InstanceName
		,CounterDateTime
		,CounterValue
		from dbo.Counters 
		where fullcountername = @countername2 or fullcounternamewithwildchar = @countername2)
	Insert into @return
	Select 
		c1.CounterDatetime
		,c1.CounterValue
		,c2.CounterValue
		,Case c2.CounterValue 
			When 0	then 0
			ELSE c1.countervalue/c2.CounterValue 
	END 
	From 
		counter1 c1 Inner Join counter2 c2
		on c1.CounterDateTime = c2.CounterDateTime

end
else
begin
	;With counter1 as 
	(Select ObjectName
		,CounterName
		,InstanceName
		,CounterDateTime
		,CounterValue
		from dbo.Counters  
		where fullcountername = @countername1 or fullcounternamewithwildchar = @countername1)
	Insert into @return
	Select 
		c1.CounterDatetime
		,c1.CounterValue
		,null
		,c1.countervalue
	 
	From 
		counter1 c1

end

return 

END
GO

Create Function dbo.ufnIMResourcePoolStats(@countername1 nvarchar(128), @countername2 nvarchar(128))
returns @return table
(
	CounterDateTime datetime2,
	Counter1Value float,
	Counter2Value float,
	Value decimal(19,4),
	Threshold decimal(19,4)
)
AS
BEGIN
	;With counter1 as 
	(Select ObjectName
		,CounterName
		,InstanceName
		,CounterDateTime
		,CounterValue
		from dbo.Counters  
		where fullcountername = @countername1 or fullcounternamewithwildchar = @countername1)
	,counter2 as 
	(Select ObjectName
		,CounterName
		,InstanceName
		,CounterDateTime
		,CounterValue
		from dbo.Counters 
		where fullcountername = @countername2 or fullcounternamewithwildchar = @countername2)
	Insert into @return
	Select 
		c1.CounterDatetime
		,c1.CounterValue
		,c2.CounterValue
		,Case c2.CounterValue 
			When 0	then 0
			ELSE c1.countervalue/c2.CounterValue 
			END
		, Case 
			When C2.CounterValue <= 8388608 THEN 70
			When C2.CounterValue <= 16777216 THEN 75
			When C2.CounterValue <= 33554432 THEN 80
			When c2.CounterValue <= 100663296 THEN 85
			Else 90
		End as Threshold
	 
	From 
		counter1 c1 Inner Join counter2 c2
		on c1.CounterDateTime = c2.CounterDateTime
	return
END
GO