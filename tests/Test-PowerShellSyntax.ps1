$Root = Split-Path -Parent $PSScriptRoot
$Failures = 0
$Tokens = $null
$Errors = $null
[System.Management.Automation.Language.Parser]::ParseFile((Join-Path $Root 'Start-Toolkit.ps1'), [ref]$Tokens, [ref]$Errors) | Out-Null
foreach ($ParseError in $Errors) {
    Write-Error "Start-Toolkit.ps1: $($ParseError.Message)" -ErrorAction Continue
    $Failures++
}
foreach ($Directory in @('powershell', 'projects/helpsite', 'tests')) {
    Get-ChildItem -LiteralPath (Join-Path $Root $Directory) -Filter '*.ps1' -Recurse | ForEach-Object {
        $Tokens = $null
        $Errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$Tokens, [ref]$Errors) | Out-Null
        foreach ($ParseError in $Errors) {
            Write-Error "$($_.FullName): $($ParseError.Message)" -ErrorAction Continue
            $Failures++
        }
    }
}
if ($Failures -gt 0) { exit 1 }
Write-Host 'Active PowerShell scripts parsed successfully.'
