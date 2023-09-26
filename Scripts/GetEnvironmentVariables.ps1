# if values are already set, skip everything
# if there is an env file, use that
# otherwise, look for branch specific settings
# if nothing was found, throw an exception

if(!(test-path ('env:DB_HOST'))) {
    if (Test-Path -Path ($PSScriptRoot + "\..\.env")) {
        write-host ("Setting environment form .env")
        (Get-Content -Path ($PSScriptRoot + "\..\.env")) | ForEach-Object {
            if ($_.IndexOf("=") -ne -1) {
                $key = ($_.Substring(0, $_.IndexOf("=")))
                $value = ($_.Substring($_.IndexOf("=") + 1, $_.Length - $_.IndexOf("=") - 1))
                write-host ("    Setting {0}" -f $key)
                [System.Environment]::SetEnvironmentVariable($key, $value)
            }
        }
    } elseif (test-path('env:BUILD_SOURCEBRANCHNAME')) {
        write-host("Looking for pipeline variables for branch {0}" -f $ENV:BUILD_SOURCEBRANCHNAME)

        "DB_HOST_{0}" -f $ENV:BUILD_SOURCEBRANCHNAME | set-variable -name "branchHost"
        if(test-path('env:'+$branchHost)) {
            "DB_PORT_{0}" -f $ENV:BUILD_SOURCEBRANCHNAME | set-variable -name "branchPort"
            "DB_NAME_{0}" -f $ENV:BUILD_SOURCEBRANCHNAME | set-variable -name "branchName"
            "DB_USERNAME_{0}" -f $ENV:BUILD_SOURCEBRANCHNAME | set-variable -name "branchUsername"

            $ENV:DB_HOST = [System.Environment]::GetEnvironmentVariable($branchHost)
            $ENV:DB_PORT = [System.Environment]::GetEnvironmentVariable($branchPort)
            $ENV:DB_NAME = [System.Environment]::GetEnvironmentVariable($branchName)
            $ENV:DB_USERNAME = [System.Environment]::GetEnvironmentVariable($branchUsername)
        }
    }
}

if(!(test-path ('env:DB_PASSWORD'))) {
    throw [System.IO.FileNotFoundException] ".env file does not exist, and no pipeline variables found for DB_PASSWORD"
}