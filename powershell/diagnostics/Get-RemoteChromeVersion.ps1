$Computers = @(
    "PC01",
    "PC02",
    "PC03"
)

$Results = foreach ($Computer in $Computers) {
    try {
        $regPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome"
        $regPathWow = "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome"

        $version = Invoke-Command -ComputerName $Computer -ScriptBlock {
            param($regPath, $regPathWow)

            $chrome = Get-ItemProperty -Path "HKLM:\$regPath" -ErrorAction SilentlyContinue
            if (-not $chrome) {
                $chrome = Get-ItemProperty -Path "HKLM:\$regPathWow" -ErrorAction SilentlyContinue
            }

            if ($chrome -and $chrome.DisplayVersion) {
                return $chrome.DisplayVersion
            } else {
                return $null
            }
        } -ArgumentList $regPath, $regPathWow -ErrorAction Stop

        [PSCustomObject]@{
            ComputerName  = $Computer
            ChromeVersion = if ($version) { $version } else { "Not Installed" }
        }
    }
    catch {
        [PSCustomObject]@{
            ComputerName  = $Computer
            ChromeVersion = "Error: $_"
        }
    }
}

$Results | Format-Table -AutoSize
