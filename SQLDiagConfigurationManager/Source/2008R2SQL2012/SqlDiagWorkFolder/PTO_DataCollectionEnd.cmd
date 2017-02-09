setlocal DisableDelayedExpansion
@echo off


@echo on
%1 > C:\2.log
PowerShell.exe -ExecutionPolicy Bypass -File PTO_DataCollectionEnd.ps1 -InstanceName %1 -DataSubFolder %2

goto EOF

:Usage
echo Usage:  
echo ***************************************************************************
echo *  PTO_DataCollector.cmd ServerName OutputFileName InternalOutputFileName*
echo ***************************************************************************

:EOF