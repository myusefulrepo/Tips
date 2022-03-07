
# The challenge

You must determine the week number because you would like to do something in Week1, otherthing in week2 ...

There is a class named WIN32-LocalTime to do this


````powershell
Get-CimInstance -ClassName WIN32_LocalTime

Day            : 7
DayOfWeek      : 1
Hour           : 12
Milliseconds   :
Minute         : 2
Month          : 3
Quarter        : 1
Second         : 7
WeekInMonth    : 2
Year           : 2022
PSComputerName :
````

## Get only the Week Number in the month

````powershell
(Get-CimInstance -ClassName WIN32_LocalTime).WeekInMonth
2
````

As you can see in the first previous cmdlet, by the same way, you could get the ***quarter*** on the year

Hope this Help