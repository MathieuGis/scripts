# Get last installed updates from Windows Update logs

$Top = 10

Write-Host "Last $Top Installed Windows Updates (Event Log):" -ForegroundColor Cyan
Write-Host "------------------------------------------------"

Get-WinEvent -LogName "Microsoft-Windows-WindowsUpdateClient/Operational" |
    Where-Object { $_.Id -eq 19 } |  # Event ID 19 = Installation successful
    Select-Object -First $Top `
        TimeCreated,
        @{Name="UpdateTitle"; Expression = { $_.Properties[0].Value }} |
    Format-Table -AutoSize
