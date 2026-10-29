#requires -Version 5.1
<#
.SYNOPSIS
    Browse and run MathieuGis/scripts PowerShell tools without downloading files.
.DESCRIPTION
    Requires Windows PowerShell 5.1 or PowerShell 7, a console and internet access.
    Uses GitHub's public API and a local memory pipe; no script/cache/log files
    are written by this launcher. Selected scripts retain their own side effects.
    Windows, PowerShell and security products may still record execution.
#>
[CmdletBinding()]
param()

function Get-ToolkitIndex {
    $tree = Invoke-RestMethod -Uri 'https://api.github.com/repos/MathieuGis/scripts/git/trees/master?recursive=1' -Headers @{'User-Agent'='MathieuGis-Toolkit'} -TimeoutSec 30 -ErrorAction Stop
    if ($tree.truncated) { throw 'GitHub returned an incomplete script list. Please retry later.' }
    @($tree.tree | Where-Object {
        $_.type -eq 'blob' -and $_.path -match '^(powershell|projects)/.*\.ps1$'
    } | Sort-Object path)
}

function Get-ToolkitSource {
    param([Parameter(Mandatory)] [string]$BlobSha)
    if ($BlobSha -notmatch '^[a-f0-9]{40}$') { throw 'Invalid GitHub blob identifier.' }
    $blob = Invoke-RestMethod -Uri "https://api.github.com/repos/MathieuGis/scripts/git/blobs/$BlobSha" -Headers @{'User-Agent'='MathieuGis-Toolkit'} -TimeoutSec 30 -ErrorAction Stop
    if ($blob.encoding -ne 'base64') { throw 'Unsupported GitHub file encoding.' }
    $bytes = [Convert]::FromBase64String($blob.content)
    $header = [Text.Encoding]::UTF8.GetBytes("blob $($bytes.Length)`0")
    $sha = [Security.Cryptography.SHA1]::Create()
    try {
        $actual = [BitConverter]::ToString($sha.ComputeHash([byte[]]($header + $bytes))).Replace('-','').ToLowerInvariant()
    } finally { $sha.Dispose() }
    if ($actual -ne $BlobSha) { throw 'The downloaded script does not match the selected GitHub version.' }
    [Text.Encoding]::UTF8.GetString($bytes).TrimStart([char]0xFEFF)
}

function Get-ToolkitScriptInfo {
    param([string]$Source)
    $tokens = $null
    $parseErrors = $null
    $ast = [Management.Automation.Language.Parser]::ParseInput($Source, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) { throw ($parseErrors.Message -join '; ') }
    $fileVariables = @($ast.FindAll({ param($node)
        $node -is [Management.Automation.Language.VariableExpressionAst] -and
        $node.VariablePath.UserPath -match '^(PSScriptRoot|PSCommandPath|MyInvocation)$'
    }, $true))
    [PSCustomObject]@{
        NeedsCheckout = $fileVariables.Count -gt 0
        Parameters = @($ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })
    }
}

function ConvertTo-ToolkitParameters {
    param([string]$Json, [string[]]$Allowed)
    $result = @{}
    if ([string]::IsNullOrWhiteSpace($Json)) { return $result }
    if (-not $Json.TrimStart().StartsWith('{')) { throw 'Parameters must be a JSON object.' }
    $value = ConvertFrom-Json -InputObject $Json -ErrorAction Stop
    foreach ($property in $value.PSObject.Properties) {
        if ($property.Name -notin $Allowed) { throw "Unknown parameter: $($property.Name)" }
        $result[$property.Name] = $property.Value
    }
    $result
}

