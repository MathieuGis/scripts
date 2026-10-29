#requires -version 5.1
<#
.SYNOPSIS
    Detects and removes Yandex applications from Windows.

.DESCRIPTION
    - Discovers registered Yandex applications in uninstall registries.
    - Runs registered uninstall commands when available.
    - Checks common Yandex installation locations.
    - Optionally removes leftover files and scheduled tasks.
    - Supports dry-run mode.

    Run PowerShell as Administrator for system-wide removal.

.PARAMETER Execute
    Performs the requested removal. Without this switch, the script
    reports potential actions without changing the system.

.PARAMETER RemoveUserData
    Also removes Yandex browser profiles and local user data.
    This may permanently delete bookmarks, passwords, history,
    cookies, and other local information.

.EXAMPLE
    .\Remove-Yandex.ps1

.EXAMPLE
    .\Remove-Yandex.ps1 -Execute

.EXAMPLE
    .\Remove-Yandex.ps1 -Execute -RemoveUserData
#>

[CmdletBinding()]
param(
    [switch]$Execute,
    [switch]$RemoveUserData
)

$ErrorActionPreference = 'Continue'

$LogPath = Join-Path $env:TEMP (
    'Remove-Yandex-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date)
)

function Write-Log {
    param([string]$Message)

    $line = '[{0:yyyy-MM-dd HH:mm:ss}] {1}' -f (Get-Date), $Message

    Write-Host $line

    try {
        Add-Content -LiteralPath $LogPath -Value $line -ErrorAction SilentlyContinue
    }
    catch {}
}

function Invoke-RemovalAction {
    param(
        [string]$Description,
        [scriptblock]$Action
    )

    if (-not $Execute) {
        Write-Log "[DRY RUN] $Description"
        return
    }

    try {
        Write-Log "[ACTION] $Description"
        & $Action
    }
    catch {
        Write-Log "[ERROR] $Description -- $($_.Exception.Message)"
    }
}

# Verify elevation before system-wide changes.
$isAdmin = (
    [Security.Principal.WindowsPrincipal](
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )
).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if ($Execute -and -not $isAdmin) {
    Write-Error 'Run PowerShell as Administrator before executing removals.'
    exit 1
}

Write-Log 'Starting Yandex application cleanup.'
Write-Log "Execution mode: $(if ($Execute) {'EXECUTE'} else {'DRY RUN'})"
Write-Log "Remove browser data: $RemoveUserData"
Write-Log "Log file: $LogPath"

# Stop running Yandex processes.
$processes = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -match '(?i)yandex' -or
        $_.ExecutablePath -match '(?i)\\Yandex\\'
    }

foreach ($process in $processes) {
    $pidToStop = [int]$process.ProcessId

    Invoke-RemovalAction `
        -Description "Stop Yandex process: $($process.Name), PID $pidToStop" `
        -Action {
            Stop-Process -Id $pidToStop -Force -ErrorAction SilentlyContinue
        }
}

# Discover registered applications in standard uninstall registry locations.
$uninstallKeys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Also inspect loaded user hives and the currently registered user profiles.
$userProfiles = Get-CimInstance Win32_UserProfile -ErrorAction SilentlyContinue |
    Where-Object {
        -not $_.Special -and $_.LocalPath -and
        (Test-Path -LiteralPath $_.LocalPath)
    }

