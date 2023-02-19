# Play with dates

Through a few exercises, let's learn how to play with dates

## First Look to ````Get-Date```` cmdlet

````powershell
 Get-Date
````
This return the current Date, but let see the properties

````powershell 
Get-Date | Get-Member

   TypeName : System.DateTime

Name                 MemberType     Definition
----                 ----------     ----------
Add                  Method         datetime Add(timespan value)
AddDays              Method         datetime AddDays(double value)
AddHours             Method         datetime AddHours(double value)
AddMilliseconds      Method         datetime AddMilliseconds(double value)
AddMinutes           Method         datetime AddMinutes(double value)
AddMonths            Method         datetime AddMonths(int months)
AddSeconds           Method         datetime AddSeconds(double value)
AddTicks             Method         datetime AddTicks(long value)
AddYears             Method         datetime AddYears(int value)
CompareTo            Method         int CompareTo(System.Object value), int CompareTo(datetime value), int IComparable.CompareTo(System.Object obj), int IComparable[datetime].CompareTo(datetime other)
Equals               Method         bool Equals(System.Object value), bool Equals(datetime value), bool IEquatable[datetime].Equals(datetime other)
GetDateTimeFormats   Method         string[] GetDateTimeFormats(), string[] GetDateTimeFormats(System.IFormatProvider provider), string[] GetDateTimeFormats(char format), string[] GetDateTimeFormats(char format, System.IFormatProvider provider)
GetHashCode          Method         int GetHashCode()
GetObjectData        Method         void ISerializable.GetObjectData(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context)
GetType              Method         type GetType()
GetTypeCode          Method         System.TypeCode GetTypeCode(), System.TypeCode IConvertible.GetTypeCode()
IsDaylightSavingTime Method         bool IsDaylightSavingTime()
Subtract             Method         timespan Subtract(datetime value), datetime Subtract(timespan value)
ToBinary             Method         long ToBinary()
ToBoolean            Method         bool IConvertible.ToBoolean(System.IFormatProvider provider)
ToByte               Method         byte IConvertible.ToByte(System.IFormatProvider provider)
ToChar               Method         char IConvertible.ToChar(System.IFormatProvider provider)
ToDateTime           Method         datetime IConvertible.ToDateTime(System.IFormatProvider provider)
ToDecimal            Method         decimal IConvertible.ToDecimal(System.IFormatProvider provider)
ToDouble             Method         double IConvertible.ToDouble(System.IFormatProvider provider)
ToFileTime           Method         long ToFileTime()
ToFileTimeUtc        Method         long ToFileTimeUtc()
ToInt16              Method         int16 IConvertible.ToInt16(System.IFormatProvider provider)
ToInt32              Method         int IConvertible.ToInt32(System.IFormatProvider provider)
ToInt64              Method         long IConvertible.ToInt64(System.IFormatProvider provider)
ToLocalTime          Method         datetime ToLocalTime()
ToLongDateString     Method         string ToLongDateString()
ToLongTimeString     Method         string ToLongTimeString()
ToOADate             Method         double ToOADate()
ToSByte              Method         sbyte IConvertible.ToSByte(System.IFormatProvider provider)
ToShortDateString    Method         string ToShortDateString()
ToShortTimeString    Method         string ToShortTimeString()
ToSingle             Method         float IConvertible.ToSingle(System.IFormatProvider provider)
ToString             Method         string ToString(), string ToString(string format), string ToString(System.IFormatProvider provider), string ToString(string format, System.IFormatProvider provider), string IFormattable.ToString(string format, System.IFo... 
ToType               Method         System.Object IConvertible.ToType(type conversionType, System.IFormatProvider provider)
ToUInt16             Method         uint16 IConvertible.ToUInt16(System.IFormatProvider provider)
ToUInt32             Method         uint32 IConvertible.ToUInt32(System.IFormatProvider provider)
ToUInt64             Method         uint64 IConvertible.ToUInt64(System.IFormatProvider provider)
ToUniversalTime      Method         datetime ToUniversalTime()
DisplayHint          NoteProperty   DisplayHintType DisplayHint=DateTime
Date                 Property       datetime Date {get;}
Day                  Property       int Day {get;}
DayOfWeek            Property       System.DayOfWeek DayOfWeek {get;}
DayOfYear            Property       int DayOfYear {get;}
Hour                 Property       int Hour {get;}
Kind                 Property       System.DateTimeKind Kind {get;}
Millisecond          Property       int Millisecond {get;}
Minute               Property       int Minute {get;}
Month                Property       int Month {get;}
Second               Property       int Second {get;}
Ticks                Property       long Ticks {get;}
TimeOfDay            Property       timespan TimeOfDay {get;}
Year                 Property       int Year {get;}
DateTime             ScriptProperty System.Object DateTime {get=if ((& { Set-StrictMode -Version 1; $this.DisplayHint }) -ieq  "Date")...
````
Lot of properties, and some very interesting Methods. 


````Powershell 
Get-Date
dimanche 19 février 2023 10:39:42

(Get-Date).AddDays(-5) # Add or remove days to a date
mardi 14 février 2023 10:39:35

(Get-Date).DayOfWeek # returns the name of the Day
Sunday
````
The Method ````-AddDays()```` add or minus the date being processed. 
We could use ````Get-Date | Select-Object -ExpandProperty DayOfWeek````, but the previous command is shorter. 


## Get the first Day on month
This first exercice is very simple to do.

````powershell 
$Date = Get-Date
# Gathering the first Day of month for $Date
Get-Date -Date $Date -Day 1
mercredi 1 février 2023 10:34:15
````

Simple isn't it ! Now build a advanced function to do this. 

**Specifications :**

- [X] : We could use the function with any date or the current date
- [X] : The function must accept Value from Pipeline 

````Powershell 
function Get-StartOfMonth
{
    [CmdletBinding()]
    [OutputType([DateTime])]
    Param(
        [Parameter(Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [DateTime]$Date
    )
    Process
    {
        if (-Not $Date)
        {
            $Date = Get-Date
        }
        return (Get-Date $date -Day 1 -Hour 0 -Minute 0 -Second 0).Date
    }
}
````

**In action :**

````Powershell
Get-StartOfMonth
mercredi 1 février 2023 00:00:00

Get-StartOfMonth -Date (Get-Date -Day 30 -Month 11 -Year 2023)
mercredi 1 novembre 2023 00:00:00
````

Pershaps, you may be wondering why I didn't enter a date directly behind the ````-Date```` parameter ? In order to avoid any error (I'm not on an OS in En-US culture, and the dates are generally in the form *dd/MM/YYYY*)

## Get the last Day of month
This second exercice is simple too, but it requires a little thought to determine how to get to the target.

````powershell 
$Date = Get-Date
$StartOfMonth = Get-Date $Date -Day 1 -Hour 0 -Minute 0 -Second 0
$StartOfMonth
mercredi 1 février 2023 00:00:00
# And now let's add a month, then remove a second to return to the current month
($StartOfmonth).AddMonths(1).AddSeconds(-1))
mercredi 1 mars 2023 23:59:59
````

[Nota] : In my sample I passed as a parameter -Hour -Minute and -Second. It's not mandatory, If not defined, the Time returned will be the Time of the ````$Date ````variable.

Simple isn't it ! Now build a advanced function to do this. 

**Specifications :**
- [X] : We could use the function with any date or the current date
- [X] : The function must accept Value from Pipeline

````powershell
function Get-EndOfMonth
{
    [CmdletBinding()]
    [OutputType([DateTime])]
    Param(
        [Parameter(Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [DateTime]$Date
    )
    Process
    {
        if (-Not $Date)
        {
            $Date = Get-Date
        }
        $StartOfMonth = Get-Date $Date -Day 1
        return (($StartOfmonth).AddMonths(1).AddSeconds(-1)).Date
    }
}
````

**In action :**

````Powershell
Get-EndOfMonth
mercredi 1 mars 2023 00:00:00

Get-EndOfMonth -Date (Get-Date -Date 30/06/2023)
vendredi 30 juin 2023 00:00:00
````

## Get Tuesday Patch

The day called ***Tuesday Patch*** is defined by Microsoft as the 2nd tuesday of the month.

the whole difficulty is to determine this day.
- We already know how to determine the 1st day of the month, using ````-Day 1```` parameter
- We also know how to identify the name of this first day of the month using the property ````DayOfWeek````
- We also know how to increment a date using the method ````AddDays()````
- If we increment the date from the first day of the month until we have a date whose name is Tuesday, we will have identified the 1st Tuesday of the month, using a ````While```` Loop
- All that remains is to increment by 7 days to obtain the 2nd Tuesday of the month using the method ````AddDays()````

let's put it all together, and go directly to the advanced function

**Specifications :**
- [X] : We could use the function with any date or the current date
- [X] : The function must accept Value from Pipeline
- [X] : let's stay flexible, and make sure that the name of the day (Tuesday) and the week (2) can be changed if necessary


````powershell
Function Get-PatchTuesday
{
    [CmdletBinding()]
    [OutputType([DateTime])]
    Param
    (
        [Parameter(position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [DateTime]$Date,

        [Parameter(position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')]
        [String]$PatchDay = 'Tuesday',

        [Parameter(position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, 5)]
        [int]$WeekOfMonth = 2
    )

    Process
    {
        if (-Not $Date)
        {
            $Date = Get-Date
        }

        # Determining first day of month
        [datetime]$FirstDayOfMonth = Get-Date -Date $Date -Day 1

        # Determining the 1st day of the month that has the name of the day we are looking for
        while ($FirstDayOfMonth.DayofWeek -ine $PatchDay ) 
        {
            # We add a day ... until we find the name of the day we are looking for
            $FirstDayOfMonth = $FirstDayOfMonth.AddDays(1)
        }
        $FirstDayName = $FirstDayOfMonth

        # Identify and calculate of the day offset
        if ($WeekOfMonth -eq 1) 
        {
            $Offset = 0
        }
        else 
        {
            $Offset = ($WeekOfMonth - 1) * 7
        }

        # Return date of the day/instance specified
        $PatchTuesday = $FirstDayName.AddDays($Offset) 
        return $PatchTuesday
    }
}
````

**In action :** 

````powershell 
Get-PatchTuesday
mardi 14 février 2023 11:38:01

Get-PatchTuesday -Date (Get-Date -Year 2023 -Month 06)
mardi 13 juin 2023 11:38:24
````

# Final word

Through these examples in increasing difficulty, you have seen how we can play with dates.

As far as advanced functions are concerned, it is important 
- to clearly define the goal to be achieved before even starting to code, 
- to name the variables with names representative of their content, 
- and to respect the Powershell Best-Practices as a minimum (The **PSScriptAnalyzer** Module can help to do this).

Hope this help