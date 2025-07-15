# Get drive info with numeric values for calculations
$drives = Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name="FreeGB";Expression={ [math]::Round($_.Free/1GB,2) }}, @{Name="TotalGB";Expression={ [math]::Round(($_.Used + $_.Free)/1GB,2) }}

Write-Host "==================== Disk Space Report ====================" -ForegroundColor Cyan
$drives | ForEach-Object {
    $name = $_.Name
    $free = $_.FreeGB
    $total = $_.TotalGB
    $used = [math]::Round($total - $free,2)
    $barLength = 30
    $usedPercent = if ($total -ne 0) { [math]::Round(($used / $total) * 100, 0) } else { 0 }
    $barUsed = ([string]::new([char]0x2588, [math]::Round($barLength * $usedPercent / 100,0)))
    $barFree = ([string]::new([char]0x2591, ($barLength - $barUsed.Length)))
    Write-Host ("Drive: $name".PadRight(10)) -NoNewline
    Write-Host (" [$barUsed$barFree] ") -NoNewline -ForegroundColor Yellow
    Write-Host (" $usedPercent% used ($used GB / $total GB)")
}
Write-Host "===========================================================" -ForegroundColor Cyan

# Calculate and display the total disk space across all drives
$total = ($drives | Measure-Object -Property TotalGB -Sum).Sum
Write-Host "`nTotal Disk Space (GB): $total" -ForegroundColor Green