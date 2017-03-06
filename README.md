# SQLPA
<B>SQL Server Performance Analyzer </B>

SQL PA leverage SQLDIAG to collect SQL Server performance data including DMVs, meta data, xEvent etc and visualize them in a client application. The goal is to reduce the time consumped by manually collecting data, analyzing data. 

It also visualize expensive query together with PerfMon data to the correlation between PerfMon data like CPU utilization, Disk queues etc with query execution.

<H2>
Recent Release
</H2>
https://github.com/louis-li/SQLPA/releases


In the release link, you can download PACMAN (Performance Analyzer Configuration Manager) and PA (Performance Analyzer).

PACMAN is to generate data collection package, use it to generate data collectio package and run the package to collect data.
Once the data is collected, store data in the analyze server with SQL Server 2016 and SSRS installed. Run Performance Analyzer to import data.


<H2>
Prerequisite:
</H2>
SQL Server 2015 Report Viewer:

https://www.microsoft.com/en-us/download/confirmation.aspx?id=45496


<H2>Features:</H2>
Expensive queries
Waits
Performance Counters
Customerization
Installation
DMV analysis
Export to report
Data archive
Data collection client configuration
Toolset availability
Release cycle
Snapshot collection
SQL best practices 
xEvent Analysis (events categorization)
PAL intergration
Performance Counter with query exection visualization
Performance Counter with expensive queries visualization
Query events analysis (events per query)
Database hot spot analysis (most time consumping tables & indexes)
Query plan analysis (query pattern, warning messages etc)
Performance baseline comparison (comparing 2 collections)
Query exection plan collection and file generation
Correction scripts (update stats, index rebuild  etc) auto-generation


<h2>
Installation Guide
</h2>
1. Install SQL Server 2016 with SQL Server Reporting Service
2. Configure SQL Server Report Service
3. Install SQL Server Report Viewer 2015
4. Run Performance Analyzer exe file and follow the instruction to setup SQLPA
5. Use PACMAN from the download link to download the Performance Analyzer Configuration Manager to generate data collection package
6. Run generated package to collect data
7. Config import path in Performance Analyzer
8. Click "Data Import" to import data
