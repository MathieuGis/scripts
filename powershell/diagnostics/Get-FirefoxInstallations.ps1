cls
# Check which Windows users have Firefox installed
# Searches user profiles, AppData folders, and system-wide locations.
# Outputs results to the console only.

Write-Host "`n=== Firefox Installation Report ===" -ForegroundColor Cyan
Write-Host ("=" * 100)

# System-wide Firefox installation locations
$SystemPaths = @(
    "$env:ProgramFiles\Mozilla Firefox\firefox.exe",
    "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe"
) | Where-Object { $_ -and (Test-Path $_) }

# Retrieve local Windows user profiles
$UserProfiles = Get-CimInstance Win32_UserProfile |
    Where-Object {
        $_.LocalPath -and
        (Test-Path $_.LocalPath) -and
        -not $_.Special
    }

foreach ($Profile in $UserProfiles) {

    $Username = Split-Path $Profile.LocalPath -Leaf
    $ProfilePath = $Profile.LocalPath

    # AppData directories to check
    $AppDataPaths = @(
        "$ProfilePath\AppData\Local",
        "$ProfilePath\AppData\Roaming",
        "$ProfilePath\AppData\LocalLow"
    )

    $FoundPaths = @()

    # Check common Firefox executable locations
    $ExecutablePaths = @(
        "$ProfilePath\AppData\Local\Mozilla Firefox\firefox.exe",
        "$ProfilePath\AppData\Local\Programs\Mozilla Firefox\firefox.exe",
        "$ProfilePath\AppData\Roaming\Mozilla Firefox\firefox.exe",
        "$ProfilePath\AppData\LocalLow\Mozilla Firefox\firefox.exe"
    )

    foreach ($Path in $ExecutablePaths) {
        if (Test-Path $Path) {
            $FoundPaths += $Path
        }
    }

    # Search recursively throughout each AppData folder for firefox.exe
    foreach ($AppData in $AppDataPaths) {

        if (Test-Path $AppData) {

            $Matches = Get-ChildItem `
                -Path $AppData `
                -Filter "firefox.exe" `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue

            foreach ($Match in $Matches) {
                $FoundPaths += $Match.FullName
            }
        }
    }

    # Remove duplicate paths
    $FoundPaths = @($FoundPaths | Sort-Object -Unique)

    Write-Host "`nUser: $Username" -ForegroundColor Yellow
    Write-Host "Profile: $ProfilePath"

    if ($FoundPaths.Count -gt 0) {

        Write-Host "Firefox: INSTALLED IN APPDATA" -ForegroundColor Green

        foreach ($Path in $FoundPaths) {
            Write-Host "  Found: $Path"
        }

    }
    elseif ($SystemPaths.Count -gt 0) {

        Write-Host "Firefox: SYSTEM-WIDE INSTALLATION FOUND" -ForegroundColor Green

        foreach ($Path in $SystemPaths) {
            Write-Host "  Found: $Path"
        }

    }
    else {

        Write-Host "Firefox: NOT FOUND" -ForegroundColor Red
    }
}

Write-Host "`n" ("=" * 100)
Write-Host "Scan completed." -ForegroundColor Cyan
