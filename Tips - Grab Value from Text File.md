# THE PROBLEM
How to Grab Value from Text File

# THE SAMPLE
I have a large text file that am I'm trying to grab values
I've got this small snippet that grabs the 'User' line from the text file which narrows it down but I've been playing with Get-Content and substrings need a little help grabbing the license and total licenses in use. The goal here is to get a historical look at network license usage on a AutoCAD License server.


````
-----------SAMPLE TEXT FILE -------------------------------------------------------------
Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)

  "87224ACD_2020_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  vendor_string: commercial:extendable
  floating license

pav2 PAV2LT PAV2LT (v1.0) (WSERVICES/27000 1403), start Tue 10/15 8:50

Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)

  "87084ACD_2019_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  vendor_string: commercial:extendable
  floating license

mjd5 MJD5LT MJD5LT (v1.0) (WSERVICES/27000 2003), start Tue 10/15 9:03

Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)

  "86830ACD_2018_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  vendor_string: commercial:extendable
  floating license

ajf1 AJF1LT AJF1LT (v1.0) (WSERVICES/27000 1002), start Tue 10/15 10:50
dcj1 DCJ1TBL DCJ1TBL (v1.0) (WSERVICES/27000 2202), start Tue 10/15 12:11

Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)
-----------SAMPLE TEXT FILE -------------------------------------------------------------
````


# 1 - USING `REGEX`
Consider that I have the data in an input.txt file

````powershell
$result = Get-Content '.\input.txt' |
     Where-Object { $_ -match 'Users of (?<ProductID>\w+):  \(Total of (?<Total>\d+) licenses? issued;  Total of (?<InUse>\d+) licenses? in use\)' } |
     ForEach-Object {
        [PSCustomObject] @{
            'ProductID' = $Matches['ProductID']
            'Total' = $Matches['Total']
            'InUse' = $Matches['InUse']
        }
     }
 $result | Export-Csv '.\output.csv' -NoTypeInformation
````
Output in console looks like this
````powershell
ProductID        Total InUse
---------        ----- -----
87224ACD_2020_0F 16    1
87084ACD_2019_0F 16    1
86830ACD_2018_0F 16    2
86604ACD_2017_0F 16    0
````
Output in the .csv file looks like this :
`````
"ProductID","Total","InUse"
"87224ACD_2020_0F","16","1"
"87084ACD_2019_0F","16","1"
"86830ACD_2018_0F","16","2"
"86604ACD_2017_0F","16","0"
`````
## REGEX Explanations :
(?<groupname>) : This settings if to create a named capture group
\w : Match any word character (letters and numbers). This is roughly equivalent to [a-zA-Z_0-9] but will also match foreign letters with accents : (áåäæçèπΈψ etc) but not unicode symbols or punctuation.
\d+ : Match any decimal digit. This is equivalent to \p{Nd} for Unicode and [0-9] for non-Unicode

## Other explanations
Create and PSCustomObject that contains the properties of the automatic variable $Match ($match contains the result of the match)
Finally export the result in a .csv file

## Comments
|pros |cons
|:---------------------------------------:| :------------------------------:
| Clearly the result is clean.| Not so easy to set Regex
| It's very easy to use the export file |


# 2 - USING `ConvertFrom-String -TemplateContent`
for this sample, I've put the date in a `Here-String` but it's also possible to use `Get-Content` like the previous sample.
````powershell
$SrcData = @'
Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)

  "87224ACD_2020_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  vendor_string: commercial:extendable
  floating license

    pav2 PAV2LT PAV2LT (v1.0) (WSERVICES/27000 1403), start Tue 10/15 8:50

Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)

  "87084ACD_2019_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  vendor_string: commercial:extendable
  floating license

    mjd5 MJD5LT MJD5LT (v1.0) (WSERVICES/27000 2003), start Tue 10/15 9:03

Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)

  "86830ACD_2018_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  vendor_string: commercial:extendable
  floating license

    ajf1 AJF1LT AJF1LT (v1.0) (WSERVICES/27000 1002), start Tue 10/15 10:50
    dcj1 DCJ1TBL DCJ1TBL (v1.0) (WSERVICES/27000 2202), start Tue 10/15 12:11

Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)
'@

