Write-Host "`n=== DRIVER SECURITY CHECK ===`n" -ForegroundColor Cyan

$drivers = Get-CimInstance Win32_PnPSignedDriver |
    Where-Object DeviceName

Write-Host "Problem devices:" -ForegroundColor Yellow
Get-PnpDevice |
    Where-Object Status -ne "OK" |
    Select-Object Status, Class, FriendlyName |
    Format-Table -AutoSize

Write-Host "`nUnsigned drivers:" -ForegroundColor Yellow
$drivers |
    Where-Object IsSigned -ne $true |
    Select-Object DeviceName, Manufacturer, DriverVersion, DriverDate, InfName |
    Format-Table -AutoSize

Write-Host "`nDriver files with signature problems:" -ForegroundColor Yellow

Get-ChildItem "$env:windir\System32\drivers\*.sys" |
    ForEach-Object {
        $sig = Get-AuthenticodeSignature $_.FullName

        if ($sig.Status -notin @("Valid", "NotSigned")) {
            [PSCustomObject]@{
                File   = $_.Name
                Status = $sig.Status
                Signer = $sig.SignerCertificate.Subject
            }
        }
    } |
    Format-Table -AutoSize

Write-Host "`n=== SFC CHECK ===" -ForegroundColor Cyan
sfc /verifyonly

Write-Host "`n=== COMPLETE ===" -ForegroundColor Green
