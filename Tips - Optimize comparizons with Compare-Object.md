# OBJECTIVE
The Objective of this Tip is to demonstrate with samples how fast the cmdlet Compare-Object running Fast and can help to save time


# Compare 2 trees and do-something (i.e. sync 2 directories)
````powershell
$Folder1Path = 'C:\temp'
$Folder2Path = 'C:\temp2'

$Folder1Files = Get-ChildItem -Path $Folder1Path -Recurse | Select-Object -Property Name, FullName
Write-Host "Files count in $folder1Path : $($Folder1Files.count)" -ForegroundColor Green

$Folder2Files = Get-ChildItem -Path $Folder2Path -Recurse | Select-Object -Property Name, FullName
Write-Host "Files count in $folder2Path : $($Folder2Files.count)" -ForegroundColor Green

$FileDiffs = Compare-Object -ReferenceObject $Folder1Files -DifferenceObject $Folder2Files -Property Name -PassThru
Write-Host "Count Different Files : $($fileDiffs.count)" -ForegroundColor Green
````

As we can see there are some files to add in the Destination folder and some files that doesn't exist in the Reference Folder
***How long does it take ?***
````powershell
$CompareFilesToSync = Measure-Command -Expression {
    Compare-Object -ReferenceObject $Folder1Files -DifferenceObject $Folder2Files -Property Name -PassThru
}
Write-Host "Running time to compare files in $folder1Path and $Folder2Path : $($CompareFilesToSync.TotalMilliseconds) ms" -ForegroundColor Green
````
How fast is the cmdlet Compare-Object

# Discussion
As we could see, only some few differences. Ok, I know that this 2 trees contains few files.
I want to draw your attention on one important thing. If after this comparison you want to do-something, with a foreach loop,
it will take a shorter time, because foreach run sequentially ... and sometime it will take a long time to run.

