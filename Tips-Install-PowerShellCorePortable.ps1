#requires -RunAsAdministrator
#requires -Version 5

## Install latest PowerShell Core Zip x64 release
$latestRelease = Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/latest -UseBasicParsing
$zipRelativeLink = $latestRelease.Links | Where href -Match '-win-x64.zip' | % href
$zipPath = Join-Path -Path $env:TEMP -ChildPath $zipRelativeLink.Split('/')[-1]

if (-not (Test-Path -Path $zipPath)) {
    Invoke-WebRequest -Uri ('https://github.com{0}' -f $zipRelativeLink) -OutFile $zipPath
}

Unblock-File -Path $zipPath

if (-not (Test-Path -Path "$env:ALLUSERSPROFILE\PowerShell")) {
    $null = New-Item -Path $env:ALLUSERSPROFILE -Name 'PowerShell' -ItemType Directory -Force
}

$folderName = $zipRelativeLink.Split('/')[-1] -replace '^PowerShell-','' -replace '-win-x64\.zip$',''
$destinationFolder = Join-Path -Path "$env:ALLUSERSPROFILE\PowerShell" -ChildPath $folderName
Expand-Archive -Path $zipPath -DestinationPath $destinationFolder
