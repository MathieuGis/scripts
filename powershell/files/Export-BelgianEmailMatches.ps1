[CmdletBinding()]
param(
    [string]$InputDirectory = 'F:\BigDump',
    [string]$OutputFile = 'E:\export\belgian.txt'
)

foreach ($doc in (Get-ChildItem -LiteralPath $InputDirectory -File)) {
    Get-Content -LiteralPath $doc.FullName |
        Select-String -Pattern '[a-z_]+@[a-z]+\.(be)' |
        Add-Content -LiteralPath $OutputFile
}
