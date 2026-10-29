$lineArray=@("03","04","05","06","07","08","09","10","11","12")

foreach ($element in $lineArray)
{
    foreach ($log in (get-childitem "C:\Users\mathieug\Desktop\script and batch\LIEVEN\logs"))
    {
         $FileDate = $log.creationtime
         write-host $FileDate
    }
}
