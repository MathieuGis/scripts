#line 1 - 2

write-host $(date)

echo "-----------------------------------------"  >> C:\Temp\help\updatelog.txt
echo "update FT started on $(date)"  >> C:\Temp\help\updatelog.txt
echo "-----------------------------------------"  >> C:\Temp\help\updatelog.txt

$i=1
While ($i -le 2)
    {
    
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\English\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\German\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Spanish\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\French\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Italian\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Dutch\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Polish\* -recurse -force -verbose

    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item C:\Temp\help\helpde\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item C:\Temp\help\helpes\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpfr\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item C:\Temp\help\helpit\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpnl\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item C:\Temp\help\helppl\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Romanian\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Swedish\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Czech\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Danish\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Norwegian\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Russian\* -recurse -force -verbose
    Remove-Item \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Slovak\* -recurse -force -verbose
    
    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\line_20$i\c$\TRANSICS\FieldTest\Websites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "line_20$i has been copied on $(date)"  >> C:\Temp\help\updatelog.txt
     
    $i++
    }