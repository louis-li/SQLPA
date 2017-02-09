param ($DataFolder)

function Add-Zip
{
    param([string]$zipfilename)

    if(-not (test-path($zipfilename)))
    {
        set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (dir $zipfilename).IsReadOnly = $false  
    }

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipfilename)

    foreach($file in $input) 
    { 
            $zipPackage.CopyHere($file.FullName)
            do
            {
                Start-sleep -milliseconds 250
            }
            while ($zipPackage.Items().count -eq 0)
    }
}

$ZipFile = $DataFolder + ".zip" 
#[Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" );
#if (Test-Path $ZipFile) { remove-item $ZipFile}
#[IO.Compression.ZipFile]::CreateFromDirectory($DataFolder , $ZipFile)
Get-ChildItem "$DataFolder" | Add-Zip -zipfilename $ZipFile