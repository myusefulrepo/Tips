
# 1 - How to retrieve the list of Event Logs
````powershell
Get-WinEvent -ListLog *
````
The result looks like this :
````powershell
(Get-WinEvent -ListLog *)
LogMode   MaximumSizeInBytes RecordCount LogName
-------   ------------------ ----------- -------
Circular            15728640         866 Windows PowerShell
Circular             1052672           0 Volume Activation Management Tool
Circular            33554432       27191 System
Circular             1052672           0 Spybot 3
Circular            33554432       43550 Security
Circular             1052672          70 OAlerts
Circular            15532032        8419 Microsoft-ServerManagementExperience
Circular            20971520           0 Key Management
...
````
On my Windows 10 computer, I've run the following `(Get-WinEvent -ListLog *).count` and it returns 493 log files.

# 2 - Searching of a specific event log
````powershell
Get-WinEvent -ListLog *powershell*
````
Windows organizes log files in a ***hierarchical tree structure***. Thus, if you want to query logs that are not at the root of the tree, you must specify the whole path. For instance,
if you want to list all events from the PowerShell Operational log, use the following command : `Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' `

# 3 - Display all events one page at a time
````powershell
Get-WinEvent -LogName 'System' | Out-Host -Paging
````
>[Nota] :  the `Out-Host` cmdlet does not work in the Integrated Scripting Environment (ISE) console.

# 4 - Get a limited number of events
````powershell
Get-WinEvent -LogName 'System' -MaxEvents 20
````

# 5 - Get a (or some) specific Event
## The Bad way : filtering with `Where-Object`
````powershell
Measure-Command -Expression {
    Get-WinEvent -LogName system |
        Where-Object { $_.ID -eq "6005" } | Select-Object -Last 10
}
````
About 10 second to run

## The best way : Filtering with a Hash Table
````powershell
Measure-Command -Expression {
    Get-WinEvent -MaxEvents 10 -FilterHashtable @{
        Logname = 'System';
        id      = 6005
    }
}
````
and now 44 ms to run
>[Nota] : Using `-filterhashtable` is really powerful

another use with multiple values for a parameter (i.e. ID)
````powershell
Get-WinEvent -MaxEvents 10 -FilterHashTable @{
    LogName = 'System'
    ID      = '1', '42'
}
````
ID of event are `[System.String]` separate by **comma** if several

# 6 - Get event with Specific information level
- level LogAlways 0
- Critical 1- Error 2
- Warning 3
- Informational 4
- Verbose 5
````powershell
Get-WinEvent -FilterHashTable @{
                LogName = 'System'
                Level = '2'
                } -MaxEvents 10 |
    Sort-Object TimeCreated, ProviderName
````
## Filter on multiple levels
Unfortunately, you can only specify one level at a time through a hash table.
However, we can circumvent this problem by using the `Where-Object` cmdlet instead of the Level key from the hash table or if you pass Level as an array.
Let's do this
```` powershell
Measure-Command -Expression {
    Get-WinEvent -FilterHashTable @{
                LogName = 'System'
                Level = '2', '3'
                } -MaxEvents 10
}
````
22 ms
This way runs fine too, but
````powershell
Measure-Command -Expression {
    Get-WinEvent -FilterHashtable @{
                    LogName = 'system' } -MaxEvents 10 |
        Where-Object -FilterScript { ($_.Level -eq 2) -or ($_.Level -eq 3) }
}
````
28 ms, slower !
>[Tiqs] : Remember ***filter left, format right***, it will be always faster.

You can filter on many elements : 
 - **LogName** : Specifies the name of the event log (e.g., "Security", "Application", "System").
 - **ProviderName** : Specifies the name of the event provider.
