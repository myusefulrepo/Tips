# THE CHALLENGE
We have a block of different datas and we would like to separate them.
These datas are separated by space, not tab, not comma, not semi-column`

Like the following example :
````
Event                  Total  Per Sec |Event                  Total  Per Sec

Commits               35768       4.7 |DB Reads              70767       9.4
Undos                     0       0.0 |DB Writes              7838       1.0
Record Reads        2941630     389.6 |BI Reads               4522       0.6
Record Updates         9709       1.3 |BI Writes              7886       1.0
Record Creates         8081       1.1 |AI Writes                 0       0.0
Record Deletes         1050       0.1 |Checkpoints               1       0.0
Record Locks          89751      11.9 |Flushed at chkpt          0       0.0
Record Waits              0       0.0 |Active trans              0
````

# THE SOLUTION : Use REGEX
````powershell
# Put Data in a array variable
$Data = @'
Event                  Total  Per Sec |Event                  Total  Per Sec

Commits               35768       4.7 |DB Reads              70767       9.4
Undos                     0       0.0 |DB Writes              7838       1.0
Record Reads        2941630     389.6 |BI Reads               4522       0.6
Record Updates         9709       1.3 |BI Writes              7886       1.0
Record Creates         8081       1.1 |AI Writes                 0       0.0
Record Deletes         1050       0.1 |Checkpoints               1       0.0
Record Locks          89751      11.9 |Flushed at chkpt          0       0.0
Record Waits              0       0.0 |Active trans              0
'@

# Use regex and feed an PSCustomObject
$Result = [regex]::Matches($Data,'(?<FieldName>\w+(\s\w+)?)\s{2,}(?<Total>(\d|\.)+)\s+(?<PerSec>(\d|\.)+)') |
   ForEach-Object {
        [pscustomobject]@{
        FieldName = $PSItem.Groups.Where({$PSItem.Name -eq 'FieldName'}).Value
        Total = $PSItem.Groups.Where({$PSItem.Name -eq 'Total'}).Value
        PerSec = $PSItem.Groups.Where({$PSItem.Name -eq 'PerSec'}).Value
        }
   }
$Result | sort FieldName
````

The output looks like the following
````powershell
FieldName      Total   PerSec
---------      -----   ------
AI Writes      0       0.0
at chkpt       0       0.0
BI Reads       4522    0.6
BI Writes      7886    1.0
Checkpoints    1       0.0
Commits        35768   4.7
DB Reads       70767   9.4
DB Writes      7838    1.0
Record Creates 8081    1.1
Record Deletes 1050    0.1
Record Locks   89751   11.9
Record Reads   2941630 389.6
Record Updates 9709    1.3
Record Waits   0       0.0
Undos          0       0.0
````

Now examine in details

```` powershell
[regex]::Matches($Data,'(?<FieldName>\w+(\s\w+)?)\s{2,}(?<Total>(\d|\.)+)\s+(?<PerSec>(\d|\.)+)')
````
return
````powershell
Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 80
Length   : 37
Value    : Commits               35768       4.7

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 119
Length   : 37
Value    : DB Reads              70767       9.4

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 158
Length   : 37
Value    : Undos                     0       0.0

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 197
Length   : 37
Value    : DB Writes              7838       1.0

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 236
Length   : 37
Value    : Record Reads        2941630     389.6

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 275
Length   : 37
Value    : BI Reads               4522       0.6

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 314
Length   : 37
Value    : Record Updates         9709       1.3

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 353
Length   : 37
Value    : BI Writes              7886       1.0

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 392
Length   : 37
Value    : Record Creates         8081       1.1

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 431
Length   : 37
Value    : AI Writes                 0       0.0

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 470
Length   : 37
Value    : Record Deletes         1050       0.1

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 509
Length   : 37
Value    : Checkpoints               1       0.0

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 548
Length   : 37
Value    : Record Locks          89751      11.9

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 595
Length   : 29
Value    : at chkpt          0       0.0

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 626
Length   : 37
Value    : Record Waits              0       0.0
````
At this step we have a collection of objects with properties.

Examines this collection
````powershell
$regex = [regex]::Matches($Data,'(?<FieldName>\w+(\s\w+)?)\s{2,}(?<Total>(\d|\.)+)\s+(?<PerSec>(\d|\.)+)')
$regex|Get-Member
   TypeName : System.Text.RegularExpressions.Match

Name        MemberType Definition
----        ---------- ----------
Equals      Method     bool Equals(System.Object obj)
GetHashCode Method     int GetHashCode()
GetType     Method     type GetType()
NextMatch   Method     System.Text.RegularExpressions.Match NextMatch()
Result      Method     string Result(string replacement)
ToString    Method     string ToString()
Captures    Property   System.Text.RegularExpressions.CaptureCollection Captures {get;}
Groups      Property   System.Text.RegularExpressions.GroupCollection Groups {get;}
Index       Property   int Index {get;}
Length      Property   int Length {get;}
Name        Property   string Name {get;}
Success     Property   bool Success {get;}
Value       Property   string Value {get;}
````
Groups is a System.Text.RegularExpressions.GroupCollection, and if we expand the property Groups

````powershell
$regex | Select-Object -ExpandProperty groups
Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 80
Length   : 37
Value    : Commits               35768       4.7

Success  : False
Name     : 1
Captures : {}
Index    : 0
Length   : 0
Value    :

Success  : True
Name     : 2
Captures : {3, 5, 7, 6...}
Index    : 106
Length   : 1
Value    : 8

Success  : True
Name     : 3
Captures : {4, ., 3}
Index    : 116
Length   : 1
Value    : 7

Success  : True
Name     : FieldName
Captures : {FieldName}
Index    : 80
Length   : 7
Value    : Commits

Success  : True
Name     : Total
Captures : {Total}
Index    : 102
Length   : 5
Value    : 35768

Success  : True
Name     : PerSec
Captures : {PerSec}
Index    : 114
Length   : 3
Value    : 4.7

Groups   : {0, 1, 2, 3...}
Success  : True
Name     : 0
Captures : {0}
Index    : 119
Length   : 37
Value    : DB Reads              70767       9.4
...
````
Now we can build a PSCustomObject with 3 properties
````
FieldName = $PSItem.Groups.Where({$PSItem.Name -eq 'FieldName'}).Value
Total = $PSItem.Groups.Where({$PSItem.Name -eq 'Total'}).Value
PerSec = $PSItem.Groups.Where({$PSItem.Name -eq 'PerSec'}).Value
````
Put the result in a variable ($result) ad finally sort the result by the property FieldName
```powershell
$Result = [regex]::Matches($Data,'(?<FieldName>\w+(\s\w+)?)\s{2,}(?<Total>(\d|\.)+)\s+(?<PerSec>(\d|\.)+)') |
   ForEach-Object {
        [pscustomobject]@{
        FieldName = $PSItem.Groups.Where({$PSItem.Name -eq 'FieldName'}).Value
        Total = $PSItem.Groups.Where({$PSItem.Name -eq 'Total'}).Value
        PerSec = $PSItem.Groups.Where({$PSItem.Name -eq 'PerSec'}).Value
        }
   }
$Result | sort FieldName
````
The last line is missing (Active trans              0), I've read replace the multi-spaces with a comma, then the single spaces with an underscore, and then process the line, but i can't do that.

https://www.reddit.com/r/PowerShell/comments/df07tf/need_some_help_splitting_string/
