cls
# ==========================================
# Last Crash / BSOD Information Collector
# ==========================================

Write-Host "=== Last Crash / BSOD Information ===" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------
# BugCheck Events (BSOD)
# ---------------------------------------------------
Write-Host "=== BugCheck Events (Event ID 1001) ===" -ForegroundColor Yellow

$bugcheck = Get-WinEvent -FilterHashtable @{
    LogName='System'
    Id=1001
} -ErrorAction SilentlyContinue |
Sort-Object TimeCreated -Descending |
Select-Object -First 1

if ($bugcheck) {
    $bugcheck | Format-List TimeCreated, Id, ProviderName, Message
} else {
    Write-Host "No BugCheck events found."
}

Write-Host ""

# ---------------------------------------------------
# Unexpected Shutdowns (Kernel-Power)
# ---------------------------------------------------
Write-Host "=== Unexpected Shutdowns (Event ID 41) ===" -ForegroundColor Yellow

$kernelPower = Get-WinEvent -FilterHashtable @{
    LogName='System'
    Id=41
} -ErrorAction SilentlyContinue |
Sort-Object TimeCreated -Descending |
Select-Object -First 1

if ($kernelPower) {
    $kernelPower | Format-List TimeCreated, Id, ProviderName, Message
} else {
    Write-Host "No Kernel-Power events found."
}

Write-Host ""

# ---------------------------------------------------
# EventLog Service Restart (indicates reboot)
# ---------------------------------------------------
Write-Host "=== Last System Restart Events ===" -ForegroundColor Yellow

Get-WinEvent -FilterHashtable @{
    LogName='System'
    Id=6008,6005,6006
} -ErrorAction SilentlyContinue |
Sort-Object TimeCreated -Descending |
Select-Object -First 10 |
Format-Table TimeCreated, Id, ProviderName -AutoSize

Write-Host ""

# ---------------------------------------------------
# Windows Error Reporting Crashes
# ---------------------------------------------------
Write-Host "=== Recent Crash Reports ===" -ForegroundColor Yellow

$wer = Get-WinEvent -LogName Application -ErrorAction SilentlyContinue |
Where-Object {
    $_.ProviderName -like "*Windows Error Reporting*"
} |
Sort-Object TimeCreated -Descending |
Select-Object -First 5

if ($wer) {
    $wer | Format-Table TimeCreated, Id, ProviderName -AutoSize
} else {
    Write-Host "No WER crash reports found."
}

Write-Host ""

# ---------------------------------------------------
# MEMORY.DMP
# ---------------------------------------------------
Write-Host "=== Memory Dump File ===" -ForegroundColor Yellow

$memoryDump = "C:\Windows\MEMORY.DMP"

if (Test-Path $memoryDump) {
    Get-Item $memoryDump |
    Select-Object FullName,
                  @{Name="SizeMB";Expression={[math]::Round($_.Length/1MB,2)}},
                  LastWriteTime |
    Format-List
} else {
    Write-Host "No MEMORY.DMP found."
}

Write-Host ""

# ---------------------------------------------------
# Minidumps
# ---------------------------------------------------
Write-Host "=== Minidump Files ===" -ForegroundColor Yellow

$miniDumpFolder = "C:\Windows\Minidump"

if (Test-Path $miniDumpFolder) {
    Get-ChildItem $miniDumpFolder -Filter *.dmp |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 10 Name,
                           LastWriteTime,
                           @{Name="SizeKB";Expression={[math]::Round($_.Length/1KB,0)}} |
    Format-Table -AutoSize
} else {
    Write-Host "Minidump folder not found."
}

Write-Host ""

# ---------------------------------------------------
# Reliability Monitor Data
# ---------------------------------------------------
Write-Host "=== Recent Critical Reliability Events ===" -ForegroundColor Yellow

Get-CimInstance Win32_ReliabilityRecords -ErrorAction SilentlyContinue |
Where-Object {
    $_.SourceName -match "Windows|Application Error|BlueScreen"
} |
Sort-Object TimeGenerated -Descending |
Select-Object -First 10 TimeGenerated,
                       SourceName,
                       ProductName,
                       Message |
Format-Table -Wrap -AutoSize

Write-Host ""
Write-Host "=== Collection Complete ===" -ForegroundColor Green
