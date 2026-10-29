# Configuration

## User management

The existing serverlist.txt and userlist.txt have moved into user-management/ without content changes. Defaults resolve relative to the repository, not /home/<user>/usercreation or the shell working directory. Companion scripts resolve relative to their own location.

To use a separate configuration directory, copy the example files, remove their comment lines, supply the same existing formats, then set USER_MANAGEMENT_CONFIG_DIR. A server list has one hostname/IP per line; a user list has username:password-hash records with no header/comments. USER_MANAGEMENT_LOG_DIR overrides the default runtime/user-management/ output directory. Both paths may contain spaces. The example files are templates and are not loaded automatically.

```bash
export USER_MANAGEMENT_CONFIG_DIR="$HOME/my-script-config"
export USER_MANAGEMENT_LOG_DIR="$HOME/my-script-logs"
bash bash/user-management/test-login.sh
```

Account names, credential handling and remote commands remain the original behavior. create-user.sh and configure-sudo.sh are remote helper scripts called by the local orchestration scripts.

## Help-site deployment

Copy helpsite.example.json to helpsite.local.json and set sourceRoot. The local file is ignored. Without an override, the existing C:\Temp\help source path is used. HELPSITE_SOURCE_ROOT can override the file setting. Existing destination hosts and deployment operations remain in the corresponding Fleet/Sky script.

## File utilities

Copy-DocumentFolders.ps1 accepts SourcePath, DestinationPath, LogDirectory and ExpectedSizeGB. Export-BelgianEmailMatches.ps1 accepts InputDirectory and OutputFile. Defaults preserve the previous locations.
