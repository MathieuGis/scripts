Clear-Host
Write-Host "=== Real-Time System Monitor ==="
Write-Host "Press Ctrl + C to stop.`n"

while ($true) {
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMem = [math]::round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeMem = [math]::round($os.FreePhysicalMemory / 1MB, 2)
    $usedMem = [math]::round($totalMem - $freeMem, 2)
    $memUsagePct = [math]::round(($usedMem / $totalMem) * 100, 2)

    # Top 10 memory-using processes
    $topProcesses = Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 10

    Clear-Host
    Write-Host "====== Real-Time System Monitor ======"
    Write-Host ("CPU Usage    : {0,6:N2} %" -f $cpu)
    Write-Host ("Memory Usage : {0,6:N2} GB / {1,6:N2} GB ({2,5:N2} %)" -f $usedMem, $totalMem, $memUsagePct)
    Write-Host ("Free Memory  : {0,6:N2} GB" -f $freeMem)

    Write-Host "`n====== Top 10 Memory-Using Apps ======"
    foreach ($p in $topProcesses) {
        $memGB = [math]::round(($p.WorkingSet / 1GB), 3)
        Write-Host ("{0,-25} {1,8:N3} GB" -f $p.ProcessName, $memGB)
    }

    Write-Host "`nPress Ctrl + C to stop."

    Start-Sleep -Seconds 1
}
