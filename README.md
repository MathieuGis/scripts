# PowerShell, Bash and Batch scripts

Administration utilities and historical deployment projects, organized by platform and purpose.

| Directory | Contents |
| --- | --- |
| [powershell/diagnostics](powershell/diagnostics/) | Windows system, event and network reports |
| [powershell/maintenance](powershell/maintenance/) | Windows image repair and cleanup |
| [powershell/files](powershell/files/) | File copying, folder discovery and text extraction |
| [bash/diagnostics](bash/diagnostics/) | Linux system-information menu |
| [bash/user-management](bash/user-management/) | Remote user and SSH administration |
| [batch](batch/) | Legacy Windows Batch utilities |
| [projects/helpsite](projects/helpsite/) | Fleet and Sky help-site deployment scripts |
| [config](config/) | Configuration files, examples and setup instructions |
| [archive](archive/) | Historical projects, logs and scratch inputs |
| [tests](tests/) | Non-destructive structure and syntax checks |
| [backup](backup/) | Frozen snapshot of the original 56 files |

See the [Notion synchronization](docs/notion-sync.md) for imported scripts, source links and behavior changes.

Start with the [script catalogue](docs/script-catalogue.md) for purposes, prerequisites, parameters and example commands. See the [path migration](docs/path-migration.md) when updating existing shortcuts or scheduled tasks.

## Quick examples

From the repository root:

```powershell
powershell -File powershell/diagnostics/Show-SystemInfo.ps1
powershell -File powershell/files/Get-LargestFolders.ps1
```

```bash
bash bash/diagnostics/system-info.sh
```

Use Windows PowerShell 5.1 for Windows-only scripts using WMI. See the catalogue for PowerShell 7 recommendations. Bash user-management tools retain their existing remote account behavior; configure their lists before use. Maintenance and deployment tools change the target machine or servers and are not run by the validation checks.

## Configuration and output

Read [config/README.md](config/README.md). User-management scripts resolve configuration relative to this checkout and write new logs under runtime/user-management/. Existing configuration contents are retained; credentials are not changed by this reorganization. Legacy Batch tools and historical archive scripts retain their original environment assumptions.

Generated output and machine-local overrides are ignored by Git. Historical logs live in archive/ rather than the active tools. The backup/ snapshot is unchanged and excluded from text normalization. New Bash files use LF; PowerShell and Batch files check out with CRLF through .gitattributes.

## Validation

```bash
python3 tests/validate-repository.py
```

On Windows, also run this parser-only check (it does not execute the scripts):

```powershell
powershell -File tests/Test-PowerShellSyntax.ps1
```

Keep experimental snippets in archive/ until their purpose and requirements are documented. Use tests/ for actual checks. Keep backup/ frozen; use Git history/tags and a separate repository backup for later checkpoints.
