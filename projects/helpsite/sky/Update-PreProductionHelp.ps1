. (Join-Path $PSScriptRoot '../Import-HelpSiteSettings.ps1')

#line 1 - 2

write-host $(date)

echo "--------------------------------"  >> $HelpSourceRoot\updatelog.txt
echo "update PROD A started on $(date)"  >> $HelpSourceRoot\updatelog.txt
echo "--------------------------------"  >> $HelpSourceRoot\updatelog.txt

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

    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpde\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item $HelpSourceRoot\helpes\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpfr\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpit\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpnl\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helppl\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Romanian\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Swedish\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Czech\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Danish\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Norwegian\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Russian\* -recurse -force -verbose
    Remove-Item \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Slovak\* -recurse -force -verbose
    
    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_30$i\c$\TRANSICS\PreProduction\Websites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "Line_30$i has been copied on $(date)"  >> $HelpSourceRoot\updatelog.txt
     
    $i++
    }