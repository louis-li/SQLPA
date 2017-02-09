[cmdletbinding()]
param (
    $InstanceName = "Localhost",
    $DataSubFolder = "Data\"
)
$DataSubFolder = $DataSubFolder.Substring(0,$DataSubFolder.length-2)
$DataFolder = Join-Path -Path $DataSubFolder -ChildPath  "Begin\"
If (!(Test-Path $DataFolder)) { New-Item $DataFolder -ItemType Directory | Out-Null}

$SourceFolder = Join-Path -Path $PSScriptRoot -ChildPath  "Begin"


$Scripts = Get-ChildItem -Path $SourceFolder -Filter *.ps1 -Recurse
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