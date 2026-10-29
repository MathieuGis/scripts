# Tests use synthetic scripts only; no administration tools are executed.
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '../Start-Toolkit.ps1')

function Assert-Toolkit {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$info = Get-ToolkitScriptInfo 'param([switch]$Execute, [string]$Name) Write-Output $Name'
Assert-Toolkit ($info.Parameters.Count -eq 2 -and -not $info.NeedsCheckout) 'Parameter discovery failed.'
Assert-Toolkit (Get-ToolkitScriptInfo '. (Join-Path $PSScriptRoot helper.ps1)').NeedsCheckout 'Checkout dependency was not detected.'
Assert-Toolkit (Get-ToolkitScriptInfo '$myInvocation.MyCommand.Definition').NeedsCheckout 'Self-relaunch dependency was not detected.'
$parameters = ConvertTo-ToolkitParameters '{"Execute":true,"Name":"a value with spaces"}' @('Execute','Name')
Assert-Toolkit ($parameters.Execute -eq $true -and $parameters.Name -eq 'a value with spaces') 'JSON parameters were changed.'
$rejected = $false
try { ConvertTo-ToolkitParameters '{"Unexpected":true}' @('Name') | Out-Null } catch { $rejected = $true }
Assert-Toolkit $rejected 'Unknown parameters must be rejected.'

# Mock GitHub so the test also works offline and cannot execute repository code.
$fixtureSource = 'Write-Output "fixture"'
$fixtureBytes = [Text.Encoding]::UTF8.GetBytes($fixtureSource)
$fixtureHeader = [Text.Encoding]::UTF8.GetBytes("blob $($fixtureBytes.Length)`0")
$hasher = [Security.Cryptography.SHA1]::Create()
try { $fixtureSha = [BitConverter]::ToString($hasher.ComputeHash([byte[]]($fixtureHeader + $fixtureBytes))).Replace('-','').ToLowerInvariant() }
finally { $hasher.Dispose() }
function Invoke-RestMethod {
    param($Uri, $Headers, $TimeoutSec, $ErrorAction)
    if ($Uri -like '*git/trees/*') {
        return [PSCustomObject]@{truncated=$false; tree=@(
            @{path='powershell/diagnostics/Test.ps1'; type='blob'},
            @{path='projects/demo/Test.ps1'; type='blob'},
            @{path='backup/Old.ps1'; type='blob'},
            @{path='archive/Old.ps1'; type='blob'},
            @{path='tests/Test.ps1'; type='blob'},
            @{path='Start-Toolkit.ps1'; type='blob'},
            @{path='powershell/readme.md'; type='blob'}
        )}
    }
    [PSCustomObject]@{encoding='base64'; content=[Convert]::ToBase64String($fixtureBytes)}
}
Assert-Toolkit (@(Get-ToolkitIndex).Count -eq 2) 'Discovery includes backup, tests or the launcher itself.'
Assert-Toolkit ((Get-ToolkitSource $fixtureSha) -eq $fixtureSource) 'Source decoding/hash verification failed.'
$rejected = $false
try { Get-ToolkitSource ('0' * 40) | Out-Null } catch { $rejected = $true }
Assert-Toolkit $rejected 'A content/hash mismatch must be rejected.'
Remove-Item Function:\Invoke-RestMethod

$result = Invoke-ToolkitScript -Source 'param([string]$Name,[switch]$Enabled) Write-Output "$Name|$Enabled"' -Parameters @{Name='hello with spaces'; Enabled=$true} -CaptureOutput
Assert-Toolkit ($result.ExitCode -eq 0 -and $result.Output -match 'hello with spaces\|True') "Child parameter execution failed: $($result.Errors)"
$largeSource = ('# padding for a script larger than the Windows command-line limit' + "`n") * 1500
$largeSource += 'Write-Output "LARGE_OK"'
$result = Invoke-ToolkitScript -Source $largeSource -CaptureOutput
Assert-Toolkit ($result.ExitCode -eq 0 -and $result.Output -match 'LARGE_OK') "Large in-memory script failed: $($result.Errors)"
$result = Invoke-ToolkitScript -Source 'exit 7' -CaptureOutput
Assert-Toolkit ($result.ExitCode -eq 7) 'A child exit code was lost.'
$result = Invoke-ToolkitScript -Source 'Write-Output "MENU_ALIVE"' -CaptureOutput
Assert-Toolkit ($result.ExitCode -eq 0 -and $result.Output -match 'MENU_ALIVE') 'A child exit prevented subsequent runs.'
Write-Host 'PASS: discovery, dependency checks, parameters, hash validation, large scripts and process isolation.'
