setlocal DisableDelayedExpansion
@echo off


@echo on
PowerShell.exe -ExecutionPolicy Bypass -File PTO_Snapshot.ps1 -InstanceName %1 -Interval _Interval_ -DataSubFolder %2 

goto EOF

:Usage
echo Usage:  
echo ***************************************************************************
echo *  PTO_DataCollector.cmd ServerName OutputFileName InternalOutputFileName*
echo ***************************************************************************

:EOF