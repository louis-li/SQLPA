Get-WmiObject -computername $serverName -query "select Name from Win32_Volume where Capacity <> NULL"
