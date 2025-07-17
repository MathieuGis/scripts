# Finds all available network shares on the local network

# Get all computers in the current domain/workgroup
if (Get-Command Get-ADComputer -ErrorAction SilentlyContinue) {
    $computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue
} else {
    # Fallback: Try to get computers from Net View if not in a domain or AD module is missing
    $computers = (net view | Select-String '\\' | ForEach-Object {
        ($_ -split '\\')[2]
    }) | Where-Object { $_ }
}

foreach ($computer in $computers) {
    Write-Host "Shares on ${computer}:"
    try {
        Get-WmiObject -Class Win32_Share -ComputerName $computer -ErrorAction Stop | 
            Select-Object Name, Path, Description | 
            Format-Table -AutoSize
    } catch {
        Write-Host "  Unable to access shares on $computer"
    }
    Write-Host ""
}