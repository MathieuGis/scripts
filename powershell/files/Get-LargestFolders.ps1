# Find the biggest folder on your computer, ignoring system folders

# Define system folders to ignore
$systemFolders = @(
    "$env:SystemRoot",
    "$env:WinDir",
    "$env:ProgramFiles",
    "$env:ProgramFiles(x86)",
    "$env:ProgramData",
    "$env:AppData",
    "$env:LocalAppData",
    "$env:USERPROFILE\AppData"
) | Where-Object { $_ -ne $null }

# Get all drives
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null }

# Store all folder sizes
$folderSizes = @()

foreach ($drive in $drives) {
    # Get top-level folders, excluding system folders
    $folders = Get-ChildItem -Path $drive.Root -Directory -ErrorAction SilentlyContinue | Where-Object {
        $folder = $_.FullName
        -not ($systemFolders | Where-Object { $folder.StartsWith($_) })
    }
    $total = $folders.Count
    $current = 0
    foreach ($folderObj in $folders) {
        $current++
        Write-Progress -Activity "Scanning folders on $($drive.Name):" -Status $folderObj.FullName -PercentComplete (($current / $total) * 100)
        Write-Host "Scanning $($folderObj.FullName)..."
        try {
            $size = (Get-ChildItem -Path $folderObj.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $folderSizes += [PSCustomObject]@{ Folder = $folderObj.FullName; Size = $size }
        } catch {
            # Ignore folders we can't access
        }
    }
}
Write-Progress -Activity "Scanning folders" -Completed

Clear-Host

if ($folderSizes.Count -gt 0) {
    $topFolders = $folderSizes | Sort-Object -Property Size -Descending | Select-Object -First 10
    Write-Host "Top 10 biggest folders:"
    $i = 1
    foreach ($f in $topFolders) {
        Write-Host ("{0}. {1} - {2} GB" -f $i, $f.Folder, [math]::Round($f.Size / 1GB, 2))
        $i++
    }
} else {
    Write-Host "No folders found."
}