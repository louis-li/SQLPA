PowerCfg -l | Where-Object {$_ -like "Power Scheme*"} | 
    Select @{Name="Plan";Expression={[RegEx]::Match($_,"\((.+)\)").Groups[1].Value}},
        @{Name="Current";Expression={$_ -match "\)\s+\*"}}

