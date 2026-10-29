$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
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
   }


. (Join-Path $PSScriptRoot '../Import-HelpSiteSettings.ps1')

$i=1
While ($i -le 9)
    {
    
    Copy-Item $HelpSourceRoot\Helpwebsite\* \\TXC_00$i\c$\TRANSICS\WebSites\HelpWebsite\ -force -Recurse -verbose

    $i++

    }

$l=10
While ($l -le 22)
    {

    Copy-Item $HelpSourceRoot\Helpwebsite\* \\TXC_0$l\c$\TRANSICS\WebSites\HelpWebsite\ -force -Recurse  -verbose

    $l++

    }
    