foreach ($profile in $userProfiles) {
    $userUninstall = Join-Path $profile.LocalPath `
        'AppData\Local\Microsoft\Windows\CurrentVersion\Uninstall\*'

    $uninstallKeys += $userUninstall
}

$applications = foreach ($key in $uninstallKeys) {
    Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
        Where-Object {
            $_.DisplayName -match '(?i)yandex'
        }
}

$applications = @(
    $applications |
        Sort-Object DisplayName, UninstallString -Unique
)

Write-Log "Found $($applications.Count) registered Yandex application entries."

foreach ($app in $applications) {
    Write-Log "Application: $($app.DisplayName)"
    Write-Log "Version: $($app.DisplayVersion)"
    Write-Log "Publisher: $($app.Publisher)"

    $uninstallString = $app.QuietUninstallString

    if ([string]::IsNullOrWhiteSpace($uninstallString)) {
        $uninstallString = $app.UninstallString
    }

    if ([string]::IsNullOrWhiteSpace($uninstallString)) {
        Write-Log "No registered uninstaller found for $($app.DisplayName)."
        continue
    }

    # Parse the executable and its arguments without invoking a shell.
    $command = $uninstallString.Trim()
    $exe = $null
    $arguments = ''

    if ($command -match '^\s*"([^"]+)"\s*(.*)$') {
        $exe = $Matches[1]
        $arguments = $Matches[2]
    }
    elseif ($command -match '^\s*(.+?\.exe)\s*(.*)$') {
        $exe = $Matches[1].Trim()
        $arguments = $Matches[2]
    }
    else {
        Write-Log "Could not safely parse uninstaller: $command"
        continue
    }

    # Never add silent switches automatically. Use the registered
    # command as supplied, because application uninstallers differ.
    Invoke-RemovalAction `
        -Description "Run registered uninstaller for $($app.DisplayName): $exe $arguments" `
        -Action {
            if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
                throw "Uninstaller executable not found: $exe"
            }

            $startParams = @{
                FilePath     = $exe
                PassThru     = $true
                ErrorAction  = 'Stop'
            }

            if ($arguments) {
                $startParams.ArgumentList = $arguments
            }

            $proc = Start-Process @startParams
            Write-Log "Uninstaller started with PID $($proc.Id)."
        }
}

# Common installation locations. These are checked explicitly instead
# of deleting every directory whose name happens to contain Yandex.
$knownInstallPaths = @(
    (Join-Path $env:ProgramFiles 'Yandex'),
    (Join-Path ${env:ProgramFiles(x86)} 'Yandex'),
    (Join-Path $env:LOCALAPPDATA 'Yandex'),
    (Join-Path $env:APPDATA 'Yandex')
)

foreach ($profile in $userProfiles) {
    $knownInstallPaths += Join-Path $profile.LocalPath 'AppData\Local\Yandex'
    $knownInstallPaths += Join-Path $profile.LocalPath 'AppData\Roaming\Yandex'
    $knownInstallPaths += Join-Path $profile.LocalPath 'AppData\LocalLow\Yandex'
}

$knownInstallPaths = @(
    $knownInstallPaths |
        Where-Object { $_ } |
        Sort-Object -Unique
)

foreach ($path in $knownInstallPaths) {
    if (-not (Test-Path -LiteralPath $path)) {
        continue
    }

    # Preserve user profiles unless explicitly requested.
    $isUserData = $path -match '(?i)\\AppData\\(Local|Roaming|LocalLow)\\Yandex$'

    if ($isUserData -and -not $RemoveUserData) {
        Write-Log "[SKIPPED] User data preserved: $path"
        continue
    }

    Invoke-RemovalAction `
        -Description "Remove remaining Yandex directory: $path" `
        -Action {
            Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        }
}

# Remove clearly Yandex-related scheduled tasks.
$tasks = Get-ScheduledTask -ErrorAction SilentlyContinue |
    Where-Object {
        $_.TaskName -match '(?i)yandex' -or
        $_.TaskPath -match '(?i)yandex'
    }

foreach ($task in $tasks) {
    $taskPath = $task.TaskPath
    $taskName = $task.TaskName

    Invoke-RemovalAction `
        -Description "Remove Yandex scheduled task: $taskPath$taskName" `
        -Action {
            Unregister-ScheduledTask `
                -TaskName $taskName `
                -TaskPath $taskPath `
                -Confirm:$false `
                -ErrorAction Stop
        }
}

# Remove Yandex-specific browser-data directories only when requested.
if ($RemoveUserData) {
    foreach ($profile in $userProfiles) {
        $dataPaths = @(
            (Join-Path $profile.LocalPath 'AppData\Local\Yandex'),
            (Join-Path $profile.LocalPath 'AppData\Roaming\Yandex'),
            (Join-Path $profile.LocalPath 'AppData\LocalLow\Yandex')
        )

        foreach ($path in ($dataPaths | Sort-Object -Unique)) {
            if (Test-Path -LiteralPath $path) {
                Invoke-RemovalAction `
                    -Description "Remove Yandex user data: $path" `
                    -Action {
                        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
                    }
            }
        }
    }
}

Write-Log 'Cleanup scan completed.'
Write-Log 'Review the log and installed-app list to confirm removal.'
Write-Log 'A restart may be required.'
Write-Log "Log saved to: $LogPath"
