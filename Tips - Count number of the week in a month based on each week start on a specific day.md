# The challenge

Get the number of weeks per month based on the assumption that each week starts on a specifc day (i.e. :  Sunday)

## Define the day starting the week

````powershell
$FirsDayofweek = "sunday"
````
[Nota] : You must use the Day in ````en-US```` language, even your current language is  different.


## retrieve the Year, month and Days in month

````powershell
$Year = (Get-Date).Year
$Month = (Get-Date).Month
$days = [datetime]::DaysInMonth($Year,$Month)
<#
Year = 2021
Month = 5
Days = 31
#>
````
Here I'm using the Method DayInMonth. The syntax is the following

````powershell
[datetime]::DaysInMonth
OverloadDefinitions
-------------------
static int DaysInMonth(int year, int month)
````

## Calculate the number of day in the month

````powershell
$list = @() # initialization of the array
$list = ( 1..$days | foreach { Get-Date -Month $Month -Year $Year -Day $_} )
<#
samedi 1 mai 2021 08:49:36
dimanche 2 mai 2021 08:49:36
lundi 3 mai 2021 08:49:36
mardi 4 mai 2021 08:49:36
mercredi 5 mai 2021 08:49:36
jeudi 6 mai 2021 08:49:36
vendredi 7 mai 2021 08:49:36
samedi 8 mai 2021 08:49:36
dimanche 9 mai 2021 08:49:36
lundi 10 mai 2021 08:49:36
mardi 11 mai 2021 08:49:36
mercredi 12 mai 2021 08:49:36
jeudi 13 mai 2021 08:49:36
vendredi 14 mai 2021 08:49:36
samedi 15 mai 2021 08:49:36
dimanche 16 mai 2021 08:49:36
lundi 17 mai 2021 08:49:36
mardi 18 mai 2021 08:49:36
mercredi 19 mai 2021 08:49:36
jeudi 20 mai 2021 08:49:36
vendredi 21 mai 2021 08:49:36
samedi 22 mai 2021 08:49:36
dimanche 23 mai 2021 08:49:36
lundi 24 mai 2021 08:49:36
mardi 25 mai 2021 08:49:36
mercredi 26 mai 2021 08:49:36
jeudi 27 mai 2021 08:49:36
vendredi 28 mai 2021 08:49:36
samedi 29 mai 2021 08:49:36
dimanche 30 mai 2021 08:49:36
lundi 31 mai 2021 08:49:36
#>
````



## Identify days corresponding to $FirstDayOfWeek

````powershell
$list | Where { $_.DayofWeek -like $FirsDayofweek }
<#
dimanche 2 mai 2021 08:49:36
dimanche 9 mai 2021 08:49:36
dimanche 16 mai 2021 08:49:36
dimanche 23 mai 2021 08:49:36
dimanche 30 mai 2021 08:49:36
#>
````

## and finally, count the number of weeks

````powershell
$Weeks = ($list | Where { $_.DayofWeek -like $FirsDayofweek }).Count
Write-Host " there are $Weeks in this month" -ForegroundColor Green
there are 5 in this month
````


Hope this help
