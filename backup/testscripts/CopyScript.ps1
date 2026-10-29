# used to copy all docscan"briel" on verizon

$Path = "\\fileserver_01\d$"
$Destination = "H:\fileserver\D"
$logdir = "C:\Users\$([Environment]::UserName)\Desktop\docscancopy"
$sourcesize = 449  #$(Get-ChildItem $path -recurse | Measure-Object -property length -sum).Sum /1GB
$startDTM = (Get-Date)
$lines = "=========================================================================="

clear

 if (test-path $logdir)
{ write-host $lines
  write-host "=> LOGDIR EXISTS <="
  write-host $lines}
else
{ mkdir $logdir
  write-host $lines
  write-host "=> LOGDIR CREATED <="
  write-host $lines}

Write-Host "               Total    Copied   Skipped  Mismatch    FAILED    Extras" > $logdir\faileddoc.txt

if (test-path $Destination\*)
{write-host $lines
 write-host "=> DIRECTORY NOT EMPTY! <="
 write-host $lines}
else
{Write-Host ""
 write-host $lines
 write-host "=> MOVING FOLDERS <="
 write-host $(get-date)
 write-host $lines
 Write-Host ""

 ForEach ($object in (Get-ChildItem "$Path"))
{
    $logname = "$($object)_log.txt"

    if ((Get-Item "$Path\$object").PSIsContainer)
    {
        $target = [math]::round((Get-ChildItem "$Path\$object" -recurse | Measure-Object -property length -sum).Sum / 1GB, 2)
        Write-Host "moving $Path\$object with size: $target GB"
        Robocopy "$Path\$object" "$Destination\$object" /e /z /v /r:5 /w:5 > "$logdir\$logname"
        Write-Host $($object).name >> "$logdir\faileddoc.txt"
        Get-Content "$logdir\$logname" | Select-String -Pattern ("files :    ") >> "$logdir\faileddoc.txt"
        Remove-Item "$logdir\$logname"

        $dessize = (Get-ChildItem "$Destination" -recurse | Measure-Object -property length -sum).Sum / 1GB
        $procent = 100 / ($sourcesize / $dessize)
        $totalafg = [math]::Round($procent, 2)
        $destafg = [math]::Round($dessize, 2)
        $sourceafg = [math]::Round($sourcesize, 2)

        Write-Host (Get-Date)
        Write-Host "Moved $totalafg % ($destafg GB / $sourceafg GB )"
        Write-Host ""
    }
    else
    {
        Add-Content -Path "$logdir\files.txt" -Value "$Path\$object"
    }
}

if (Test-Path "$logdir\files.txt")
{
    Write-Host ""
    Write-Host $lines
    Write-Host "=> MOVING LOOSE FILES <="
    Write-Host $lines
    Write-Host ""
    foreach ($file in (Get-Content "$logdir\files.txt"))
    {
        $filesize = [math]::round((Get-Item $file).length / 1GB, 2)
        Write-Host "moving $file ($filesize GB)"
        xcopy "$file" "$Destination" >> "$logdir\toremove.txt" /Y
        Remove-Item "$logdir\toremove.txt" -ErrorAction SilentlyContinue
    }
    Remove-Item "$logdir\files.txt" -ErrorAction SilentlyContinue
}

$dessize = (Get-ChildItem "$Destination" -recurse | Measure-Object -property length -sum).Sum / 1GB
$procent = if ($dessize -ne 0) { 100 / ($sourcesize / $dessize) } else { 0 }
$totalafg = [math]::Round($procent, 2)
$destafg = [math]::Round($dessize, 2)
$sourceafg = [math]::Round($sourcesize, 2)

(Get-Content "$logdir\faileddoc.txt") | Where-Object { $_.Trim() -ne "" } | Set-Content "$logdir\faileddoc.txt"

Write-Host ""
Write-Host $lines
Write-Host "copied $destafg GB of $sourceafg GB"
Write-Host ""
$endDTM = (Get-Date)

Write-Host "Time taken: $([math]::round(($endDTM-$startDTM).TotalMinutes,2)) minutes"
Write-Host ""

if ($destafg -eq $sourceafg)
{
    Write-Host "=> EVERYTHING COPIED! <="
    Write-Host $lines
}
else
{
    Write-Host "=> SOMETHING LOOKS WRONG? <="
    Write-Host $lines
}
Write-Host ""