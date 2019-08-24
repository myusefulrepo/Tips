
Measure-Command -Expression {
Get-WinEvent -LogName system | where{$_.ID -eq "6005"} | Select-Object -Last 10
}
# about 10 second to run
Measure-Command -Expression {
Get-WinEvent -MaxEvents 10 -FilterHashtable @{
                                                Logname = 'System';
                                                id= 6005
                                                }    
}
# and now 44 ms to run

# Using filterhashtable is really powerful

# another use with multiple values for a parameter (i.e. ID)
Get-WinEvent -MaxEvents 10 -FilterHashTable @{
                                LogName='System';
                                ID='1','42'
                                }

# Get event with all error events (level LogAlways 0, Critical 1, Error 2, Warning 3, Informational 4, Verbose 5)
Get-WinEvent -FilterHashTable @{LogName='System';Level='2'} -MaxEvents 10  | Sort-Object TimeCreated, providerName

# Filter on multiple levels
<#
Unfortunately, you can only specify one level at a time through a hash table. 
However, we can circumvent this problem by using the Where-Object cmdlet instead of the Level key from the hash table.
#>
Get-WinEvent -FilterHashtable @{LogName='system'} -MaxEvents 10 | Where-Object -FilterScript {($_.Level -eq 2) -or ($_.Level -eq 3)} 

# Audit success or audit failure security events 
<#
Filtering events from the Security log is a bit different from other logs because it does not provide the information level. 
Instead you can search for audit failure or audit success events. 
You must provide this filter with the Keywords key in the hash table, and the value must be a number. 
Here are the two audit keywords associated with their respective numbers:
    Failure Audit 4503599627370496
    Success audit 9007199254740992
#>
Get-WinEvent -FilterHashtable @{LogName='Security';Keywords='4503599627370496'} # failure audit

# Events with messages containing specific words
<#
To display only events with messages containing a specific word, you could use the Data key. 
However, this is a little tricky, especially because you can't work with wildcards or regular expressions. 
The easiest way to find events with a specific word is to use the Where-Object cmdlet and filter events with the Message property.
#>
Get-WinEvent -FilterHashtable @{LogName='System'} | Where-Object -Property Message -Match 'the system has resumed'

# Get Events with a specific date or time 
<#
You can display events with a specific date or time with the help of the StartTime key and/or the EndTime key inside the hash table. 
Although there are several possibilities to provide the StartTime and EndTime values, I will only show the simplest way. 
The first step is to store the timestamp returned by the Get-Date cmdlet into a variable.
#>
$StartTime = Get-Date -Year 2018 -Month 1 -Day 1  -Hour 15 -Minute 30
$EndTime   = Get-Date -Year 2019 -Month 7 -Day 25 -Hour 12 -Minute 00
Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$StartTime;EndTime=$EndTime}
$StartDate = Get-Date -Year 2019 -Month 7 -Day 25 -Hour 12 -Minute 00
Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$StartDate;Level='2';ID='10010'} -MaxEvents 5

# AN EXAMPLE WITH HTML EXPORT
#region Define CSS style
$css= @"
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

#region Search criterias
<# Explanations about criterias
Level values. [System.String] separate by comma if several
    1 : Critical
    2 : Error
    3 : Warning
    4 : Information

LogName = "System", "Application", "Security", ... and many other logs. [System.String] separate by comma if several
    Get-WinEvent -ListLog *   ===> to get all log files Name
    Get-WinEvent -ListProvider *KeyWord* to get log files containing the keyword. Look for the Name property

ID  = ID of event. [System.String] separate by comma if several
 
Keywords names and enumerated values 
    Name 	            Values
    AuditFailure 	    4503599627370496
    AuditSuccess 	    9007199254740992
    CorrelationHint2 	18014398509481984
    EventLogClassic 	36028797018963968
    Sqm 	            2251799813685248
    WdiDiagnostic 	    1125899906842624
    WdiContext 	        562949953421312
    ResponseTime 	    281474976710656
    None 	            0

TimeCreated = [System.Time]
StartDate = [System.Date]

Get-WinEvent -ListLog <LogName> | Format-List -Property *  ==> to enumerate all properties
#>

# Define the filterHashTable parameters
$StartDate = (get-date).adddays(-1)
$LogName = "System"
$Level = "2"
$Id = ""
$Keywords = ""
# ...

#endregion

#region query : ADJUST AS YOU WANT
$Query = Get-WinEvent -ErrorAction SilentlyContinue -FilterHashtable @{logname=$LogName; 
                                                                      StartTime=$StartDate
                                                                      }                                                                      Level = $Level}
#end region

#region Export the result in a beautiful html page 
$Query | 
    ConvertTo-HTML -Head $css MachineName, ID, LevelDisplayName, level, TimeCreated, Message | 
    Out-File -FilePath $ReportFile

# and show it
& $ReportFile
#endregion
