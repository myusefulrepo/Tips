# How to know if the current user is on the the "Admin role" or not ? 

Often we could see some lines like the following : 

````powershell
[System.Security.Principal.WindowsPrincipal]$CurrentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
        if ( $CurrentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) )
        {
            # Admin mode
            # do this, do that
        }
        else
        {
            # User mode
            # do this, do that
        }
````
but what is this ? Here, I'll try to explain a little bit.



`[System.Security.Principal.WindowsIdentity]` : it's .NET class represents a Windows User.

````powershell
[System.Security.Principal.WindowsIdentity]

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     WindowsIdentity                          System.Security.Claims.ClaimsIdentity

````
Let'see the methods.

````powershell
[System.Security.Principal.WindowsIdentity] | Get-Member -MemberType Method -Static

   TypeName : System.Security.Principal.WindowsIdentity

Name            MemberType Definition
----            ---------- ----------
Equals          Method     static bool Equals(System.Object objA, System.Object objB)
GetAnonymous    Method     static System.Security.Principal.WindowsIdentity GetAnonymous()
GetCurrent      Method     static System.Security.Principal.WindowsIdentity GetCurrent(), static System.Security.Principal.WindowsIdentity GetCurrent(bool ifImpersonating), static System.Security.Principal.WindowsIdentity GetCurrent(Sys...
Impersonate     Method     static System.Security.Principal.WindowsImpersonationContext Impersonate(System.IntPtr userToken)
new             Method     System.Security.Principal.WindowsIdentity new(System.IntPtr userToken), System.Security.Principal.WindowsIdentity new(System.IntPtr userToken, string type), System.Security.Principal.WindowsIdentity new(System... 
ReferenceEquals Method     static bool ReferenceEquals(System.Object objA, System.Object objB)
RunImpersonated Method     static void RunImpersonated(Microsoft.Win32.SafeHandles.SafeAccessTokenHandle safeAccessTokenHandle, System.Action action), static T RunImpersonated[T](Microsoft.Win32.SafeHandles.SafeAccessTokenHandle safeAcc...
````

`[System.Security.Principal.WindowsIdentity]::GetCurrent()` : It's a WindowsIdentity Object that represents the current user.


This type of object has a method called `IsInRole()`, that returns a `[boolean]`

````powershell
[System.Security.Principal.WindowsPrincipal]$CurrentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())

$CurrentUser |
    Get-member -MemberType Method -Name IsinRole |
    format-Table -Wrap

   TypeName : System.Security.Principal.WindowsPrincipal

Name     MemberType Definition                                                                                                                                                                 
----     ---------- ----------                                                                                                                                                                 
IsInRole Method     bool IsInRole(string role),
                    bool IsInRole(System.Security.Principal.WindowsBuiltInRole role), 
                    bool IsInRole(int rid), 
                    bool IsInRole(System.Security.Principal.SecurityIdentifier sid), 
                    bool IPrincipal.IsInRole(string role)
````

We'll use the boolean to check if the current user is on the Admin role or not. As you can see, there are several ways to do this using the `IsInRole()` method.

`$CurrentUser.IsInRole("S-1-5-32-544")` is a way. Here I'm using the the Well-known SID for the Administrator role (see [Well-Known SID](https://learn.microsoft.com/en-us/windows/win32/secauthz/well-known-sids)). It's a way but in this case, you must know the Well-known SIDs.

But there is a .NET class called `[System.Security.Principal.WindowsBuiltInRole]` - it's a `[Enum]`  - to do this.

````powershell
[System.Security.Principal.WindowsBuiltInRole] | Get-Member -Static -MemberType Property
   
     TypeName : System.Security.Principal.WindowsBuiltInRole

Name            MemberType Definition                                                                
----            ---------- ----------                                                                
AccountOperator Property   static System.Security.Principal.WindowsBuiltInRole AccountOperator {get;}
Administrator   Property   static System.Security.Principal.WindowsBuiltInRole Administrator {get;}  
BackupOperator  Property   static System.Security.Principal.WindowsBuiltInRole BackupOperator {get;} 
Guest           Property   static System.Security.Principal.WindowsBuiltInRole Guest {get;}          
PowerUser       Property   static System.Security.Principal.WindowsBuiltInRole PowerUser {get;}      
PrintOperator   Property   static System.Security.Principal.WindowsBuiltInRole PrintOperator {get;}  
Replicator      Property   static System.Security.Principal.WindowsBuiltInRole Replicator {get;}     
SystemOperator  Property   static System.Security.Principal.WindowsBuiltInRole SystemOperator {get;} 
User            Property   static System.Security.Principal.WindowsBuiltInRole User {get;}           
````
Often we use this second way perhaps because `$CurrentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)` 
is more clearer and longer than `$CurrentUser.IsInRole("S-1-5-32-544")` but the 2 ways return the same thing : a `[Bool]`.

With A `if` stratement, We'll know is the current user is on the "Administrator Role" or not. Depending on the case, then we'll change the Windows Settings.


````powershell
# powershell run in the normal mode
$CurrentUser.Identity  
AuthenticationType : NTLM
ImpersonationLevel : None
IsAuthenticated    : True
IsGuest            : False
IsSystem           : False
IsAnonymous        : False
Name               : ASUS11\Olivier
Owner              : S-1-5-21-349234613-936635038-205130404-1001
User               : S-1-5-21-349234613-936635038-205130404-1001
Groups             : {S-1-5-21-349234613-936635038-205130404-513, S-1-1-0, S-1-5-21-349234613-936635038-205130404-1002, S-1-5-32-559...}
Token              : 2676
AccessToken        : Microsoft.Win32.SafeHandles.SafeAccessTokenHandle
...

#powershell run in "RunAsAdmin" mode
$CurrentUser.Identity

AuthenticationType : NTLM
ImpersonationLevel : None
IsAuthenticated    : True
IsGuest            : False
IsSystem           : False
IsAnonymous        : False
Name               : ASUS11\Olivier
Owner              : S-1-5-32-544
User               : S-1-5-21-349234613-936635038-205130404-1001
Groups             : {S-1-5-21-349234613-936635038-205130404-513, S-1-1-0, S-1-5-114, S-1-5-21-349234613-936635038-205130404-1002...}
Token              : 3564
AccessToken        : Microsoft.Win32.SafeHandles.SafeAccessTokenHandle
````
Have you seen the difference ? The Property `onwner` has not the same value is the **RunAsAdmin** mode. In the case, the value is the **Well-known SID** of the the administrator account.

let's take a look on the available methods for this object. 

````powershell
$currentUser.Identity.Owner | Get-Member -MemberType Method   


   TypeName : System.Security.Principal.SecurityIdentifier

Name              MemberType Definition
----              ---------- ----------
CompareTo         Method     int CompareTo(System.Security.Principal.SecurityIdentifier sid), int IComparable[SecurityIdentifier].CompareTo(System.Security.Principal.SecurityIdentifier other)
Equals            Method     bool Equals(System.Object o), bool Equals(System.Security.Principal.SecurityIdentifier sid)
GetBinaryForm     Method     void GetBinaryForm(byte[] binaryForm, int offset)
GetHashCode       Method     int GetHashCode()
GetType           Method     type GetType()
IsAccountSid      Method     bool IsAccountSid()
IsEqualDomainSid  Method     bool IsEqualDomainSid(System.Security.Principal.SecurityIdentifier sid)
IsValidTargetType Method     bool IsValidTargetType(type targetType)
IsWellKnown       Method     bool IsWellKnown(System.Security.Principal.WellKnownSidType type)
ToString          Method     string ToString()
Translate         Method     System.Security.Principal.IdentityReference Translate(type targetType)
````


`$CurrentUser.Identity.Owner.IsAccountSid()`, this return a bool. We could also use something like the following to kwnow if the current user is on the **RunAsAdmin** mode or not. 

````powershell
[System.Security.Principal.WindowsPrincipal]$CurrentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not ($CurrentUser.Identity.Owner.IsAccountSid() ) )
    {
    "Powershell run in a RunAsAdminCode"
    }
else
    {
     "Powershell doesn't run in a RunAsAdminCode"
    }
````

## In action : change the Host windows Title

````powershell
[System.Security.Principal.WindowsPrincipal]$CurrentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
        if ( $CurrentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) )
        {
            # Admin mode
            $User = '(RunAsAdmin) - ' + $CurrentUser.Identities.Name
        }
        else
        {
            # User mode
            $User = '(NotRunAsAdmin) - ' + $CurrentUser.Identities.Name
        }
        (Get-Host).UI.RawUI.WindowTitle = $User + ' on ' + [System.Net.Dns]::GetHostName() + ' (PS version : ' + (Get-Host).Version + ')'
````
or

````powershell
[System.Security.Principal.WindowsPrincipal]$CurrentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not ($CurrentUser.Identity.Owner.IsAccountSid() ) )
        {
            # Admin mode
            $User = '(RunAsAdmin) - ' + $CurrentUser.Identities.Name
        }
        else
        {
            # User mode
            $User = '(NotRunAsAdmin) - ' + $CurrentUser.Identities.Name
        }
        (Get-Host).UI.RawUI.WindowTitle = $User + ' on ' + [System.Net.Dns]::GetHostName() + ' (PS version : ' + (Get-Host).Version + ')'
````