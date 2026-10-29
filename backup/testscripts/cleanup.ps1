# Run this script as Administrator

Write-Host "Starting Windows cleanup with DISM..." -ForegroundColor Cyan

# Clean up the component store (WinSxS folder)
dism.exe /Online /Cleanup-Image /StartComponentCleanup

# Optionally, remove superseded updates (uncomment the next line if desired)
dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Optionally, scan and repair system image (uncomment if needed)
dism.exe /Online /Cleanup-Image /ScanHealth
dism.exe /Online /Cleanup-Image /RestoreHealth

Write-Host "DISM cleanup completed." -ForegroundColor Green