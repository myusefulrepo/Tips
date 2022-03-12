# Play With SID


## One first way to Get SID

````Powershell
(([adsisearcher]"(objectSid=*)").FindAll()).Properties.ObjectSID |
    ForEach-Object
        {
        (New-Object System.Security.Principal.SecurityIdentifier($_,0)).Value
        }
````

## Get Local User SID

````Powershell
(Get-LocalUser -Name $env:USERNAME | Select-Object -Property SID).SID.Value
````
or more simple

````Powershell
(Get-LocalUser -Name $env:USERNAME | Select-Object -ExpandProperty SID).Value
````

## Get AD User SID

````Powershell
Get-AdUser -Identity toms | Select-Oject -Property Name, SID
````
## Get AD Computers SID

````Powershell
Get-AdUCompter -Filter *| Select-Oject -Property Name, SID
````

## Get AD Group SID

````Powershell
Get-ADGroup -Identity Sales | Select-Object -Property Name, SID
````
## Get Domain SID

````Powershell
Get-ADDomain -Identity MyDomain | Select-Object -Property Name, DomainSID
````

## Get SID of all Domains in a forest

````Powershell
(Get-ADForest).Domains |
    Foreach {Get-ADDomain -Server $_} |
    Select-Object -Property Name, DomainSID
````

## Get AD User SID usingg translate method applied to a System.Security.Principal.NTAccount object

````Powershell
$UserName = 'julian'
(New-Object System.Security.Principal.NTAccount($UserName)).Translate([System.Security.Principal.SecurityIdentifier]).Value

$UserName = 'goku@tech.local'
(New-Object System.Security.Principal.NTAccount($UserName)).Translate([System.Security.Principal.SecurityIdentifier]).value
````

>[Nota] : we could do the reverse operation SID to UserName

````Powershell
$SID = 'S-1-5-21-1528183062-2169693211-1356664787-1175'
$UserName = ((New-Object System.Security.Principal.SecurityIdentifier($SID)).Translate([System.Security.Principal.NTAccount])).value
````

## Get the SID of the loggued on User

