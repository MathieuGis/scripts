$uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
(New-TimeSpan -Start $uptime -End (Get-Date)) | Select-Object Days, Hours, Minutes, Seconds
