# Le challenge
Déterminer le 1er jour du mois suivant et le dernier jour du du mois courant, pour la date courante

## Way 1 :

````powershell
$NowMonth = Get-Date -Day 1 -hour 0 -Minute 0 -Second 0
$NowMonth
lundi 1 février 2021 00:00:00
$FirstDayNextMonth = $NowMonth.AddMonths(1)
$FirstDayNextMonth
lundi 1 mars 2021 00:00:00
````

## Way 2 :
````powershell
$Date = Get-Date
$Date
jeudi 4 février 2021 09:10:11
$NowFirstDayOfMonth = Get-Date -Year $Date.Year -Month $Date.Month -Day 1 -Hour 0 -Minute 0 -Second 0
$NowFirstDayOfMonth
$FirstDayNextMonth = $NowFirstDayOfMonth.addMonths(1)
$FirstDayNextMonth
lundi 1 mars 2021 00:00:00
$LastDayofMonth = $FirstDayNextMonth.addSeconds(-1)
dimanche 28 février 2021 23:59:59
````

## Way 3 :

````powershell
[DateTime] $Date = Get-Date
jeudi 4 février 2021 09:26:50
$DaysInMonth = [System.DateTime]::DaysInMonth($Date.Year, $Date.Month)
$DaysInMonth
28
$LastDayCurrentMonth = Get-Date -Day $DaysInMonth -Year $Date.Year -Month $Date.Month
$LastDayCurrentMonth
dimanche 28 février 2021 09:19:23
$FirstDayNextMonth = $LastDayCurrentMonth.addDays(1)
$FirstDayNextMonth
lundi 1 mars 2021 09:19:23
````

## Way 4 :

````powershell
$Date = Get-Date
$Date
jeudi 4 février 2021 09:22:11
$NowFirstDayOfMonth = Get-Date -Year $Date.Year -Month $Date.Month -Day 1 -Hour 0 -Minute 0 -Second 0
$NowFirstDayOfMonth
lundi 1 février 2021 00:00:00
$FirstDayNextMonth = $NowFirstDayOfMonth.addMonths(1)
$FirstDayNextMonth
lundi 1 mars 2021 00:00:00
$LastDayofMonth = $FirstDayNextMonth.addSeconds(-1)
$LastDayofMonth
dimanche 28 février 2021 23:59:59
````

## Way 5 :

````Powershell
$FirstDaynextMonth = (Get-Date -Day 1).AddMonths(1)
$FirstDayNextMonth
lundi 1 mars 2021 09:32:32
$LastDayOfMonth = $FirstDayNextMonth.addSeconds(-1)
$LastDayOfMonth
lundi 1 mars 2021 09:32:31
````
