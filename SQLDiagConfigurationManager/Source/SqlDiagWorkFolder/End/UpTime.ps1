$wmi = Get-WmiObject -Class Win32_OperatingSystem
$wmi.ConvertToDateTime($wmi.LastBootUpTime)
