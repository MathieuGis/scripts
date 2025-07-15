# System Info
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS

$cyanLine = "=" * 38

function Convert-ToSafeDateTime($dmtfDate) {
    if ($dmtfDate -and $dmtfDate -match '^\d{8}') {
        try {
            return [Management.ManagementDateTimeConverter]::ToDateTime($dmtfDate)
        } catch {
            return "N/A"
        }
    } else {
        return "N/A"
    }
}

Write-Host "$($cyanLine.Substring(0, 19)) System Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host ("Hostname:".PadRight(20) + "$($cs.Name)")
Write-Host ("OS:".PadRight(20) + "$($os.Caption) $($os.OSArchitecture)")
Write-Host ("Version:".PadRight(20) + "$($os.Version)")
Write-Host ("Install Date:".PadRight(20) + "$(Convert-ToSafeDateTime $os.InstallDate)")
Write-Host ("Last Boot:".PadRight(20) + "$(Convert-ToSafeDateTime $os.LastBootUpTime)")
Write-Host ("Manufacturer:".PadRight(20) + "$($cs.Manufacturer)")
Write-Host ("Model:".PadRight(20) + "$($cs.Model)")
Write-Host ("BIOS Version:".PadRight(20) + "$($bios.SMBIOSBIOSVersion)")
Write-Host ("Serial Number:".PadRight(20) + "$($bios.SerialNumber)")
Write-Host "$($cyanLine.Substring(0, 19)) System Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Hardware Info
Write-Host "`n$($cyanLine.Substring(0, 19)) Hardware Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host ("CPU:".PadRight(20) + "$(Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name)")
Write-Host ("Cores/Logical:".PadRight(20) + "$(Get-CimInstance Win32_Processor | ForEach-Object { "$($_.NumberOfCores)/$($_.NumberOfLogicalProcessors)" })")
Write-Host ("RAM (GB):".PadRight(20) + "{0:N2}" -f ($cs.TotalPhysicalMemory / 1GB))
Write-Host ("GPU:".PadRight(20) + "$(Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name -First 1)")
Write-Host "$($cyanLine.Substring(0, 19)) Hardware Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Network Interfaces (moved up)
Write-Host "`n$($cyanLine.Substring(0, 19)) Active Network Interfaces $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host ("Name".PadRight(30) + "Description".PadRight(40) + "MAC Address") -ForegroundColor White
Write-Host ("-"*30 + "-"*40 + "-"*17)
Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
    $name = $_.Name.PadRight(30)
    $desc = $_.InterfaceDescription.PadRight(40)
    $mac = $_.MacAddress
    Write-Host "$name $desc $mac"
    $ifIndex = $_.ifIndex
    $ipAddresses = Get-NetIPAddress -InterfaceIndex $ifIndex | Where-Object { $_.AddressState -eq 'Preferred' }
    foreach ($ip in $ipAddresses) {
        $type = if ($ip.AddressFamily -eq 'IPv4') { "IPv4" } else { "IPv6" }
        Write-Host ("    $type Address : " + $ip.IPAddress)
    }
    # Default Gateway
    $gateway = Get-NetRoute -InterfaceIndex $ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty NextHop
    if ($gateway) {
        Write-Host ("    Default Gateway : " + $gateway)
    }
}
Write-Host "$($cyanLine.Substring(0, 19)) Active Network Interfaces $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Top 10 Resource Hungry Processes (Average CPU over 5 seconds, grouped by process name)
Write-Host "`n$($cyanLine.Substring(0, 19)) Top 10 Resource Hungry Processes $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host ("Name".PadRight(30) + "Count".PadRight(8) + "CPU (%)".PadRight(10) + "RAM (MB)") -ForegroundColor White
Write-Host ("-"*30 + "-"*8 + "-"*10 + "-"*10)

# Capture initial CPU times
$procsStart = Get-Process | Where-Object { $_.CPU -ne $null } | Select-Object Id, Name, CPU, @{Name="RAMMB";Expression={ [math]::Round($_.WorkingSet64/1MB,2) }}

Start-Sleep -Seconds 5

# Capture CPU times after 5 seconds
$procsEnd = Get-Process | Where-Object { $_.CPU -ne $null } | Select-Object Id, Name, CPU, @{Name="RAMMB";Expression={ [math]::Round($_.WorkingSet64/1MB,2) }}

# Calculate CPU usage %
$cpuCount = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
$procUsage = @()

foreach ($pStart in $procsStart) {
    $pEnd = $procsEnd | Where-Object { $_.Id -eq $pStart.Id }
    if ($pEnd) {
        $cpuDelta = $pEnd.CPU - $pStart.CPU
        $cpuPercent = ($cpuDelta / 5) * 100 / $cpuCount
        $procUsage += [PSCustomObject]@{
            Name   = $pEnd.Name
            CPU    = [math]::Round($cpuPercent,2)
            RAMMB  = $pEnd.RAMMB
        }
    }
}

