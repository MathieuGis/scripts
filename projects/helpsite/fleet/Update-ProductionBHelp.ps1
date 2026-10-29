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

. (Join-Path $PSScriptRoot '../Import-HelpSiteSettings.ps1')

#TXC 1 - 9

write-host $(date)

$i=1
While ($i -le 9)
    {
    
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\English\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\German\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Spanish\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\French\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Italian\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Dutch\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Polish\* -recurse -force 

    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpde\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item $HelpSourceRoot\helpes\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpfr\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpit\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpnl\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helppl\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Romanian\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Swedish\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Czech\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Danish\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Norwegian\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Russian\* -recurse -force
    Remove-Item \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Slovak\* -recurse -force
    
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "TXC_00$i has been copied on $(date)"  >> $HelpSourceRoot\updatelog.txt
     
    $i++
    }

#TXC 10 -22

$i=10
While ($i -le 22)
    {

    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\English\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\German\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Spanish\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\French\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Italian\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Dutch\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Polish\* -recurse -force
    
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpde\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item $HelpSourceRoot\helpes\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpfr\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpit\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpnl\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helppl\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Romanian\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Swedish\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Czech\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Danish\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Norwegian\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Russian\* -recurse -force
    Remove-Item \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Slovak\* -recurse -force
    
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\TXC_0$i\c$\TRANSICS\WebSites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "TXC_0$i has been copied on $(date)"  >> $HelpSourceRoot\updatelog.txt
        
    $i++
    }