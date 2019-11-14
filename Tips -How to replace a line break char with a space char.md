# The Problem
A existing file is like the followwing
````powershell
Get-Content -Path C:\Temp\test.txt
a
b
c
d
`````

I would like to transform it like this
````powershell
a b c d
````
# First way : use ````-replace````
````powershell
 (Get-Content C:\Temp\test.txt -Raw) -replace '\r\n', ' '
a b c d
# And now update the file
(Get-Content C:\Temp\test.txt -Raw) -replace '\r\n', ' ' | Set-Content -Path c:\temp\Test.txt
````
>[Explanation] : the ````-Raw```` flag with ````Get-Content````, separates by default the lines into an array of strings, so you never see the new line char.


# 2nd way : use the ````-join```` operator
By omitting ````-Raw````, ````Get-Content```` returns an *array of strings* by default which allows you to use the ````-join```` operator.
````powershell
(Get-Content C:\Temp\test.txt) -join ' '
a b c d
# And now update the file
(Get-Content C:\Temp\test.txt) -join ' ' | Set-Content -Path c:\temp\Test.txt
````
Remember that the end of a line consists of both a new line and a character return (\n and \r respectively). You need to account for both.