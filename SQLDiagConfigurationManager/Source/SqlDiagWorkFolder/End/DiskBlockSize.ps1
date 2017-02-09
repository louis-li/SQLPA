Get-WmiObject -computername $serverName -query "select * from Win32_Volume where DriveLetter <> NULL and DriveType = 3"

