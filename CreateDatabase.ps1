try 
{
    Import-Module SQLServer
    Invoke-Expression("0\Scripts\GetEnvironmentVariables.ps1" -f $PSScriptRoot)

    $ConnectionInfo = New-Object Microsoft.SqlServer.Management.Common.SqlConnectionInfo($("{0},{1}" -f $ENV:DB_HOST, $ENV:DB_PORT), $ENV:DB_USERNAME, $ENV:DB_PASSWORD);
    $Srvr = New-Object Microsoft.SqlServer.Management.Smo.Server($ConnectionInfo);
    if($Srvr.Databases | Where {$_.Name -contains $ENV:DB_NAME}){
        Write-Host "Database already exists!"
    } else {
        $db.Create()
        if($Srvr.Databases | Where {$_.Name -contains $ENV:DB_NAME}){
            Write-Host "Successfully created database!"
        } else {
            Write-Error "Failed to create database!"
        }
    }
}
catch [Exception]
{
    echo $_.Exception|format-list -Force
    Write-Error "Failed to connect to host"
}