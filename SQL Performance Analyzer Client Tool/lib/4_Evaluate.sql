--Evaluate
If (Exists(Select * from sys.objects where name = 'uspEvaluate' and type ='P'))
	Drop Proc uspEvaluate
GO
Create Proc uspEvaluate
As
BEGIN

BEGIN TRAN
Truncate Table Analysis.Evaluation


Declare @Sqlcmd NVARCHAR(MAX);
Declare @id int, @CurrentValue varchar(max), @Operator varchar(20),@Threshold varchar(max)
Declare @Description varchar(2000)
DECLARE @priority TINYINT
Declare curRules CURSOR FOR 
	Select Id,[CurrentValue],[Operator],[Threshold],[Description],[priority]
	From Analysis.Rules ORDER BY ID

OPEN curRules

FETCH NEXT FROM curRules INTO @id,@CurrentValue,@Operator,@Threshold,@Description,@priority

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SqlCmd = 'INSERT INTO Analysis.Evaluation SELECT ' + Convert(nvarchar(10), @ID) + ' AS ID, ' + @CurrentValue + ' AS [CurrentValue], ' + @Threshold + ' AS [Threshold],CASE WHEN ' + @CurrentValue + ' ' + @Operator + ' ' + @Threshold + ' THEN ''Pass'' ELSE ''Fail'' END AS Result, ''' + @Description + ''' As [Description],' + Cast(@priority as varchar(2)) + ' AS [Priority]'
	--SET @SqlCmd = 'SELECT ' + Convert(nvarchar(10), @ID) + ' AS ID, ' + @CurrentValue + ' AS [CurrentValue], ' + @Threshold + ' AS [Threshold],CASE WHEN ' + @CurrentValue + ' ' + @Operator + ' ' + @Threshold + ' THEN ''Pass'' ELSE ''Fail'' END AS Result, ''' + @Description + ''' As [Description]'
	Print @SqlCmd
	Begin Try
		EXEC sp_executesql @SqlCmd
	End try
	Begin Catch
		Print @sqlCmd;
	End Catch

	FETCH NEXT FROM curRules INTO @id,@CurrentValue,@Operator,@Threshold,@Description,@priority
END

CLOSE curRules;
DEALLOCATE curRules;

COMMIT
END
GO
