# Sitra commands

Source: [Sitra Commands](https://app.notion.com/p/2776138e249f80e0aec3c8f0dac2ef03?pvs=204)

These are separate, environment-specific commands. For Office sign-in repair, run the commands interactively as administrator and restart the device after `dsregcmd /leave`, before continuing with recovery.

```powershell
#ad sync command on vrds2 =>

invoke-command -computername vdc2 -scriptblock {start-adsyncsynccycle} -cred mathieu-cd
```

```powershell
#office login problems (run as ADMIN)=>

dsregcmd /leave

#Restart device!!!

dsregcmd /forcerecover

#check registration:

dsregcmd /status /debug
```
