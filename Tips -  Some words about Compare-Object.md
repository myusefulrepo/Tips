
# Some words about ````Compare-Object````

## Compare-Object not working if I don't list the properties

if you don't specify the ````-Property```` parameter, ````Compare-Object```` doesn't compare all properties, it compares the results of invoking the ````.ToString()```` method on both objects. So, ````Compare-Object $DataTable $DataTable2```` compares ````$DataTable1.ToString()```` with ````$DataTable1.ToString()````. The ````.ToString()```` method returns an empty string when invoked on a DataTable object, so there is no difference to report.

For example:

````powershell
$file1 = Get-Item somefilename
$file1 = Get-Item anotherfilename
Compare-Object $file1 $file2
````

This will return the difference between the full paths of the two files, like this:

````powershell
InputObject              SideIndicator
---------- - ------------ -
<path>\anotherfilename   =>
<path>\somefilename      <=
````

That's because invoking ````.ToString()```` on a FileInfo object returns its FullName property, so you're comparing the files's full path names.

Although the ````-Property```` parameter accepts multiple properties, listing all the properties is not the solution. Aside from being very tedious, it will not give you the results you want. If you list multiple properties, ````Compare-Object```` compares the ***combination of all the properties***, and if any one of the listed properties is different, it returns a result showing all the listed properties (both ones that are the same and ones that are different) as a single difference.

What you need to do is iterate over a list of properties, and invoke ````Compare-Object```` once for each property:

````powershell
$properties = ($DataTable | Get-Member -MemberType Property | Select-Object -ExpandProperty Name)
foreach ($property in $properties) {
  Compare-Object $DataTable $DataTable2 -Property "$property" | Format-Table -AutoSize
}
````

In most cases, when comparing all properties of two objects, you'd want to use ````Get-Member -MemberType```` Properties, in order to get cover all property types. However, if you're comparing DataTable objects, you're better off using ````Get-Member -MemberType Property```` so that you're comparing only the properties corresponding to data fields, not other properties of the DataTable objects that have nothing to do with the data.

This is written assuming that ***the number of columns is the same***, as you stated, ***or at least that the number of columns in $DataTable2 doesn't exceed the number of columns in $DataTable***.

If you can't reliably assume that, derive the $properties array from whichever one has more columns, by comparing ````($DataTable | Get-Member -MemberType Property).Count```` with ````($DataTable2 | Get-Member -MemberType Property).Count```` and using the properties from whichever is greater.

Using ````Format-Table```` is important, it's not just there to make things look pretty. If you list multiple objects of the same type (in this case, arrays), PowerShell remembers the format of the first object, and uses it for all subsequent objects, unless you explicitly specify a format. Since the name of the first column will be different for each property (i.e., each column from the spreadsheet), the first column will be empty for all but the first difference encountered.

The ````-AutoSize```` switch is optional. That is there just to make things look pretty. But you must pipe the results to a formatting filter. You can also use ````Format-List```` if you prefer.

Ref. Source : <https://stackoverflow.com/questions/18259861/compare-object-not-working-if-i-dont-list-the-properties> from mklement0

## ````Compare-Object```` with ````Get-Content```` of .txt files

````powershell
$ref = Get-Content C:\Temp\37896.txt
$new = Get-Content C:\temp\41553.txt
Compare-Object -ReferenceObject $ref -DifferenceObject $new
````

This returns, that expected : comparing content of the 2 files

````powershell
InputObject             SideIndicator
-----------             -------------
Just a simple demo file <=
````

## ````Compare-Object```` with ````Import-Csv```` of .csv files

````powershell
$ref = Import-Csv -Path C:\Temp\csv1.csv
$ref

Autre  ID
-----  --
sefsdf 1
fsgsdg 2
rgerg  3
$new = Import-Csv  -Path C:\temp\csv2.csv
$new

Autre  ID
-----  --
sefsdf 1
fsgsdg 4
rgerg  5
Compare-Object -ReferenceObject $ref -DifferenceObject $new -Property ID
ID SideIndicator
-- -------------
4  =>
5  =>
2  <=
3  <=
````

As we can see, this returns the expected result, because we've compared a specific property


Hope this help