function Invoke-ToolkitScript {
    param([string]$Source, [hashtable]$Parameters = @{}, [switch]$CaptureOutput)
    # A separate process contains 'exit', errors and preference changes. Its
    # console input remains available for Read-Host and interactive tools.
    # Only the short bootstrap goes on the command line, avoiding Windows'
    # command-line length limit even for large scripts.
    $pipeName = 'MathieuToolkit-' + [Guid]::NewGuid().ToString('N')
    $pipe = [IO.Pipes.NamedPipeServerStream]::new($pipeName, [IO.Pipes.PipeDirection]::Out, 1,
        [IO.Pipes.PipeTransmissionMode]::Byte, [IO.Pipes.PipeOptions]::Asynchronous)
    $bootstrap = @'
$ErrorActionPreference = 'Stop'
$pipe = [IO.Pipes.NamedPipeClientStream]::new('.', '__PIPE__', [IO.Pipes.PipeDirection]::In)
try {
    $pipe.Connect(30000)
    $reader = [IO.StreamReader]::new($pipe, [Text.Encoding]::UTF8)
    $payload = ConvertFrom-Json -InputObject $reader.ReadToEnd()
} finally { $pipe.Dispose() }
$arguments = @{}
foreach ($property in $payload.Parameters.PSObject.Properties) {
    $arguments[$property.Name] = $property.Value
}
$ErrorActionPreference = 'Continue'
& ([ScriptBlock]::Create($payload.Source)) @arguments
'@
    $bootstrap = $bootstrap.Replace('__PIPE__', $pipeName)
    $executable = if ($PSVersionTable.PSEdition -eq 'Desktop') { 'powershell.exe' }
        elseif ($env:OS -eq 'Windows_NT') { 'pwsh.exe' } else { 'pwsh' }
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = Join-Path $PSHOME $executable
    $start.UseShellExecute = $false
    $start.Arguments = '-NoLogo -NoProfile -EncodedCommand ' + [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($bootstrap))
    if ($CaptureOutput) {
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
    }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    $writer = $null
    $pending = $null
    try {
        $pending = $pipe.BeginWaitForConnection($null, $null)
        if (-not $process.Start()) { throw 'Could not start PowerShell.' }
        if (-not $pending.AsyncWaitHandle.WaitOne(30000)) { throw 'PowerShell did not connect within 30 seconds.' }
        $pipe.EndWaitForConnection($pending)
        $writer = [IO.StreamWriter]::new($pipe, [Text.UTF8Encoding]::new($false))
        $payload = @{Source=$Source; Parameters=$Parameters} | ConvertTo-Json -Depth 20 -Compress
        $writer.Write($payload)
        $writer.Dispose()
        $writer = $null
        if ($CaptureOutput) {
            $outputTask = $process.StandardOutput.ReadToEndAsync()
            $errorTask = $process.StandardError.ReadToEndAsync()
        }
        $process.WaitForExit()
        if ($CaptureOutput) {
            [PSCustomObject]@{ExitCode=$process.ExitCode; Output=$outputTask.Result; Errors=$errorTask.Result}
        } else { Write-Host "`nPowerShell finished (exit code $($process.ExitCode))." -ForegroundColor Cyan }
    } finally {
        if ($writer) { $writer.Dispose() }
        $pipe.Dispose()
        if ($pending) { $pending.AsyncWaitHandle.Close() }
        try { if (-not $process.HasExited) { $process.Kill() } } catch { }
        $process.Dispose()
    }
}

function Start-ToolkitMenu {
    if ($env:OS -ne 'Windows_NT') { throw 'Run this menu in a Windows PowerShell console.' }
    $oldProtocol = [Net.ServicePointManager]::SecurityProtocol
    try {
        [Net.ServicePointManager]::SecurityProtocol = $oldProtocol -bor [Net.SecurityProtocolType]::Tls12
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $admin = ([Security.Principal.WindowsPrincipal]::new($identity)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $items = @(Get-ToolkitIndex)
        $filter = ''
        while ($true) {
            Clear-Host
            Write-Host 'MathieuGis - GitHub PowerShell Toolkit' -ForegroundColor Cyan
            Write-Host "Repository: MathieuGis/scripts | master | Administrator: $admin"
            Write-Host 'Launcher downloads to memory only. Selected tools may write files or change Windows.'
            if (-not $admin) { Write-Host 'For administrative tools, start PowerShell as Administrator first.' -ForegroundColor Yellow }
            Write-Host "`nFilter: $filter"
            $visible = @($items | Where-Object { $_.path.IndexOf($filter, [StringComparison]::OrdinalIgnoreCase) -ge 0 })
            for ($i = 0; $i -lt $visible.Count; $i++) {
                Write-Host ('{0,3}. {1}' -f ($i + 1), $visible[$i].path)
            }
            $choice = Read-Host "`nNumber = select | F = filter | R = refresh | Q = quit"
            if ($choice -eq 'q') { return }
            if ($choice -eq 'f') { $filter = Read-Host 'Search path/name (blank = all)'; continue }
            if ($choice -eq 'r') {
                try { $items = @(Get-ToolkitIndex) }
                catch { Write-Warning $_.Exception.Message; [void](Read-Host 'Press Enter') }
                continue
            }
            $number = 0
            if (-not [int]::TryParse($choice, [ref]$number) -or $number -lt 1 -or $number -gt $visible.Count) { continue }
            try {
                $item = $visible[$number - 1]
                $source = Get-ToolkitSource -BlobSha $item.sha
                $info = Get-ToolkitScriptInfo -Source $source
                Write-Host "`nSelected: $($item.path)`nVersion: $($item.sha)" -ForegroundColor Cyan
                if ((Read-Host 'V = view source first; Enter = continue') -eq 'v') {
                    $source | Out-Host -Paging
                }
                if ($info.NeedsCheckout) {
                    Write-Warning 'This script uses its on-disk location or companion files. It needs a repository checkout and cannot run in this memory-only menu.'
                    [void](Read-Host 'Press Enter to return')
                    continue
                }
                $parameters = @{}
                if ($info.Parameters.Count -gt 0) {
                    Write-Host ('Parameters: ' + ($info.Parameters -join ', '))
                    Write-Host 'Optional JSON, e.g. {"Execute":true} or {"SourcePath":"C:\\Input"}. Blank uses defaults/prompts.'
                    $parameters = ConvertTo-ToolkitParameters -Json (Read-Host 'Parameters') -Allowed $info.Parameters
                }
                if ((Read-Host 'Type RUN to execute this script; Enter = cancel') -cne 'RUN') { continue }
                Invoke-ToolkitScript -Source $source -Parameters $parameters
            } catch { Write-Warning $_.Exception.Message }
            [void](Read-Host 'Press Enter to return to the menu')
        }
    } finally { [Net.ServicePointManager]::SecurityProtocol = $oldProtocol }
}

if ($MyInvocation.InvocationName -ne '.') { Start-ToolkitMenu }
