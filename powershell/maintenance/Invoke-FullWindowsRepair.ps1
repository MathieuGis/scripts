<#
    Windows Repair Toolkit Script
    Run this script as Administrator
    It performs safe system health checks & repairs.
#>
cls
Write-Host "=== Starting Windows Repair Toolkit ===" -ForegroundColor Cyan

# --- Step 1: Check & Repair Windows Image (DISM equivalent)
Write-Host "`n[1/7] Checking and repairing Windows image..." -ForegroundColor Yellow
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth

# --- Step 2: Run System File Checker
Write-Host "`n[2/7] Running System File Checker (SFC)..." -ForegroundColor Yellow
sfc /scannow

# --- Step 3: Run CHKDSK (online scan, won’t force reboot)
Write-Host "`n[3/7] Running CHKDSK (scan mode)..." -ForegroundColor Yellow
chkdsk C: /scan

# --- Step 4: Repair Disk Volume via PowerShell
Write-Host "`n[4/7] Running Repair-Volume (PowerShell disk check)..." -ForegroundColor Yellow
Repair-Volume -DriveLetter C -Scan
Repair-Volume -DriveLetter C -OfflineScanAndFix

# --- Step 5: Cleanup Component Store
Write-Host "`n[5/7] Cleaning up WinSxS component store..." -ForegroundColor Yellow
DISM /Online /Cleanup-Image /StartComponentCleanup

# --- Step 6: Reset Networking
Write-Host "`n[6/7] Resetting networking stack..." -ForegroundColor Yellow
netsh winsock reset
netsh int ip reset
Clear-DnsClientCache

# --- Step 7: Restart Windows Update Services
Write-Host "`n[7/7] Restarting Windows Update services..." -ForegroundColor Yellow
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Stop-Service bits -Force -ErrorAction SilentlyContinue
Start-Service wuauserv
Start-Service bits

Write-Host "`n=== Repair tasks completed. Please restart your computer. ===" -ForegroundColor Green
