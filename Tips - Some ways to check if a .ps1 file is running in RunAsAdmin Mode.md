# Some ways to check if a .ps1 file is running in RunAsAdmin mode

## using a function

````powershell
function Test-ISElevated
{
  $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $p = New-Object System.Security.Principal.WindowsPrincipal ($id)
  if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
  {
    Write-Output $true
    Write-Output " You're in RunAsAdmin mode"
  }
  else
  {
    Write-Output $false
  }
}

if (-not $(Test-IsElevated))
{
  Write-Error -Message 'Access Denied. Please run with Administrator privileges.'
  exit 1
}
````
The previous code test if the script is running in RunAsAdmin mode, but it doesn't switch to this mode.


## Self Evelevating script

````powershell
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
{
  Start-Process powershell.exe '-NoProfile -ExecutionPolicy Bypass -File ' $PSCommandPath"" -Verb RunAs
  #exit
}
````
This code test if the script is running in a RinAsAdmin mode and if not the case, launch another powershell instance of powershell and exec the script once again




