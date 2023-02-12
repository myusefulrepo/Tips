# Differents Ways to view loggued-on Users

## The Differents ways
- [X] Quser.exe
- [X] PsloggedOn.ex
- [X] Get-CimInstance or Get-WMiObject (deprecated) : 2 different class
- [X] Get-Process
- [X] Get-PSSession

## Quser.exe way

Quser is a builtin DOS command. As all DOS commands, the command return on ````[String block]```` and not an ````object```` as Powershell cmdlets.

### Get Users loggedOn locally

````powershell
quser
 UTILISATEUR           SESSION            ID  TAT    TEMPS INACT TEMPS SESSION
>olivier               console             1  Actif       aucun   12/02/2023 07:11
````

As you can see, the outuput id depending of the culture. Another drawback occurs when we want to parse the output. The length of the words is not the same also according to the languages. The best way is to get rid of all that.

Example : 

````powershell
$Computer = $env:COMPUTERNAME
$SessionList = quser /Server:$Computer. 2>$null
$UserInfo = foreach ($Session in ($SessionList | select -Skip 1)) # Skip the headers line
    {
    # Trim $Session, replace multi blank spaces by only one, remove '>' if present
    $Session = $Session.ToString().trim() -replace '\s+', ' ' -replace '>', ''
    # If we split $Session, each part is corresponding respectively to UserName (0), SessionName (1), Session ID (2), SessionState (3), IdleTime (4), LogonTime (5, 6, 7)
    if ($Session.Split(' ')[3] -eq 'Active') 
        {
        [PSCustomObject]@{
                          ComputerName = $Computer.ToUpper()
                          UserName     = $session.Split(' ')[0]
                          SessionName  = $session.Split(' ')[1]
                          SessionID    = $Session.Split(' ')[2]
                          SessionState = $Session.Split(' ')[3]
                          IdleTime     = $Session.Split(' ')[4]
                          LogonTime    = $session.Split(' ')[5, 6, 7] -as [string] -as [datetime]
                          }
        }
    else 
        {
         [PSCustomObject]@{
                           ComputerName = $Computer.ToUpper()
                           UserName     = $session.Split(' ')[0]
                           SessionName  = $null
                           SessionID    = $Session.Split(' ')[1]
                           SessionState = 'Disconnected'
                           IdleTime     = $Session.Split(' ')[3]
                           LogonTime    = $session.Split(' ')[4, 5, 6] -as [string] -as [datetime]
                           }
        }
    }
$UserInfo

<#
ComputerName : asus10
UserName     : olivier
SessionName  : 
SessionID    : console
SessionState : Disconnected
IdleTime     : Actif
LogonTime    : 
#>
````

We can show above that the ````SessionState```` is not returned. We can deduce that it's the ````else```` that has been processed and not the ````if````. 

So I should add a test to determine the ````SessionState```` value

````powershell
if ((Get-Culture).Name -eq "fr-Fr") 
    {
    $SessionCulture = 'Actif'
    }   
elseif ((Get-Culture).Name -eq "fr-Fr") 
    {
    $SessionCulture = 'Active'
    }
````
then the if statement will be

````powershell 
if (($Session.Split(' ')[3] -eq $SessionCulture)  -eq 'Active') 
    {
        ...
        }
````

Now, this works fine for the 2 defined cultures. 

### Get Users loggedOn on one or more remote computers

we can keep the same principle as before. Here a complet code from https://thesysadminchannel.com/get-logged-in-users-using-powershell/
I've slightly modified it to run in my culture. 

