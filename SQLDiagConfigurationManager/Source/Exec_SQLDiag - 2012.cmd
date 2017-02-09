@ECHO OFF
@REM  To register the collector as a service, open a command prompt, change to this 
@REM  directory, and run: 

@REM  	md %CD%\SQLDiagOutput
@REM    xcopy "%CD%\SQL*.sql" "%CD%\SQLDiagWorkFolder" /Y
@REM    SQLDIAG /R /I "%CD%\SQLDiag.xml" /O "%CD%\SQLDiagOutput" /P "%CD%\SQLDiagWorkFolder"

@REM  You can then start collection by running "SQLDIAG START" from Start->Run, and 
@REM  stop collection by running "SQLDIAG STOP". 

ECHO  Output folder will be created in %CD%
set mydatetime=%date:/=%_%time:~0,2%%time:~3,2%%time:~6,2%

ECHO  Starting SQLDiag with Custom generated XML in current folder. Includes PerfStats.
"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\SQLDiag.exe" /I "%CD%\SQLDiagWorkFolder\SQLDiagPTO2012.xml" /O "%CD%\SQLDiagOutput_%mydatetime%" /P "%CD%\SQLDiagWorkFolder"

ECHO  Archiving output folder
REM explorer "%CD%\SQLDiagWorkFolder\SQLDiagOutput_%mydatetime%"
powershell.exe -File "%CD%\SQLDiagWorkFolder\ZipFiles.ps1" -DataFolder "%CD%\SQLDiagOutput_%mydatetime%"

pause