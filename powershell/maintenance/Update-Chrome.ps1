# Force Google Chrome Update Script with Version Check (Fixed for all install paths)

function Get-ChromeVersion {
    $chromePaths = @(
        "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
    )

    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            return (Get-Item $path).VersionInfo.ProductVersion
        }
    }
    return $null
}

Write-Host "=== Google Chrome Update Script ===" -ForegroundColor Cyan

# Get version before update
$beforeVersion = Get-ChromeVersion
if (-not $beforeVersion) {
    Write-Host "Google Chrome is not installed on this system." -ForegroundColor Red
    exit 1
}

Write-Host "Current Chrome version: $beforeVersion" -ForegroundColor Yellow

# Try GoogleUpdate.exe (both Program Files and LocalAppData)
$updatePaths = @(
    "$env:ProgramFiles(x86)\Google\Update\GoogleUpdate.exe",
    "$env:ProgramFiles\Google\Update\GoogleUpdate.exe",
    "$env:LocalAppData\Google\Update\GoogleUpdate.exe"
)

$updated = $false
foreach ($path in $updatePaths) {
    if (Test-Path $path) {
        Write-Host "Running $path to force update..." -ForegroundColor Yellow
        Start-Process $path -ArgumentList "/ua /installsource scheduler" -Wait
        $updated = $true
        break
    }
}

if (-not $updated) {
    Write-Host "Trying scheduled tasks..." -ForegroundColor Yellow
    schtasks /run /tn "GoogleUpdateTaskMachineUA" 2>$null
    schtasks /run /tn "GoogleUpdateTaskMachineCore" 2>$null
    $updated = $true
}

if (-not $updated) {
    Write-Host "Falling back to manual installer download..." -ForegroundColor Yellow
    $chromeInstaller = "$env:TEMP\ChromeSetup.exe"
    Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromeInstaller
    Start-Process $chromeInstaller -ArgumentList "/silent /install" -Wait
    Remove-Item $chromeInstaller -Force
    Write-Host "Chrome has been updated via fresh installer." -ForegroundColor Green
} else {
    Write-Host "Chrome update triggered successfully." -ForegroundColor Green
}

# Get version after update
Start-Sleep -Seconds 10  # allow updater to finish
$afterVersion = Get-ChromeVersion

Write-Host "Updated Chrome version: $afterVersion" -ForegroundColor Cyan

if ($beforeVersion -ne $afterVersion) {
    Write-Host "✅ Chrome has been updated successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Chrome version did not change. It may already be up to date." -ForegroundColor Yellow
}
