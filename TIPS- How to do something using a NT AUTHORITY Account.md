# TIPS - How to do something using a NT AUTHORITY Account

## Introduction

When I design a script, I want the code to be "code-reuse" as much as possible. However, I often have to work on OSs of different languages.

This is why when for example I want to search for the members of a particular group, rather than searching for the group by its name, I search for it by its Weel-known SID.
There is a list on the MS site but also here: https://morgantechspace.com/2013/10/well-known-sids-and-built-in-groups.html

But I am often asked how to do when I want to use an account such as NT AUTHORITY\System, NT AUTHORITY\Local service...
Through the following example, I will describe the approach

 How to retrieve this account ? 
 There is a well-known SID (S-1-5-19) for this account, but it's not like a Domain Account.
Thanks to https://new.reddit.com/user/PinchesTheCrab/ for the solution. 

The solution is to a WMI query (or CIM query) using the ClassName ````WIN32_Service````

The example consists of configuring a service to run with the NT AUTHORITY\Local Service account

````powershell
 Get-CimInstance -ClassName Win32_SystemAccount -Filter 'sid = "S-1-5-19"'
<#
The output looks like the following :

Caption              Domain Name          SID     
-------              ------ ----          ---     
ASUS10\SERVICE LOCAL ASUS10 SERVICE LOCAL S-1-5-19
#>
````

It's not enough to get the Name of the account

Let's use ````Get-CimAssociatedInstance```` cmdlet after the pipeline

````powershell
Get-CimInstance -ClassName Win32_SystemAccount -Filter 'sid = "S-1-5-19"' |
    Get-CimAssociatedInstance -ResultClassName Win32_SID
<#
The output looks like the following :

AccountName          : SERVICE LOCAL
BinaryRepresentation : {1, 1, 0, 0...}
ReferencedDomainName : AUTORITE NT
SID                  : S-1-5-19
SidLength            : 12
PSComputerName       : 
#>
````

The property ````ReferenceDomaineName```` and the property```` AccountName```` give me enough info to build the real Name of the search account, regardless the culture of the OS. 

````powershell
$LocalService = Get-CimInstance -ClassName Win32_SystemAccount -Filter 'sid = "S-1-5-19"' |
    Get-CimAssociatedInstance -ResultClassName Win32_SID

 $AccountName =  "$($localService.ReferencedDomainName)\$($localService.AccountName)"
 $AccountName
 <#
 The output looks like the following :

 AUTORITE NT\SERVICE LOCAL
 #>
````

At this step, it easy to set a service to run with the identified account
let's do this

A good way to change the service account using by the service is to use ````Invoke-CimMethod```` cmdlet.

````powershell 
$ServiceName = 'AJRouter' # here I'm using a ramdom service
$ServiceName |
    Invoke-CimMethod -MethodName Change  -Arguments @{
        StartName       = '{0}\{1}' -f $localService.ReferencedDomainName,$localService.AccountName
        #StartPassword   = $null
        DesktopInteract = $false
    }
# take care to do this in RunAsAdmin else the return value will be 2. 
<#
 The output looks like the following :

ReturnValue PSComputerName
----------- --------------
          0      
#>
````
Let's check the service set

````powershell 
$ServiceName | Get-CimInstance | Select-Object name, DesktopInteract, StartName
````

> [Nota] that if the service is already running you'll probably need to restart it.

