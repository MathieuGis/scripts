# Visually enhanced fun.ps1

Write-Host ("="*60) -ForegroundColor DarkCyan
Write-Host ("SYSTEM INFORMATION REPORT".PadLeft(40)) -ForegroundColor White
Write-Host ("="*60) -ForegroundColor DarkCyan

# Computer Name and OS
Write-Host ("Computer Name:".PadRight(20)) -NoNewline; Write-Host "$env:COMPUTERNAME" -ForegroundColor Yellow
Write-Host ("User Name:".PadRight(20)) -NoNewline; Write-Host "$env:USERNAME" -ForegroundColor Yellow
Write-Host ("OS Version:".PadRight(20)) -NoNewline; Write-Host (Get-CimInstance Win32_OperatingSystem).Caption -ForegroundColor Yellow
Write-Host ("OS Build:".PadRight(20)) -NoNewline; Write-Host (Get-CimInstance Win32_OperatingSystem).BuildNumber -ForegroundColor Yellow
Write-Host ("Uptime:".PadRight(20)) -NoNewline; Write-Host ((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime).ToString("dd\.hh\:mm\:ss") -ForegroundColor Yellow

Write-Host ("\n" + ("-"*60)) -ForegroundColor DarkCyan
Write-Host ("HARDWARE".PadLeft(20)) -ForegroundColor Green
Write-Host ("-"*60) -ForegroundColor DarkCyan

# CPU
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
Write-Host ("CPU:".PadRight(20)) -NoNewline; Write-Host $cpu.Name -ForegroundColor Green
Write-Host ("Cores/Threads:".PadRight(20)) -NoNewline; Write-Host "$($cpu.NumberOfCores)/$($cpu.NumberOfLogicalProcessors)" -ForegroundColor Green

# RAM
$ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
Write-Host ("RAM:".PadRight(20)) -NoNewline; Write-Host ("{0:N2} GB" -f $ram) -ForegroundColor Green

# GPU
$gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
Write-Host ("GPU:".PadRight(20)) -NoNewline; Write-Host $gpu.Name -ForegroundColor Green

Write-Host ("\n" + ("-"*60)) -ForegroundColor DarkCyan
Write-Host ("STORAGE".PadLeft(20)) -ForegroundColor Magenta
Write-Host ("-"*60) -ForegroundColor DarkCyan

# Drives
Get-PSDrive -PSProvider 'FileSystem' | ForEach-Object {
    $used = ($_.Used/1GB)
    $free = ($_.Free/1GB)
    $total = $used + $free
    $percent = if ($total -gt 0) { [math]::Round($used / $total * 100, 1) } else { 0 }
    $barLength = 20
    $usedBars = [math]::Round($barLength * $percent / 100)
    $freeBars = $barLength - $usedBars
    $bar = ([string]::new([char]0x2588, $usedBars)) + ([string]::new([char]0x2591, $freeBars))
    Write-Host ("Drive {0}: [" -f $_.Name) -NoNewline
    Write-Host $bar -NoNewline -ForegroundColor Yellow
    Write-Host ("] {0:N1} GB free / {1:N1} GB total ({2}% used)" -f $free, $total, $percent) -ForegroundColor Magenta
}

Write-Host ("\n" + ("-"*60)) -ForegroundColor DarkCyan
Write-Host ("NETWORK".PadLeft(20)) -ForegroundColor Blue
Write-Host ("-"*60) -ForegroundColor DarkCyan

# IP Addresses
$ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '169.*'} | Select-Object -ExpandProperty IPAddress
Write-Host "IPv4 Addresses:" -ForegroundColor Blue
$ip | ForEach-Object { Write-Host ("  $_") -ForegroundColor Yellow }

# MAC Addresses
$macs = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -ExpandProperty MacAddress
Write-Host "MAC Addresses:" -ForegroundColor Blue
$macs | ForEach-Object { Write-Host ("  $_") -ForegroundColor Yellow }

Write-Host ("\n" + ("-"*60)) -ForegroundColor DarkCyan
Write-Host ("USERS & SESSIONS".PadLeft(25)) -ForegroundColor White
Write-Host ("-"*60) -ForegroundColor DarkCyan

# Logged in users
$users = quser 2>$null
if ($users) {
    Write-Host "Logged in users:" -ForegroundColor Blue
    $users | ForEach-Object { Write-Host ("  $_") -ForegroundColor Yellow }
} else {
    Write-Host "No users found or 'quser' not available." -ForegroundColor Red
}

Write-Host ("\n" + ("="*60)) -ForegroundColor DarkCyan
Write-Host ("END OF REPORT".PadLeft(35)) -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor DarkCyan