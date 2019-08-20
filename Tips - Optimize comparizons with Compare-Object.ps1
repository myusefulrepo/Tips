<#
The Objective of this Tip is to demonstrate with samples how fast the cmdlet Compare-Object running Fast and can help to save time
#>

#region compare 2 trees and do-something (i.e. sync 2 directories)
$Folder1Path = 'C:\temp'
$Folder2Path = 'C:\temp2'

$Folder1Files = Get-ChildItem -Path $Folder1Path -Recurse | Select-Object -Property Name, FullName
Write-Host "Files count in $folder1Path : $($Folder1Files.count)" -ForegroundColor Green
$Folder2Files = Get-ChildItem -Path $Folder2Path -Recurse | Select-Object -Property Name, FullName
Write-Host "Files count in $folder2Path : $($Folder2Files.count)" -ForegroundColor Green
$FileDiffs = Compare-Object -ReferenceObject $Folder1Files -DifferenceObject $Folder2Files -Property Name -PassThru
Write-Host "Count Different Files : $($fileDiff.count)" -ForegroundColor Green
# as we can see there are some files to add in the Destination folder and some files that doesn't exist in the Reference Folfer
# How long does it take ?
$CompareFilesToSync = Measure-Command -Expression {
    Compare-Object -ReferenceObject $Folder1Files -DifferenceObject $Folder2Files -Property Name -PassThru
}
Write-Host "Running time to compare files in $folder1Path and $Folder2Path : $($CompareFilesToSync.TotalMilliseconds) ms" -ForegroundColor Green
# How fast is the cmdlet Compare-Object
#endregion

#region discussion
<#
As we could see, only some few differences. Ok, I know that this 2 trees contains few files.
I want to draw your attention on one important thing. If after this comparizon you want to do-sometihing, with a foreach loop,
it will take a shorter time, because foreach run sequentially ... and sometime it will take a long time to run.

i.e. : I would like to feed a big AD Security Group with a ref. list of member (located in a .csv file with 10 000 members. It's not surrealist,this case exists in the real life)
If I perform a foreach loop with the following :
			Add-ADGroupMember -Identity GroupIdentity -Member $Member
	> It take a long time (depending of the ref list)
	> but the goal is not achieved (what about the excess members ? )

If I perform 2 foreach loop with the following :
			Remove-ADGroupMember -Identity GroupIdentity -Member $Member
			Add-ADGroupMember -Identity GroupIdentity -Member $Member
	> the goal is achieved but the running time is doubled

Then the best solution - from my point of view - is to minimize the actions do perform in the foreach loop.

As we can see in my previous object, only few differences.

And believe me, in the most cases, it will be the same. Find an another way to compare faster if you can. I'll take it.
#>
#endregion

#region How to proceed with compare-Object
# Process with one loop and 2 conditionnal actions (If)
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
# All done
