# How to check if there are new or modified files in a path with a lot of files

This is a big question. Let's go this together.

If I'm using ````Get-ChildItem```` to collect file, and put the result in a var,  this could be a first step.

````powershell
$AllFiles = Get-ChildItem -Path 'C:\temp' -Recurse -File | Select-Object -Property Name, FullName, length, CreationTime
````

Later, I can run the same ````Get-ChildItem```` cmdlet and then I can use the ````Compare-Object```` cmdlet and compare with a specific (or more) property.

````powershell
$AllFiles = Get-ChildItem -Path 'C:\temp' -Recurse -File | Select-Object -Property Name, FullName, length, CreationTime
$AllFiles | Export-csv -Path C:\temp2\RefFile.csv -NoTypeInformation -UseCulture
# creating a newfile, and gather the files again
$CurrentFiles = Get-ChildItem -Path 'C:\temp' -Recurse -File | Select-Object -Property Name, FullName, length, CreationTime
$Ref = Import-Csv -Path C:\temp2\RefFile.csv  -Delimiter ";"
Compare-Object -ReferenceObject $Ref -DifferenceObject $CurrentFiles -Property Name
Name        SideIndicator
----        -------------
Newfile.txt =>
|````

Now I modify an existing file. (just add a single char). and run again

````powershell
$Ref = Import-Csv -Path C:\temp2\RefFile.csv  -Delimiter ";"
Compare-Object -ReferenceObject $Ref -DifferenceObject $CurrentFiles -Property Length
````

This is not a good way in this case. Let's try with ````Get-FileHash```` cmdlet

````powershell
$AllFilesHash = Get-ChildItem -Path 'C:\temp' -Recurse -File |
    Get-FileHash -Algorithm MD5
# export filehash in a file for later use
$AllFilesHash |Export-Csv -Path C:\temp2\FileHashes.csv -UseCulture -NoTypeInformation -Append
````

Modify an existing file or add or delete afile

````powershell
$CurrentHash = Get-FileHash -Path C:\Temp -Algorithm MD5
# looking for new files or modified files based on the fullName
$NewFilesByFullName = Get-ChildItem -Path C:\Temp -Recurse -File |
    Where-Object {$_.FullName -notin $($AllFilesHash.Path)}

Répertoire : C:\Temp


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----       18/06/2020     12:00              0 newfile2.txt
````

Yes, I've grab new files and modified files !

Depending on how many files we need to process, that could get pretty time consuming to gather ````Get-ChildItem```` and ````Get-FileHash````, and this continue increasing as more files get processed.
It could be better like the following and by this respect the rule "filter left, format right" :-)
Like this :

````powershell
Get-ChildItem -Path C:\Temp -Recurse -File -Exclude $($Ref.Name) |
    Get-FileHash -Algorithm MD5
Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
MD5             5058F1AF8388633F609CADB75A75DC9D                                       C:\Temp\Newfile.txt
MD5             D41D8CD98F00B204E9800998ECF8427E                                       C:\Temp\newfile2.txt
````

Is it really efficient ? Let's measure.

````powershell
(Measure-Command -Expression {Get-ChildItem -Path 'C:\temp' -Recurse -File |
    Get-FileHash -Algorithm MD5}).TotalMilliseconds

(Measure-Command -Expression {Get-ChildItem -Path 'C:\temp' -Recurse -File -Exclude $($Ref.Name)  |
    Get-FileHash -Algorithm MD5}).TotalMilliseconds

<#
(Measure-Command -Expression {Get-ChildItem -Path 'C:\temp' -Recurse -File |
    Get-FileHash -Algorithm MD5}).TotalMilliseconds
693,7484

(Measure-Command -Expression {Get-ChildItem -Path 'C:\temp' -Recurse -File -Exclude $($Ref.Name)  |
    Get-FileHash -Algorithm MD5}).TotalMilliseconds
80,0364
#>
````

Nice, consuming time to run is smaller !

Last step, I would like to update my reference file to have only new (modify) entries regularly.

````powershell
$AllFilesHash | Export-Csv -Path "C:\temp2\FileHashes.csv" -UseCulture -NoTypeInformation -Append
$FilesHashes = Import-Csv "C:\temp2\FileHashes.csv" -Delimiter ";"
$CurrentHashes = Get-ChildItem -Path "C:\Temp" -Recurse -File -Exclude $($FilesHashes.path) |
    Get-FileHash -Algorithm MD5
$CurrentHashes | Export-Csv -Path 'D:\MyFileshashes.csv' -UseCulture -NoTypeInformation
````

Hope this helpful.
