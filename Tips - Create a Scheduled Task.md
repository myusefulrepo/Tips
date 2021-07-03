In a Active Directory Domain context there are several ways to create Scheduled tasks on computers.
The question in not "is it a GUI way or a Powershell way". OK, I concede that i prefer the powershell way.

In this post, i will mention mainly security considerations and maintaining in operational conditions.

# CONSIDERATIONS

## Pre-requisite
- AD In functional level > 2012 (AD Schema must be 52)
- The first master root key (KDS Root Key) for Active Directory has been created on the forest

## Security considerations
- Scheduled Task should run respecting the principle of least privilege
- Script, executing by the Scheduled Task, should run respecting the principle of least privilege

## Maintaining in operational conditions
- Reduce to the minimal some boring - but necessary - administratives tasks like changing regularly the accounts password.

If you have an Active Directory with functional level 2012, then you can use G.M.S.A. (Group Managed Service Accounts). A GMSA is a new AD Object, and this object can be use to run a Windows Service on a remote computer of the AD Domain.
It respect the principle of least privilege on the remote computer. Technically the remote computer has delegation for renew the GMSA password with the Active Directory. The settings about password are in the GMSA properties.
A GMSA have also a property name ApplyTo. This property could be a AD Computer or a Global Security Group populate with AD Computers. If you use this last way you can use the same GMSA on several computers.

But do you know that a GMSA could be use also with scheduled Task respecting the principle of least privilege too ?


# Let's go to do this, with powershell
## Create a Global Security Group
````Powershell
$NewADServiceAccountArgs = @{
                            Name = "GMSA-ScheduledTasks"
                            Description = "GMSA use tu run scheduled Tasks"
                            DNSHostName = "GMSA-ScheduledTasks.myDomain.com"
                            Enabled = $true
                            PrincipalsAllowedToRetrieveManagedPassword = "SG-ScheduleTask" # this is the previously created Global Security Group
}
<# Note :
- I don't define Path parameter, the default path in Active Directory is "Managed Service Accounts" builtin container but you can use an OU if you want.
- I don't define ManagedPasswordIntervalInDays parameter. By default, it value is 30 Days. The password change interval can only be set during creation.
  If you need to change the interval, you must create a new gMSA and set it at creation time.
#>
````
## Deploy the GMSA on a remote computer (locally)
````powershell
# To Deploy on a computer
Install-ADServiceAccount -AuthType=0 -Identity "GMSA-ScheduledTasks"
# To check if GMSA is deployed on a computer
Test-ADServiceAccount "GMSA-ScheduledTasks" # this return True if it's OK
````
## Deploy the GMSA on remote computers (remotly)
````powershell
$Servers = Get-ADGroupMember -Identity "SG-ScheduleTask" | Select-Object Name
foreach ($server in $server)
    {
     Invoke-Command -ComputerName $server.Name -ScriptBlock {
                                                             Install-ADServiceAccount -AuthType=0 -Identity "GMSA-ScheduledTasks";
                                                             Test-ADServiceAccount "GMSA-ScheduledTasks"
                                                            }
    }
````

## Create a Scheduled Task on the computer
This couldn't be done by GUI, only powershell is possible. Normal, we can't know the GMSA password, only the concerning computer (s) know it.
First you can enter in a PSSession
Example in action :
````powershell
Enter-PSSession -ComputerName "RemoteComputer"
$Action = New-ScheduledTaskAction "c:\scripts\MyScript.ps1" # this script contains the code seen in "Deploy the GMSA on a remote computer (locally)" section
$Trigger = New-ScheduledTaskTrigger -At 23:00 -Daily
$Principal = New-ScheduledTaskPrincipal -UserID MyDomain\GMSA-ScheduledTask$ -LogonType Password
    # nota 1 : the $ at the end of the GMSA Account, like a computer account
    # Nota 2 : The value "password" in the parameter logonType is not the password. It just requires the scheduled task to receive the current password of the gMSA of a domain controller
Register-ScheduledTask "MyScheduledTask" -Action $Action -Trigger $Trigger -Principal $Principal
````

# SYNTHESIS
By this way, it's very easy to have a single account for the different tasks scheduled on different computers whose password is maintained by design securely by the AD.

**Secure** - **Automatically maintained and managed**, what more could you wish for ?
