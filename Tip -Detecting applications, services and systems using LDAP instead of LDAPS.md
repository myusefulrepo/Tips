# Detecting applications, services and systems using LDAP instead of LDAPS

## principle
Active Directory Domain Services (AD DS) offers many ways to integrate applications and services.

Traditionally, the Lightweight Directory Access Protocol (LDAP) was used by software developers to integrate. While Kerberos-based Integrated Windows Authentication (IWA) can also be used, LDAP has kept a certain foothold for software solutions, as it is also available on non-Windows and non-IIS-based solutions and can be used to integrate with other directories, besides AD DS.

LDAP, however, was never envisioned from the start as a protocol for open networks. Eventually, LDAP over SSL (commonly abbreviated as LDAPS and described in RFC 2830) was introduced in 2000 to address the plain-text nature of the original LDAP (LDAPv3, described in RFC 2251).

Many of the software packages supporting LDAPS have no issues connecting using LDAP, thus removing the need to work with certificates. As appealing as this sounds to AD admins, it should be avoided as the service accounts used to poke around in AD DS through LDAP often have significant privileges. These privileges can be asserted after a malicious person has acquired them through a Meddle in the Middle (MitM) attack.

LDAP Channel Binding has been introduced to counteract MitM and replay attacks, but it only work when using LDAPS. LDAP should be a thing of the past. All LDAP communications to domain controllers should be LDAPS.


[Note] : Using Microsoft Defender for Identity, detecting apps and services using LDAP instead of LDAPS is simple, as there is a built-in detection. However the license requirements for Microsoft Defender for Identity may be considered too steep to answer just this one question.

Domain Controllers with default settings do not provide the information needed to detect non-S LDAP connections. The 16 LDAP Interface Events diagnostic logging needs to be enabled. This can be achieved using Group Policy or using Windows PowerShell. We use the most efficient way to do this : GPO



# Create GPO
- Open Group Policy management Console
- Create a New Policy called "Enabling LDAP Diagnostics" in the Group Policy Objects container
- Edit the New GPO
-  Browse to Computer Configuration ==> Preferences ==> Registry
- Add a new Entry in HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics\
Name : "16 LDAP Interface Events" 
Value : 2 
Type : DWORD
- And validate
- Link the New GPO to the Domain Controller OU

At this step, All DCs will have the New settings. 

## Detecting applications, services and systems using LDAP instead of LDAPS
to do this, a simple Powershell Script query EventLog in All DC is the way 

````Powershell 
$Hours = 24
 # retreive All DCs
$DCs = Get-ADDomainController -filter *
$InsecureLDAPBinds = @() # Init Array

# Query EventLog (Directory Service) for All DCs
$FilterHashTable = @{Logname='Directory Service'
                    Id=2889
                    StartTime=(Get-Date).AddHours("-$Hours")
                    }

ForEach ($DC in $DCs) 
    {
    $Events = Get-WinEvent -ComputerName $DC.Hostname -FilterHashtable @FilterHashTable | Out-null # Out-Null is only to avoid Console display
    # Parsing Events
    ForEach ($Event in $Events) 
        {
        $eventXML = [xml]$Event.ToXml()
        $Client = ($eventXML.event.EventData.Data[0])
        $IPAddress = $Client.SubString(0,$Client.LastIndexOf(":"))
        $User = $eventXML.event.EventData.Data[1]
        Switch ($eventXML.event.EventData.Data[2])
              {
              0 {$BindType = "Unsigned"}
              1 {$BindType = "Simple"}
              }
        # Adding Headers
        $Row = "" | select IPAddress,User,BindType
        # Populate $Row var
        $Row.IPAddress = $IPAddress
        $Row.User = $User
        $Row.BindType = $BindType
        # Adding $row to $InsecureLDAPBinds 
        $InsecureLDAPBinds += $Row
        } #end foreach
    } # end foreach
# Display Result in Out-GrivView
$InsecureLDAPBinds | Out-Gridview 
````
Feel free to adjust the code to your need


## Disabling LDAP diagnostics
TO disabled LDAP Diagnostic, modifiy the previous GPO like in the following "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics\" 
Name "16 LDAP Interface Events" 
Value : 0 
Type : DWORD



### reference
https://dirteam.com/sander/2022/05/30/howto-detect-apps-and-services-using-ldap-instead-of-ldaps/



