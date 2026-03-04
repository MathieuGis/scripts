# Ensure Admin
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    exit
}

function Get-FreeSpaceGB {
    (Get-PSDrive C).Free / 1GB
}

Write-Host "Checking free disk space before cleanup..." -ForegroundColor Cyan
$Before = Get-FreeSpaceGB
Write-Host ("Free space BEFORE cleanup: {0:N2} GB" -f $Before) -ForegroundColor Yellow

# Temp Cleanup
Write-Host "Cleaning Temp folders..." -ForegroundColor Cyan

$UserProfiles = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue
foreach ($Profile in $UserProfiles) {
    $TempPath = Join-Path $Profile.FullName "AppData\Local\Temp"
    if (Test-Path $TempPath) {
        Remove-Item "$TempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Recycle Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Windows Update Cleanup
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv

# Component Store
Dism.exe /online /Cleanup-Image /StartComponentCleanup

# After Cleanup
Write-Host "`nChecking free disk space after cleanup..." -ForegroundColor Cyan
$After = Get-FreeSpaceGB
Write-Host ("Free space AFTER cleanup: {0:N2} GB" -f $After) -ForegroundColor Yellow

$Recovered = $After - $Before
Write-Host ("Total space recovered: {0:N2} GB" -f $Recovered) -ForegroundColor Green