# Define a template
$Template = @'
Users of {ProductID*:86604ACD_2017_0F}:  (Total of {Total:16} licenses issued;  Total of {InUse:0} license in use)
Users of {ProductID*:87084ACD_2019_0F}:  (Total of {Total:16} licenses issued;  Total of {InUse:1} license in use)
'@

$result = $SrcData | ConvertFrom-String -TemplateContent $Template
````
Output in console looks like this
````powershell
ProductID        Total InUse
---------        ----- -----
87224ACD_2020_0F 16    1
87084ACD_2019_0F 16    1
86830ACD_2018_0F 16    2
86604ACD_2017_0F 16    0
````
Output in the .csv file looks like this :
`````
"ProductID","Total","InUse"
"87224ACD_2020_0F","16","1"
"87084ACD_2019_0F","16","1"
"86830ACD_2018_0F","16","2"
"86604ACD_2017_0F","16","0"
`````

## Comments
|pros |cons
|:---------------------------------------:| :------------------------------:
| It works well if we take at least 2 examples to forge the template | I am still searching
| Easy to understand and to use |


# 3 - SEARCH STRING WITH `Get-Content`
````powershell
$Result = Get-Content -Path '.\input.txt' | Where-Object {$_ -like "Users of *"}
$result | Export-Csv '.\output.csv' -NoTypeInformation
````
The output in console is like the following
````
Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)
Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)
````
Output in the .csv file looks like this :
````
"PSPath";"PSParentPath";"PSChildName";"PSDrive";"PSProvider";"ReadCount";"Length"
"C:\Temp\input.txt";"C:\Temp";"input.txt";"C";"Microsoft.PowerShell.Core\FileSystem";"1";"85"
"C:\Temp\input.txt";"C:\Temp";"input.txt";"C";"Microsoft.PowerShell.Core\FileSystem";"9";"85"
"C:\Temp\input.txt";"C:\Temp";"input.txt";"C";"Microsoft.PowerShell.Core\FileSystem";"17";"86"
"C:\Temp\input.txt";"C:\Temp";"input.txt";"C";"Microsoft.PowerShell.Core\FileSystem";"26";"86"
````
## Explanations
Output in console returns the information we're looking for, but export in a file not.

## Comments

|pros |cons
|:---------------------------------------:| :------------------------------:
| Simple to use for a console output only | export in a .csv file : Goal not achieved


# 4 - SEARCH STRING with `Select-String`
````powershell
Select-String "Users of 8"  C:\Temp\text.txt
````
The output in console is like the following
````
text.txt:1:Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
text.txt:9:Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
text.txt:17:Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)
text.txt:26:Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)
````
As we can see, this return line and string that match by default
Then complete the code
````powershell
$result = Select-String "Users of 8" '.\input.txt' | Select-Object -Property LineNumber, Line
$result | Export-Csv -Path '.\output.csv'
````
The Output is like the following
````
"LineNumber";"Line"
"1";"Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)"
"9";"Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)"
"17";"Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)"
"26";"Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)"
````
>[Nota] : if you search in several files, it could be useful to return the file name. In this case, add the property `FileName` or the property `Path`


## Explanations
The `Select-String` cmdlet searches for text and text patterns in input strings and files.

## Comments
|pros |cons
|:---------------------------------------:| :------------------------------:
| Simple to use | ProductID, Total, In Use are not separated
| run fine to search for a text in a bunch of files |
| return line number

## Other use of `Select-String` cmdlet
````powershell
Select-String -Pattern "users of "  '.\input.txt' -Context 0,3
text.txt:1:Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
  text.txt:2:
  text.txt:3:  "87224ACD_2020_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  text.txt:4:  vendor_string: commercial:extendable
> text.txt:9:Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
  text.txt:10:
  text.txt:11:  "87084ACD_2019_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  text.txt:12:  vendor_string: commercial:extendable
