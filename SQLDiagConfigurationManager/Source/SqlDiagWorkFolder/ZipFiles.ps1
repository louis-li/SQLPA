param ($DataFolder)

#$ZipDir = Split-Path $DataFolder -Parent
$ZipFile = $DataFolder + ".zip" 
#Zip-Files  $ZipFile (Split-Path $DataFolder -Parent)
Add-Type -A System.IO.Compression.FileSystem
if (Test-Path $ZipFile) { remove-item $ZipFile}
[IO.Compression.ZipFile]::CreateFromDirectory($DataFolder , $ZipFile)
