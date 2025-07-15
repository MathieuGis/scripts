$drives = Get-PSDrive -PSProvider 'FileSystem' | 
    Select-Object Name, 
        @{Name="FreeSpace(GB)";Expression={"{0:N2}" -f ($_.Free/1GB)}}, 
        @{Name="TotalSize(GB)";Expression={"{0:N2}" -f (($_.Used + $_.Free)/1GB)}}

$drives | Format-Table -AutoSize

# Calculate and display the total disk space across all drives
$total = ($drives | Measure-Object -Property 'TotalSize(GB)' -Sum).Sum
Write-Host "`nTotal Disk Space (GB): $total"