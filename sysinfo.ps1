# Get drive info with numeric values for calculations
$drives = Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name="FreeGB";Expression={ [math]::Round($_.Free/1GB,2) }}, @{Name="TotalGB";Expression={ [math]::Round(($_.Used + $_.Free)/1GB,2) }}

$cyanLine = "=" * 38

Write-Host $cyanLine -ForegroundColor Cyan
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
Write-Host $cyanLine -ForegroundColor Cyan

# Calculate and display the total disk space across all drives
$total = ($drives | Measure-Object -Property TotalGB -Sum).Sum
Write-Host "`nTotal Disk Space (GB): $total" -ForegroundColor Green

# List all local users on the computer
Write-Host "`n$($cyanLine.Substring(0, 19)) Local Users $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Write-Host ("Name".PadRight(25) + "Enabled".PadRight(10) + "LastLogon")
Write-Host ("-"*25 + "-"*10 + "-"*20)
Get-LocalUser | Select-Object Name, Enabled, LastLogon | ForEach-Object {
    $name = $_.Name.PadRight(25)
    $enabled = $_.Enabled.ToString().PadRight(10)
    $lastLogon = if ($_.LastLogon) { $_.LastLogon } else { "Never" }
    Write-Host "$name $enabled $lastLogon"
}
Write-Host "$($cyanLine.Substring(0, 19)) Local Users $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# Get user-installed applications
$apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -and $_.DisplayName -ne "" -and ($_.DisplayName -notmatch "visual c\+\+") }

Write-Host "`n$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
if ($apps) {
    $apps | Sort-Object DisplayName | ForEach-Object {
        $name = $_.DisplayName.PadRight(40)
        $version = ($_.DisplayVersion -as [string]).PadRight(15)
        $publisher = ($_.Publisher -as [string])
        Write-Host "$name $version $publisher"
    }
} else {
    Write-Host "No user-installed applications found."
}
Write-Host "$($cyanLine.Substring(0, 19)) Applications (Name | Version | Publisher) $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan

# List all active network interfaces
Write-Host "`n$($cyanLine.Substring(0, 19)) Active Network Interfaces $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
    $name = $_.Name.PadRight(30)
    $desc = $_.InterfaceDescription.PadRight(40)
    $mac = $_.MacAddress
    Write-Host "$name $desc $mac"

    # Get IP addresses for this adapter
    $ifIndex = $_.ifIndex
    $ipAddresses = Get-NetIPAddress -InterfaceIndex $ifIndex | Where-Object { $_.AddressState -eq 'Preferred' }
    foreach ($ip in $ipAddresses) {
        $type = if ($ip.AddressFamily -eq 'IPv4') { "IPv4" } else { "IPv6" }
        Write-Host ("    $type Address : " + $ip.IPAddress)
    }
}
Write-Host "$($cyanLine.Substring(0, 19)) Active Network Interfaces $($cyanLine.Substring(0, 19))" -ForegroundColor Cyan
