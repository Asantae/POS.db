[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$FilePath
)

return Get-Content $FilePath | Out-String