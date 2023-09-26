Invoke-Expression ("{0}\Scripts\GetEnvironmentVariables.ps1" -f $PSScriptRoot)

Write-Host ("`nServer={0}:{1}, Database{2}" -f $ENV:DB_HOST, $ENV:DB_PORT, $ENV:DB_NAME)
Write-Host "Running migrations..."

Get-ChildItem ("{0}\Migrations" -f $PSScriptRoot) -Filter *.sql |
ForEach-Object {
    Invoke-Expression ("{0}\Scripts\ExecuteMigration.ps1 -MigrationFileName {1}" -f $PSScriptRoot, $_.Name)
}
Write-Host "Migrations complete `r`n"

Invoke-Expression ("{0}\UpdateProgammability.ps1" -f $PSScriptRoot)

Remove-Item env:DB_*
Write-Host "Cleared environment variables"

Write-Host "Complete. `n"