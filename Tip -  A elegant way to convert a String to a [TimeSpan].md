# A elegant way to convert a `[String]` to a `[TimeSpan]`

## The [TimeSpan] type

Do you know that this type has some interresting static méthods ?

Let's see them.

```` powershell
[TimeSpan] | Get-Member -MemberType Method -Static

   TypeName : System.TimeSpan

Name             MemberType Definition                                                                                                                                                         
----             ---------- ----------                                                                                                                                                         
Compare          Method     static int Compare(timespan t1, timespan t2)                                                                                                                       
Equals           Method     static bool Equals(timespan t1, timespan t2), static bool Equals(System.Object objA, System.Object objB)                                                           
FromDays         Method     static timespan FromDays(double value)                                                                                                                             
FromHours        Method     static timespan FromHours(double value)                                                                                                                            
FromMilliseconds Method     static timespan FromMilliseconds(double value)                                                                                                                     
FromMinutes      Method     static timespan FromMinutes(double value)                                                                                                                          
FromSeconds      Method     static timespan FromSeconds(double value)                                                                                                                          
FromTicks        Method     static timespan FromTicks(long value)                                                                                                                              
new              Method     timespan new(long ticks), timespan new(int hours, int minutes, int seconds), timespan new(int days, int hours, int minutes, int seconds), timespan new(int days,...
Parse            Method     static timespan Parse(string s), static timespan Parse(string input, System.IFormatProvider formatProvider)                                                        
ParseExact       Method     static timespan ParseExact(string input, string format, System.IFormatProvider formatProvider), static timespan ParseExact(string input, string[] formats, Syste...
ReferenceEquals  Method     static bool ReferenceEquals(System.Object objA, System.Object objB)                                                                                                
TryParse         Method     static bool TryParse(string s, [ref] timespan result), static bool TryParse(string input, System.IFormatProvider formatProvider, [ref] timespan result)            
TryParseExact    Method     static bool TryParseExact(string input, string format, System.IFormatProvider formatProvider, [ref] timespan result), static bool TryParseExact(string input, st...
````
In the present case, let's take a look to the 6 methods `From****`.

````powershell
$Milliseconds = "100"

# In the present case, $milliseconds is a [String]
$Milliseconds.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     String                                   System.Object
````

Now let's convert it to a `[TimeSpan]`

```` powershell
$Time= [TimeSpan]::FromMilliseconds($milliseconds)

$Time
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 100
Ticks             : 1000000
TotalDays         : 1,15740740740741E-06
TotalHours        : 2,77777777777778E-05
TotalMinutes      : 0,00166666666666667
TotalSeconds      : 0,1
TotalMilliseconds : 100
````
It's a `[timespan]`

<span style="color:green;font-weight:700;font-size:20px">[Nota]</span> : **This tip works also when the input is a `[Int]`**

## And does it work if we want to add them together ?

Let's try

````powershell
$sec = "50"
$Min = "3"
$Hour = "1"

$Time = [TimeSpan]::FromSeconds($sec) + [TimeSpan]::FromMinutes($Min) + [TimeSpan]::FromHours($Hour)
$Time

Days              : 0
Hours             : 1
Minutes           : 3
Seconds           : 50
Milliseconds      : 0
Ticks             : 38300000000
TotalDays         : 0,0443287037037037
TotalHours        : 1,06388888888889
TotalMinutes      : 63,8333333333333
TotalSeconds      : 3830
TotalMilliseconds : 3830000
````

This works fine.

I hope this will be useful to you.




