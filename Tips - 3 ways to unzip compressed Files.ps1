# This tip is based on the following article from Prateeek Singh (https://ridicurious.com/2019/07/29/3-ways-to-unzip-compressed-files-using-powershell/)

$ZippedFilePath = "c:\temp\archive.zip"
$DestinationFolder = "c:\temp2"
Get-ChildItem -Path $DestinationFolder -Recurse | Remove-Item # initialization
$Iterations = "20"


#region Using Expand-Archive Cmdlet -PS V5)

$ExpandArchive = 0..$Iterations | Measure-command -Expression {
    Expand-Archive -Path $ZippedFilePath -DestinationPath $DestinationFolder
    Get-ChildItem -Path $DestinationFolder -Recurse
    Get-ChildItem -Path $DestinationFolder -Recurse | Remove-Item
}

#endregion

#region Using .Net v4.5 class [System.IO.Compression.ZipFile]
$NetClass = 0..$Iterations | Measure-command -Expression {
    [System.IO.Compression.ZipFile]::extractToDirectory($ZippedFilePath, $DestinationFolder)
    Get-ChildItem -Path $DestinationFolder -Recurse
    Get-ChildItem -Path $DestinationFolder -Recurse | Remove-Item
}
#endregion

#region Using Folder.CopyHere() Method of Shell.Application Class
$FolderCopyHere = 0..$Iterations | Measure-command -Expression {
    $Shell = New-Object -ComObject shell.application
    $Shell.Namespace($DestinationFolder).copyhere($Shell.NameSpace($ZippedFilePath).Items(), 4)
    Get-ChildItem -Path $DestinationFolder -Recurse
    Get-ChildItem -Path $DestinationFolder -Recurse | Remove-Item
}
#endregion 

#region Results
Write-Host "ExpandArchive : " -ForegroundColor Green -NoNewline
Write-Host "$($ExpandArchive.TotalMilliseconds)" -ForegroundColor Yellow -NoNewline
Write-Host " Ms" -ForegroundColor Green

Write-Host "NetClass  : " -ForegroundColor Green -NoNewline
Write-Host "$($NetClass.TotalMilliseconds)" -ForegroundColor Yellow -NoNewline
Write-Host " Ms" -ForegroundColor Green

Write-Host "FolderCopyHere : " -ForegroundColor Green -NoNewline
Write-Host "$($FolderCopyHere.TotalMilliseconds)" -ForegroundColor Yellow -NoNewline
Write-Host " Ms" -ForegroundColor Green
#endregion

#region comments
<# I've tested on differents zip files. Here a result for looping 20 times
ExpandArchive : 1157.6897 Ms
NetClass  : 879.3944 Ms
FolderCopyHere : 21007.1486 Ms

Synthesis of the performance tests : 
... and the result is always the same. Using Net Class is fastest, and Shell.Application class the slowest from ... far. :-( 
The native cmdlet have often executing time not far as .Net class, but in my opinion, the cmdlet is more readable, more scriptable, 
more practical to use ... and it's matching the opposite cmldlet :   Compress-Archive. 
#>
#endregion

