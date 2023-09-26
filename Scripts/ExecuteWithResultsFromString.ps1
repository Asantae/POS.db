[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$SqlCommand
)

Import-Module SQLServer

Invoke-Expression ("{0}\GetEnvironmentVariables.ps1" -f $PSScriptRoot)

$ConnectionInfo = New-Object Microsoft.SqlServer.Management.Common.SqlConnectionInfo(("{0},{1}" -f $ENV:DB_HOST, $ENV:DB_PORT), $ENV:DB_USERNAME, $ENV:DB_PASSWORD);
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server($ConnectionInfo);
$Db = $Server.Databases.Item($ENV:DB_NAMEd)

$DataSet = $Db.ExecuteWithResults($SqlCommand);

return $DataSet.Tables[0]