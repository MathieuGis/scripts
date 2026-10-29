# PowerShell script to check and remove KB5064401 and KB5065426

# List of updates to check
$KBs = @("KB5064401", "KB5065426")

foreach ($KB in $KBs) {
    Write-Host "Checking for $KB..." -ForegroundColor Cyan

    # Look for the update
    $update = Get-HotFix | Where-Object { $_.HotFixID -eq $KB }

    if ($update) {
        Write-Host "$KB is installed. Attempting to uninstall..." -ForegroundColor Yellow

        try {
            # Use WUSA to uninstall silently, no restart
            Start-Process "wusa.exe" -ArgumentList "/uninstall /kb:$($KB.TrimStart('KB')) /quiet /norestart" -Wait -NoNewWindow
            Write-Host "$KB uninstall command executed." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to uninstall $KB. Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "$KB is not installed." -ForegroundColor Gray
    }
}

Write-Host "Script completed." -ForegroundColor Cyan
