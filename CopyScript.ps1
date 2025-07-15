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

echo "               Total    Copied   Skipped  Mismatch    FAILED    Extras" > $logdir\faileddoc.txt

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
        echo $($object).name >> "$logdir\faileddoc.txt"
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
        echo "$Path\$object" >> "$logdir\files.txt"
    }
}

if (test-path $logdir\files.txt)
{write-host ""
 write-host $lines
 Write-Host "=> MOVING LOOSE FILES <="
 write-host $lines
 write-host "" 
 
foreach ($file in (cat $logdir\files.txt))
{$filesize = [math]::round((Get-Item $file).length /1GB,2)
 write-host "moving $file ($filesize GB)"
 xcopy "$file" $destination >> $logdir\toremove.txt /Y
 del $logdir\toremove.txt}
 del $logdir\files.txt}

$dessize = $(Get-ChildItem $destination -recurse | Measure-Object -property length -sum).Sum /1GB
$procent = 100/($sourcesize/$dessize)
$totalafg = [math]::Round($procent,2)
$destafg = [math]::Round($dessize,2)
$sourceafg = [math]::round($sourcesize,2) 

(gc $logdir\faileddoc.txt) | ? {$_.trim() -ne "" } | set-content $logdir\faileddoc.txt

write-host ""
write-host $lines
write-host "copied $destafg GB of $sourceafg GB"
write-host ""
$endDTM = (Get-Date)

"Time taken: $([math]::round(($endDTM-$startDTM).totalminutes,2)) minutes"
write-host ""

if ($destafg -eq $sourceafg)
{write-host "=> EVERYTHING COPIED! <="
 write-host $lines}
else
{write-host "=> SOMETHING LOOKS WRONG? <="
 write-host $lines}
 Write-Host "" }