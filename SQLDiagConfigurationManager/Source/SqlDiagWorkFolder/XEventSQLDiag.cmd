setlocal DisableDelayedExpansion
@echo off
set ServerName=%~1
set OutputFileName=%~2
set InternalOutFileName=%~3

if "%ServerName%"=="" goto Usage
if "%OutputFileName%"=="" goto Usage
if "%InternalOutFileName%" =="" goto Usage


@echo on
PowerShell.exe -ExecutionPolicy Bypass -File XEventSQLDiag.ps1 -ServerInstance %ServerName% -InternalOutFileName "%InternalOutFileName%" -OutputFileName "%OutputFileName%"
rem sqlcmd.exe -S %ServerName% -E -i .\XEventSQLDiag.sql -o "%InternalOutFileName%" -w2000 -v XEFileName="%OutputFileName%"
rem sqlcmd.exe -S %ServerName% -E -Q "ALTER EVENT SESSION [SQLDiag] ON SERVER STATE=STOP "

goto EOF

:Usage
echo Usage:  
echo ***************************************************************************
echo *  XEventSQLDiag.cmd ServerName OutputFileName InternalOutputFileName*
echo ***************************************************************************

:EOF