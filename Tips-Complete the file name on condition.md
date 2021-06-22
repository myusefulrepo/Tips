# Complete file name on condition

## the objective

We have a collection of files named like IMG1.jpg, IMG2.jpg, ... IMG5085.jpg
We would mike to rename them if the name has less than 6 characters.

i.e. :
Before :  IMG1.jpg - After : IMG000006.jpg

````powershell
Get-ChildItem C:\IMG | ForEach-Object{
    $NewName = ([int]$_.BaseName).PadLeft('6','0') + $_.Extension
    Rename-Item -Path $_.FullName -NewName $NewName
````

## Explanations

We're using the PadLeft Method to returns a new string of a specified length in which the beginning of the current string is padded with spaces or with a specified Unicode character.

[Nota : ] There is another method called PadRight doing a similar job. It's not the answser for the current objective but just to keep in mind for another uses.


Hope this help