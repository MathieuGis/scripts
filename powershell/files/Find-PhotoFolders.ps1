# List all drives
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 }
Write-Host "Available Drives:"
for ($i = 0; $i -lt $drives.Count; $i++) {
    Write-Host "$($i+1): $($drives[$i].Name):\"
}

# Ask user to select a drive
$driveIndex = Read-Host "Enter the number of the drive to scan"
if (-not ($driveIndex -as [int]) -or $driveIndex -lt 1 -or $driveIndex -gt $drives.Count) {
    Write-Host "Invalid selection. Exiting."
    exit
}
$selectedDrive = "$($drives[$driveIndex-1].Name):\"

# Define picture extensions
$picExts = @('*.jpg','*.jpeg','*.png','*.bmp','*.gif','*.tiff','*.heic')

# Scan for folders with user-created pictures (skip system folders)
Write-Host "Scanning for folders with pictures. Please wait..."
# Only scan folders in user directories
$userDirs = Get-ChildItem -Path $selectedDrive -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @('Users','Documents and Settings') }
$foldersWithPics = @()
foreach ($userDir in $userDirs) {
    $userFolders = Get-ChildItem -Path $userDir.FullName -Directory -Recurse -ErrorAction SilentlyContinue
    $userFolders = $userFolders | Where-Object {
        $sysFolders = @('Windows','Program Files','Program Files (x86)','ProgramData','$Recycle.Bin','System Volume Information','AppData')
        if ($sysFolders -contains $_.Name) { return $false }
        return $true
    }
    $foldersWithPics += $userFolders | Where-Object {
        foreach ($ext in $picExts) {
            if (Test-Path -Path (Join-Path $_.FullName $ext)) { return $true }
        }
        return $false
    }
}

if (-not $foldersWithPics) {
    Write-Host "No folders with pictures found."
    exit
}

# Show found folders
Write-Host "`nFolders with pictures:"
$foldersWithPics = $foldersWithPics | Sort-Object FullName
for ($i = 0; $i -lt $foldersWithPics.Count; $i++) {
    Write-Host "$($i+1): $($foldersWithPics[$i].FullName)"
}

# Ask user to open a folder
$folderIndex = Read-Host "Enter the number of the folder to open in File Explorer (or press Enter to exit)"
if ($folderIndex -and ($folderIndex -as [int]) -ge 1 -and ($folderIndex -as [int]) -le $foldersWithPics.Count) {
    $folderToOpen = $foldersWithPics[$folderIndex-1].FullName
    Start-Process explorer.exe "`"$folderToOpen`""
} else {
    Write-Host "No folder opened."
}