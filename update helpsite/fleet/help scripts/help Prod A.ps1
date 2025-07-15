<#$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);
   exit
   }#>

#TXP 1 - 3

write-host $(date)

echo "--------------------------------"  >> C:\Temp\help\updatelog.txt
echo "update prod A started on $(date)"  >> C:\Temp\help\updatelog.txt
echo "--------------------------------"  >> C:\Temp\help\updatelog.txt
 
$i=1
While ($i -le 3)
    {
    
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\English\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\German\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Spanish\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\French\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Italian\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Dutch\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Polish\* -recurse -force -verbose

    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item C:\Temp\help\helpde\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item C:\Temp\help\helpes\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpfr\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item C:\Temp\help\helpit\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpnl\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item C:\Temp\help\helppl\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Romanian\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Swedish\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Czech\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Danish\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Norwegian\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Russian\* -recurse -force -verbose
    Remove-Item \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Slovak\* -recurse -force -verbose
    
    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item C:\Temp\help\helpen\* \\TXP_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "TXP_00$i has been copied on $(date)"  >> C:\Temp\help\updatelog.txt
     
    $i++
    }
