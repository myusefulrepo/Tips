# Manipulate a .csv for more information

The initial code

````powershell
$csv_file = "C:\File_Location\File.csv"
$mthcnt = Import-csv -path $csv_file -Delimiter ',' -header 'workout','date','score','maxstreak'
$Results = @()
ForEach ($item in $mthcnt) {
$w = $item.workout
$d = $item.date
$s = $item.score
$ms = $item.maxstreak

$obj = New-Object PSObject
$obj | Add-Member -type Noteproperty -name workout -value $w
$obj | Add-Member -type Noteproperty -name date -value $d
$obj | Add-Member -type Noteproperty -name score -value $s
$obj | Add-Member -type Noteproperty -name maxstreak -value $ms
$Results += $obj
}
#Spit everything out to the Dashboard
$Results | Select-Object workout, date, score, maxstreak
````

## The common mistakes

- In the code, ````$Result```` var contains only 4 properties : useless to use ````Select-Object```` cmdlet on the last line.
- To sort $Result by a specific property just use ````Sort-Object```` cmdlet
- Avoid using var with a name with non sense (w, d, s, ms) of their goal. Use descriptive Names for var.

Here some improvments for the code

````powershell
# Simulate Import-Csv
$mthcnt = @"
Workout,date,score,maxstreak
Workout1,04/05/21,653215,653
Workout2,04/05/21,25398,432
Workout1,05/05/21,325175,625
Workout1,06/05/21,65231,211
Workout1,07/05/21,86532,232
"@ | ConvertFrom-Csv

$Results = @()
$Results = ForEach ($item in $mthcnt)
    {
    # building a PSCustomObject
    [PsCustomObject]@{workout  = $item.workout
                            date      = $item.date
                            score     = $item.score
                            maxstreak = $item.maxstreak
                     }
    }
````
Output of $Results  from the above example

````powershell
workout  date     score  maxstreak
-------  ----     -----  ---------
Workout1 04/05/21 653215 653
Workout2 04/05/21 25398  432
Workout1 05/05/21 325175 625
Workout1 06/05/21 65231  211
Workout1 07/05/21 86532  232
````

and now sort the result

````powershell
$Result | Sort-Object -Property Workout
workout  date     score  maxstreak
-------  ----     -----  ---------
Workout1 04/05/21 653215 653
Workout1 05/05/21 325175 625
Workout1 06/05/21 65231  211
Workout1 07/05/21 86532  232
Workout2 04/05/21 25398  432
````

## A new challenge
Have each line grouped by 'workout', a new colum with a count of times it occured and the last column the average 'maxstreak' value.

Let's do it

````Powershell
# use Group-Object to find out how many instances of each workout there are
$workouts = $Results | Group-Object -Property workout
````

Output of ````$Workouts````  var from the above example

````powershell
Count Name     Group
----- ----     -----
4     Workout1 {@{workout=Workout1; date=04/05/21; score=653215; maxstreak=653 }, @{workout=Workout1; date=05/05/21; score=325175;maxstreak=625 }, @{workout=Workout1; date=06/05/21; score=65231; maxstreak=211 }, @{workout=Workout1; date=07/05/21;score=86532; maxstreak=232}}
1     Workout2 {@{workout=Workout2; date=04/05/21; score=25398; maxstreak=432 }}
````
As we can see, the output is an object with 3 properties :  ````Count````, ````Name````, ````Group````. The ````Group```` property contains a collection of objects

And now, loop through your grouped workouts and produce new results that only include the workout name, recurrence count, and maxstreak average.
````powershell
$Results2 = for ($i = 0; $i -lt $workouts.count; $i++){
    [pscustomobject]@{
        Workout      = $workouts[$i].name
        WorkoutCount = $workouts[$i].Count
        MaxStreakAvg = ($workouts[$i].group.maxstreak | Measure-Object -Average).Average
    }
}
````

Explanations :

````$Workouts.count```` : count the lines in the var ````$Workouts````


````powershell
2
````

````$workouts[$i].name```` : value for the property name in the ````$i```` object of the collection

````powershell
Workout2
````

````$workouts[$i].group.maxstreak ````: value for the property ````maxstreak```` in the property ````group```` in the ````$i```` object of the collection

````powershell
432
````

````($workouts[$i].group.maxstreak | Measure-Object -Average) ````: calculate the average for the property ````maxstreak````

````powershell
Count    : 1
Average  : 432
Sum      :
Maximum  :
Minimum  :
Property :
````

````($workouts[$i].group.maxstreak | Measure-Object -Average).Average ```` : display only the property Average

````powershell
432
````

Output of ````$Results2```` var from the above example

````powerhell
Workout  WorkoutCount MaxStreakAvg
-------  ------------ ------------
Workout1            4       430.25
Workout2            1          432
````

Extract from the following reddit post  : https://www.reddit.com/r/PowerShell/comments/n69d0o/manipulate_output_of_csv/
