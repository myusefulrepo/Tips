# About [DateTime]

## DaysInMonth property

The class [DateTime] has an interesting property : DaysInMonth
The syntax is : ````[DateTime]::DaysInMonth(<Year>, <Month>)````
i.e.

````powershell
$Current Date / Times
$CurrentYear = $((Get-Date).Year) #Current Year
$CurrentMonth = $((Get-Date).Month) #Current Month
$LastDayofCurrentMonth = [DateTime]::DaysInMonth($CurrentYear, $CurrentMonth)
Write-Host "Current Year is $CurrentYear " -ForegroundColor Green
Write-Host "Current  Month is $CurrentMonth" -ForegroundColor Green
Write-host "Last Day of CurrentMonth is $LastDayofCurrentMonth" -ForegroundColor Green
Current Year is 2020
Current  Month is 2
Last Day of CurrentMonth is 29
````

This Could be useful when we want to work with date.

## First Day of the month

To get the first day of the month we can do like the following

````powershell
$FirstDateTimeoftheMonth = Get-Date -Day 1 -Month $CurrentMonth -Year $CurrentYear -Hour 0 -Minute 0 -Second 0
$FirstDateTimeoftheMonth
samedi 1 février 2020 00:00:00
````

Of course, this object is a [DateTime] object, then we can query its specifics property.

````powershell
$FirstDateTimeoftheMonth.Date
$FirstDateTimeoftheMonth.Day
$FirstDateTimeoftheMonth.DayOfWeek
````

## Last [DateTime] of the month

Use the previous var to build an new [DateTime] object giving the desired information

````powershell
$LastDateTimeoftheMonth = Get-Date -Day $LastDayofCurrentMonth -Month $CurrentMonth -Year $CurrentYear -Hour 23 -Minute 59 -Second 59
````



references :
<https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7>