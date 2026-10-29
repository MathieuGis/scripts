# Validation

Run python3 tests/validate-repository.py from any working directory. It checks the path migration, the frozen backup hashes, active Bash syntax, relocated Bash path resolution, line endings and local Markdown links without running administration or deployment scripts.

On Windows, powershell -File tests/Test-PowerShellSyntax.ps1 parses active PowerShell files using the PowerShell parser without executing them. Historical archive/ and backup/ scripts are intentionally excluded.