# Group by process name and sum CPU/RAM, count instances
$grouped = $procUsage | Group-Object Name | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        Count = $_.Count
        CPU = ($_.Group | Measure-Object -Property CPU -Sum).Sum
        RAMMB = ($_.Group | Measure-Object -Property RAMMB -Sum).Sum
    }
}

$topProcs = $grouped | Sort-Object -Property @{Expression="CPU";Descending=$true},@{Expression="RAMMB";Descending=$true} | Select-Object -First 10
foreach ($p in $topProcs) {
    $procName = ($p.Name -as [string]).PadRight(30)
    $procCount = ($p.Count -as [string]).PadRight(8)
    $cpu = if ($null -ne $p.CPU) { "{0:N2}" -f $p.CPU } else { "0.00" }
    $cpu = $cpu.PadRight(10)
    $ram = if ($null -ne $p.RAMMB) { "{0:N2}" -f $p.RAMMB } else { "0.00" }
    Write-Host "$procName$procCount$cpu$ram"
}
Write-Host "$($cyanLine.Substring(0, 19)) Top 10 Resource Hungry Processes $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Get drive info with numeric values for calculations
$drives = Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name="FreeGB";Expression={ [math]::Round($_.Free/1GB,2) }}, @{Name="TotalGB";Expression={ [math]::Round(($_.Used + $_.Free)/1GB,2) }}

$cyanLine = "=" * 38

# Disk Space Report
Write-Host "`n$($cyanLine.Substring(0, 19)) Disk Space Report $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
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
Write-Host "$($cyanLine.Substring(0, 19)) Disk Space Report $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Total Disk Space
$total = ($drives | Measure-Object -Property TotalGB -Sum).Sum
Write-Host ("Total Disk Space (GB): ".PadRight(30) + "$total") -ForegroundColor Green

# Local Users
Write-Host "`n$($cyanLine.Substring(0, 19)) Local Users $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host ("Name".PadRight(25) + "Enabled".PadRight(10) + "LastLogon") -ForegroundColor White
Write-Host ("-"*25 + "-"*10 + "-"*20)
Get-LocalUser | Select-Object Name, Enabled, LastLogon | ForEach-Object {
    $name = $_.Name.PadRight(25)
    $enabled = $_.Enabled.ToString().PadRight(10)
    $lastLogon = if ($_.LastLogon) { $_.LastLogon } else { "Never" }
    Write-Host "$name $enabled $lastLogon"
}
Write-Host "$($cyanLine.Substring(0, 19)) Local Users $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Applications
$apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -and $_.DisplayName -ne "" -and ($_.DisplayName -notmatch "visual c\+\+") }

Write-Host "`n$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher | Size) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
if ($apps) {
    Write-Host ("Name".PadRight(40) + "Version".PadRight(15) + "Publisher".PadRight(25) + "Size (MB)") -ForegroundColor White
    Write-Host ("-"*40 + "-"*15 + "-"*25 + "-"*10)
    $apps | Sort-Object {[int]($_.EstimatedSize -as [int])} -Descending | ForEach-Object {
        $name = $_.DisplayName.PadRight(40)
        $version = ($_.DisplayVersion -as [string]).PadRight(15)
        $publisher = ($_.Publisher -as [string]).PadRight(25)
        $sizeMB = if ($_.EstimatedSize) { "{0:N2}" -f ($_.EstimatedSize / 1KB) } else { "N/A" }
        Write-Host "$name $version $publisher $sizeMB"
    }
} else {
    Write-Host "No user-installed applications found."
}
Write-Host "$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher | Size) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Connected Devices (USB Only)
Write-Host "`n$($cyanLine.Substring(0, 19)) Connected USB Devices $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host ("DeviceID".PadRight(25) + "Description") -ForegroundColor White
Write-Host ("-"*25 + "-"*40) -ForegroundColor DarkGray
$usbDevices = Get-PnpDevice | Where-Object { $_.Status -eq 'OK' -and $_.InstanceId -like 'USB*' }
if ($usbDevices) {
    foreach ($dev in $usbDevices) {
        $id = $dev.DeviceID.PadRight(25)
        $desc = $dev.FriendlyName
        Write-Host $id -NoNewline -ForegroundColor Yellow
        Write-Host $desc -ForegroundColor Green
    }
} else {
    Write-Host "No USB devices found." -ForegroundColor Red
}
Write-Host "$($cyanLine.Substring(0, 19)) Connected USB Devices $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host "" -ForegroundColor DarkGray
Pause
