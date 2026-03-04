function Get-FreeSpaceGB {
    (Get-PSDrive C).Free / 1GB
}

Write-Host "Checking free disk space before cleanup..." -ForegroundColor Cyan
$Before = Get-FreeSpaceGB
Write-Host ("Free space BEFORE cleanup: {0:N2} GB" -f $Before) -ForegroundColor Yellow

# Start Cleanup

Write-Host "`nCleaning Temp folders..." -ForegroundColor Cyan
Get-ChildItem "$env:TEMP" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem "C:\Windows\Temp" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Emptying Recycle Bin..." -ForegroundColor Cyan
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

Write-Host "Cleaning Windows Update downloads..." -ForegroundColor Cyan
Stop-Service wuauserv -Force
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv

Write-Host "Cleaning Component Store (WinSxS)..." -ForegroundColor Cyan
Dism.exe /online /Cleanup-Image /StartComponentCleanup

# After Cleanup

Write-Host "`nChecking free disk space after cleanup..." -ForegroundColor Cyan
Write-Host ("Free space BEFORE cleanup: {0:N2} GB" -f $Before) -ForegroundColor Yellow
$After = Get-FreeSpaceGB
Write-Host ("Free space AFTER cleanup: {0:N2} GB" -f $After) -ForegroundColor Yellow

$Recovered = $After - $Before
Write-Host ("Total space recovered: {0:N2} GB" -f $Recovered) -ForegroundColor Green
