cls
$usersRoot = Join-Path $env:SystemDrive 'Users'
$skip = 'Public','Default','Default User','All Users'

$browsers = @(
    @{
        Name        = 'Chrome'
        SystemPaths = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe")
        UserInstall = 'AppData\Local\Google\Chrome\Application\chrome.exe'
        UserProfile = 'AppData\Local\Google\Chrome\User Data'
    },
    @{
        Name        = 'Firefox'
        SystemPaths = @("$env:ProgramFiles\Mozilla Firefox\firefox.exe",
                        "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe")
        UserInstall = 'AppData\Local\Mozilla Firefox\firefox.exe'
        UserProfile = 'AppData\Roaming\Mozilla\Firefox\Profiles'
    }
)

function Get-Ver($path) { (Get-Item $path -ErrorAction SilentlyContinue).VersionInfo.ProductVersion }

# 1. Machine-wide installs
Write-Host "`n=== Machine-wide installs ===" -ForegroundColor Cyan
$machine = foreach ($b in $browsers) {
    $found = $b.SystemPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    [pscustomobject]@{
        Browser   = $b.Name
        Installed = [bool]$found
        Version   = if ($found) { Get-Ver $found } else { '-' }
        Path      = if ($found) { $found } else { '-' }
    }
}
$machine | Format-Table -AutoSize | Out-Host

# 2. Per-user installs and profiles
Write-Host "=== Per-user overview ===" -ForegroundColor Cyan
$perUser = Get-ChildItem $usersRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $skip -notcontains $_.Name } |
    ForEach-Object {
        $row = [ordered]@{ User = $_.Name }
        foreach ($b in $browsers) {
            $installPath = Join-Path $_.FullName $b.UserInstall
            $profilePath = Join-Path $_.FullName $b.UserProfile
            $row["$($b.Name) (user install)"] = if (Test-Path $installPath) { Get-Ver $installPath } else { '-' }
            $row["$($b.Name) (profile)"]      = if (Test-Path $profilePath) { 'Yes' } else { 'No' }
        }
        [pscustomobject]$row
    }
$perUser | Format-Table -AutoSize | Out-Host