```` powershell 
Function Get-LoggedInUser
{
    <#
.SYNOPSIS
    This will check the specified machine to see all users who are logged on.
    For updated help and examples refer to -Online version.

.NOTES
    Name: Get-LoggedInUser
    Author: Paul Contreras
    Version: 3.0
    DateUpdated: 2021-Sep-21

.LINK
    https://thesysadminchannel.com/get-logged-in-users-using-powershell/ -
    For updated help and examples refer to -Online version.

.PARAMETER ComputerName
    Specify a computername to see which users are logged into it.  If no computers are specified, it will default to the local computer.

.PARAMETER UserName
    If the specified username is found logged into a machine, it will display it in the output.

.EXAMPLE
    Get-LoggedInUser -ComputerName Server01
    Display all the users that are logged in server01

.EXAMPLE
    Get-LoggedInUser -ComputerName Server01, Server02 -UserName jsmith
    Display if the user, jsmith, is logged into server01 and/or server02
#>

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string[]]
        $ComputerName = $env:COMPUTERNAME,


        [Parameter(
            Mandatory = $false
        )]
        [Alias('SamAccountName')]
        [string]   $UserName
    )

    BEGIN
    {
    }

    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            try
            {
                $SessionList = quser /Server:$Computer 2>$null
                if ($SessionList)
                {
                    $UserInfo = foreach ($Session in ($SessionList | Select-Object -Skip 1))
                    {
                        $Session = $Session.ToString().trim() -replace '\s+', ' ' -replace '>', ''
                        if ((Get-Culture).Name -eq 'fr-Fr') 
                        {
                            $SessionCulture = 'Actif'
                        }      
                        elseif ((Get-Culture).Name -eq 'fr-Fr') 
                        {
                            $SessionCulture = 'Active'
                        }
                        if ($Session.Split(' ')[3] -eq $SessionCulture)
                        {
                            [PSCustomObject]@{
                                ComputerName = $Computer.toUpper()
                                UserName     = $session.Split(' ')[0]
                                SessionName  = $session.Split(' ')[1]
                                SessionID    = $Session.Split(' ')[2]
                                SessionState = $Session.Split(' ')[3]
                                IdleTime     = $Session.Split(' ')[4]
                                LogonTime    = $session.Split(' ')[5, 6, 7] -as [string] -as [datetime]
                            }
                        }
                        else
                        {
                            [PSCustomObject]@{
                                ComputerName = $Computer.toUpper()
                                UserName     = $session.Split(' ')[0]
                                SessionName  = $null
                                SessionID    = $Session.Split(' ')[1]
                                SessionState = 'Disconnected'
                                IdleTime     = $Session.Split(' ')[3]
                                LogonTime    = $session.Split(' ')[4, 5, 6] -as [string] -as [datetime]
                            }
                        }
                    }

                    if ($PSBoundParameters.ContainsKey('Username'))
                    {
                        $UserInfo | Where-Object { $_.UserName -eq $UserName }
                    }
                    else
                    {
                        $UserInfo | Sort-Object LogonTime
                    }
                }
            }
            catch
            {
                Write-Error $_.Exception.Message

            }
        }
    }

    END
    {
    }
}
````

We the previous code, the output is like the expected for the en-us and fr-fr culture. 

## PsloggedOn.exe

