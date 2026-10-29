# Define the Event IDs we care about
$eventIDs = 41

# Query only the last 20 relevant events
$events = Get-WinEvent -FilterHashtable @{LogName='System'; Id=$eventIDs} -MaxEvents 20 |
    Sort-Object TimeCreated -Descending

if ($events.Count -eq 0) {
    Write-Output "No recent crashes or unexpected restarts found."
} else {
    Write-Output "Recent PC crashes and restarts:"
    foreach ($event in $events) {
        $time = $event.TimeCreated
        $id = $event.Id
        $level = $event.LevelDisplayName
        $msg = $event.Message

        switch ($id) {
            41 { $reason = "Unexpected shutdown/power loss (Kernel-Power)" }
            6008 { $reason = "Unexpected shutdown" }
            default { $reason = "Other" }
        }

        Write-Output "-----------------------------------"
        Write-Output "Time: $time"
        Write-Output "Event ID: $id"
        Write-Output "Level: $level"
        Write-Output "Reason: $reason"
        Write-Output "Message: $msg"
    }
}