- **Path** : Specifies the path to the event log.
- **Id** : Specifies the ID of the event.
- **Keywords** : Filters events based on specific keywords. See Chap 7.
- **Level** : Specifies the level of the event (e.g., 0 for Verbose, 1 for Critical, 2 for Error, 3 for Warning, 4 for Information). See a sample in chap. 9.
- **StartTime** : Specifies the start time of the search. See many samples in this doc
- **EndTime** : Specifies the end time of the search. See many samples in this doc
- **UserID** : Filters events based on user ID.
- **Data** : Filters events based on specific data. See an example below.
- **XPath** : Uses an XPath expression to filter events.

**Example of Filtering on User and LogonType**

````powershell
$TargetUser = "Olivier"
$LogonType = "2"
$ID = 4624
$LogName = "Security" 
$EndTime = Get-Date
$StartTime = $EndTime.adddays(-1)

$Query =  Get-WinEvent -FilterHashtable @{ 
            LogName = $LogName
            Id = $ID
            StartTime = $StartTime
            EndTime = $EndTime
            Data = $TargetUser
            }  # + Optional -MaxEvents
````
This query is very fast (see below)

This is the main task in terms of execution time, but this time is reduced to a minimum by **efficient filtering**. At this step, we have alteady filtered on the User, but not yet on **LogonType**. The problem is all interesting info like **LogonType** are in the Property called **"Properties"**. Sometines, il can be difficult to identify the searched properties. I suggest to use a different approach : using a Xml. 

````Powershell
[xml]$Xmldoc = ($Query[0]).ToXml()
# and now examine this
$xmldoc.event.eventdata.Data
Name                      #text                                      
----                      -----                                      
SubjectUserSid            S-1-5-18                                   
SubjectUserName           xxxx                                   
SubjectDomainName         WORKGROUP                                  
SubjectLogonId            0x3e7                                      
TargetUserSid             S-1-5-21-349234613-936635038-205130404-1001
TargetUserName            xxxx                                    
TargetDomainName          ASUS11                                     
TargetLogonId             0x6ceddf                                   
LogonType                 2                                          
....
````
 Now, let's do this in a loop

````Powershell 
# initialization - I'm using A Generic list because, it's the more efficient way for performance 
$Data = [System.Collections.Generic.List[PSObject]]::new()  
foreach ($Item in  $Query)
    {
    [Xml]$Xml = $Item.toxml()
    # building a PSCustomObject with needed informations
    $Obj =  [PSCustomObject]@{
            TimeCreated = $Item.TimeCreated
            ID = $Item.ID
            LogName  = $Item.LogName
            MachineName = $Item.MachineName
            LogonType = ($xml.Event.EventData.Data | Where-Object -Property Name -EQ "LogonType").'#text'
            TargetUserName  = ($xml.Event.EventData.Data | Where-Object -Property Name -EQ "TargetUserName").'#text'
            }
    # Adding $Obj to $Data
    $Data.add($Obj)
    }
$Data
# and now ultimate filtering
$FilteringData = $Data | Where-Object -FilterScript {$_.LogonType -eq $LogonType}
````

>[Nota] : adjust the properties in `$Obj` to your needs of course. 

**Performance considerations**
In my computer there are 205 871 events in the security log (200 000 Kb) and the Query time is :

- 6.68 seconds based on a filtering on ID only (545 events returned)

- 1.30 seconds based on filtering on ID and Data (12 events returned)

- 1.25 seconds based on filtering on ID, Data, StartTime and EndTime (4 events returned)

- And the ultimate filtering takes only 10 ms.


>[Attention Point] : To query Security Event Log, you must be an Administrator (RunAsAdmin). 



# 7 - Audit success or audit failure security events
Filtering events from the Security log is a bit different from other logs because it does not provide the information level.
Instead you can search for audit failure or audit success events.
You must provide this filter with the Keywords key in the hash table, and the value must be a number.
Here are the Keywords names and enumerated values
|**Name**           | **Values**
|-------------------|:------------------:|
| AuditFailure 	    | `4503599627370496` |
| AuditSuccess 	    | `9007199254740992` |
| CorrelationHint2 	| `18014398509481984`|
| EventLogClassic 	| `36028797018963968`|
| Sqm 	            | `2251799813685248` |
| WdiDiagnostic 	| `1125899906842624` |
| WdiContext 	    | `562949953421312`  |
| ResponseTime 	    | `281474976710656`  |
| None 	            | `0`                |

