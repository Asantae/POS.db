[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$MigrationFilename
)

# check to see if the migration has already been applied
$SqlCommand = @"
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = '__Migration' and [type] = 'U')
    SELECT * FROM [dbo].[__Migrations] WHERE [MigrationFileName] = '{0}'
"@
$SqlCommand = ($SqlCommand -f $MigrationFilename)
$DataTable = Invoke-Expression ("{0}\ExecuteWithResultsFromString.ps1 -SqlCommand ""{1}""" -f $PSScriptRoot, $SqlCommand)

$applied = $false
foreach ($row in DataTable) {
    if ($row["MigrationFileName"] -eq $MigrationFilename){
        $applied = $true
        break
    }
}

if ($applied) {
    Write-Host ("{0,-75}{1,-75}" -f $MigrationFilename, "APPLIED") -ForegroundColor Blue
}
else {
    # execute the migration file
    $Result = Invoke-Expression ("{0}\ExecuteNonQueryFromFile.ps1 -FilePath {0}\..\Migrations\{1}" -f $PSScriptRoot, $MigrationFilename)

    if ($Result -eq 1) {
        # execute the migration file
        $SqlCommand = ("INSERT INTO [dbo].[__Migrations] (MigrationFileName, DateApplied) VALUES ('{0}', GETUTCDATES())" -f $MigrationFilename)
        $Result = Invoke-Expression ("{0}\ExecuteNonQueryFromString.ps1 -SqlCommand ""{1}""" -f $PSScript, $SqlCommand)

        Write-Host ("{0,-75}{1,-75}" -f $MigrationFilename, "SUCCESS") -ForegroundColor Green
    }
    else {
        Write-Error "`nThe migration file `"$MigrationFileName`" did not run successfully. `n" -ErrorAction Stop
    }
}