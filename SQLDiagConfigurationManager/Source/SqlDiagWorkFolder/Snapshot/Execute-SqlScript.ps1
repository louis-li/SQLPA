foreach ($sqlscript in (Get-ChildItem (Join-Path -Path $SourceFolder -ChildPath "SqlScripts\")))
{
    Write-Verbose "$(Get-Date): Executing: $($sqlscript.BaseName).sql"
    try
    {
        $data = Invoke-Sqlcmd -ServerInstance $InstanceName -InputFile $sqlscript.FullName -QueryTimeout 0 -ErrorAction Stop
        Export-Clixml -InputObject $data -Path (Join-Path -Path $DataFolder -ChildPath $sqlscript.BaseName) 
    }
    Catch
    {
        Write-Error "$(Get-Date): Error Executing: $($sqlscript.BaseName).sql`n$_"
    }
    
}