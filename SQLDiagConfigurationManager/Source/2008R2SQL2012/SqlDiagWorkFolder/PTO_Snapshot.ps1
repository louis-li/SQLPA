[cmdletbinding()]
param (
    $InstanceName = "Localhost",
    $DataSubFolder = "Data\",
    $Interval = 5
)
$DataSubFolder = $DataSubFolder.Substring(0,$DataSubFolder.length-2)
$SnapshotDataFolder = Join-Path -Path $DataSubFolder -ChildPath  "SnapshotData\"

If (!(Test-Path $SnapshotDataFolder)) { New-Item $SnapshotDataFolder -ItemType Directory | Out-Null}

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$SourceFolder = Join-Path -Path $PSScriptRoot -ChildPath  "Snapshot"


$Scripts = Get-ChildItem -Path $SourceFolder -Filter *.ps1 -Recurse

While (1 -eq 1)
{
    Start-Sleep ($Interval * 60)
    $DataFolder = Join-Path -Path $SnapshotDataFolder -ChildPath (get-date).tostring('yyyyMMdd_hhmmss')
    If (!(Test-Path $DataFolder)) { New-Item $DataFolder -ItemType Directory | Out-Null}


    ForEach ($script in $Scripts)
    {
        Switch ($Script.BaseName)
        {
        "Execute-SqlScript"  { . $script.FullName;Break;    }
        Default   {
            Write-Verbose  "$(Get-Date): $($script.BaseName): Executing"
            $data = . $script.FullName
            Write-Verbose "$(Get-Date): $($script.BaseName): Exporting data "
            Export-Clixml -InputObject $data -Path (Join-Path -Path $DataFolder -ChildPath $script.BaseName) -Depth 1
            }
        }
    }
}