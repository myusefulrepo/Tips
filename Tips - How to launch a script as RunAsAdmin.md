# How to launch a script as RunAsAdmin

There are miltiple ways to to this. I'm thinking the easiest way is to test test if the script is running in ````RunAsAdmin```` mode. 
If not, the script will start a new process Powershell using the ````-Verb```` parameter with the value ````RunAs```` and execute the script in this new process. 

For that, in the beginning of the script add this : 

````powershell
 if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
    { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
    }
````
## Final word
This tips is a reminder for me ... and I hope for other people. 






