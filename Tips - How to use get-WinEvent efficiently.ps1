
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