````powershell
Get-WinEvent -FilterHashtable @{
                        LogName = 'Security'
                        Keywords = '4503599627370496' } # failure audit
````

# 8 - Events with messages containing specific words
To display only events with messages containing a specific word, you could use the Data key.
However, this is a little tricky, especially because you can't work with wildcards or regular expressions.
The easiest way to find events with a specific word is to use the `Where-Object` cmdlet and filter events with the Message property.
````powershell
Get-WinEvent -FilterHashtable @{LogName = 'System' } |
    Where-Object -Property Message -Match 'le système a redémarré'
````
but I must admit that this method is not very fast

# 9 - Get Events with a specific date or time
You can display events with a specific date or time with the help of the `StartTime` key and/or the `EndTime` key inside the hash table.
Although there are several possibilities to provide the `StartTime` and `EndTime` values,
The following , is probably the simplest way.

The first step is to store the timestamp returned by the Get-Date cmdlet into a variable.
````powershell
$StartTime = Get-Date -Year 2018 -Month 1 -Day 1  -Hour 15 -Minute 30
$EndTime = Get-Date -Year 2019 -Month 7 -Day 25 -Hour 12 -Minute 00
Get-WinEvent -FilterHashtable @{
                            LogName = 'System'
                            StartTime = $StartTime
                            EndTime = $EndTime }
$StartDate = Get-Date -Year 2019 -Month 7 -Day 25 -Hour 12 -Minute 00
````
Another sample
````powershell
Get-WinEvent -FilterHashtable @{
                            LogName = 'System'
                            StartTime = $StartDate
                            Level = '2'
                            ID = '10010' } -MaxEvents 5
````


