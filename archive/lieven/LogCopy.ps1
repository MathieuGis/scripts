$lineArray=@("03","04","05","06","07","08","09","10","11","12")

foreach ($element in $lineArray)
{
    foreach ($log in (get-childitem "\\Line_0$element\d$\Logging\Production\FWS\" | Where-object {$log.creationtime -gt ‘16/05/2017 10:00’ -AND $log.creationtime -lt ‘16/05/2017 20:00’} ))
    {
        write-host $log
    }

}

