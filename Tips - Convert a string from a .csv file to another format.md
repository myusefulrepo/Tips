# convert a string from a .csv file to another format

## The scenario
We have a string from a .csv file, and this string represent a Time value, but this is a string.
We would like to transform this value to another value

````powershell
# Simulate Import-Csv
$Csv = @'
Duration
01:23.4
59.29
01:23.2
59.4
59.85
01:23.2
01:37.3
01:30.4
01:20.2
54.46
01:49.3
53.65
01:28.4
53.29
52.55
01:22.9
01:51.1
01:33.1
01:22.6
56.95
01:10.9
01:37.0
57.22
01:11.8
01:36.8
56.52
01:45.4
01:44.5
59.54
01:40.0
01:13.5
58.7
01:07.1
'@ | ConvertFrom-Csv
````

let set the ````$Csv```` variable

````Powershell
$csv | Get-Member
   TypeName : System.Management.Automation.PSCustomObject

Name        MemberType   Definition
----        ----------   ----------
Equals      Method       bool Equals(System.Object obj)
GetHashCode Method       int GetHashCode()
GetType     Method       type GetType()
ToString    Method       string ToString()
Duration    NoteProperty string Duration=01:23.4
````

As we can see, the property ````Duration```` is a ````[String]````


To transform this [String] representing a time to another Time format (I would like to have something expressed in seconds), we can use the ````[TimeSpan]::ParseExact```` method.

## Step 1 : Convert to ````[TimeSpan]````
The most common syntax for ````[TimeSpan]::ParseExact```` is the following :

````powershell
[TimeSpan]::ParseExact($String, $Format, $Culture)
````

the result will be :

````powershell
$string = "01:07.1"
$Format = 'mm\:ss\.f'
$Culture = [CultureInfo]::InvariantCulture
[TimeSpan]::ParseExact($String, $Format, $Culture)
Days              : 0
Hours             : 0
Minutes           : 1
Seconds           : 7
Milliseconds      : 100
Ticks             : 671000000
TotalDays         : 0,00077662037037037
TotalHours        : 0,0186388888888889
TotalMinutes      : 1,11833333333333
TotalSeconds      : 67,1
TotalMilliseconds : 67100
# Check the type
[TimeSpan]::ParseExact($String, $Format, $Culture).GetType()

IsPublic IsSerial Name BaseType
-------- -------- ------------
True     True     TimeSpan                                 System.ValueType
````
## Step 2 - Select the appropriate Property (format)

Then I use the Property ````TotalSeconds```` to have this to the expected Format.

````powershell
[TimeSpan]::ParseExact($String, $Format, $Culture).TotalSeconds
67,1
# check the type of the result
[TimeSpan]::ParseExact($String, $Format, $Culture).TotalSeconds.GetType()
IsPublic IsSerial Name BaseType
-------- -------- ---- --------
True     True     Double                                   System.ValueType
````
The ````TotalSeconds```` value is a ````[number]````, and more precisely a long number ````[Double]````


## Step 3 : Convert the number to ````[String]````

and now, we will retransform this to [String] using the method ````.ToString()````


The most common syntax is the following :
````powershell
ToString($Format, $Culture)
````
Ref : https://docs.microsoft.com/fr-fr/dotnet/api/system.object.tostring?view=net-5.0

in action :

````powershell
$Format2 = "N1" # numeric  with 1 décimale
$Culture2 = [CultureInfo]::InvariantCulture
[TimeSpan]::ParseExact($String, $Format, $Culture).TotalSeconds.ToString($Format2, $Culture2)
67.1
# Check the type of the result
[TimeSpan]::ParseExact($String, $Format, $Culture).TotalSeconds.ToString($Format2, $Culture2).GetType()
IsPublic IsSerial Name BaseType
-------- -------- ---- --------
True     True     String                                   System.Object
````

Ok, it is  fine, We have a ````[String]```` again.

## Final Step : Assemble all together now

````powershell
$Csv = @'
Duration
01:23.4
59.29
01:23.2
59.4
59.85
01:23.2
01:37.3
01:30.4
01:20.2
54.46
01:49.3
53.65
01:28.4
53.29
52.55
01:22.9
01:51.1
01:33.1
01:22.6
56.95
01:10.9
01:37.0
57.22
01:11.8
01:36.8
56.52
01:45.4
01:44.5
59.54
01:40.0
01:13.5
58.7
01:07.1
'@ | ConvertFrom-Csv
ForEach ($Item in $Csv)
{
    if ($Item.Duration -match '\d\d:\d\d\.\d') # this is the Regex form for the entry
        {
        $Item.Duration = [TimeSpan]::ParseExact($Item.Duration, 'mm\:ss\.f', [CultureInfo]::InvariantCulture).TotalSeconds.ToString('N1', [CultureInfo]::InvariantCulture)
        }
    $Item.Duration
}
83.4
59.29
83.2
59.4
59.85
83.2
97.3
90.4
80.2
54.46
109.3
53.65
88.4
53.29
52.55
82.9
111.1
93.1
82.6
56.95
70.9
97.0
57.22
71.8
96.8
56.52
105.4
104.5
59.54
100.0
73.5
58.7
67.1
# Check the $Item.Duration type
Item.Duration.GetType()
IsPublic IsSerial Name BaseType
-------- -------- ---- --------
True     True     String  System.Object
````
Yep, It is a ````[string]```` again, cool the goal is achieved !

## Final Word

By this sample, I hope this help readers to understand



[Nota ] : Based on sample on Reddit\Powershell forum :  https://new.reddit.com/r/PowerShell/comments/nkwluo/convert_csv_column_to_seconds/