````Powershell
function Get-LoggedOnUserSID {
    <#
        .SYNOPSIS
            This function queries the registry to find the SID of the user that's currently logged onto the computer interactively.
            Source : https://adamtheautomator.com/powershell-get-user-sid/
    #>
    [CmdletBinding()]
    param ()

    process
        {
        try {
            New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
            (Get-ChildItem HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName
            }
        catch
            {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
            $false
            }
        }
} # end function
````

2 tips to keep in mind :
- SID are stored in the registry in the Hive HKEY_USERS
- We can identify a SID by a Regex (see below)

## Regex Pattern for a SID

````Powershell
$Pattern = 'S-\d-\d+-(\d+-){1,14}\d+$'
````

**Explanations :**

- "S-" : matches the S- string
- "\d" : Matches a digit, equivalent to [0-9]
- "-"  : Machtes the char -
- "\d" : Matches a digit, equivalent to [0-9]
- "+"  : Matches the previous token between one and unlimited times, as many times as possible, giving back as needed (greedy)
- "-"  : Matches the Char -
- "(\d+-){1,14}" : 1st Capturing Group {1,14} matches the previous token between 1 and 14 times, as many times as possible, giving back as needed (greedy)
A repeated capturing group will only capture the last iteration. Put a capturing group around the repeated group to capture all iterations or use a non-capturing group instead if you're not interested in the data
- "\d"  : Matches a digit (equivalent to [0-9])
- "+"   : Matches the previous token between one and unlimited times, as many times as possible, giving back as needed (greedy)
- "-"   : Matches the character -
- "\d"  : Matches a digit (equivalent to [0-9])
- "+"   : Matches the previous token between one and unlimited times, as many times as possible, giving back as needed (greedy)
- "$"   : Asserts position at the end of a line


## SID structure

S-1-5-21-3578921928-1188333357-1870954717-1001
S-R-X-Y1 -Y 2 ...-Y n-1 -Y n

In this notation, the components of a SID are as follows :
 - S indicates that the string is a SID.
 - R is the revision level.
 - X is the identifier authority value. A 5 value is NT Authority
 - Y is a series of subauthority values, where n is the number of values.
 In the previous SID, 21-3578921928-1188333357-1870954717 : Is the Domain Identifier.
 1001 : Is the Specific Identifier

## Well-Knowns SID
See : https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/81d92bba-d22b-4a8c-908a-554ab29148ab

i.e. :
    S-1-5-21-<domain>-512 is the SID of DOMAIN_ADMINS Group
    S-1-5-21-<domain>-513 is the SID of DOMAIN_USERS Group
    S-1-5-21-<domain>-516 is the SID of DOMAIN_DOMAIN_CONTROLLERS group
    S-1-5-32-544 is the SID of BUILTIN_ADMINISTRATORS group
    S-1-5-113 is the SID for a LOCAL_ACCOUNT group that includes all user who are local
    S-1-5-21-<machine>-500 is the SID of ADMINISTRATOR account (A user account for the system administrator. By default, it's the only user account that is given full control over the system.)


## Function ConvertFrom-SID
>[Source] : Function from the PSSharedGoods Module - https://www.powershellgallery.com/packages/PSSharedGoods/, https://github.com/EvotecIT/PSSharedGoods, https://evotec.xyz/hub/scripts/pssharedgoods-powershell-module/

Below the 0.224 version

This function knows how to identify all Well-Known SIDs. It's very practical and useful

````Powershell
function ConvertFrom-SID
{
    <#
    .SYNOPSIS
    Small command that can resolve SID values

    .DESCRIPTION
    Small command that can resolve SID values

    .PARAMETER SID
    Value to resolve

    .PARAMETER OnlyWellKnown
    Only resolve SID when it's well know SID. Otherwise return $null

    .PARAMETER OnlyWellKnownAdministrative
    Only resolve SID when it's administrative well know SID. Otherwise return $null

    .PARAMETER DoNotResolve
    Uses only dicrionary values without querying AD

    .EXAMPLE
    ConvertFrom-SID -SID 'S-1-5-8', 'S-1-5-9', 'S-1-5-11', 'S-1-5-18', 'S-1-1-0' -DoNotResolve

    .NOTES
    General notes
    #>
    [cmdletbinding(DefaultParameterSetName = 'Standard')]

    param
    (
        [Parameter(ParameterSetName = 'Standard')]
        [Parameter(ParameterSetName = 'OnlyWellKnown')]
        [Parameter(ParameterSetName = 'OnlyWellKnownAdministrative')]
        [string[]] $SID,

        [Parameter(ParameterSetName = 'OnlyWellKnown')]
        [switch] $OnlyWellKnown,

        [Parameter(ParameterSetName = 'OnlyWellKnownAdministrative')]
        [switch] $OnlyWellKnownAdministrative,

        [Parameter(ParameterSetName = 'Standard')]
        [switch] $DoNotResolve
    )

    $WellKnownAdministrative = @{'S-1-5-18' = [PSCustomObject] @{Name = 'NT AUTHORITY\SYSTEM'
            SID                                                       = 'S-1-5-18'
            DomainName                                                = ''
            Type                                                      = 'WellKnownAdministrative'
            Error                                                     = ''
        }
        'S-1-5-32-544'                      = [PSCustomObject] @{Name = 'BUILTIN\Administrators'
            SID                                  = 'S-1-5-32-544'
            DomainName                           = ''
            Type                                 = 'WellKnownAdministrative'
            Error                                = ''
        }
    }

    $wellKnownSIDs = @{'S-1-0' = [PSCustomObject] @{Name = 'Null AUTHORITY'
            SID                                          = 'S-1-0'
            DomainName                                   = ''
            Type                                         = 'WellKnownGroup'
            Error                                        = ''
        }
        'S-1-0-0'              = [PSCustomObject] @{Name = 'NULL SID'
            SID                             = 'S-1-0-0'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-1'                = [PSCustomObject] @{Name = 'WORLD AUTHORITY'
            SID                           = 'S-1-1'
            DomainName                    = ''
            Type                          = 'WellKnownGroup'
            Error                         = ''
        }
        'S-1-1-0'              = [PSCustomObject] @{Name = 'Everyone'
            SID                             = 'S-1-1-0'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-2'                = [PSCustomObject] @{Name = 'LOCAL AUTHORITY'
            SID                           = 'S-1-2'
            DomainName                    = ''
            Type                          = 'WellKnownGroup'
            Error                         = ''
        }
        'S-1-2-0'              = [PSCustomObject] @{Name = 'LOCAL'
            SID                             = 'S-1-2-0'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-2-1'              = [PSCustomObject] @{Name = 'CONSOLE LOGON'
            SID                             = 'S-1-2-1'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-3'                = [PSCustomObject] @{Name = 'CREATOR AUTHORITY'
            SID                           = 'S-1-3'
            DomainName                    = ''
            Type                          = 'WellKnownGroup'
            Error                         = ''
        }
        'S-1-3-0'              = [PSCustomObject] @{Name = 'CREATOR OWNER'
            SID                             = 'S-1-3-0'
            DomainName                      = ''
            Type                            = 'WellKnownAdministrative'
            Error                           = ''
        }
        'S-1-3-1'              = [PSCustomObject] @{Name = 'CREATOR GROUP'
            SID                             = 'S-1-3-1'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-3-2'              = [PSCustomObject] @{Name = 'CREATOR OWNER SERVER'
            SID                             = 'S-1-3-2'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-3-3'              = [PSCustomObject] @{Name = 'CREATOR GROUP SERVER'
            SID                             = 'S-1-3-3'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-3-4'              = [PSCustomObject] @{Name = 'OWNER RIGHTS'
            SID                             = 'S-1-3-4'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-80-0'           = [PSCustomObject] @{Name = 'NT SERVICE\ALL SERVICES'
            SID                                = 'S-1-5-80-0'
            DomainName                         = ''
            Type                               = 'WellKnownGroup'
            Error                              = ''
        }
        'S-1-4'                = [PSCustomObject] @{Name = 'Non-unique Authority'
            SID                           = 'S-1-4'
            DomainName                    = ''
            Type                          = 'WellKnownGroup'
            Error                         = ''
        }
        'S-1-5'                = [PSCustomObject] @{Name = 'NT AUTHORITY'
            SID                           = 'S-1-5'
            DomainName                    = ''
            Type                          = 'WellKnownGroup'
            Error                         = ''
        }
        'S-1-5-1'              = [PSCustomObject] @{Name = 'NT AUTHORITY\DIALUP'
            SID                             = 'S-1-5-1'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-2'              = [PSCustomObject] @{Name = 'NT AUTHORITY\NETWORK'
            SID                             = 'S-1-5-2'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-3'              = [PSCustomObject] @{Name = 'NT AUTHORITY\BATCH'
            SID                             = 'S-1-5-3'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-4'              = [PSCustomObject] @{Name = 'NT AUTHORITY\INTERACTIVE'
            SID                             = 'S-1-5-4'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-6'              = [PSCustomObject] @{Name = 'NT AUTHORITY\SERVICE'
            SID                             = 'S-1-5-6'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-7'              = [PSCustomObject] @{Name = 'NT AUTHORITY\ANONYMOUS LOGON'
            SID                             = 'S-1-5-7'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-8'              = [PSCustomObject] @{Name = 'NT AUTHORITY\PROXY'
            SID                             = 'S-1-5-8'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-9'              = [PSCustomObject] @{Name = 'NT AUTHORITY\ENTERPRISE DOMAIN CONTROLLERS'
            SID                             = 'S-1-5-9'
            DomainName                      = ''
            Type                            = 'WellKnownGroup'
            Error                           = ''
        }
        'S-1-5-10'             = [PSCustomObject] @{Name = 'NT AUTHORITY\SELF'
            SID                              = 'S-1-5-10'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-11'             = [PSCustomObject] @{Name = 'NT AUTHORITY\Authenticated Users'
            SID                              = 'S-1-5-11'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-12'             = [PSCustomObject] @{Name = 'NT AUTHORITY\RESTRICTED'
            SID                              = 'S-1-5-12'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-13'             = [PSCustomObject] @{Name = 'NT AUTHORITY\TERMINAL SERVER USER'
            SID                              = 'S-1-5-13'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-14'             = [PSCustomObject] @{Name = 'NT AUTHORITY\REMOTE INTERACTIVE LOGON'
            SID                              = 'S-1-5-14'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-15'             = [PSCustomObject] @{Name = 'NT AUTHORITY\This Organization'
            SID                              = 'S-1-5-15'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-17'             = [PSCustomObject] @{Name = 'NT AUTHORITY\IUSR'
            SID                              = 'S-1-5-17'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-18'             = [PSCustomObject] @{Name = 'NT AUTHORITY\SYSTEM'
            SID                              = 'S-1-5-18'
            DomainName                       = ''
            Type                             = 'WellKnownAdministrative'
            Error                            = ''
        }
        'S-1-5-19'             = [PSCustomObject] @{Name = 'NT AUTHORITY\NETWORK SERVICE'
            SID                              = 'S-1-5-19'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-20'             = [PSCustomObject] @{Name = 'NT AUTHORITY\NETWORK SERVICE'
            SID                              = 'S-1-5-20'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-32-544'         = [PSCustomObject] @{Name = 'BUILTIN\Administrators'
            SID                                  = 'S-1-5-32-544'
            DomainName                           = ''
            Type                                 = 'WellKnownAdministrative'
            Error                                = ''
        }
        'S-1-5-32-545'         = [PSCustomObject] @{Name = 'BUILTIN\Users'
            SID                                  = 'S-1-5-32-545'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-546'         = [PSCustomObject] @{Name = 'BUILTIN\Guests'
            SID                                  = 'S-1-5-32-546'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-547'         = [PSCustomObject] @{Name = 'BUILTIN\Power Users'
            SID                                  = 'S-1-5-32-547'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-548'         = [PSCustomObject] @{Name = 'BUILTIN\Account Operators'
            SID                                  = 'S-1-5-32-548'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-549'         = [PSCustomObject] @{Name = 'BUILTIN\Server Operators'
            SID                                  = 'S-1-5-32-549'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-550'         = [PSCustomObject] @{Name = 'BUILTIN\Print Operators'
            SID                                  = 'S-1-5-32-550'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-551'         = [PSCustomObject] @{Name = 'BUILTIN\Backup Operators'
            SID                                  = 'S-1-5-32-551'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-552'         = [PSCustomObject] @{Name = 'BUILTIN\Replicators'
            SID                                  = 'S-1-5-32-552'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-64-10'          = [PSCustomObject] @{Name = 'NT AUTHORITY\NTLM Authentication'
            SID                                 = 'S-1-5-64-10'
            DomainName                          = ''
            Type                                = 'WellKnownGroup'
            Error                               = ''
        }
        'S-1-5-64-14'          = [PSCustomObject] @{Name = 'NT AUTHORITY\SChannel Authentication'
            SID                                 = 'S-1-5-64-14'
            DomainName                          = ''
            Type                                = 'WellKnownGroup'
            Error                               = ''
        }
        'S-1-5-64-21'          = [PSCustomObject] @{Name = 'NT AUTHORITY\Digest Authentication'
            SID                                 = 'S-1-5-64-21'
            DomainName                          = ''
            Type                                = 'WellKnownGroup'
            Error                               = ''
        }
        'S-1-5-80'             = [PSCustomObject] @{Name = 'NT SERVICE'
            SID                              = 'S-1-5-80'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-5-83-0'           = [PSCustomObject] @{Name = 'NT VIRTUAL MACHINE\Virtual Machines'
            SID                                = 'S-1-5-83-0'
            DomainName                         = ''
            Type                               = 'WellKnownGroup'
            Error                              = ''
        }
        'S-1-16-0'             = [PSCustomObject] @{Name = 'Untrusted Mandatory Level'
            SID                              = 'S-1-16-0'
            DomainName                       = ''
            Type                             = 'WellKnownGroup'
            Error                            = ''
        }
        'S-1-16-4096'          = [PSCustomObject] @{Name = 'Low Mandatory Level'
            SID                                 = 'S-1-16-4096'
            DomainName                          = ''
            Type                                = 'WellKnownGroup'
            Error                               = ''
        }
        'S-1-16-8192'          = [PSCustomObject] @{Name = 'Medium Mandatory Level'
            SID                                 = 'S-1-16-8192'
            DomainName                          = ''
            Type                                = 'WellKnownGroup'
            Error                               = ''
        }
        'S-1-16-8448'          = [PSCustomObject] @{Name = 'Medium Plus Mandatory Level'
            SID                                 = 'S-1-16-8448'
            DomainName                          = ''
            Type                                = 'WellKnownGroup'
            Error                               = ''
        }
        'S-1-16-12288'         = [PSCustomObject] @{Name = 'High Mandatory Level'
            SID                                  = 'S-1-16-12288'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-16-16384'         = [PSCustomObject] @{Name = 'System Mandatory Level'
            SID                                  = 'S-1-16-16384'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-16-20480'         = [PSCustomObject] @{Name = 'Protected Process Mandatory Level'
            SID                                  = 'S-1-16-20480'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-16-28672'         = [PSCustomObject] @{Name = 'Secure Process Mandatory Level'
            SID                                  = 'S-1-16-28672'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-554'         = [PSCustomObject] @{Name = 'BUILTIN\Pre-Windows 2000 Compatible Access'
            SID                                  = 'S-1-5-32-554'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-555'         = [PSCustomObject] @{Name = 'BUILTIN\Remote Desktop Users'
            SID                                  = 'S-1-5-32-555'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-556'         = [PSCustomObject] @{Name = 'BUILTIN\Network Configuration Operators'
            SID                                  = 'S-1-5-32-556'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-557'         = [PSCustomObject] @{Name = 'BUILTIN\Incoming Forest Trust Builders'
            SID                                  = 'S-1-5-32-557'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-558'         = [PSCustomObject] @{Name = 'BUILTIN\Performance Monitor Users'
            SID                                  = 'S-1-5-32-558'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-559'         = [PSCustomObject] @{Name = 'BUILTIN\Performance Log Users'
            SID                                  = 'S-1-5-32-559'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-560'         = [PSCustomObject] @{Name = 'BUILTIN\Windows Authorization Access Group'
            SID                                  = 'S-1-5-32-560'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-561'         = [PSCustomObject] @{Name = 'BUILTIN\Terminal Server License Servers'
            SID                                  = 'S-1-5-32-561'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-562'         = [PSCustomObject] @{Name = 'BUILTIN\Distributed COM Users'
            SID                                  = 'S-1-5-32-562'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-569'         = [PSCustomObject] @{Name = 'BUILTIN\Cryptographic Operators'
            SID                                  = 'S-1-5-32-569'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-573'         = [PSCustomObject] @{Name = 'BUILTIN\Event Log Readers'
            SID                                  = 'S-1-5-32-573'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-574'         = [PSCustomObject] @{Name = 'BUILTIN\Certificate Service DCOM Access'
            SID                                  = 'S-1-5-32-574'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-575'         = [PSCustomObject] @{Name = 'BUILTIN\RDS Remote Access Servers'
            SID                                  = 'S-1-5-32-575'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-576'         = [PSCustomObject] @{Name = 'BUILTIN\RDS Endpoint Servers'
            SID                                  = 'S-1-5-32-576'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-577'         = [PSCustomObject] @{Name = 'BUILTIN\RDS Management Servers'
            SID                                  = 'S-1-5-32-577'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-578'         = [PSCustomObject] @{Name = 'BUILTIN\Hyper-V Administrators'
            SID                                  = 'S-1-5-32-578'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-579'         = [PSCustomObject] @{Name = 'BUILTIN\Access Control Assistance Operators'
            SID                                  = 'S-1-5-32-579'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
        'S-1-5-32-580'         = [PSCustomObject] @{Name = 'BUILTIN\Remote Management Users'
            SID                                  = 'S-1-5-32-580'
            DomainName                           = ''
            Type                                 = 'WellKnownGroup'
            Error                                = ''
        }
    }

    foreach ($S in $SID)
    {
        if ($OnlyWellKnownAdministrative)
        {
            if ($WellKnownAdministrative[$S])
            {
                $WellKnownAdministrative[$S]
            }
        }
        elseif ($OnlyWellKnown)
        {
            if ($wellKnownSIDs[$S])
            {
                $wellKnownSIDs[$S]
            }
        }
        else
        {
            if ($wellKnownSIDs[$S])
            {
                $wellKnownSIDs[$S]
            }
            else
            {
                if ($DoNotResolve)
                {
                    if ($S -like "S-1-5-21-*-519" -or $S -like "S-1-5-21-*-512")
                    {
                        [PSCustomObject] @{Name = $S
                            SID                 = $S
                            DomainName          = ''
                            Type                = 'Administrative'
                            Error               = ''
                        }
                    }
                    else
                    {
                        [PSCustomObject] @{Name = $S
                            SID                 = $S
                            DomainName          = ''
                            Error               = ''
                            Type                = 'NotAdministrative'
                        }
                    }
                }
                else
                {
                    try
                    {
                        if ($S -like "S-1-5-21-*-519" -or $S -like "S-1-5-21-*-512")
                        {
                            $Type = 'Administrative'
                        }
                        else
                        {
                            $Type = 'NotAdministrative'
                        }
                        $Name = (([System.Security.Principal.SecurityIdentifier]::new($S)).Translate([System.Security.Principal.NTAccount])).Value
                        [PSCustomObject] @{Name = $Name
                            SID                 = $S
                            DomainName          = (ConvertFrom-NetbiosName -Identity $Name).DomainName
                            Type                = $Type
                            Error               = ''
                        }
                    }
                    catch
                    {
                        [PSCustomObject] @{Name = $S
                            SID                 = $S
                            DomainName          = ''
                            Error               = $_.Exception.Message -replace [environment]::NewLine, ' '
                            Type                = 'Unknown'
                        }
                    }
                }
            }
        }
    }
}
````

## Convert To SID
>[Source] : Function from the PSSharedGoods Module - https://www.powershellgallery.com/packages/PSSharedGoods/, https://github.com/EvotecIT/PSSharedGoods, https://evotec.xyz/hub/scripts/pssharedgoods-powershell-module/

Below the 0.224 version

````Powershell
function ConvertTo-SID
{
    [cmdletBinding()]
    param
        (
        [string[]] $Identity
        )

    Begin
    {
        if (-not $Script:GlobalCacheSidConvert)
        {
            $Script:GlobalCacheSidConvert = @{}
        }
    }
    Process
    {
        foreach ($Ident in $Identity)
        {
            if ($Script:GlobalCacheSidConvert[$Ident])
            {
                $Script:GlobalCacheSidConvert[$Ident]
            }
            else
            {
                try
                {
                    $Script:GlobalCacheSidConvert[$Ident] = [PSCustomObject] @{Name = $Ident
                        Sid                                                         = ([System.Security.Principal.NTAccount] $Ident).Translate([System.Security.Principal.SecurityIdentifier]).Value
                        Error                                                       = ''
                    }
                }
                catch
                {
                    [PSCustomObject] @{Name = $Ident
                        Sid                 = ''
                        Error               = $_.Exception.Message
                    }
                }
                $Script:GlobalCacheSidConvert[$Ident]
            }
        }
    }
    End
    {
    }
}
````
