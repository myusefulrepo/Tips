# Some useful accelerators, .NET class and their methods for daily tasks
- [Some useful accelerators, .NET class and their methods for daily tasks](#some-useful-accelerators-net-class-and-their-methods-for-daily-tasks)
  - [Preface](#preface)
  - [The Tips](#the-tips)
    - [1. Using `[Guid]` accelerator : Generate a new GUID](#1-using-guid-accelerator--generate-a-new-guid)
    - [2. Using the `LeapYear` method from `[DateTime]` type : Determinate if a year is a leap year](#2-using-the-leapyear-method-from-datetime-type--determinate-if-a-year-is-a-leap-year)
    - [3. Using the `UtcNow Method` from `[DateTime]` type : Get current time in UTC (universal time coordinated)](#3-using-the-utcnow-method-from-datetime-type--get-current-time-in-utc-universal-time-coordinated)
    - [4. Using the `FromFileTime` method from `[DateTime]` type : Gathering a date in \[DateTime\] format](#4-using-the-fromfiletime-method-from-datetime-type--gathering-a-date-in-datetime-format)
    - [5. Using the `DayInMonth` Method from `[DateTime]` Type to get Number of days in month](#5-using-the-dayinmonth-method-from-datetime-type-to-get-number-of-days-in-month)
    - [6. Using the `[Version]` accelerator : Converting type from a Application version](#6-using-the-version-accelerator--converting-type-from-a-application-version)
    - [7. Using the `[System.Net.Mail.MailAddress]` .NET Class : validating a mail address or split a email address](#7-using-the-systemnetmailmailaddress-net-class--validating-a-mail-address-or-split-a-email-address)
    - [8. Display a Date in another Culture using `[System.Threading.Thread]` .NET Class and its method `CurrentThread`](#8-display-a-date-in-another-culture-using-systemthreadingthread-net-class-and-its-method-currentthread)
    - [9. Using the `[System.DayOfWeek]` .NET class : Get the Day Names or the Month Name in your Current Culture](#9-using-the-systemdayofweek-net-class--get-the-day-names-or-the-month-name-in-your-current-culture)
    - [10. using the `[System.TimeZoneInfo]` .NET Class to get Time Zone](#10-using-the-systemtimezoneinfo-net-class-to-get-time-zone)
    - [11. Using the `[Char]` and `[String]` types to convert a Number to a character](#11-using-the-char-and-string-types-to-convert-a-number-to-a-character)
    - [12. Using `[System.net.Dns]` .NET Class to Resolve HostName](#12-using-systemnetdns-net-class-to-resolve-hostname)
    - [13. Using `[WMIClass]` Type to query WMI](#13-using-wmiclass-type-to-query-wmi)
    - [14. Test if Admin Privileges using `[Security.Principal.WindowsBuiltInRole]` and `[Security.Principal.WindowsIdentity]` .NET Class](#14-test-if-admin-privileges-using-securityprincipalwindowsbuiltinrole-and-securityprincipalwindowsidentity-net-class)
    - [15. Finding System Folders using the `[Environment+SpecialFolder]` accelerator](#15-finding-system-folders-using-the-environmentspecialfolder-accelerator)
    - [16. Validate an IPAddress using `[IPAddress]` accelerator or `[System.Net.IPAddress]` .NET Class](#16-validate-an-ipaddress-using-ipaddress-accelerator-or-systemnetipaddress-net-class)
    - [17. Get a list of all available accelerators](#17-get-a-list-of-all-available-accelerators)
  - [final Word](#final-word)


## Preface

In this short post, I'm sharing some accelerators or .NET class with their applicabler methods useful in daily powershell scripting tasks.

## The Tips

### 1. Using `[Guid]` accelerator : Generate a new GUID

````Powershell
# Using .NET class
[System.Guid]::NewGuid().Guid
# using accelerator
[Guid]::newGuid().Guid
````

sample
````output
[Guid]::newGuid().Guid
e08ba766-54d6-4f38-8d62-2b8f70a77b74
````

### 2. Using the `LeapYear` method from `[DateTime]` type : Determinate if a year is a leap year
Simple, you say. You could build a function that determinate that. I'm sure of that, but there is a simplest way. Indeed, there is a static method of `[systemDateTime]` class or `[ateTime]` accelarator.

Let's take a look ! 

````Powershell
[DateTime] | Get-Member -Static

   TypeName : System.DateTime

Name            MemberType Definition
----            ---------- ----------
Compare         Method     static int Compare(datetime t1, datetime t2)
DaysInMonth     Method     static int DaysInMonth(int year, int month)
Equals          Method     static bool Equals(datetime t1, datetime t2), static bool Equals(System.Object objA, System.Object objB)
FromBinary      Method     static datetime FromBinary(long dateData)
FromFileTime    Method     static datetime FromFileTime(long fileTime)
FromFileTimeUtc Method     static datetime FromFileTimeUtc(long fileTime)
FromOADate      Method     static datetime FromOADate(double d)
IsLeapYear      Method     static bool IsLeapYear(int year)
new             Method     datetime new(long ticks), datetime new(long ticks, System.DateTimeKind kind), datetime new(int year, int month, int day), datetime new(int year, int month, int day, System.Globalization.Calendar calendar),... 
Parse           Method     static datetime Parse(string s), static datetime Parse(string s, System.IFormatProvider provider), static datetime Parse(string s, System.IFormatProvider provider, System.Globalization.DateTimeStyles styles)  
ParseExact      Method     static datetime ParseExact(string s, string format, System.IFormatProvider provider), static datetime ParseExact(string s, string format, System.IFormatProvider provider, System.Globalization.DateTimeStyle... 
ReferenceEquals Method     static bool ReferenceEquals(System.Object objA, System.Object objB)
SpecifyKind     Method     static datetime SpecifyKind(datetime value, System.DateTimeKind kind)
TryParse        Method     static bool TryParse(string s, [ref] datetime result), static bool TryParse(string s, System.IFormatProvider provider, System.Globalization.DateTimeStyles styles, [ref] datetime result)
TryParseExact   Method     static bool TryParseExact(string s, string format, System.IFormatProvider provider, System.Globalization.DateTimeStyles style, [ref] datetime result), static bool TryParseExact(string s, string[] formats, ... 
MaxValue        Property   static datetime MaxValue {get;}
MinValue        Property   static datetime MinValue {get;}
Now             Property   datetime Now {get;}
Today           Property   datetime Today {get;}
UtcNow          Property   datetime UtcNow {get;}
````

Have you seen the method called `IsLeapYear()` ? 

````powershell
[DateTime]::IsLeapYear("2023")
False
````

You could also note some other interresting methods :

### 3. Using the `UtcNow Method` from `[DateTime]` type : Get current time in UTC (universal time coordinated)

````powershell
[DateTime]::UtcNow
mardi 7 novembre 2023 10:51:23
````

### 4. Using the `FromFileTime` method from `[DateTime]` type : Gathering a date in [DateTime] format

````powershell
Get-ADUser -Properties Name, Manager, LastLogon |
    Select-Object -Property Name, manager, LastLogon
````
LastLogon Property is not display as a datebecause it's a `tick` like "129948127853609000" but we could convert it to a proper `[DateTime]` format using its method :  `FromFileTime()`.

````powershell
Get-ADUser -Properties Name, Manager, LastLogon |
    Select-Object -Property Name, manager, 
           @{label = 'lastLogon' ; Expression = {[DateTime]::FromFileTime($_.LastLogon}) }
Monday, October 15, 2012 3:13:05 PM
````

Of course we could also change the output fotmat using different ways as using the `ToString()` method
````powershell
[datetime]::FromFileTime(129948127853609000).ToString('d MMMM')
15 October
````
>[Funny Tip] : Did you note the [MinValue] and the [MaxValue] method of [DateTime] accelerator ? 
> ````powershell
>[DateTime]::MaxValue
>vendredi 31 décembre 9999 23:59:59
>
>
>[DateTime]::MinValue
>lundi 1 janvier 0001 00:00:00
>````
> Do not plan any action after December 31, 9999 ! :grin:

### 5. Using the `DayInMonth` Method from `[DateTime]` Type to get Number of days in month
If you need to determine the days in a given month, you can use the static `DaysInMonth()` method provided by the DateTime type.

````Powershell
# The syntax is DaysInMonth(int year, int month)
[DateTime]::DaysInMonth(2023, 2)
[DateTime]::DaysInMonth(2023, 10)
````


### 6. Using the `[Version]` accelerator : Converting type from a Application version
Often a version of an app is like '3.2.12.9'. Not easy, with this format to compare it to another. But using the .NET class `[System.Version]` or the `[Version]` accelerator, it's easy

````Powershell
[version]'3.2.12.9'

Major  Minor  Build  Revision
-----  -----  -----  --------
3      2      12     9

[version]'3.2.12.9' -gt 3.1.5.2
````

Example of use
````powershell
3.2.12.9 -gt 3.1.5.2
False
[version]'3.2.12.9' -gt 3.1.5.2
True
````

Another sample : sort IP Addresses

````Powershell
$iplist = ‘1.10.10.1’, ‘100.10.10.3’, ‘2.10.10.230’
$iplist | Sort-Object
1.10.10.1
100.10.10.3
2.10.10.230
# the order is not the expected order

$iplist | Sort-Object -Property { [System.Version]$_ }
1.10.10.1
2.10.10.230
100.10.10.3
# now it's fine
````

### 7. Using the `[System.Net.Mail.MailAddress]` .NET Class : validating a mail address or split a email address
Using a Regex to validate or invalidate an email address ? 

````powershell
$Address = "john.doe@contoso.com"
[System.Net.mail.MailAddress]$Address

DisplayName User     Host        Address
----------- ----     ----        -------
            john.doe contoso.com john.doe@contoso.com

([System.Net.mail.MailAddress]$Address).Host
contoso.com
([System.Net.mail.MailAddress]$Address).User
john.doe
````

### 8. Display a Date in another Culture using `[System.Threading.Thread]` .NET Class and its method `CurrentThread`

````powershell
$Culture = [System.Globalization.CultureInfo]'de-DE'
[12:39:32 م] C:/temp> [System.Threading.Thread]::CurrentThread.CurrentCulture = $Culture ; Get-Date
Dienstag, 7. November 2023 12:39:37
````
You should note that the console character set is not able to display certain characters. You may want to run that command inside the PowerShell ISE or another Unicode-enabled environment.

### 9. Using the `[System.DayOfWeek]` .NET class : Get the Day Names or the Month Name in your Current Culture
The `[System.DayOfWeek]` .NET Class is an `[enum]`.
````Powershell
[System.DayOfWeek]

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     DayOfWeek                                System.Enum
````

To get a list of day names, you could use the following :
````powershell
[System.Enum]::GetNames([System.DayOfWeek])
Sunday
Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
````
However, this returns **a culture-neutral** list which is not returning the day in a localized (regional) form. To get the localized names, use the following instead :

````Powershell
0..6 | ForEach-Object { [Globalization.DatetimeFormatInfo]::CurrentInfo.DayNames[$_] }
dimanche
lundi
mardi
mercredi
jeudi
vendredi
samedi
# You could also use 
[Globalization.DatetimeFormatInfo]::CurrentInfo.DayNames[0,1,2,3,4,5,6]
# To get month names, try this :
0..11 | ForEach-Object { [Globalization.DatetimeFormatInfo]::CurrentInfo.MonthNames[$_]
janvier
février
mars
avril
mai
juin
juillet
août
septembre
octobre
novembre
décembre
# You could also use
[Globalization.DatetimeFormatInfo]::CurrentInfo.MonthNames[0,1,2,3,4,5,6,7,8,9,10,11]
````

### 10. using the `[System.TimeZoneInfo]` .NET Class to get Time Zone

````Powershell
[System.TimeZoneInfo]::Local

Id                         : Romance Standard Time
DisplayName                : (UTC+01:00) Bruxelles, Copenhague, Madrid, Paris
StandardName               : Paris, Madrid
DaylightName               : Paris, Madrid (heure d’été)
BaseUtcOffset              : 01:00:00
SupportsDaylightSavingTime : True

([System.TimeZoneInfo]::Local).StandardName 
Paris, Madrid
````

The following returns all available Time Zones. 

````Powershell
[System.TimeZoneInfo]::GetSystemTimeZones()

Id                         : Dateline Standard Time
DisplayName                : (UTC-12:00) Ligne de date internationale (Ouest)
StandardName               : Changement de date
DaylightName               : Changemt de date (heure d’été)
BaseUtcOffset              : -12:00:00
SupportsDaylightSavingTime : False

Id                         : UTC-11
DisplayName                : (UTC-11:00) Temps universel coordonné-11
StandardName               : UTC-11
DaylightName               : UTC-11
BaseUtcOffset              : -11:00:00
SupportsDaylightSavingTime : False

Id                         : Hawaiian Standard Time
DisplayName                : (UTC-10:00) Hawaii
StandardName               : Hawaii
DaylightName               : Hawaii (heure d’été)
BaseUtcOffset              : -10:00:00
SupportsDaylightSavingTime : False

Id                         : Aleutian Standard Time
DisplayName                : (UTC-10:00) Îles Aléoutiennes
StandardName               : Heure standard Aléoutiennes
DaylightName               : Heure d’été Aléoutiennes
BaseUtcOffset              : -10:00:00
SupportsDaylightSavingTime : True

Id                         : Marquesas Standard Time
DisplayName                : (UTC-09:30) Îles Marquises
StandardName               : Heure standard Marquises
DaylightName               : Heure d’été Marquises
BaseUtcOffset              : -09:30:00
SupportsDaylightSavingTime : False

Id                         : Alaskan Standard Time
DisplayName                : (UTC-09:00) Alaska
StandardName               : Alaska
DaylightName               : Alaska (heure d’été)
BaseUtcOffset              : -09:00:00
SupportsDaylightSavingTime : True

Id                         : UTC-09
DisplayName                : (UTC-09:00) Temps universel coordonné-09
StandardName               : UTC-09
DaylightName               : UTC-09
BaseUtcOffset              : -09:00:00
SupportsDaylightSavingTime : False
...
````

### 11. Using the `[Char]` and `[String]` types to convert a Number to a character
Characters could be represented by a number. eg.
````powershell
[Char]65
A
````

````Powershell
[string][char[]](65..90)
A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
#Or
[char[]](65..90) -join ','
A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
````

Use case : 
- Validate an input string
- Encrypt a String. eg. Transform each character to its numeric form. Add a defined number to it. Transform the number back to a character.


### 12. Using `[System.net.Dns]` .NET Class to Resolve HostName

````powershell
[System.Net.Dns]::GetHostByName("www.google.com")

HostName       Aliases AddressList
--------       ------- -----------
www.google.com {}      {142.250.179.100}

([System.Net.Dns]::GetHostByName("www.google.com")).AddressList
Address            : 1689516686
AddressFamily      : InterNetwork
ScopeId            :
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv4MappedToIPv6 : False
IPAddressToString  : 142.250.179.100


Resolve-DnsName -Name  "www.google.com"

Name                                           Type   TTL   Section    IPAddress
----                                           ----   ---   -------    ---------
www.google.com                                 AAAA   254   Answer     2a00:1450:4007:818::2004
www.google.com                                 A      261   Answer     142.250.179.100
````
>[**Attention Point**] : Have you note that the `Resolve-DnsName` cmdlet returns IPv4 AND IPv6 addresses, while `[System.Net.DNS]` .Net class with its method `GetHostByName` returns only IPv4 address ?

### 13. Using `[WMIClass]` Type to query WMI

````Powershell
[WMIClass]'Win32_NetworkAdapterConfiguration'
````

You could use `[WMIClass]` to query WMI. Why will you tell me then that we have the Get-CimInstance cmdlet ? 
The answer is simple : **Performance** ! 

Not convinced ?
````Powershell
Measure-MyScript -Name "WMI class" -Unit ms -Repeat 100 -ScriptBlock {
[WMIClass]'Win32_NetworkAdapterConfiguration'
}
Measure-MyScript -Name "CimInstance" -Unit ms -Repeat 100 -ScriptBlock {
Get-CimInstance -ClassName 'Win32_NetworkAdapterConfiguration'
}
name        Avg                  Min                  Max                 
----        ---                  ---                  ---                 
WMI class   2,3819 Milliseconds  1,882 Milliseconds   22,9218 Milliseconds
CimInstance 21,7792 Milliseconds 20,4189 Milliseconds 33,7561 Milliseconds
````

 x10 factor !

 >[Nota] : I'm using a small function called Measure-MyScript (available [here](https://github.com/christophekumor/Measure-MyScript)).


### 14. Test if Admin Privileges using `[Security.Principal.WindowsBuiltInRole]` and `[Security.Principal.WindowsIdentity]` .NET Class

````Powershell
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal $Identity
$Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
$False
````

And now as a simple function
````Powershell
function Test-Admin {
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal $Identity
$Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
Test-Admin
False
````
**Explanations :**
We use the `[Security.Principal.WindowsIdentity]` .NET Class ant its method `GetCurrent` to get the current identity.

````Powershell 
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Identity
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
Token              : 1204
AccessToken        : Microsoft.Win32.SafeHandles.SafeAccessTokenHandle
UserClaims         : {http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name: ASUS11\Olivier, http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid: S-1-5-21-349234613-936635038-205130404-1001,
                     http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid: S-1-5-21-349234613-936635038-205130404-513, http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid:
                     S-1-5-21-349234613-936635038-205130404-513...}
DeviceClaims       : {}
Claims             : {http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name: ASUS11\Olivier, http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid: S-1-5-21-349234613-936635038-205130404-1001,
                     http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid: S-1-5-21-349234613-936635038-205130404-513, http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid:
                     S-1-5-21-349234613-936635038-205130404-513...}
Actor              :
BootstrapContext   :
Label              :
NameClaimType      : http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name
RoleClaimType      : http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid
````

after that we use the previous Object to define a `WindowsPrincipal` (formally `[security.Principal.WindowsPrincipal]`)
````Powershell
$principal = New-Object Security.Principal.WindowsPrincipal $identity
# We could alos use 
[security.Principal.WindowsPrincipal]$Principal = $Identity
````
A `[security.Principal.WindowsPrincipal]` has a method called `IsInrole`.
````powershell
($Principal |Get-Member -Name IsInRole).Definition
bool IsInRole(string role), bool IsInRole(System.Security.Principal.WindowsBuiltInRole role), bool IsInRole(int rid), bool IsInRole(System.Security.Principal.SecurityIdentifier sid), bool IPrincipal.IsInRole(string role)
````
As you could see, the parameter for  `IsInrole` is a `[System.Security.Principal.WindowsBuiltInRole]` role.
This is an enum 
````powershell
[System.Security.Principal.WindowsBuiltInRole]

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     WindowsBuiltInRole                       System.Enum

[System.Security.Principal.WindowsBuiltInRole].GetEnumNames()
Administrator
User
Guest
PowerUser
AccountOperator
SystemOperator
PrintOperator
BackupOperator
Replicator
````
Then we use `[Security.Principal.WindowsBuiltInRole]::Administrator` and this return a boolean
````powershell
$Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$False
````

### 15. Finding System Folders using the `[Environment+SpecialFolder]` accelerator

As you know, The Windows Operating System has many special folders like Desktop, Programs, MyDocuments,
Personal, Favorites, Startup, Recent, SendTo, StartMenu, MyMusic, MyVideos, ...
The Display Name of these folders is in the current culture, but the real name is different (always in english)
To get a list a these special folders, we are using the `[Environment+SpecialFolder]` accelerator.

````Powershell
$SpecialFoldersNames = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder]) | Sort-Object

$SpecialFoldersNames
AdminTools
ApplicationData
CDBurning
CommonAdminTools
CommonApplicationData
CommonDesktopDirectory
CommonDocuments
CommonMusic
CommonOemLinks
CommonPictures
CommonProgramFiles
CommonProgramFilesX86
CommonPrograms
CommonStartMenu
CommonStartup
CommonTemplates
CommonVideos
Cookies
Desktop
DesktopDirectory
Favorites
Fonts
History
InternetCache
LocalApplicationData
LocalizedResources
MyComputer
MyDocuments
MyMusic
MyPictures
MyVideos
NetworkShortcuts
Personal
PrinterShortcuts
ProgramFiles
ProgramFilesX86
Programs
Recent
Resources
SendTo
StartMenu
Startup
System
SystemX86
Templates
UserProfile
Windows
````
Now we have all these special folders. It's ok but what are the real paths and names for these special folders ? Let's fo it

````Powershell
$SpecialFoldersNames = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder]) | Sort-Object

$Special_Folders =[System.Collections.Generic.List[PSObject]]::new() #initialization
ForEach ($Name in $SpecialFoldersNames)
    {
    If (([Environment]::GetFolderPath("$Name")) -ne "") 
        {
        $Empty = $false
        $Path = [Environment]::GetFolderPath("$Name")
        # Building a PSCustomObject
        $obj_folder = [PSCustomObject]@{
                            'Name'              = $Name
                            'Path'              = $Path
                            #'Special Folder'    = [string]'[' + 'Environment]::GetFolderPath(' + '"' + $name + '")'
                             }
        $Special_Folders.add($obj_folder)
        }
    Else
        {
        $Empty = $true
        $Omit = $true
        $Continue = $true
        }
    } #end ForEach


# Display the list of Windows PowerShell special folder commands and their values (paths) in console
$Special_Folders
````
and the output is : 
````output
Name                   Path
----                   ----
AdminTools             C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools
ApplicationData        C:\Users\Olivier\AppData\Roaming
CDBurning              C:\Users\Olivier\AppData\Local\Microsoft\Windows\Burn\Burn
CommonAdminTools       C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools
CommonApplicationData  C:\ProgramData
CommonDesktopDirectory C:\Users\Public\Desktop
CommonDocuments        C:\Users\Public\Documents
CommonMusic            C:\Users\Public\Music
CommonPictures         C:\Users\Public\Pictures
CommonProgramFiles     C:\Program Files\Common Files
CommonProgramFilesX86  C:\Program Files (x86)\Common Files
CommonPrograms         C:\ProgramData\Microsoft\Windows\Start Menu\Programs
CommonStartMenu        C:\ProgramData\Microsoft\Windows\Start Menu
CommonStartup          C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
CommonTemplates        C:\ProgramData\Microsoft\Windows\Templates
CommonVideos           C:\Users\Public\Videos
Cookies                C:\Users\Olivier\AppData\Local\Microsoft\Windows\INetCookies
Desktop                C:\Users\Olivier\OneDrive\Bureau
DesktopDirectory       C:\Users\Olivier\OneDrive\Bureau
Favorites              C:\Users\Olivier\Favorites
Fonts                  C:\WINDOWS\Fonts
History                C:\Users\Olivier\AppData\Local\Microsoft\Windows\History
InternetCache          C:\Users\Olivier\AppData\Local\Microsoft\Windows\INetCache
LocalApplicationData   C:\Users\Olivier\AppData\Local
MyDocuments            C:\Users\Olivier\OneDrive\Documents
MyMusic                C:\Users\Olivier\OneDrive\Musique
MyPictures             C:\Users\Olivier\OneDrive\Images
MyVideos               C:\Users\Olivier\OneDrive\Vidéos
NetworkShortcuts       C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Network Shortcuts
Personal               C:\Users\Olivier\OneDrive\Documents
PrinterShortcuts       C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Printer Shortcuts
ProgramFiles           C:\Program Files
ProgramFilesX86        C:\Program Files (x86)
Programs               C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
Recent                 C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Recent
Resources              C:\WINDOWS\resources
SendTo                 C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\SendTo
StartMenu              C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu
Startup                C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
System                 C:\WINDOWS\system32
SystemX86              C:\WINDOWS\SysWOW64
Templates              C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Templates
UserProfile            C:\Users\Olivier
Windows                C:\WINDOWS
````

>[Nota] the ````If (([Environment]::GetFolderPath("$Name")) -ne "")```` test is to avoid blank lines.

And if you uncomment in the previous code, you'll have for each special folder the command to path in powershell to get it individually.

````output
Name                   Path                                                                                        Special Folder
----                   ----                                                                                        --------------
AdminTools             C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools [Environment]::GetFolderPath("AdminTools")
ApplicationData        C:\Users\Olivier\AppData\Roaming                                                            [Environment]::GetFolderPath("ApplicationData")
CDBurning              C:\Users\Olivier\AppData\Local\Microsoft\Windows\Burn\Burn                                  [Environment]::GetFolderPath("CDBurning")
CommonAdminTools       C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools                   [Environment]::GetFolderPath("CommonAdminTools")
CommonApplicationData  C:\ProgramData                                                                              [Environment]::GetFolderPath("CommonApplicationData")
CommonDesktopDirectory C:\Users\Public\Desktop                                                                     [Environment]::GetFolderPath("CommonDesktopDirectory")
CommonDocuments        C:\Users\Public\Documents                                                                   [Environment]::GetFolderPath("CommonDocuments")
CommonMusic            C:\Users\Public\Music                                                                       [Environment]::GetFolderPath("CommonMusic")
CommonPictures         C:\Users\Public\Pictures                                                                    [Environment]::GetFolderPath("CommonPictures")
CommonProgramFiles     C:\Program Files\Common Files                                                               [Environment]::GetFolderPath("CommonProgramFiles")
CommonProgramFilesX86  C:\Program Files (x86)\Common Files                                                         [Environment]::GetFolderPath("CommonProgramFilesX86")
CommonPrograms         C:\ProgramData\Microsoft\Windows\Start Menu\Programs                                        [Environment]::GetFolderPath("CommonPrograms")
CommonStartMenu        C:\ProgramData\Microsoft\Windows\Start Menu                                                 [Environment]::GetFolderPath("CommonStartMenu")
CommonStartup          C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup                                [Environment]::GetFolderPath("CommonStartup")
CommonTemplates        C:\ProgramData\Microsoft\Windows\Templates                                                  [Environment]::GetFolderPath("CommonTemplates")
CommonVideos           C:\Users\Public\Videos                                                                      [Environment]::GetFolderPath("CommonVideos")
Cookies                C:\Users\Olivier\AppData\Local\Microsoft\Windows\INetCookies                                [Environment]::GetFolderPath("Cookies")
Desktop                C:\Users\Olivier\OneDrive\Bureau                                                            [Environment]::GetFolderPath("Desktop")
DesktopDirectory       C:\Users\Olivier\OneDrive\Bureau                                                            [Environment]::GetFolderPath("DesktopDirectory")
Favorites              C:\Users\Olivier\Favorites                                                                  [Environment]::GetFolderPath("Favorites")
Fonts                  C:\WINDOWS\Fonts                                                                            [Environment]::GetFolderPath("Fonts")
History                C:\Users\Olivier\AppData\Local\Microsoft\Windows\History                                    [Environment]::GetFolderPath("History")
InternetCache          C:\Users\Olivier\AppData\Local\Microsoft\Windows\INetCache                                  [Environment]::GetFolderPath("InternetCache")
LocalApplicationData   C:\Users\Olivier\AppData\Local                                                              [Environment]::GetFolderPath("LocalApplicationData")
MyDocuments            C:\Users\Olivier\OneDrive\Documents                                                         [Environment]::GetFolderPath("MyDocuments")
MyMusic                C:\Users\Olivier\OneDrive\Musique                                                           [Environment]::GetFolderPath("MyMusic")
MyPictures             C:\Users\Olivier\OneDrive\Images                                                            [Environment]::GetFolderPath("MyPictures")
MyVideos               C:\Users\Olivier\OneDrive\Vidéos                                                            [Environment]::GetFolderPath("MyVideos")
NetworkShortcuts       C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Network Shortcuts                        [Environment]::GetFolderPath("NetworkShortcuts")
Personal               C:\Users\Olivier\OneDrive\Documents                                                         [Environment]::GetFolderPath("Personal")
PrinterShortcuts       C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Printer Shortcuts                        [Environment]::GetFolderPath("PrinterShortcuts")
ProgramFiles           C:\Program Files                                                                            [Environment]::GetFolderPath("ProgramFiles")
ProgramFilesX86        C:\Program Files (x86)                                                                      [Environment]::GetFolderPath("ProgramFilesX86")
Programs               C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu\Programs                      [Environment]::GetFolderPath("Programs")
Recent                 C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Recent                                   [Environment]::GetFolderPath("Recent")
Resources              C:\WINDOWS\resources                                                                        [Environment]::GetFolderPath("Resources")
SendTo                 C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\SendTo                                   [Environment]::GetFolderPath("SendTo")
StartMenu              C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu                               [Environment]::GetFolderPath("StartMenu")
Startup                C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup              [Environment]::GetFolderPath("Startup")
System                 C:\WINDOWS\system32                                                                         [Environment]::GetFolderPath("System")
SystemX86              C:\WINDOWS\SysWOW64                                                                         [Environment]::GetFolderPath("SystemX86")
Templates              C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\Templates                                [Environment]::GetFolderPath("Templates")
UserProfile            C:\Users\Olivier                                                                            [Environment]::GetFolderPath("UserProfile")
Windows                C:\WINDOWS                                                                                  [Environment]::GetFolderPath("Windows")
````

### 16. Validate an IPAddress using `[IPAddress]` accelerator or `[System.Net.IPAddress]` .NET Class
The `[IPAddress]` powershell accelerator is formally the `[System.Net.IPAddress]` .NET Class.

Some people use a Regex to validate an IP (v4 or V6). The Regex is not always easy to develop. This is not always necessary to make this effort, the [IPAddress] accelerator can help you go faster.
eg.

````Powershell
# in commandline
$string ="192.168.0.20"
$string -match [ipaddress]$string
True

$string ="2345:425:2ca1::567:5673:23b5"
$string -match [ipaddress]$string
True

# in a advanced function
        [ValidateScript({
            If ($_ -match [IPAddress]$_) 
                {
                $true
                }
            else
                {
                Throw "Cannot convert value `"$_`" to type `"System.Net.IPAddress`". Error: `"An invalid IP address was specified.`""
                }
            })]
        [String]$IpAddress

# or a shorter version
$_ -as [IPAddress] -as [bool]

# with a IPv4 Address
"192.168.0.20" -as [IPAddress]

Address            : 335587520
AddressFamily      : InterNetwork
ScopeId            :
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv4MappedToIPv6 : False
IPAddressToString  : 192.168.0.20

# With a IPv6 address
"2345:0425:2CA1:0000:0000:0567:5673:23b5" -as [IPAddress]

Address            :
AddressFamily      : InterNetworkV6
ScopeId            : 0
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv4MappedToIPv6 : False
IPAddressToString  : 2345:425:2ca1::567:5673:23b5
````
Have you seen the difference between IPv4 and IPv6 ? The value of the property `AddressFamilly` is not the same.
Then, we could distinguish them easily. 

````Powershell
$string ="192.168.0.20"
$string -match [ipaddress]$string -and ([ipaddress]$string).AddressFamily -eq "InterNetwork"
True

$string ="2345:425:2ca1::567:5673:23b5"
$string -match [ipaddress]$string -and ([ipaddress]$string).AddressFamily -eq "InterNetworkv6"
True
````

Another way is using the `TryParse()` method that can also validate a IP Address, like in the following code sample

````Powershell
[ipaddress]::TryParse
OverloadDefinitions
-------------------
static bool TryParse(string ipString, [ref] ipaddress address)  

# with a Valid IPAddress
[ipaddress]::TryParse("192.168.1.145",[ref][ipaddress]::Loopback)
True
# with an Invalid IPAddress
[ipaddress]::TryParse("192.168.1.300",[ref][ipaddress]::Loopback)
False
````

>[**Attention Point**] : There is a limitation with `[IPAddress]::TryParse()` method, that is it verifies if a string could be converted to an IP address. So, if you pass a string “10”, it considered as “0.0.0.10” and $true would be returned.

````powershell
[ipaddress]::TryParse("10",[ref][ipaddress]::Loopback)
True
````

### 17. Get a list of all available accelerators

````powershell
$acceleratorsType = [PSObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Get
$acceleratorsType
Key                          Value
---                          -----
Alias                        System.Management.Automation.AliasAttribute
AllowEmptyCollection         System.Management.Automation.AllowEmptyCollectionAttribute
AllowEmptyString             System.Management.Automation.AllowEmptyStringAttribute
AllowNull                    System.Management.Automation.AllowNullAttribute
ArgumentCompleter            System.Management.Automation.ArgumentCompleterAttribute
array                        System.Array
bool                         System.Boolean
byte                         System.Byte
char                         System.Char
CmdletBinding                System.Management.Automation.CmdletBindingAttribute
datetime                     System.DateTime
decimal                      System.Decimal
double                       System.Double
DscResource                  System.Management.Automation.DscResourceAttribute
float                        System.Single
single                       System.Single
guid                         System.Guid
hashtable                    System.Collections.Hashtable
int                          System.Int32
int32                        System.Int32
int16                        System.Int16
long                         System.Int64
int64                        System.Int64
ciminstance                  Microsoft.Management.Infrastructure.CimInstance
cimclass                     Microsoft.Management.Infrastructure.CimClass
cimtype                      Microsoft.Management.Infrastructure.CimType
cimconverter                 Microsoft.Management.Infrastructure.CimConverter
IPEndpoint                   System.Net.IPEndPoint
NullString                   System.Management.Automation.Language.NullString
OutputType                   System.Management.Automation.OutputTypeAttribute
ObjectSecurity               System.Security.AccessControl.ObjectSecurity
Parameter                    System.Management.Automation.ParameterAttribute
PhysicalAddress              System.Net.NetworkInformation.PhysicalAddress
pscredential                 System.Management.Automation.PSCredential
PSDefaultValue               System.Management.Automation.PSDefaultValueAttribute
pslistmodifier               System.Management.Automation.PSListModifier
psobject                     System.Management.Automation.PSObject
pscustomobject               System.Management.Automation.PSObject
psprimitivedictionary        System.Management.Automation.PSPrimitiveDictionary
ref                          System.Management.Automation.PSReference
PSTypeNameAttribute          System.Management.Automation.PSTypeNameAttribute
regex                        System.Text.RegularExpressions.Regex
DscProperty                  System.Management.Automation.DscPropertyAttribute
sbyte                        System.SByte
string                       System.String
SupportsWildcards            System.Management.Automation.SupportsWildcardsAttribute
switch                       System.Management.Automation.SwitchParameter
cultureinfo                  System.Globalization.CultureInfo
bigint                       System.Numerics.BigInteger
securestring                 System.Security.SecureString
timespan                     System.TimeSpan
uint16                       System.UInt16
uint32                       System.UInt32
uint64                       System.UInt64
uri                          System.Uri
ValidateCount                System.Management.Automation.ValidateCountAttribute
ValidateDrive                System.Management.Automation.ValidateDriveAttribute
ValidateLength               System.Management.Automation.ValidateLengthAttribute
ValidateNotNull              System.Management.Automation.ValidateNotNullAttribute
ValidateNotNullOrEmpty       System.Management.Automation.ValidateNotNullOrEmptyAttribute
ValidatePattern              System.Management.Automation.ValidatePatternAttribute
ValidateRange                System.Management.Automation.ValidateRangeAttribute
ValidateScript               System.Management.Automation.ValidateScriptAttribute
ValidateSet                  System.Management.Automation.ValidateSetAttribute
ValidateTrustedData          System.Management.Automation.ValidateTrustedDataAttribute
ValidateUserDrive            System.Management.Automation.ValidateUserDriveAttribute
version                      System.Version
void                         System.Void
ipaddress                    System.Net.IPAddress
DscLocalConfigurationManager System.Management.Automation.DscLocalConfigurationManagerAttribute
WildcardPattern              System.Management.Automation.WildcardPattern
X509Certificate              System.Security.Cryptography.X509Certificates.X509Certificate
X500DistinguishedName        System.Security.Cryptography.X509Certificates.X500DistinguishedName
xml                          System.Xml.XmlDocument
CimSession                   Microsoft.Management.Infrastructure.CimSession
adsi                         System.DirectoryServices.DirectoryEntry
adsisearcher                 System.DirectoryServices.DirectorySearcher
wmiclass                     System.Management.ManagementClass
wmi                          System.Management.ManagementObject
wmisearcher                  System.Management.ManagementObjectSearcher
mailaddress                  System.Net.Mail.MailAddress
scriptblock                  System.Management.Automation.ScriptBlock
psvariable                   System.Management.Automation.PSVariable
type                         System.Type
psmoduleinfo                 System.Management.Automation.PSModuleInfo
powershell                   System.Management.Automation.PowerShell
runspacefactory              System.Management.Automation.Runspaces.RunspaceFactory
runspace                     System.Management.Automation.Runspaces.Runspace
initialsessionstate          System.Management.Automation.Runspaces.InitialSessionState
psscriptmethod               System.Management.Automation.PSScriptMethod
psscriptproperty             System.Management.Automation.PSScriptProperty
psnoteproperty               System.Management.Automation.PSNoteProperty
psaliasproperty              System.Management.Automation.PSAliasProperty
psvariableproperty           System.Management.Automation.PSVariableProperty
````

## final Word

I hope that this page can serve you - at least in part - as a daily reminder.
