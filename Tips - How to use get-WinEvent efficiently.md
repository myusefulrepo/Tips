
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


# 9 - An example with HTML report
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
