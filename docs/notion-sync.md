# Notion script synchronization

Synced on 2026-10-29 from the 24 child pages under [Scripts](https://www.notion.so/2726138e249f8086b9efcf50144d203a). Notion is the source for script behavior. Existing unrelated scripts and the frozen backup were retained.

23 PowerShell scripts: 19 added, 3 updated, 1 already identical. Sitra Commands is retained as a manual command reference because its steps require an intervening restart.

Code blocks were copied with original logic. Only trailing whitespace, Markdown wrappers and escaping were removed (nested fences in Remove-Yandex and inline formatting in Reinstall-Edge). Changed/new PowerShell files use UTF-8 with BOM for Windows PowerShell 5.1. The manifest records source URLs, edit timestamps and SHA-256 of extracted UTF-8 content without BOM, with LF, no trailing line whitespace and one final newline.

## Source mapping

| Notion page | Repository file | Result |
| --- | --- | --- |
| [Windows Uptime](https://app.notion.com/p/2cd6138e249f80d0abe1c13256e7dcda?pvs=204) | [powershell/diagnostics/Get-WindowsUptime.ps1](../powershell/diagnostics/Get-WindowsUptime.ps1) | added |
| [pc info](https://app.notion.com/p/3266138e249f80a88271c2f11fcd8c69?pvs=204) | [powershell/diagnostics/Get-SystemReport.ps1](../powershell/diagnostics/Get-SystemReport.ps1) | unchanged |
| [safe disk cleanup](https://app.notion.com/p/2c46138e249f805a835cefa5f7b3641d?pvs=204) | [powershell/maintenance/Clear-TemporaryFiles.ps1](../powershell/maintenance/Clear-TemporaryFiles.ps1) | updated |
| [last installed updates](https://app.notion.com/p/3416138e249f80d8bdd8ce1ec734894f?pvs=204) | [powershell/diagnostics/Get-LastInstalledUpdates.ps1](../powershell/diagnostics/Get-LastInstalledUpdates.ps1) | added |
| [firefox installed?](https://app.notion.com/p/3fe6138e249f80448c8cf69ccc5f1bfb?pvs=204) | [powershell/diagnostics/Get-FirefoxInstallations.ps1](../powershell/diagnostics/Get-FirefoxInstallations.ps1) | added |
| [driver check](https://app.notion.com/p/3cf6138e249f80be86e8d2683eaa97a1?pvs=204) | [powershell/diagnostics/Test-DriverSecurity.ps1](../powershell/diagnostics/Test-DriverSecurity.ps1) | added |
| [Sitra Commands](https://app.notion.com/p/2776138e249f80e0aec3c8f0dac2ef03?pvs=204) | [docs/sitra-commands.md](../docs/sitra-commands.md) | added |
| [list installed apps](https://app.notion.com/p/2b76138e249f80149f9be687aa4f0080?pvs=204) | [powershell/diagnostics/Get-InstalledApplications.ps1](../powershell/diagnostics/Get-InstalledApplications.ps1) | added |
| [Chrome installed?](https://app.notion.com/p/4006138e249f8097a1aaf644441e0262?pvs=204) | [powershell/diagnostics/Get-ChromeInstallations.ps1](../powershell/diagnostics/Get-ChromeInstallations.ps1) | added |
| [Bluescreen info](https://app.notion.com/p/3826138e249f80bc8f44f45f875caa11?pvs=204) | [powershell/diagnostics/Get-BlueScreenInfo.ps1](../powershell/diagnostics/Get-BlueScreenInfo.ps1) | added |
| [Full Windows Repair](https://app.notion.com/p/2736138e249f80578a6fc286167c342b?pvs=204) | [powershell/maintenance/Invoke-FullWindowsRepair.ps1](../powershell/maintenance/Invoke-FullWindowsRepair.ps1) | added |
| [Chrome/firefox check](https://app.notion.com/p/4016138e249f80f4889dd1e5c26ebbda?pvs=204) | [powershell/diagnostics/Get-BrowserInstallations.ps1](../powershell/diagnostics/Get-BrowserInstallations.ps1) | added |
| [remove yandex](https://app.notion.com/p/3fb6138e249f80fe9c7dd91a165e3e37?pvs=204) | [powershell/maintenance/Remove-Yandex.ps1](../powershell/maintenance/Remove-Yandex.ps1) | added |
| [shrink PST files](https://app.notion.com/p/2af6138e249f808f86edcf2312545232?pvs=204) | [powershell/maintenance/Compress-OutlookPst.ps1](../powershell/maintenance/Compress-OutlookPst.ps1) | added |
| [DISM](https://app.notion.com/p/2736138e249f801f8605e3ec5334f470?pvs=204) | [powershell/maintenance/Repair-WindowsImage.ps1](../powershell/maintenance/Repair-WindowsImage.ps1) | updated |
| [10 largest folders](https://app.notion.com/p/2c36138e249f802e82a8d93930b16c13?pvs=204) | [powershell/files/Get-LargestFolders.ps1](../powershell/files/Get-LargestFolders.ps1) | updated |
| [top 10 memory hoggers](https://app.notion.com/p/2c46138e249f80a481f3dcbfda1ceb5b?pvs=204) | [powershell/diagnostics/Get-TopMemoryProcesses.ps1](../powershell/diagnostics/Get-TopMemoryProcesses.ps1) | added |
| [cpu and memory usage](https://app.notion.com/p/28e6138e249f8077b3caf5c8be1404e2?pvs=204) | [powershell/diagnostics/Watch-SystemUsage.ps1](../powershell/diagnostics/Watch-SystemUsage.ps1) | added |
| [Remove Windows updates](https://app.notion.com/p/2776138e249f80a6a4b5c01d70cc14b8?pvs=204) | [powershell/maintenance/Remove-WindowsUpdates.ps1](../powershell/maintenance/Remove-WindowsUpdates.ps1) | added |
| [Auto update Chrome](https://app.notion.com/p/27d6138e249f805fb89cfec1a475688b?pvs=204) | [powershell/maintenance/Update-Chrome.ps1](../powershell/maintenance/Update-Chrome.ps1) | added |
| [Unexpected Shutdown](https://app.notion.com/p/2736138e249f8066adf8fe9547e2a9bc?pvs=204) | [powershell/diagnostics/Get-UnexpectedShutdowns.ps1](../powershell/diagnostics/Get-UnexpectedShutdowns.ps1) | added |
| [Check Chrome version](https://app.notion.com/p/2726138e249f80f9840ccf96bc3e475e?pvs=204) | [powershell/diagnostics/Get-RemoteChromeVersion.ps1](../powershell/diagnostics/Get-RemoteChromeVersion.ps1) | added |
| [Check installed Office version](https://app.notion.com/p/2726138e249f80a8945fc90fa8c383b5?pvs=204) | [powershell/diagnostics/Get-OfficeVersion.ps1](../powershell/diagnostics/Get-OfficeVersion.ps1) | added |
| [Reinstall Edge](https://app.notion.com/p/2926138e249f8011a49ddf084b6863a8?pvs=204) | [powershell/maintenance/Reinstall-Edge.ps1](../powershell/maintenance/Reinstall-Edge.ps1) | added |

## Behavior and source limitations

These are source imports, validated for structure and syntax rather than executed on a Windows machine. Review machine-specific values before use.

- Get-LargestFolders now follows Notion: scans C:\ rather than all drives; no system-folder exclusion.
- Repair-WindowsImage now follows the five Notion DISM commands, including `/Source:WindowsUpdate` and `/ResetBase`; run elevated. Automatic elevation and the final pause from the old version are removed. `/Source:WindowsUpdate` is preserved from Notion and has not been validated as a repair-source value.
- Clear-TemporaryFiles gains the Notion banner and summary; retains temp/cache removal, recycle-bin clearing and DISM ResetBase.
- Invoke-FullWindowsRepair includes offline volume repair and network resets; its source description of safe checks should not be read as a guarantee of no disruption.
- Compress-OutlookPst preserves the source call to `$rootFolder.Compact()`; this is not a standard Outlook MAPIFolder method, so the existing catch may report failure rather than compacting PSTs.
- Update-Chrome preserves the source updater logic, including the unconditional scheduled-task success flag; triggering an update does not verify installation success.
- Remove-Yandex defaults to dry run as in Notion; `-Execute` performs removals and `-RemoveUserData` includes browser profiles.
- Remove-WindowsUpdates targets the two fixed KB numbers in the source. Get-RemoteChromeVersion uses placeholder hostnames PC01/PC02/PC03.

The Notion pages themselves were not modified. For per-file source provenance see [notion-sync.json](notion-sync.json).
