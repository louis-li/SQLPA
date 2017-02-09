@ECHO OFF
@REM  To register the collector as a service, open a command prompt, change to this 
@REM  directory, and run: 

@REM  	md %CD%\SQLDiagOutput
@REM    xcopy "%CD%\SQL*.sql" "%CD%\SQLDiagWorkFolder" /Y
@REM    SQLDIAG /R /I "%CD%\SQLDiag.xml" /O "%CD%\SQLDiagOutput" /P "%CD%\SQLDiagWorkFolder"

@REM  You can then start collection by running "SQLDIAG START" from Start->Run, and 
@REM  stop collection by running "SQLDIAG STOP". 

ECHO  sqldiag.exe will be able to capture multiple platforms.
ECHO  Any sqldiag will be able to detect 32 bit or 64 bit instances.

ECHO  Output folder will be created in %CD%
set mydatetime=%date:/=%_%time:~0,2%%time:~3,2%%time:~6,2%

ECHO  Starting SQLDiag with Custom generated XML in current folder. Includes PerfStats.
ECHO  for SQLDIAG see more details at https://msdn.microsoft.com/en-us/library/ms162833.aspx
ECHO  /B [+]start_time
ECHO  Specifies the date and time to start collecting diagnostic data in the following format:
ECHO  YYYYMMDD_HH:MM:SS
ECHO  The time is specified using 24-hour notation. For example, 2:00 P.M. should be specified as 14:00:00.
ECHO  Use + without the date (HH:MM:SS only) to specify a time that is relative to the current date and time. For example, if you specify /B +02:00:00, SQLdiag will wait 2 hours before it starts collecting information.
ECHO  Do not insert a space between + and the specified start_time.
ECHO  If you specify a start time that is in the past, SQLdiag forcibly changes the start date so the start date and time are in the future. For example, if you specify /B 01:00:00 and the current time is 08:00:00, SQLdiag forcibly changes the start date so that the start date is the next day.
ECHO  Note that SQLdiag uses the local time on the computer where the utility is running.
ECHO  /E [+]stop_time
ECHO  Specifies the date and time to stop collecting diagnostic data in the following format:
ECHO  YYYYMMDD_HH:MM:SS
ECHO  The time is specified using 24-hour notation. For example, 2:00 P.M. should be specified as 14:00:00.
ECHO  Use + without the date (HH:MM:SS only) to specify a time that is relative to the current date and time. For example, if you specify a start time and end time by using /B +02:00:00 /E +03:00:00, SQLdiag waits 2 hours before it starts collecting information, then collects information for 3 hours before it stops and exits. If /B is not specified, SQLdiag starts collecting diagnostics immediately and ends at the date and time specified by /E.
ECHO  Do not insert a space between + and the specified start_time or end_time.
ECHO  Note that SQLdiag uses the local time on the computer where the utility is running.
"C:\Program Files\Microsoft SQL Server\130\Tools\Binn\SQLDiag.exe" /B 13:10:00 /E 13:15:00 /I "%CD%\SQLDiagWorkFolder\SQLDiagPTO2016.xml" /O "%CD%\SQLDiagOutput_%mydatetime%" /P "%CD%\SQLDiagWorkFolder"

ECHO  Archiving output folder
REM explorer "%CD%\SQLDiagWorkFolder\SQLDiagOutput_%mydatetime%"
powershell.exe -File "%CD%\SQLDiagWorkFolder\ZipFiles.ps1" -DataFolder "%CD%\SQLDiagOutput_%mydatetime%"
pause