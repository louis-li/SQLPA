[cmdletbinding()]
param (
    $InstanceName = "Localhost",
    $DataSubFolder = "Data\"
)

$instancename > C:\1.log
$DataSubFolder >> C:\1.log

Write-Host "$(Get-Date): Start Collecting..." -ForegroundColor Green
add-pssnapin SqlServerCmdletSnapin100 -ErrorAction silentlycontinue

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$DataSubFolder = $DataSubFolder.Substring(0,$DataSubFolder.length-1)
$DataFolder = Join-Path -Path $DataSubFolder -ChildPath  "Data\"
$DataFolder >> C:\1.log

Write-Verbose "Data folder = $DataFolder" 
$PoliciesFolder = Join-Path -Path $PSScriptRoot -ChildPath  "Policies\"
$SourceFolder = Join-Path -Path $PSScriptRoot -ChildPath  "End"
$SourceFolder >> C:\1.log

Write-Verbose "PSScript Root = $PSScriptRoot" 
Write-Verbose "Source folder = $SourceFolder" 


If ($InstanceName -match "\\")
{
    $ServerName = Split-Path $InstanceName
}
else
{
    $ServerName = $InstanceName
}


$Scripts = Get-ChildItem -Path $SourceFolder -Filter *.ps1 -Recurse
If (!(Test-Path $DataFolder)) { New-Item $DataFolder -ItemType Directory | Out-Null}


#Scan SQL Server first
Write-Verbose "$(Get-Date): SqlServer: Executing"
$data = . (Join-Path -Path $SourceFolder -ChildPath "SqlServer.ps1")
Write-Verbose "$(Get-Date): SqlServer: Exporting data "
Export-Csv -InputObject $data -Path (Join-Path -Path $DataFolder -ChildPath "SqlServer.csv") -NoTypeInformation


ForEach ($script in $Scripts)
{
    Switch ($Script.BaseName)
    {
    "Execute-SqlScript"  { . $script.FullName;Break;    }
    "SqlServer" { 
        break;
        }
    Default   {
        Write-Verbose  "$(Get-Date): $($script.BaseName): Executing"
        $data = . $script.FullName
        Write-Verbose "$(Get-Date): $($script.BaseName): Exporting data "
        Export-Clixml -InputObject $data -Path (Join-Path -Path $DataFolder -ChildPath $script.BaseName) -Depth 1
        }
    }
}

#"Start evaluating policies"
#Get-ChildItem $PoliciesFolder | Invoke-PolicyEvaluation -TargetServerName $InstanceName | Export-Clixml -Path (Join-Path -Path $DataFolder -ChildPath "Policies") 

#$ZipDir = Split-Path $DataFolder -Parent
#$ZipFile = $ZipDir + ".zip" 
#Zip-Files  $ZipFile (Split-Path $DataFolder -Parent)
#Add-Type -A System.IO.Compression.FileSystem
#[IO.Compression.ZipFile]::CreateFromDirectory($ZipDir , $ZipFile)

Write-Host "$(Get-Date):Data Collection completed." -ForegroundColor Green