> text.txt:17:Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)
  text.txt:18:
  text.txt:19:  "86830ACD_2018_0F" v1.000, vendor: adskflex, expiry: 21-jul-2022
  text.txt:20:  vendor_string: commercial:extendable
> text.txt:26:Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)
````
Captures the specified number of lines before and after the line with the match. This allows you to view the match in context..
If you enter one number as the value of this parameter, that number determines the number of lines captured before and after the match. If you enter two numbers as the value, the first number determines the number of lines before the match and the second number determines the number of lines after the match.
        0,3 means 0 line before ans 3 lines after.

# 4 - SEARCH STRING with `Select-String` and REGEX
This cmdlet `Select-String` also accepts Regex expression as InputObject
````powershell
$Result = Select-String -Pattern 'Users of (?<ProductID>\w+):  \(Total of (?<Total>\d+) licenses? issued;  Total of (?<InUse>\d+) licenses? in use\)' '.\input.txt'
$result | Export-Csv -Path '.\output.csv'
````
The output in console will be like this
````
input.txt:1:Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
input.txt:9:Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
input.txt:17:Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)
input.txt:26:Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)
````
The output in .csv file will be :
````
"IgnoreCase";"LineNumber";"Line";"Filename";"Path";"Pattern";"Context";"Matches"
"True";"1";"Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)";"input.txt";"C:\Temp\input.txt";"Users of (?<ProductID>\w+):  \(Total of (?<Total>\d+) licenses? issued;  Total of (?<InUse>\d+) licenses? in use\)";;"System.Text.RegularExpressions.Match[]"
"True";"9";"Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)";"input.txt";"C:\Temp\input.txt";"Users of (?<ProductID>\w+):  \(Total of (?<Total>\d+) licenses? issued;  Total of (?<InUse>\d+) licenses? in use\)";;"System.Text.RegularExpressions.Match[]"
"True";"17";"Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)";"input.txt";"C:\Temp\input.txt";"Users of (?<ProductID>\w+):  \(Total of (?<Total>\d+) licenses? issued;  Total of (?<InUse>\d+) licenses? in use\)";;"System.Text.RegularExpressions.Match[]"
"True";"26";"Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)";"input.txt";"C:\Temp\input.txt";"Users of (?<ProductID>\w+):  \(Total of (?<Total>\d+) licenses? issued;  Total of (?<InUse>\d+) licenses? in use\)";;"System.Text.RegularExpressions.Match[]"
````
So, Affine the query like this
````powershell
$result = Select-String -Pattern 'Users of (?<ProductID>\w+):  \(Total of (?<Total>\d+) licenses? issued;  Total of (?<InUse>\d+) licenses? in use\)' '.\input.txt' |
            Select-Object -Property lineNumber, Line

$result | Export-Csv -Path '.\output.csv'
````
The Output in cosole is like this :
`
LineNumber Line
---------- ----
         1 Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
         9 Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)
        17 Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)
        26 Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)
`
and the output in .csv file is like :
`
"LineNumber";"Line"
"1";"Users of 87224ACD_2020_0F:  (Total of 16 licenses issued;  Total of 1 license in use)"
"9";"Users of 87084ACD_2019_0F:  (Total of 16 licenses issued;  Total of 1 license in use)"
"17";"Users of 86830ACD_2018_0F:  (Total of 16 licenses issued;  Total of 2 licenses in use)"
"26";"Users of 86604ACD_2017_0F:  (Total of 16 licenses issued;  Total of 0 licenses in use)"
`
## Explanations
The `Select-String` cmdlet searches for text and text patterns in input strings and files.

## Comments
|pros |cons
|:---------------------------------------:| :------------------------------:
| run fine to search for a text in a bunch of files | ProductID, Total, In Use are not separated
| return line number | Not so easy to set Regex


# SYNTHESIS
There are many ways to search for text in one (or more) file. The choice of a solution or another will ultimately depend on the subsequent operation will be done with the result ... and also your knowledge of powershell and regex


 For the present case, the use of `ConvertFrom-String -TemplateContent` is certainly the simplest way to do.
