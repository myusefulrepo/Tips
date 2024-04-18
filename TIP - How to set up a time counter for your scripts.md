# Tip : How to set up a time counter for your script

## Preface

Sometimes, you need to know how long did a script run. To do this, we'll implement a time watcher.


## 1 - Define and starting a watcher
Place the following code at the beginning of your script

````powershell
$Watcher = [System.Diagnostics.Stopwatch]::StartNew()
````
## 2 - Do some code

Place some code in your script (thanks doctor obvious :-) )

## 3 - and at the end of your script : stop the watcher

````Powershell
$Watcher.Stop()
````

The ``$Watcher`` object has some interresting properties. Let's see them.

````powershell
$Watcher

IsRunning Elapsed          ElapsedMilliseconds ElapsedTicks
--------- -------          ------------------- ------------
    False 00:00:07.3024634                7302     73024634


$Watcher | Get-Member

   TypeName : System.Diagnostics.Stopwatch

Name                MemberType Definition
----                ---------- ----------
Equals              Method     bool Equals(System.Object obj)
GetHashCode         Method     int GetHashCode()
GetType             Method     type GetType()
Reset               Method     void Reset()
Restart             Method     void Restart()
Start               Method     void Start()
Stop                Method     void Stop()
ToString            Method     string ToString()
Elapsed             Property   timespan Elapsed {get;}
ElapsedMilliseconds Property   long ElapsedMilliseconds {get;}
ElapsedTicks        Property   long ElapsedTicks {get;}
IsRunning           Property   bool IsRunning {get;}
````

but let's see in depth, the property ``Elapsed``. It's a ``TimeSpan`` type.

````powershell
$Watcher.Elapsed

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 7
Milliseconds      : 302
Ticks             : 73024634
TotalDays         : 8,45192523148148E-05
TotalHours        : 0,00202846205555556
TotalMinutes      : 0,121707723333333
TotalSeconds      : 7,3024634
TotalMilliseconds : 7302,4634
````


## 4 - Display watcher in console

here different ways to display the elapsed time counted by the watcher.

````powershell
$Watcher.Elapsed
# basic output
write-Host "$($Watcher.Elapsed.Hours)"," h, ","$($Watcher.Elapsed.Minutes)"," min, ","$($Watcher.Elapsed.Seconds)", " sec :  Elapsed since the script has started"
# or
Write-Output "$($Watcher.Elapsed.Hours) h, $($Watcher.Elapsed.Minutes) min, $($Watcher.Elapsed.Seconds) sec :  Elapsed since the script has started"

# output using Write-Color cmdlet from PSWriteColor module
Write-Color -Text "$($Watcher.Elapsed.Hours)"," h, ","$($Watcher.Elapsed.Minutes)"," min, ","$($Watcher.Elapsed.Seconds)", " sec :  Elapsed since the script has started" -Color Yellow, Green, Yellow, Green, Yellow, Green
````


Hope this will be useful