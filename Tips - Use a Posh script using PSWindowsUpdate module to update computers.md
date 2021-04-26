# Use a Powershell script using ````PSWindowsUpdate```` module to update Remote Computers

The PSWindowsUpdate Module is a great module. It targets the Windows Update client (wuaclt.exe) and conditions their behavior. Of course, it also able to be running remotely (The main cmdlets have a -````ComputerName```` parameter).

The different ways to use it, are in preference order :

- Running a central script that call remote computers : This is the best way. Easy to maintain
- Running a local script in each remote computer : Harder ! Some questions to answer before.
  - How to copy the script on each computer
  - How to run the script on each computer ... Scheduled Task, OK ! but we must create this one.
  - ... and a couple of other questions

Of course, we can answer to all questions and then, integrate the script, its dependencies (Posh Modules), ans the Scheduled Task in a Master (if physical computer) or template (if virtual computer).

There will always remain the question of keeping the existing computers in operational condition and managing changes. This is why a central way is better.

Let's show how to do the different task to use local script in existing computers.

- copies the dependencies (Posh module) to the remote Computer,
- copies a powershell script (WindowsUpdate.ps1) to the Remote Computer,
- creates a windows task that calls the WindowsUpdate.ps1 script (note that there is no schedule attached to the task).

## Deploy Posh modules, Scripts, and create Scheduled Task

````powershell
$ServerList = "Computer1","Computer2"
$Script = {
# Set ExecutionPolicy to avoid any issue
Set-ExecutionPolicy Unrestricted -Force
# Unblocks module files. I presume, that module files haven't beeb unblocked after they have been download from the Internet and copy to the internal repository
Unblock-File -Path "C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate\*"
# Import module
Import-Module -Name PSWindowsUpdate -Force -Scope Global
# Check if there is an existing scheduled Task, then create
$Task = Get-ScheduledTask | Where-Object TaskName -eq  "Posh-WindowsUpdate"
 If (-not $Task)
  {
  $TaskName = "Posh-WindowsUpdate"
  $TaskAction = New-ScheduledTaskAction -Execute "PowerShell" -Argument ".\WindowsUpdate.ps1" -WorkingDirectory "C:\Scripts"
  $TaskPrincipal = New-ScheduledTaskPrincipal -GroupId "SYSTEM" -RunLevel "Highest"
  Register-ScheduledTask $TaskName -Action $TaskAction -Principal $TaskPrincipal | Out-Null
  }
}
ForEach ($Server in $ServerList)
 {
 # Remove - if already existing - and Install Posh modules : PSWindowsUpdate and EZLog (Posh module to create easily log files.)
 If(test-path "\\$Server\c$\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate")
   {
   Remove-Item "\\$Server\c$\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate" -Recurse -Force | Out-Null
   }
 New-Item -ItemType Directory -Force -Path "\\$Server\c$\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate" | Out-Null
 Copy-Item "\\InternalRepository\Modules\PSWindowsUpdate\*" "\\$Server\c$\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate" -Recurse -Force

 If(test-path "\\$Server\c$\Program Files\WindowsPowerShell\Modules\EZLog")
   {
   Remove-Item "\\$Server\c$\Program Files\WindowsPowerShell\Modules\EZLog" -Recurse -Force | Out-Null
   }
 New-Item -ItemType Directory -Force -Path "\\$Server\c$\Program Files\WindowsPowerShell\Modules\EZLog" | Out-Null
 Copy-Item "\\InternalRepository\Modules\EZLog\*" "\\$Server\c$\Program Files\WindowsPowerShell\Modules\EZLog" -Recurse -Force

 # Copy Scripts
 Copy-Item "\\InternalRepository\Scripts" "\\$Server\c$\" -Recurse -Force
 # Check ScheduledTask and creation
 Invoke-Command -ComputerName $Server -Script $Script | Out-Null
}
````

At this step, we have deployed Posh Modules, Script and create Scheduled Task

## Take a look at the WindowsUpdate.ps1 script

````powershell
$Date = Get-Date -Format "dd-MM-yyyy-hh-MM-ss"
Import-Module EZLog
$LogFile = Join-Path -Path "$PSScriptRoot\Log-$($MyInvocation.MyCommand.Name)-$Date.log"
$PSDefaultParameterValues  = @{ 'Write-EZLog:LogFile'   = $LogFile
                                'Write-EZLog:Delimiter' = ';'
                                'Write-EZLog:ToScreen'  = $true
                              }
Import-Module PSWindowsUpdate
Write-EZLog -Header
Write-EZLog -Category INF -Message "Start Installing Update to $Env:ComputerName"
Get-WindowsUpdate -Install -Acceptall -Autoreboot -Verbose | Write-EZLog -Category INF
Write-EZLog -Category INF -Message "End Installing Update to $Env:ComputerName"
Write-EZLog -Footer
````

## Scheduling

Once all the Remote computers are configured with modules, powershell script, and windows task you have a couple different options.
You can either :

- Attach a schedule to the local task on each Remote Computer
or
- Create a separate windows task and corresponding schedule on a central management server that calls the Remote Computer specific tasks remotely. Using a central task for scheduling is a better way, because it's easier to manage. The task on the central server would call a script like the one below.

````powershell
$Servers= "Computer1","Computer2"
Workflow InstallUpdates
{
    param ($Servers)
 ForEach -Parallel -ThrottleLimit 5 ($Server in $Servers)
 {
  Write-Output "Checking for updates on $Server..."
  $Updates = inlineScript
        {
            $Script = {
                      Import-Module PSWindowsUpdate -Force
                      $UpdateList = Get-WindowsUpdate
                     if ($UpdateList)
                        {
                        return 1
                        }
                      }

            $Value = Invoke-Command -Computer $Using:Server -Script $Script
            return  $Value
        }

  if ($Updates -eq 1) # updates are pending
  {
   Write-Output "Installing updates on $Server..."
   inlineScript  {Invoke-Command -Computer $Using:Server -ScriptBlock {schtasks /run /tn "Posh-WindowsUpdate"} | Out-Null}
   Start-Sleep -s 300
  }
  else
  {
   Write-Output "No updates available on $Server..."
  }
 } #end foreach
} #end workflow
# run Workflow
InstallUpdates -Servers $Servers

````

## Final words

One thing worth pointing out is that the reason for calling a windows task instead of a powershell script directly from the central management server is due to permissions. I wasn't able to get a remote call that installs updates to work correctly. The workaround for this is to call a windows task remotely and have that call the powershell script that installs updates locally instead.

We can also create a simple script, easy to maintain, using the workflow with different collections of remote computers. The following is very basic.

````powershell
$Date = (Get-Date).Hour
Switch ($Date)
 {
     9  {InstallUpdates -Servers $Servers1}
     10 {InstallUpdates -Servers $Servers2}
     11 {InstallUpdates -Servers $Servers3}
 }
````

With ````ServersX```` the result of ````Get-Content```` .txt file containing a list of servers.

Of course the workflow is also very basic, we could improve it by adding more informations, using other **PSWindowsUpdate** cmdlets like ````Get-WUHistory````, ````Get-WULastResults````, ````Get-WURebootStatus```` or by adding additional tests like ````Test-Connection```` if a reboot was required.

Initial Source inspiring me : <https://www.reddit.com/r/PowerShell/comments/ezir2i/pswindowsupdate_2019_rds_servers/>
