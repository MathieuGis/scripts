# Get the last 10 critical events from the System event log
Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    Level   = 1  # Critical
} -MaxEvents 10 | 
Select-Object TimeCreated, Id, ProviderName, Message |
Format-Table -AutoSize