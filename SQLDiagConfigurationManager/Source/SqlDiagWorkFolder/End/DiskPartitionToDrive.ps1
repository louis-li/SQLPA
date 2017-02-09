Get-WmiObject -Class Win32_LogicalDiskToPartition | 
    Select @{Name='DeviceID';Expression={[REGEX]::Match($_.Antecedent,'DeviceID="(.*)"').Groups[1].Value}},
        @{Name='DriveLetter';Expression={[REGEX]::Match($_.Dependent,'DeviceID="(.*)"').Groups[1].Value}}
