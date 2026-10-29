# --- Ensure Admin ---
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[ERROR] Please run this script as Administrator.`n" -ForegroundColor Red
    exit
}
function Get-FreeSpaceGB {
    [math]::Round((Get-PSDrive C).Free / 1GB, 2)
}
Clear-Host
# --- Before ---
$Before = Get-FreeSpaceGB
Write-Host ("Free Space Before Cleanup : {0} GB`n" -f $Before) -ForegroundColor Yellow
Write-Host "Cleaning User Temp Folders..." -ForegroundColor Cyan
Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $TempPath = Join-Path $_.FullName "AppData\Local\Temp"
    if (Test-Path $TempPath) {
        Remove-Item "$TempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "Cleaning System Temp..." -ForegroundColor Cyan
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Emptying Recycle Bin..." -ForegroundColor Cyan
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "Cleaning Windows Update Cache..." -ForegroundColor Cyan
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue
Write-Host "Optimizing Component Store..." -ForegroundColor Cyan
Start-Process -FilePath "Dism.exe" `
    -ArgumentList "/online /Cleanup-Image /StartComponentCleanup" `
    -Wait -NoNewWindow
Write-Host "Optimizing Component Store (DISM ResetBase)..." -ForegroundColor Cyan
Start-Process -FilePath "Dism.exe" `
    -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase" `
    -Wait -NoNewWindow
$After = Get-FreeSpaceGB
$Recovered = [math]::Round($After - $Before, 2)
Write-Host ("Free Space Before : {0} GB" -f $Before) -ForegroundColor yellow
Write-Host ("Free Space After  : {0} GB" -f $After) -ForegroundColor yellow
Write-Host ("Total Recovered   : {0} GB" -f $Recovered) -ForegroundColor Green


