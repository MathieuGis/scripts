# Load path settings; host names and deployment behavior stay in each deployment script.
$HelpSourceRoot = 'C:\Temp\help'
$SettingsPath = Join-Path $PSScriptRoot '../../config/helpsite.local.json'
if (Test-Path -LiteralPath $SettingsPath) {
    $Settings = Get-Content -LiteralPath $SettingsPath -Raw | ConvertFrom-Json
    if ($Settings.sourceRoot) { $HelpSourceRoot = [string]$Settings.sourceRoot }
}
if ($env:HELPSITE_SOURCE_ROOT) { $HelpSourceRoot = $env:HELPSITE_SOURCE_ROOT }
