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

#line 1 - 9

write-host $(date)

echo "--------------------------------"  >> $HelpSourceRoot\updatelog.txt
echo "update PROD B started on $(date)"  >> $HelpSourceRoot\updatelog.txt
echo "--------------------------------"  >> $HelpSourceRoot\updatelog.txt

$i=1
While ($i -le 9)
    {
    
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\English\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\German\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Spanish\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\French\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Italian\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Dutch\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Polish\* -recurse -force -verbose

    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpde\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item $HelpSourceRoot\helpes\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpfr\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpit\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpnl\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helppl\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Romanian\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Swedish\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Czech\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Danish\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Norwegian\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Russian\* -recurse -force -verbose
    Remove-Item \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Slovak\* -recurse -force -verbose
    
    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_00$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "Line_00$i has been copied on $(date)"  >> $HelpSourceRoot\updatelog.txt
     
    $i++
    }

#line 10 - 18

$i=10
While ($i -le 18)
    {

    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\English\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\German\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Spanish\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\French\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Italian\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Dutch\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Polish\* -recurse -force -verbose

    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\English -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpde\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\German -recurse -force -Verbose
    Copy-Item $HelpSourceRoot\helpes\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Spanish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpfr\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\French -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpit\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Italian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpnl\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Dutch -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helppl\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Polish -recurse -force -verbose
    
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Romanian\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Swedish\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Czech\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Danish\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Norwegian\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Russian\* -recurse -force -verbose
    Remove-Item \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Slovak\* -recurse -force -verbose
    
    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Romanian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Swedish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Czech -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Danish -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Norwegian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Russian -recurse -force -verbose
    Copy-Item $HelpSourceRoot\helpen\* \\line_0$i\c$\TRANSICS\Production\Websites\HelpWebsite\Content\Slovak -recurse -force -verbose 

    echo "Line_0$i has been copied on $(date)"  >> $HelpSourceRoot\updatelog.txt
        
    $i++
    }