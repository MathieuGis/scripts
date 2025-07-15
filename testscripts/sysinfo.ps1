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

function Show-Menu {
    Clear-Host
    Write-Host "================= System Info Menu =================" -ForegroundColor Cyan
    Write-Host "1. System Information"
    Write-Host "2. Hardware Information"
    Write-Host "3. Network Interfaces"
    Write-Host "4. Top 10 Resource Hungry Processes"
    Write-Host "5. Top 10 Largest Folders in User Profiles"
    Write-Host "6. Disk Space Report"
    Write-Host "7. Local Users"
    Write-Host "8. Applications"
    Write-Host "9. Connected USB Devices"
    Write-Host "10. Full System Report"
    Write-Host "0. Exit"
    Write-Host "====================================================" -ForegroundColor Cyan
}

function Wait-ReturnMenu {
    Write-Host "\nPress any key to return to the menu..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Select an option (0-10)"
    switch ($choice) {
        '1' {
            Clear-Host
            # System Information
            Write-Host "\n$($cyanLine.Substring(0, 19)) System Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
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
            Wait-ReturnMenu
        }
        '2' {
            Clear-Host
            # Hardware Information
            Write-Host "\n$($cyanLine.Substring(0, 19)) Hardware Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Write-Host ("CPU:".PadRight(20) + "$(Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name)")
            Write-Host ("Cores/Logical:".PadRight(20) + "$(Get-CimInstance Win32_Processor | ForEach-Object { "$($_.NumberOfCores)/$($_.NumberOfLogicalProcessors)" })")
            Write-Host ("RAM (GB):".PadRight(20) + "{0:N2}" -f ($cs.TotalPhysicalMemory / 1GB))
            Write-Host ("GPU:".PadRight(20) + "$(Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name -First 1)")
            Write-Host "$($cyanLine.Substring(0, 19)) Hardware Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Wait-ReturnMenu
        }
        '3' {
            Clear-Host
            # Network Interfaces
            Write-Host "\n$($cyanLine.Substring(0, 19)) Active Network Interfaces $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
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
            Wait-ReturnMenu
        }
        '4' {
            Clear-Host
            # Top 10 Resource Hungry Processes
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
            Wait-ReturnMenu
        }
        '5' {
            Clear-Host
            # Top 10 Largest Folders in User Profiles
            Write-Host "`n$($cyanLine.Substring(0, 19)) Top 10 Largest Folders in User Profiles $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Write-Host ("User".PadRight(25) + "Folder".PadRight(60) + "Size (GB)") -ForegroundColor White
            Write-Host ("-"*25 + "-"*60 + "-"*10) -ForegroundColor DarkGray
            $usersPath = Join-Path $env:SystemDrive 'Users'
            $allFolders = @()
            if (Test-Path $usersPath) {
                Get-ChildItem -Path $usersPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    $user = $_.Name
                    $userFolders = Get-ChildItem -Path $_.FullName -Directory -ErrorAction SilentlyContinue
                    foreach ($folder in $userFolders) {
                        $files = Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue
                        $size = ($files | Measure-Object -Property Length -Sum).Sum
                        $sizeGB = if ($size) { [math]::Round($size/1GB,2) } else { 0 }
                        $allFolders += [PSCustomObject]@{ User=$user; Folder=$folder.FullName; SizeGB=$sizeGB }
                    }
                }
                $topFolders = $allFolders | Sort-Object -Property SizeGB -Descending | Select-Object -First 10
                foreach ($f in $topFolders) {
                    Write-Host ($f.User.PadRight(25) + $f.Folder.PadRight(60) + ("{0:N2}" -f $f.SizeGB)) -ForegroundColor Yellow
                }
            } else {
                Write-Host "No user folders found." -ForegroundColor Red
            }
            Write-Host "$($cyanLine.Substring(0, 19)) Top 10 Largest Folders in User Profiles $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Wait-ReturnMenu
        }
        '6' {
            Clear-Host
            # Disk Space Report
            # Get drive info with numeric values for calculations
            $drives = Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name="FreeGB";Expression={ [math]::Round($_.Free/1GB,2) }}, @{Name="TotalGB";Expression={ [math]::Round(($_.Used + $_.Free)/1GB,2) }}

            $cyanLine = "=" * 38

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
            Wait-ReturnMenu
        }
        '7' {
            Clear-Host
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
            Wait-ReturnMenu
        }
        '8' {
            Clear-Host
            # Applications
            Write-Host "`n$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher | Size) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Where-Object { $_.DisplayName -and $_.DisplayName -ne "" -and ($_.DisplayName -notmatch "visual c\+\+") }

            if ($apps) {
                Write-Host ("Name".PadRight(40) + "Version".PadRight(15) + "Publisher".PadRight(25) + "Size (MB)") -ForegroundColor White
                Write-Host ("-"*40 + "-"*15 + "-"*25 + "-"*10)
                foreach ($app in ($apps | Sort-Object {[int]($app.EstimatedSize -as [int])} -Descending)) {
                    $name = $app.DisplayName.PadRight(40)
                    $version = ($app.DisplayVersion -as [string]).PadRight(15)
                    $publisher = ($app.Publisher -as [string]).PadRight(25)
                    $sizeMB = if ($app.EstimatedSize) { "{0:N2}" -f ($app.EstimatedSize / 1KB) } else { "N/A" }
                    Write-Host "$name $version $publisher $sizeMB"
                }
            } else {
                Write-Host "No user-installed applications found."
            }
            Write-Host "$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher | Size) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Wait-ReturnMenu
        }
        '9' {
            Clear-Host
            # Connected USB Devices
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
            Wait-ReturnMenu
        }
        '10' {
            Clear-Host
            # Full System Report
            Write-Host "\n$($cyanLine.Substring(0, 19)) FULL SYSTEM REPORT $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            # System Information
            Write-Host "\n$($cyanLine.Substring(0, 19)) System Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
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
            # Hardware Information
            Write-Host "\n$($cyanLine.Substring(0, 19)) Hardware Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Write-Host ("CPU:".PadRight(20) + "$(Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name)")
            Write-Host ("Cores/Logical:".PadRight(20) + "$(Get-CimInstance Win32_Processor | ForEach-Object { "$($_.NumberOfCores)/$($_.NumberOfLogicalProcessors)" })")
            Write-Host ("RAM (GB):".PadRight(20) + "{0:N2}" -f ($cs.TotalPhysicalMemory / 1GB))
            Write-Host ("GPU:".PadRight(20) + "$(Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name -First 1)")
            Write-Host "$($cyanLine.Substring(0, 19)) Hardware Information $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            # Network Interfaces
            Write-Host "\n$($cyanLine.Substring(0, 19)) Active Network Interfaces $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
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
                $gateway = Get-NetRoute -InterfaceIndex $ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty NextHop
                if ($gateway) {
                    Write-Host ("    Default Gateway : " + $gateway)
                }
            }
            Write-Host "$($cyanLine.Substring(0, 19)) Active Network Interfaces $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            # Top 10 Resource Hungry Processes
            Write-Host "`n$($cyanLine.Substring(0, 19)) Top 10 Resource Hungry Processes $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Write-Host ("Name".PadRight(30) + "Count".PadRight(8) + "CPU (%)".PadRight(10) + "RAM (MB)") -ForegroundColor White
            Write-Host ("-"*30 + "-"*8 + "-"*10 + "-"*10)
            $procsStart = Get-Process | Where-Object { $_.CPU -ne $null } | Select-Object Id, Name, CPU, @{Name="RAMMB";Expression={ [math]::Round($_.WorkingSet64/1MB,2) }}
            Start-Sleep -Seconds 5
            $procsEnd = Get-Process | Where-Object { $_.CPU -ne $null } | Select-Object Id, Name, CPU, @{Name="RAMMB";Expression={ [math]::Round($_.WorkingSet64/1MB,2) }}
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
            # Top 10 Largest Folders in User Profiles
            Write-Host "`n$($cyanLine.Substring(0, 19)) Top 10 Largest Folders in User Profiles $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            Write-Host ("User".PadRight(25) + "Folder".PadRight(60) + "Size (GB)") -ForegroundColor White
            Write-Host ("-"*25 + "-"*60 + "-"*10) -ForegroundColor DarkGray
            $usersPath = Join-Path $env:SystemDrive 'Users'
            $allFolders = @()
            if (Test-Path $usersPath) {
                Get-ChildItem -Path $usersPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    $user = $_.Name
                    $userFolders = Get-ChildItem -Path $_.FullName -Directory -ErrorAction SilentlyContinue
                    foreach ($folder in $userFolders) {
                        $files = Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue
                        $size = ($files | Measure-Object -Property Length -Sum).Sum
                        $sizeGB = if ($size) { [math]::Round($size/1GB,2) } else { 0 }
                        $allFolders += [PSCustomObject]@{ User=$user; Folder=$folder.FullName; SizeGB=$sizeGB }
                    }
                }
                $topFolders = $allFolders | Sort-Object -Property SizeGB -Descending | Select-Object -First 10
                foreach ($f in $topFolders) {
                    Write-Host ($f.User.PadRight(25) + $f.Folder.PadRight(60) + ("{0:N2}" -f $f.SizeGB)) -ForegroundColor Yellow
                }
            } else {
                Write-Host "No user folders found." -ForegroundColor Red
            }
            Write-Host "$($cyanLine.Substring(0, 19)) Top 10 Largest Folders in User Profiles $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            # Disk Space Report
            $drives = Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name="FreeGB";Expression={ [math]::Round($_.Free/1GB,2) }}, @{Name="TotalGB";Expression={ [math]::Round(($_.Used + $_.Free)/1GB,2) }}
            $cyanLine = "=" * 38
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
            Write-Host "`n$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher | Size) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Where-Object { $_.DisplayName -and $_.DisplayName -ne "" -and ($_.DisplayName -notmatch "visual c\+\+") }
            if ($apps) {
                Write-Host ("Name".PadRight(40) + "Version".PadRight(15) + "Publisher".PadRight(25) + "Size (MB)") -ForegroundColor White
                Write-Host ("-"*40 + "-"*15 + "-"*25 + "-"*10)
                foreach ($app in ($apps | Sort-Object {[int]($app.EstimatedSize -as [int])} -Descending)) {
                    $name = $app.DisplayName.PadRight(40)
                    $version = ($app.DisplayVersion -as [string]).PadRight(15)
                    $publisher = ($app.Publisher -as [string]).PadRight(25)
                    $sizeMB = if ($app.EstimatedSize) { "{0:N2}" -f ($app.EstimatedSize / 1KB) } else { "N/A" }
                    Write-Host "$name $version $publisher $sizeMB"
                }
            } else {
                Write-Host "No user-installed applications found."
            }
            Write-Host "$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher | Size) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
            # Connected USB Devices
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
            Wait-ReturnMenu
        }
        '0' { break }
        default { Write-Host "Invalid selection. Press any key to try again..."; $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') }
    }
}
