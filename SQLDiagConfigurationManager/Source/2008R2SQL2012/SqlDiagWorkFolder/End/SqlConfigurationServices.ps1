[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null

$sqlServer = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') "Localhost"

#List all the services
$sqlServer.Services | Export-Csv (Join-Path -Path $DataFolder -ChildPath "SqlServices.csv") -NoTypeInformation

#List all server alias
$sqlServer.ServerAliases | Export-Csv (Join-Path -Path $DataFolder -ChildPath "ServerAliases.csv") -NoTypeInformation

#List all server instances
$sqlServer.ServerInstances | Export-Csv (Join-Path -Path $DataFolder -ChildPath "ServerInstances.csv") -NoTypeInformation

#List all client properties
$sqlServer.ClientProtocols | Export-Csv (Join-Path -Path $DataFolder -ChildPath "ClientProtocols.csv") -NoTypeInformation

#TCP
$sqlserver.ClientProtocols["tcp"].ProtocolProperties | Export-Csv (Join-Path -Path $DataFolder -ChildPath "TcpProtocol.csv") -NoTypeInformation