# 10 - An example with HTML report
````powershell
#region Define CSS style
$css = @"
<Style>
h1, h5, th { text-align: center; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</Style>
"@
#endregion

#region Define the Export File Name
$ReportFile = "C:\temp\LogAppView.html"
#endregion

# Define the filterHashTable parameters
$TimeCreated = Get-date -Hour 09 -Minute 30 -Second 00 # TimeCreated = [System.Time]
$StartDate = (Get-Date).Adddays(-1)                    #  StartDate = [System.Date]
$LogName = "System"
$Level = "2"
$Id = ""
$Keywords = ""
# ...
#endregion

#region query : Adjust as you want, Here a sample
$Query = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{logname    = $LogName
                                                                       StartTime  = $StartDate
                                                                       Level = $Level }
#end region

#region Export the result in a beautiful html page
$Query |
    ConvertTo-Html -Head $css MachineName, ID, LevelDisplayName, level, TimeCreated, Message |
    Out-File -FilePath $ReportFile

# and show it
& $ReportFile
#endregion
````
The result looks like this :
![Events as a HTML report](https://github.com/myusefulrepo/Tips/blob/master/Images/EventsAsHTMLReport.jpg)



# 11 - Filter on specific info on NoteProperty

````powershell
$StartTime = Get-Date -Year 2020 -Month 10 -Day 7  -Hour 07 -Minute 36 -Second 02
$EndTime = Get-Date -Year 2020 -Month 10 -Day 7  -Hour 07 -Minute 36 -Second 05
$Query = Get-WinEvent -FilterHashtable @{
                            LogName = 'Security'
                            StartTime = $StartTime
                            EndTime = $EndTime
                            ID = "4624"
                            }
````

This return the following

````powershell
TimeCreated                     Id LevelDisplayName Message
-----------                     -- ---------------- -------
07/10/2020 07:36:04           4624 Information      L'ouverture de session d'un compte s'est correctement déroulée...
07/10/2020 07:36:03           4624 Information      L'ouverture de session d'un compte s'est correctement déroulée...
07/10/2020 07:36:02           4624 Information      L'ouverture de session d'un compte s'est correctement déroulée....
````

3 Events, let's see them

````powershell
$query | Select-Object @{Label = "TimeCreated"      ; Expression = {$_.TimeCreated}},
                       @{Label = "ID"               ; Expression = {$_.ID}},
                       @{Label = "MachineName"      ; Expression = {$_.MachineName}},
                       @{Label = "LevelDisplayName" ; Expression = {$_.LevelDisplayName}},
                       @{Label = "TaskDisplayName"  ; Expression = {$_.TaskDisplayName}},
                       @{Label = "SecurityId"       ; Expression = {$_.Properties[4].Value}},
                       @{Label = "AccountName"      ; Expression = {$_.Properties[5].Value}},
                       @{Label = "AccountDomain"    ; Expression = {$_.Properties[6].Value}},
                       @{Label = "LogonId"          ; Expression = {$_.Properties[7].Value}},
                       @{Label = "LogonType"        ; Expression = {$_.Properties[8].Value}},
                       @{Label = "Workstation"      ; Expression = {$_.Properties[11].Value}},
                       @{Label = "LogonGuid"        ; Expression = {$_.Properties[12].Value}}
````
and the result is

````powershell
TimeCreated      : 07/10/2020 07:36:04
ID               : 4624
MachineName      : W2K19-DC.LAB.LOCAL
LevelDisplayName : Information
TaskDisplayName  : Ouvrir la session
SecurityId       : S-1-5-18
AccountName      : W2K19-DC$
AccountDomain    : LAB.LOCAL
LogonId          : 222853
LogonType        : 3
Workstation      : -
LogonGuid        : fe7d9233-b617-564d-ca3d-41c1d1011513

TimeCreated      : 07/10/2020 07:36:03
ID               : 4624
MachineName      : W2K19-DC.LAB.LOCAL
LevelDisplayName : Information
TaskDisplayName  : Ouvrir la session
SecurityId       : S-1-5-21-310437918-1906062273-1680514792-1130
AccountName      : W2K19-DC2$
AccountDomain    : LAB.LOCAL
LogonId          : 221273
LogonType        : 3
Workstation      : -
LogonGuid        : 010206e6-2f5e-1d8e-fc5e-64586b4dd45e

TimeCreated      : 07/10/2020 07:36:02
ID               : 4624
MachineName      : W2K19-DC.LAB.LOCAL
LevelDisplayName : Information
TaskDisplayName  : Ouvrir la session
SecurityId       : S-1-5-21-310437918-1906062273-1680514792-500
AccountName      : Administrateur
AccountDomain    : LAB
LogonId          : 220861
LogonType        : 10
Workstation      : W2K19-DC
LogonGuid        : d4f4ef05-feb0-b080-aef8-c5007d1ff1de
````
Not bad, butI have logon Event for computers. I would like to have only Users. Let's modify the initial query like this :

````powershell $Query = Get-WinEvent -FilterHashtable @{
                            LogName = 'Security'
                            StartTime = $StartTime
                            EndTime = $EndTime
                            ID = "4624"
                            } | Where-Object -FilterScript {$_.Properties[5].Value -notlike "*$"}

# and select the appropriate properties again
$query | Select-Object @{Label = "TimeCreated"      ; Expression = {$_.TimeCreated}},
                       @{Label = "ID"               ; Expression = {$_.ID}},
                       @{Label = "MachineName"      ; Expression = {$_.MachineName}},
                       @{Label = "LevelDisplayName" ; Expression = {$_.LevelDisplayName}},
                       @{Label = "TaskDisplayName"  ; Expression = {$_.TaskDisplayName}},
                       @{Label = "SecurityId"       ; Expression = {$_.Properties[4].Value}},
                       @{Label = "AccountName"      ; Expression = {$_.Properties[5].Value}},
                       @{Label = "AccountDomain"    ; Expression = {$_.Properties[6].Value}},
                       @{Label = "LogonId"          ; Expression = {$_.Properties[7].Value}},
                       @{Label = "LogonType"        ; Expression = {$_.Properties[8].Value}},
                       @{Label = "Workstation"      ; Expression = {$_.Properties[11].Value}},
                       @{Label = "LogonGuid"        ; Expression = {$_.Properties[12].Value}}
````
And the result is :

````powershell
TimeCreated      : 07/10/2020 07:36:02
ID               : 4624
MachineName      : W2K19-DC.LAB.LOCAL
LevelDisplayName : Information
TaskDisplayName  : Ouvrir la session
SecurityId       : S-1-5-21-310437918-1906062273-1680514792-500
AccountName      : Administrateur
AccountDomain    : LAB
LogonId          : 220861
LogonType        : 10
Workstation      : W2K19-DC
LogonGuid        : d4f4ef05-feb0-b080-aef8-c5007d1ff1de
````
Reach the goal ! Only users accounts.


# 12 - Another Way to identify the interesting thing in an EventLog

Upper I'm talking about Level and KeyWords as filters. 

Below, I'm define 2 vars ````$Level```` and ````$EventKeyWords````

````powershell 
$Levels = @{LogAlways     = 0
            Critical      = 1
            Error         = 2
            Warning       = 3
            Informational = 4
            Verbose       = 5
        }

$EventValues = @{} # Init

$EventKeywords = @(
            "AuditFailure",
            "AuditSuccess",
            "CorrelationHint2",
            "EventLogClassic",
            "Sqm",
            "WdiDiagnostic",
            "WdiContext",
            "ResponseTime",
            "None"
        )

foreach ($EventKeyword in $EventKeywords) 
    {
    [string]$Value = ([System.Diagnostics.Eventing.Reader.StandardEventKeywords]::$($EventKeyword)).value__
    $EventValues.add("$EventKeyword", $Value)
    }
````

Later, in a Events query, I'm using them as filter


````powershell 
$StartTime = (Get-Date).AddDays(-1)
$EndTime = Get-Date
$Events = Get-WinEvent -FilterHashtable @{ LogName = "Security"
                                 StartTime = $StartTime
                                 EndTime = $EndTime
                                 ID = "4688"
                                 Level =  $Levels['LogAlways']
                                 KeyWords = $eventValues['AuditSuccess']
                                 }
````
A Name is easier to remember than a number for KeyWords :-)

Now take a look to a specific event in details

````Powershell
$Events[0] | select *


Message              : Un nouveau processus a été créé.
                       
                       Objet créateur :
                       	ID de sécurité :		S-1-5-21-349234613-936635038-205130404-1001
                       	Nom du compte :		Olivier
                       	Domaine du compte :		ASUS10
                       	ID de connexion :		0xAE1AC
                       
                       Objet cible :
                       	ID de sécurité :		S-1-0-0
                       	Nom du compte :		-
                       	Domaine du compte :		-
                       	ID de connexion :		0x0
                       
                       Informations sur le processus :
                       	ID du nouveau processus :		0x3d74
                       	Nom du nouveau processus :	C:\Program Files\Mozilla Firefox\firefox.exe
                       	Type d'élévation du jeton :	%%1938
                       	Étiquette obligatoire :		S-1-16-4096
                       	ID du processus créateur :	0x4fe0
                       	Nom du processus créateur :	C:\Program Files\Mozilla Firefox\firefox.exe
                       	Ligne de commande du processus :	"C:\Program Files\Mozilla Firefox\firefox.exe" -contentproc --channel="20448.37.571700948\1501264702" -childID 34 -isForBrowser 
                       -prefsHandle 5528 -prefMapHandle 10232 -prefsLen 40066 -prefMapSize 238551 -jsInitHandle 1356 -jsInitLen 246772 -a11yResourceId 64 -parentBuildID 20230127170202 
                       -win32kLockedDown -appDir "C:\Program Files\Mozilla Firefox\browser" - {b86a8ac9-5b9f-4130-b175-c9d50812c90a} 20448 "\\.\pipe\gecko-crash-server-pipe.20448" 9280 
                       2b1b0cda558 tab
                       
                       Le type d'élévation du jeton indique le type de jeton qui a été attribué au nouveau processus conformément à la stratégie Contrôle de compte d'utilisateur.
                       
                       Le type 1 est un jeton complet sans aucun privilège supprimé ni groupe désactivé. Un jeton complet est uniquement utilisé si le Contrôle de compte d'utilisateur 
                       est désactivé, ou que l'utilisateur est le compte d'administrateur intégré ou un compte de service.
                       
                       Le type 2 est un jeton avec élévation de privilèges sans aucun privilège supprimé ni groupe désactivé. Un jeton avec élévation de privilèges est utilisé lorsque 
                       le Contrôle de compte d'utilisateur est activé et que l'utilisateur choisit de démarrer le programme en tant qu'administrateur. Un jeton avec élévation de 
                       privilèges est également utilisé lorsqu'une application est configurée pour exiger systématiquement un privilège administratif ou le privilège maximal, et que 
                       l'utilisateur est membre du groupe Administrateurs.
                       
                       Le type 3 est un jeton limité dont les privilèges administratifs sont supprimés et les groupes administratifs désactivés. Le jeton limité est utilisé lorsque le 
                       Contrôle de compte d'utilisateur est activé, que l'application n'exige pas le privilège administratif et que l'utilisateur ne choisit pas de démarrer le 
                       programme en tant qu'administrateur.
Id                   : 4688
Version              : 2
Qualifiers           : 
Level                : 0
Task                 : 13312
Opcode               : 0
Keywords             : -9214364837600034816
RecordId             : 7451704
ProviderName         : Microsoft-Windows-Security-Auditing
ProviderId           : 54849625-5478-4994-a5ba-3e3b0328c30d
LogName              : Security
ProcessId            : 4
ThreadId             : 25248
MachineName          : ASUS10
UserId               : 
TimeCreated          : 14/02/2023 06:55:58
ActivityId           : 
RelatedActivityId    : 
ContainerLog         : Security
MatchedQueryIds      : {}
Bookmark             : System.Diagnostics.Eventing.Reader.EventBookmark
LevelDisplayName     : Information
OpcodeDisplayName    : Informations
TaskDisplayName      : Process Creation
KeywordsDisplayNames : {Succès de l’audit}
Properties           : {System.Diagnostics.Eventing.Reader.EventProperty, System.Diagnostics.Eventing.Reader.EventProperty, System.Diagnostics.Eventing.Reader.EventProperty, 
                       System.Diagnostics.Eventing.Reader.EventProperty...}
````

````powershell 
$Events[0] | Get-Member

   TypeName : System.Diagnostics.Eventing.Reader.EventLogRecord

Name                 MemberType   Definition                                                                                                                                             
----                 ----------   ----------                                                                                                                                             
Dispose              Method       void Dispose(), void IDisposable.Dispose()                                                                                                             
Equals               Method       bool Equals(System.Object obj)                                                                                                                         
FormatDescription    Method       string FormatDescription(), string FormatDescription(System.Collections.Generic.IEnumerable[System.Object] values)                                     
GetHashCode          Method       int GetHashCode()                                                                                                                                      
GetPropertyValues    Method       System.Collections.Generic.IList[System.Object] GetPropertyValues(System.Diagnostics.Eventing.Reader.EventLogPropertySelector propertySelector)        
GetType              Method       type GetType()                                                                                                                                         
ToString             Method       string ToString()                                                                                                                                      
ToXml                Method       string ToXml()                                                                                                                                         
Message              NoteProperty string Message=Un nouveau processus a été créé....                                                                                                     
ActivityId           Property     System.Nullable[guid] ActivityId {get;}                                                                                                                
Bookmark             Property     System.Diagnostics.Eventing.Reader.EventBookmark Bookmark {get;}                                                                                       
ContainerLog         Property     string ContainerLog {get;}                                                                                                                             
Id                   Property     int Id {get;}                                                                                                                                          
Keywords             Property     System.Nullable[long] Keywords {get;}                                                                                                                  
KeywordsDisplayNames Property     System.Collections.Generic.IEnumerable[string] KeywordsDisplayNames {get;}                                                                             
Level                Property     System.Nullable[byte] Level {get;}                                                                                                                     
LevelDisplayName     Property     string LevelDisplayName {get;}                                                                                                                         
LogName              Property     string LogName {get;}                                                                                                                                  
MachineName          Property     string MachineName {get;}                                                                                                                              
MatchedQueryIds      Property     System.Collections.Generic.IEnumerable[int] MatchedQueryIds {get;}                                                                                     
Opcode               Property     System.Nullable[int16] Opcode {get;}                                                                                                                   
OpcodeDisplayName    Property     string OpcodeDisplayName {get;}                                                                                                                        
ProcessId            Property     System.Nullable[int] ProcessId {get;}                                                                                                                  
Properties           Property     System.Collections.Generic.IList[System.Diagnostics.Eventing.Reader.EventProperty] Properties {get;}                                                   
ProviderId           Property     System.Nullable[guid] ProviderId {get;}                                                                                                                
ProviderName         Property     string ProviderName {get;}                                                                                                                             
Qualifiers           Property     System.Nullable[int] Qualifiers {get;}                                                                                                                 
RecordId             Property     System.Nullable[long] RecordId {get;}                                                                                                                  
RelatedActivityId    Property     System.Nullable[guid] RelatedActivityId {get;}                                                                                                         
Task                 Property     System.Nullable[int] Task {get;}                                                                                                                       
TaskDisplayName      Property     string TaskDisplayName {get;}                                                                                                                          
ThreadId             Property     System.Nullable[int] ThreadId {get;}                                                                                                                   
TimeCreated          Property     System.Nullable[datetime] TimeCreated {get;}                                                                                                           
UserId               Property     System.Security.Principal.SecurityIdentifier UserId {get;}                                                                                             
Version              Property     System.Nullable[byte] Version {get;}   
````

As previously, some interesting things in different properties but also interessting things in the ````Message Note Property.````. How to retrieve that ? A way is to convert events to xml. 

Take a look for a specific event. 

````powershell 
[xml]$Xmldoc = ($Events[0]).ToXml()
$Xmldoc

Event
-----
Event

# and now
$xmldoc.event.eventdata.Data

Name               #text                                                                                                                                                                 
----               -----                                                                                                                                                                 
SubjectUserSid     S-1-5-21-349234613-936635038-205130404-1001                                                                                                                           
SubjectUserName    Olivier                                                                                                                                                               
SubjectDomainName  ASUS10                                                                                                                                                                
SubjectLogonId     0xae1ac                                                                                                                                                               
NewProcessId       0x3d74                                                                                                                                                                
NewProcessName     C:\Program Files\Mozilla Firefox\firefox.exe                                                                                                                          
TokenElevationType %%1938                                                                                                                                                                
ProcessId          0x4fe0                                                                                                                                                                
CommandLine        "C:\Program Files\Mozilla Firefox\firefox.exe" -contentproc --channel="20448.37.571700948\1501264702" -childID 34 -isForBrowser -prefsHandle 5528 -prefMapHandle 10...
TargetUserSid      S-1-0-0                                                                                                                                                               
TargetUserName     -                                                                                                                                                                     
TargetDomainName   -                                                                                                                                                                     
TargetLogonId      0x0                                                                                                                                                                   
ParentProcessName  C:\Program Files\Mozilla Firefox\firefox.exe                                                                                                                          
MandatoryLabel     S-1-16-4096
````

Here I'm retreive a interesting info. 
````powershell
$NewProcessName   = ($xmldoc.event.eventdata.Data  | Where-Object name -EQ "NewProcessName").'#text'

[07:43:13] C:/Temp> $NewProcessName
C:\Program Files\Mozilla Firefox\firefox.exe
````

At this step, I've identified the "Standards" properties I'm looking for and the other information retrieved from ````Message Note Properties````. 
Now build our ````PSCustomObject````

````powershell
# initialization - I'm using A Generic list because, it's the more efficient way for performance 
$Output = [System.Collections.Generic.List[PSObject]]::new()  
foreach ($Item in  $Events)
    {
    [Xml]$Xml = $Item.toxml()
    $Obj =  [PSCustomObject]@{
            TimeCreated = $Item.TimeCreated
            ID = $Item.ID
            LogName  = $Item.LogName
            ProviderName = $Item.ProviderName
            MachineName = $Item.MachineName
            LevelDisplayName = $Item.LevelDisplayName
            TaskDisplayName  = $Item.TaskDisplayName
            KeyWordsDisplayNames = $Item.KeyWordsDisplayNames
            SubjectUserSid = ($xml.Event.EventData.Data | Where-Object name -EQ "SubjectUserSid").'#text'
            SubjectUserName  = ($xml.Event.EventData.Data | Where-Object name -EQ "SubjectUserName").'#text'
            SubjectDomainName = ($xml.Event.EventData.Data | Where-Object name -EQ "SubjectDomainName").'#text'
            NewProcessName = ($xml.Event.EventData.Data | Where-Object name -EQ "NewProcessName").'#text'
            CommandLine  = ($xml.Event.EventData.Data | Where-Object name -EQ "CommandLine").'#text'
            ParentProcessName  = ($xml.Event.EventData.Data | Where-Object name -EQ "ParentProcessName").'#text'
            }
      $Output.add($Obj)
}
$Output
````
$Output is an object, then the structure is not broken if i want to export later in a .csv file. 

````powershell 
$Output.GetType()

IsPublic IsSerial Name                                     BaseType                                                                                                                      
-------- -------- ----                                     --------                                                                                                                      
True     True     List`1                                   System.Object
````    

Take a look in the output (just an extract)

````powershell 
TimeCreated          : 13/02/2023 07:01:10
ID                   : 4688
LogName              : Security
ProviderName         : Microsoft-Windows-Security-Auditing
MachineName          : ASUS10
LevelDisplayName     : Information
TaskDisplayName      : Process Creation
KeyWordsDisplayNames : {Succès de l’audit}
SubjectUserSid       : S-1-5-18
SubjectUserName      : ASUS10$
SubjectDomainName    : WORKGROUP
NewProcessName       : C:\Windows\System32\dwm.exe
CommandLine          : "dwm.exe"
ParentProcessName    : C:\Windows\System32\winlogon.exe

TimeCreated          : 13/02/2023 07:01:10
ID                   : 4688
LogName              : Security
ProviderName         : Microsoft-Windows-Security-Auditing
MachineName          : ASUS10
LevelDisplayName     : Information
TaskDisplayName      : Process Creation
KeyWordsDisplayNames : {Succès de l’audit}
SubjectUserSid       : S-1-5-18
SubjectUserName      : ASUS10$
SubjectDomainName    : WORKGROUP
NewProcessName       : C:\Windows\System32\svchost.exe
CommandLine          : C:\Windows\system32\svchost.exe -k DcomLaunch -p -s LSM
ParentProcessName    : C:\Windows\System32\services.exe
````

# Synthesis

 when we're looking in the eventslog
- Gathering Data with filter (s) using FilterHashTable for more efficiencly. This operation could be long, then put the result in a var.
- Identify the interesting properties to display or export with ````Get-Member```` but also with a transformation into a .xml for everything that is in the ````Note Properties Message````.

Hope this help