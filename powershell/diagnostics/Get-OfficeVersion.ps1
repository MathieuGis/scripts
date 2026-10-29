# PowerShell script to check installed Office version

Write-Host "Checking installed Office versions..." -ForegroundColor Cyan

# Check for Office installations in registry
$officePaths = @(
    "HKLM:\SOFTWARE\Microsoft\Office",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office"
)

$results = @()

foreach ($path in $officePaths) {
    if (Test-Path $path) {
        Get-ChildItem $path | ForEach-Object {
            $version = $_.PSChildName
            # Only process if it's a version number (e.g., 16.0, 15.0)
            if ($version -match "^\d+\.\d+$") {
                $officePath = Join-Path $_.PSPath "Common\ProductVersion"
                if (Test-Path $officePath) {
                    try {
                        $exactVersion = (Get-ItemProperty $officePath).'(default)'

                        # Map version number to Office product name
                        $productName = switch ($version) {
                            "16.0" { "Office 2016/2019/2021 or Microsoft 365" }
                            "15.0" { "Office 2013" }
                            "14.0" { "Office 2010" }
                            "12.0" { "Office 2007" }
                            "11.0" { "Office 2003" }
                            default { "Unknown Office version" }
                        }

                        $results += [PSCustomObject]@{
                            VersionNumber = $version
                            ExactVersion = $exactVersion
                            ProductName = $productName
                            RegistryPath = $_.PSPath
                        }
                    }
                    catch {
                        Write-Host "Error reading version information from $($officePath)" -ForegroundColor Red
                    }
                }
            }
        }
    }
}

# Check for Click-to-Run installations
$c2rPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
if (Test-Path $c2rPath) {
    try {
        $c2rVersion = (Get-ItemProperty $c2rPath).VersionToReport
        $channel = (Get-ItemProperty $c2rPath).UpdateChannel

        $results += [PSCustomObject]@{
            VersionNumber = "C2R"
            ExactVersion = $c2rVersion
            ProductName = "Microsoft 365 / Click-to-Run"
            RegistryPath = $c2rPath
            Channel = $channel
        }
    }
    catch {
        Write-Host "Error reading Click-to-Run information" -ForegroundColor Red
    }
}

# Output results
if ($results.Count -gt 0) {
    Write-Host "`nFound the following Office installations:" -ForegroundColor Green
    $results | Format-Table -AutoSize
} else {
    Write-Host "`nNo Office installations detected in the registry." -ForegroundColor Yellow

    # Check if Office apps exist in common locations
    $officePaths = @(
        "${env:ProgramFiles}\Microsoft Office",
        "${env:ProgramFiles(x86)}\Microsoft Office",
        "${env:ProgramFiles}\Microsoft 365",
        "${env:ProgramFiles(x86)}\Microsoft 365"
    )

    foreach ($path in $officePaths) {
        if (Test-Path $path) {
            Write-Host "Office installation folder found at: $path" -ForegroundColor Yellow
        }
    }
}

# Additional check for Office applications
Write-Host "`nChecking for common Office applications..." -ForegroundColor Cyan
$officeApps = @("WINWORD.EXE", "EXCEL.EXE", "POWERPNT.EXE", "OUTLOOK.EXE")

foreach ($app in $officeApps) {
    $appInfo = Get-Command $app -ErrorAction SilentlyContinue
    if ($appInfo) {
        $fileVersion = (Get-Item $appInfo.Source).VersionInfo.FileVersion
        Write-Host "$($app): Found at $($appInfo.Source), Version: $fileVersion" -ForegroundColor Green
    } else {
        Write-Host "$($app): Not found in PATH" -ForegroundColor Yellow
    }
}
