$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{
	$objDisks = Get-WmiObject -Computername $serverName -Class Win32_Volume | Where-Object { $_.DriveType -eq 3 -and$_.Name -like "*:\"}
	ForEach( $disk in $objDisks)
	{
		$objDefrag = $disk.DefragAnalysis()
		$rec = $objDefrag.DefragRecommended
		#$objDefrag.DefragAnalysis #| Select $rec,TotalPercentFragmentation,FreeSpacePercentFragmentation,FilePercentFragmentation

		$ObjDefrag | Select @{Name='DiskName';Expression={$disk.Name}},
                        @{Name='TotalPctFrag';Expression={$_.DefragAnalysis.TotalPercentFragmentation}},
                        @{Name='FreespacePctFrag';Expression={$_.DefragAnalysis.FreeSpacePercentFragmentation}},
                        @{Name='FilePctFrag';Expression={$_.DefragAnalysis.FilePercentFragmentation}},
                        DefragRecommended
#,$objDefragDetail.FreeSpacePercentFragmentation,$objDefragDetail.FilePercentFragmentation,$objDefrag.DefragRecommended
	}
}
else
{
	Write-Host "NotAdmin"
}
