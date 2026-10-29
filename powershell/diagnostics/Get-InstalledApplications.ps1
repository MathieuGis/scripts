cls
# Installed Software Inventory - All Users
# Console output only. No files are created.
# Run as Administrator for best results.

$Results = [System.Collections.Generic.List[object]]::new()
$Seen = @{}

function Add-Software {
    param(
        [string]$User,
        [string]$Name,
        [string]$Version = "",
        [string]$Publisher = "",
        [string]$Path = "",
        [string]$Source = ""
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return
    }

    $Key = "$User|$Name|$Version|$Path"

    if (-not $Seen.ContainsKey($Key)) {
        $Seen[$Key] = $true

        $Results.Add([PSCustomObject]@{
            User      = $User
            Name      = $Name
            Version   = $Version
            Publisher = $Publisher
            Path      = $Path
            Source    = $Source
        })
    }
}

function Get-UninstallEntries {
    param(
        [string]$RegistryPath,
        [string]$Username,
        [string]$Scope
    )

    if (Test-Path $RegistryPath) {
        Get-ItemProperty "$RegistryPath\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName } |
            ForEach-Object {
                Add-Software `
                    -User $Username `
                    -Name $_.DisplayName `
                    -Version $_.DisplayVersion `
                    -Publisher $_.Publisher `
                    -Path $_.InstallLocation `
                    -Source "Registry - $Scope"
            }
    }
}

Write-Host "`n=== SCANNING SYSTEM-WIDE REGISTRY ===" -ForegroundColor Cyan

Get-UninstallEntries `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" `
    "All Users" "System-wide"

Get-UninstallEntries `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" `
    "All Users" "System-wide"

Write-Host "`n=== SCANNING USER PROFILES ===" -ForegroundColor Cyan

$Profiles = Get-CimInstance Win32_UserProfile |
    Where-Object {
        $_.LocalPath -and
        (Test-Path $_.LocalPath) -and
        -not $_.Special
    }

foreach ($Profile in $Profiles) {

    $ProfilePath = $Profile.LocalPath
    $Username = Split-Path $ProfilePath -Leaf

    try {
        $Account = ([System.Security.Principal.SecurityIdentifier]::new(
            $Profile.SID
        )).Translate([System.Security.Principal.NTAccount]).Value

        if ($Account) {
            $Username = $Account
        }
    }
    catch {}

    Write-Host "Scanning: $Username" -ForegroundColor Yellow

    # Check the user's registry hive if it is already loaded.
    $HivePath = "Registry::HKEY_USERS\$($Profile.SID)"

    if (Test-Path $HivePath) {
        Get-UninstallEntries `
            "$HivePath\Software\Microsoft\Windows\CurrentVersion\Uninstall" `
            $Username "Per-user"

        Get-UninstallEntries `
            "$HivePath\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" `
            $Username "Per-user"
    }

    # Scan common AppData installation directories.
    $AppDataPaths = @(
        "$ProfilePath\AppData\Local\Programs",
        "$ProfilePath\AppData\Local",
        "$ProfilePath\AppData\Roaming",
        "$ProfilePath\AppData\LocalLow"
    )

    foreach ($AppData in $AppDataPaths) {

        if (-not (Test-Path $AppData)) {
            continue
        }

        # Identify executable files in immediate subdirectories.
        # This is a heuristic, not proof that every executable is installed.
        Get-ChildItem -Path $AppData -Directory -ErrorAction SilentlyContinue |
            ForEach-Object {

                $Folder = $_

                $Executables = @(
                    Get-ChildItem -Path $Folder.FullName `
                        -File -ErrorAction SilentlyContinue |
                    Where-Object {
                        $_.Extension -in @(".exe", ".msi")
                    }
                )

                foreach ($Exe in $Executables) {
                    Add-Software `
                        -User $Username `
                        -Name $Folder.Name `
                        -Path $Exe.FullName `
                        -Source "AppData scan"
                }
            }
    }

    # Scan the user's Start Menu shortcuts.
    $StartMenu = "$ProfilePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"

    if (Test-Path $StartMenu) {
        Get-ChildItem -Path $StartMenu -Filter "*.lnk" `
            -File -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object {
                Add-Software `
                    -User $Username `
                    -Name $_.BaseName `
                    -Path $_.FullName `
                    -Source "User Start Menu"
            }
    }
}

# Check machine-wide Start Menu shortcuts.
$CommonStartMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"

if (Test-Path $CommonStartMenu) {
    Get-ChildItem -Path $CommonStartMenu -Filter "*.lnk" `
        -File -Recurse -ErrorAction SilentlyContinue |
        ForEach-Object {
            Add-Software `
                -User "All Users" `
                -Name $_.BaseName `
                -Path $_.FullName `
                -Source "System Start Menu"
        }
}

Write-Host "`n=== SOFTWARE INVENTORY ===" -ForegroundColor Green

$Results |
    Sort-Object User, Name |
    Format-Table User, Name, Version, Publisher, Path, Source -AutoSize -Wrap

Write-Host "`nTotal entries found: $($Results.Count)" -ForegroundColor Cyan
