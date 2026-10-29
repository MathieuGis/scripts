#line 1 - 2

write-host $(date)

echo "--------------------------------"  >> C:\Temp\help\updatelog.txt
echo "update PROD A started on $(date)"  >> C:\Temp\help\updatelog.txt
echo "--------------------------------"  >> C:\Temp\help\updatelog.txt

$i=1
While ($i -le 2)
    {
    
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\English\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\German\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Spanish\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\French\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Italian\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Dutch\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Polish\* -recurse -force -verbose

    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item C:\Temp\help\helpde\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item C:\Temp\help\helpes\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpfr\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item C:\Temp\help\helpit\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpnl\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item C:\Temp\help\helppl\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Romanian\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Swedish\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Czech\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Danish\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Norwegian\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Russian\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Slovak\* -recurse -force -verbose
    
    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "Line_30$i has been copied on $(date)"  >> C:\Temp\help\updatelog.txt
     
    $i++
    }