# THE PROBLEM
In a folder we have a bunch of files. Theses files are part of video movies and the different parts of the same movie begin by the same number 1, 2, 3, ...)

i.e. :
01-movieABC-Part1.xxx - 01-movieABC-Part2.xxx - 01-movieABC-Part3.xxx ... are part from the same video file.
02-movieXYZ-Part1.xxx - 02-movieXYZ-Part2.xxx - 02-movieXYZ-Part3.xxx ... are part from another video file

Question from a Reddit user I answered.

# THE QUESTION
**How to move these files to another folder with sub-folders named by the number ?**

# THE SOLUTION
Of course the solution is to use some lines of powershell to do this.

## First Step : Define some variables
Cause, you know, as every good admin, I'm a lazy man. :-)
````powershell
$TargetFolder = "C:\Temp2"      # Path where the files will be moved
$SuffixForFolder = "Lectures"   # Suffix for the Target subfolders (Naming convention)
$NbrFoldersToCreate = "45"      # Number of folders to create
$PathToFiles = "c:\temp"        # Path where are currently located videos files before moving them
````
>|Nota] About the naming convention : All the Target sub-folders will be like this : `01-lectures`, `02-Lectures`, `03-Lectures`
> But, you can choose every naming convention you want according to your need


## Second Step : Creating the Target folders
````powershell
1..$NbrFoldersToCreate |
    foreach {
            New-Item -Path $TargetFolder\$_-$SuffixForFolder -ItemType Directory
            }
````
Add at the end `| Out-Null` if you won't any output in console

>[Nota] : And now, do you understand why i've defined some variables in the beginning ? :-)

## Third Step : Gather the list of file and Moving them to the corresponding folder
````Powershell
# Gather the list of files
$Files = Get-ChildItem -Path $PathToFiles -File
````
Collecting only files, use `-recurse` only if you have sub-folders on the current path

# And now moving
````powershell
foreach ($file in $files)
    {
    $begin = ($file.Name).Split('-')[0]
    # At this step we have identified the beginning of the file, then we can move it easily to the appropriate folder
    Move-Item -Path $file.FullName -Destination "$TargetFolder\$begin-$SuffixForFolder"
    Write-Host "$($file.FullName)" -ForegroundColor Yellow -NoNewline
    Write-Host " has been moved to " -ForegroundColor Green -NoNewline
    Write-Host "$TargetFolder\$begin-$SuffixForFolder" -ForegroundColor Yellow
    }
Write-Host "All files in" -ForegroundColor Cyan -NoNewline
Write-Host " $PathToFiles " -ForegroundColor Magenta -NoNewline
Write-Host "has been moved to "-ForegroundColor Cyan -NoNewline
Write-Host "$TargetFolder" -ForegroundColor Magenta
````
Explanations :
    Extracting the first letter/number of the name.
    Assume that the file are named like this : 11-textQFF. Modify to the need if necessary
    `($file.Name).Split('-')[0]` : This return only fist part separate by the split character `-` then this return only the number

>[Nota] : I used Write-Host to have a nice presentation in the console. If this should be planned, it isn't in the best-practices to use this cmdlet (See PSScriptAnalyzer rules)


# CONCLUSION
How it's simple to do something (specially when this is a boring task) with powershell when the problem is well identified.