i.e. : I would like to feed a big AD Security Group with a ref. list of member (located in a .csv file with 10 000 members. It's not surrealist,this case exists in the real life)
1 - If I perform a foreach loop with the following :
````powershell
			Add-ADGroupMember -Identity GroupIdentity -Member $Member
````
- It take a long time (depending of the ref list)
- but the goal is not achieved (what about the excess members ? )

2 - If I perform 2 foreach loop with the following :
````powershell
			Remove-ADGroupMember -Identity GroupIdentity -Member $Member
			Add-ADGroupMember -Identity GroupIdentity -Member $Member
````
- the goal is achieved but the running time is doubled

Then the best solution - from my point of view - is to minimize the actions do perform in the foreach loop.
As we can see in my previous object, only few differences.
And believe me, in the most cases, it will be the same. Find an another way to compare faster if you can. I'll take it.

# How to proceed with compare-Object
## Process with one loop and 2 conditional actions (If)
````powershell
$RunningTimeToSync = Measure-Command -Expression {
    foreach ($file in $FileDiffs)
    {
        if ($file.SideIndicator -eq '=>')
        {
            Copy-Item -Path ($file.FullName) -Destination (Join-Path -Path $Folder1Path -ChildPath ($file.name))
        }
        else
        {
            Copy-Item -Path ($file.FullName) -Destination (Join-Path -Path $Folder2Path -ChildPath ($File.name))
        }
    }
}
Write-Host "Running time to sync : $($RunningTimeToSync.Totalseconds) seconds" -ForegroundColor Green

Write-Host "Check if all is allright" -ForegroundColor Yellow
$Folder1Files = Get-ChildItem -Path $Folder1Path -Recurse | Select-Object -Property Name, FullName
Write-Host "Count file in $folder1Path : $($Folder1Files.Count)" -ForegroundColor Green
$Folder2Files = Get-ChildItem -Path $Folder2Path -Recurse | Select-Object -Property Name, FullName
Write-Host "Count file in $folder2Path : $($Folder2Files.Count)" -ForegroundColor Green
$FileDiffs = Compare-Object -ReferenceObject $Folder1Files -DifferenceObject $Folder2Files -Property Name -PassThru
Write-Host "Count different files :  $($FileDiffs.count)" -ForegroundColor Green
````
# Another case : using 2 trees with thousand files with Compare-Object and Get-Hash
````powershell
$Folder1Path = 'C:\temp'
$Folder2Path = 'C:\temp3'
$Folder1Hash = Get-ChildItem  -Path $Folder1Path -Recurse |
    ForEach {Get-FileHash -Path $_.FullName}
$Folder1Hash
````
The result looks like this :
````powershell
Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
SHA256          63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE       C:\temp\13-sdsdg642.txt
SHA256          63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE       C:\temp\37896.txt
SHA256          63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE       C:\temp\41553.txt
SHA256          63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE       C:\temp\42258.txt
SHA256          63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE       C:\temp\44056.txt
SHA256          63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE       C:\temp\52830.t
...
````
Now running the same on Target folder
````powershell
$Folder2Hash = Get-ChildItem  -Path $Folder2path -Recurse |
    ForEach {Get-FileHash -Path $_.FullName}
$Folder2Hash
````
The result looks like this :
````powershell
Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
SHA256          E41F95A31BAE8AB92F1172F14D70A6565FF5217CDB48DD53B3016CDF0710B105       C:\temp3\FilesToChangeTime_20191012_185616_979.csv
SHA256          87D12423A52CDC2E56BF149B6D155CA1A041A6EA94A3505F2096CA265FDFFEA4       C:\temp3\log.log
SHA256          E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855       C:\temp3\Nouveau document texte.txt
SHA256          BC87639E56FA10AC318C96B372208644BB1A2D183E028965AB9F9AABA37CCD27       C:\temp3\onlyinTemp3.txt
...
````
And now compare with `Compare-Object`
````powershell
$FileExistingOnlyInFolder1Path = (Compare-Object -ReferenceObject $Folder1Hash -DifferenceObject $Folder2Hash -Property hash -PassThru | Where-Object {$_.SideIndicator -eq '<=' }).Path
````
>[Nota 1] : Explanation - Using `Compare Object` with the Property `Hash`, pass the result to the next cmdlet with `-Passthru`, filter with the property `SideIndicator` and finally return only the property `Path`
> Note that this property is not displayed with this cmdline `Compare-Object -ReferenceObject $Folder1Hash -DifferenceObject $Folder2Hash -Property hash -PassThru` but it is present

let's see this :
````powershell
Compare-Object -ReferenceObject $Folder1Hash -DifferenceObject $Folder2Hash -Property hash -PassThru | Select-Object -Property *
Algorithm Hash                                                             Path                                                                SideIndicator
--------- ----                                                             ----                                                                -------------
SHA256    BC87639E56FA10AC318C96B372208644BB1A2D183E028965AB9F9AABA37CCD27 C:\temp3\onlyinTemp3.txt                                            =>
SHA256    925C5C6E391FA6C8D8B90325B26987098D7D9598E3C535FC760B3F7E5D7F357F C:\temp3\onlyinTemp3.xlsx                                           =>
SHA256    63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE C:\temp\13-sdsdg642.txt                                             <=
SHA256    63E4C2487830AD754F5ED23A0116015F8DDBB034C204333ADF5B6BE17F867DDE C:\temp\37896.txt                                                   <=
...
````

OK, Let's continue
The result looks like this :
````powershell
$FileExistingOnlyInFolder1Path
C:\temp\13-sdsdg642.txt
C:\temp\37896.txt
C:\temp\41553.txt
C:\temp\42258.txt
C:\temp\44056.txt
C:\temp\52830.txt
C:\temp\59790.txt
...
````powershell
and now the same thing in the other direction
````powershell
$FileExistingOnlyInFolder2Path = (Compare-Object -ReferenceObject $Folder1Hash -DifferenceObject $Folder2Hash -Property hash -PassThru | Where-Object {$_.SideIndicator -eq '=>' }).Path
$FileExistingOnlyInFolder2Path
````
The result looks like this :
````powershell
$FileExistingOnlyInFolder2Path
C:\temp3\onlyinTemp3.txt
C:\temp3\onlyinTemp3.xlsx
````
Only 2 files existing only in the target Directory

>[Nota 2] Using `Compare-Objet` is a very fast task.

>[Nota 3] For my test, I've created a empty text file only in the Target directory, but this file didn't appear in the $FileExistingOnlyInFolder2Path variable
> Why ? Remember that we've **compared hash, not file names**. There was also an empty text file in the source directory, so with the same hash. I added a few characters to the target folder file and it came out well in the result

Now, the last step is to copy extra files in Folder1 to folder2 and copy extra Files in folder2 to Folder1
````powershell
foreach ($file in $FileExistingOnlyInFolder1Path)
    {
    Copy-Item -Path $file -Destination $Folder2Path
    }
````
and in the other direction
````powershell
foreach ($file in $FileExistingOnlyInFolder2Path)
    {
    Copy-Item -Path $file -Destination $Folder1Path
    }
````

- Few files to copy ==> Very fast task
- guarantee to have all files even if the names are different

I've tested this on 2 folders with thousand image files (photos), with 2 main objectives
- Identify in each folder duplicate files (same content, but naming different), and delete one of the duplicate files : Compare the Hash is the only way to do this
- And in a second Step, Sync the 2 directory. I could not rely on the name of the file because then I would have no guarantee that the content was the same (which was the primary goal. In fact, the file name was really only a few importance to the owner)


Hope this is useful
