# Close Outlook first if it’s open for safety
Get-Process OUTLOOK -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Start Outlook COM object (invisible)
$outlook = New-Object -ComObject Outlook.Application
$session = $outlook.Session

# Logon to default profile (no UI)
$session.Logon($null, $null, $false, $false)

# Loop through all stores (PSTs, OSTs, etc.)
foreach ($store in $session.Stores) {
    $filePath = $store.FilePath

    # Only touch PST files
    if ($filePath -and $filePath.ToLower().EndsWith(".pst")) {
        Write-Host "Compacting PST: $filePath"

        try {
            # The property to call Compact on is the root folder
            $rootFolder = $store.GetRootFolder()
            $rootFolder.Compact()
            Write-Host "  -> Compact triggered."
        }
        catch {
            Write-Warning "  -> Failed to compact $filePath : $_"
        }
    }
}

# Log off and clean up
$session.Logoff()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($session) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($outlook) | Out-Null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()