The ````psloggedOn.exe```` is a DOS command from the [SysternalsSuite]([url](https://learn.microsoft.com/en-us/sysinternals/downloads/psloggedon))

PsLoggedOn does not support to specify alternate credentials. Therefore, you need to run the tool under an account that has administrative permissions on the remote computer.

PsLoggedOn uses the ````RemoteRegistry service```` to query the information from a remote system. Because of this, it will always be shown in the resource shares logon. Of course, RemoteRegistry Service must be reachable (point of attention : There is a predefined Windows Advanced Firewall rule to allow or not allow RemoteRegistry.)

**Syntax**

```` powershell
psloggedon /? 

PsLoggedon v1.35 - See who's logged on
Copyright (C) 2000-2016 Mark Russinovich
Sysinternals - www.sysinternals.com

Usage: D:\BinairesPourWindows10\Systernals\PsLoggedon.exe [-l] [-x] [\\computername]
    or D:\BinairesPourWindows10\Systernals\PsLoggedon.exe [username]
-l     Show only local logons
-x     Don't show logon times
-nobanner Do not display the startup banner and copyright message.
````
Like the previous tool, psloguedOn can retrieve the users connected locally or remotely

````powershell 
psloggedon \\asus10

PsLoggedon v1.35 - See who's logged on
Copyright (C) 2000-2016 Mark Russinovich
Sysinternals - www.sysinternals.com

Connecting to Registry of \\asus10...
                                                                              
Users logged on locally:
     12/02/2023 07:11:19    	ASUS10\Olivier

No one is logged on via resource shares.
````
But, it can also display the users logged on via resource shares.
In some case, this info could be useful to have. 

````powershell 
$Session = psloggedOn \\$Computer -Nobanner | Select-Object -Skip 3 2>$null
# Trim $Session, replace multi blank spaces by only one
$Session = $Session.trim() -replace '\s+', ' '
# If we split $Session, each part is corresponding respectively to Date (0), Time (1), AccountName (2)
$UserInfo = [PSCustomObject]@{
                              ComputerName = $Computer
                              AccountName  = $Session.Split(' ')[2]
                              LogonTime    = $Session.Split(' ')[0,1] -as [string] -as [datetime]
                              }
$UserInfo
<#
ComputerName AccountName    LogonTime          
------------ -----------    ---------          
ASUS10       ASUS10\Olivier 12/02/2023 07:11:19
#>
````

In this case, the result is displayed as expected cause there is only one user connected to the computer. 
For possible multiple users connected, or multi-computers, a parsing job is necessary. Moreover, users could be connected locally or by a resource shares. No time to do this at this moment. 

## Get-CimInstance

This cmdlet is a buildin cmdlet available with Windows Powershell. The output, as all cmdlets is a object. It's easier to manipulate. 

### Using ClassName Win32_ComputerSystem

````powershell
(Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property UserName).UserName
<#
ASUS10\Olivier
#>
````

For one or more remote computer

````powershell 
$ComputerName = "Asus10", "Asus10"
$ConnectedUsers=@()
$ConnectedUsers = foreach($Computer in $ComputerName)
    {
    Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Computer | Select-Object -Property Name, UserName
    }
$ConnectedUsers
<#
Name   UserName      
----   --------      
ASUS10 ASUS10\Olivier
ASUS10 ASUS10\Olivier
#>
````

The code is simple, easy to understand and easy to type. But by this way, there is no info about idle session.

### Using className Win32_LoggedOnUser

````powershell
Get-CimInstance -ClassName Win32_LoggedOnUser | select *
$Sessions = Get-CimInstance -ClassName Win32_LoggedOnUser | Select-Object -Property Antecedent -Unique
# Split $Sessions
$Sessions | foreach {"{0}\{1}" -f $_.Antecedent.ToString().Split('"')[1],$_.Antecedent.ToString().Split('"')[3]}
````
This code is more complex that using the previous class, to give the same result. 

# Get-Process

````powershell 
Get-Process -IncludeUserName |
    Select-Object UserName,SessionId |
    Where-Object { $_.UserName -ne $null } | # to avoid process being terminated
    Sort-Object UserName -Unique
<#
UserName                   SessionId
--------                   ---------
ASUS10\Olivier                     1
AUTORITE NT\SERVICE LOCAL          0
AUTORITE NT\SERVICE RÉSEAU         0
AUTORITE NT\Système                0
Font Driver Host\UMFD-0            0
Font Driver Host\UMFD-1            1
Window Manager\DWM-1               1
#>
````

too much info

````powershell
Get-Process -IncludeUserName |
    Select-Object UserName,SessionId |
    Where-Object { $_.UserName -ne $null -and $_.UserName.StartsWith("DOMAIN OR COMPUTERNAME") } |
    Sort-Object SessionId -Unique |
    Select-Object -Property UserName
````
in practice

````powershell 
$DomainAccount = "Domain"
$LocalAccount = "ASUS10"
$UsersUsingLocalAccount = (Get-Process -IncludeUserName |
    Select-Object UserName,SessionId |
    Where-Object { $_.UserName -ne $null -and $_.UserName.StartsWith("$LocalAccount") } |
    Sort-Object SessionId -Unique |
    Select-Object -Property UserName).UserName
$UsersUsingDomainAccount = (Get-Process -IncludeUserName | 
    Select-Object UserName,SessionId |
    Where-Object { $_.UserName -ne $null -and $_.UserName.StartsWith("$DomainAccount") } | 
    Sort-Object SessionId -Unique |
    Select-Object -Property UserName).UserName
$AllUsers = $UsersUsingLocalAccount + $UsersUsingDomainAccount
$AllUsers
<#
ASUS10\Olivier
Domain\jdoe
#>
````

[Nota] : If you want to use this cmdlet to remote computers, you must use ````Invoke-Command```` cdmlet, because the cmdlet ````Get-Process```` doesn't have a ````-ComputerName ````parameter. 

````powershell
Invoke-Command -ComputerName "COMPUTERNAME" -ScriptBlock { Get-Process ....}
````

# Get-PSSession

The ````Get-PSSession ````cmdlet is a building powershell cmdlet. As all cmdlet, this return an object. 

````powershell 
Get-PSSession -ComputerName "Server02"

Id Name            ComputerName    State         ConfigurationName     Availability
 -- ----            ------------    -----         -----------------     ------------
  2 Session3        Server02       Disconnected  ITTasks                       Busy
  1 ScheduledJobs   Server02       Opened        Microsoft.PowerShell     Available
  3 Test            Server02       Disconnected  Microsoft.PowerShell          Busy
  ````

As you can see, the cmdlet has a -ComputerName parameter, and the output display Opened and Disconnected Sessions. it's also easy to filter on the ````State````Property.

This cmdlet is based on WinRM use.




# Final Word

Depending what you're looking for, you have the choice for the tool to use. 
- Only Connected users : Get-CimInstance or Get-Process are a good choice. PsLoggedOn.exe too, but this requires that that tool is on the computer (and its path known by Powershell)
- Idle sessions : quser.exe is a good choice. Take care of the culture to avoid any issue. But if the remote computers are accessed only using WINRM (RemoteShell or RemoteManagement), Get-PSSession is the easiest way. 


