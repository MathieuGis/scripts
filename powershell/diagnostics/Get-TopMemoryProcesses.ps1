cls
$comp = Get-CimInstance Win32_OperatingSystem
$TotalRAM = [math]::Round($comp.TotalVisibleMemorySize / 1MB, 2) # in GB
$FreeRAM = [math]::Round($comp.FreePhysicalMemory / 1MB, 2)      # in GB
$UsedRAM = [math]::Round($TotalRAM - $FreeRAM, 2)

Write-Host "Total RAM: $TotalRAM GB"
Write-Host "Used RAM:  $UsedRAM GB"
Write-Host "Free RAM:  $FreeRAM GB"
Write-Host "-------------------------------------`n"

Get-Process |
Select-Object Name, Id, @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet/1MB,2)}} |
Sort-Object MemoryMB -Descending |
Select-Object -First 10 |
Format-Table -AutoSize
