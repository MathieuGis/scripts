# netinfo.ps1
# Fast network scan and info listing

# Get local subnet
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.*' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1).IPAddress
$subnet = ($localIP -replace '\d+$','')

Write-Host "Scanning subnet: $subnet*"

# Fast ping sweep using parallel jobs
$ips = 1..254 | ForEach-Object { "$subnet$_" }
$aliveHosts = @()

$scriptBlock = {
    param($ip)
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        return $ip
    }
}

# Use ForEach-Object -Parallel if available (PowerShell 7+), else fallback to jobs
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $aliveHosts = $ips | ForEach-Object -Parallel $scriptBlock -ThrottleLimit 50 | Where-Object { $_ }
} else {
    $jobs = @()
    foreach ($ip in $ips) {
        $jobs += Start-Job -ScriptBlock $scriptBlock -ArgumentList $ip
    }
    $total = $jobs.Count
    for ($i = 0; $i -lt $total; $i++) {
        $result = Receive-Job -Job $jobs[$i] -Wait
        if ($result) { $aliveHosts += $result }
        Write-Progress -Activity "Scanning network" -Status "Pinging $($i+1) of $total" -PercentComplete (($i+1)/$total*100)
    }
    Write-Progress -Activity "Scanning network" -Completed
    Remove-Job -Job $jobs | Out-Null
}

# Cache ARP table once for speed
$arpTable = arp -a

# Gather info in parallel (PowerShell 7+)
function Get-HostInfo {
    param($host, $arpTable)
    $info = [ordered]@{ Host = $host }

    try {
        $dns = [System.Net.Dns]::GetHostEntry($host)
        $info.Hostname = $dns.HostName
    } catch { $info.Hostname = "(not found)" }

    try {
        $arp = $arpTable | Select-String $host
        if ($arp) {
            $mac = ($arp -split '\s+')[-2]
            $info.MAC = $mac
        } else {
            $info.MAC = "(not found)"
        }
    } catch { $info.MAC = "(not found)" }

    try {
        $os = (Invoke-Command -ComputerName $host -ScriptBlock { (Get-WmiObject Win32_OperatingSystem).Caption } -ErrorAction SilentlyContinue)
        if ($os) {
            $info.OS = $os
        } else {
            $info.OS = "(not found or access denied)"
        }
    } catch { $info.OS = "(not found or access denied)" }

    return $info
}

if ($PSVersionTable.PSVersion.Major -ge 7) {
    $results = $aliveHosts | ForEach-Object -Parallel {
        param($host, $arpTable)
        function Get-HostInfo { param($host, $arpTable)
            $info = [ordered]@{ Host = $host }
            try {
                $dns = [System.Net.Dns]::GetHostEntry($host)
                $info.Hostname = $dns.HostName
            } catch { $info.Hostname = "(not found)" }
            try {
                $arp = $arpTable | Select-String $host
                if ($arp) {
                    $mac = ($arp -split '\s+')[-2]
                    $info.MAC = $mac
                } else {
                    $info.MAC = "(not found)"
                }
            } catch { $info.MAC = "(not found)" }
            try {
                $os = (Invoke-Command -ComputerName $host -ScriptBlock { (Get-WmiObject Win32_OperatingSystem).Caption } -ErrorAction SilentlyContinue)
                if ($os) {
                    $info.OS = $os
                } else {
                    $info.OS = "(not found or access denied)"
                }
            } catch { $info.OS = "(not found or access denied)" }
            return $info
        }
        Get-HostInfo $host $using:arpTable
    } -ArgumentList $arpTable -ThrottleLimit 20
} else {
    $results = foreach ($host in $aliveHosts) {
        Get-HostInfo $host $arpTable
    }
}

# Output results
foreach ($info in $results) {
    Write-Host "`nHost: $($info.Host)"
    Write-Host "  Hostname: $($info.Hostname)"
    Write-Host "  MAC: $($info.MAC)"
    Write-Host "  OS: $($info.OS)"
}