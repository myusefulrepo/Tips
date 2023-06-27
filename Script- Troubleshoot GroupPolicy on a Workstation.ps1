<#
Run on W7 or W10 to troubleshoot
A exécuter sur un poste W7 ou W10 qui pose pb pour le GPOs.
#>

[CmdletBinding()]
Param
(
    # Date la plus ancienne pour recherche dans les eventlogs
    # Older Date to search in Eventlogs
    [Parameter()]
    [DateTime]
    $StartTime = $(Get-Date -Year 2022 -Month 6 -Day 8 -Hour 08 -Minute 00 -Second 00),

    # Date la plus récente pour recherche dans les eventlogs
    # recent date to search in EventLogs
    [Parameter()]
    [DateTime]
    $EndTime = $(Get-Date -Year 2022 -Month 6 -Day 9 -Hour 08 -Minute 00 -Second 00) 
    # On peut mettre aussi Get-Date pour obtenir la date et l'heure courante
    # We can also use Get-Date to get current date et hour
)


if (-not (Test-Path -Path 'HKLM:\software\Microsoft\Windows NT\CurrentVersion\Diagnostics') )
{
    Write-Host "Diagnostics Key does'nt exist, creating" -ForegroundColor Green
    New-Item 'HKLM:\SOFTWARE\Microsoft\Windows NT\currentVersion\Diagnostics'
    Write-Host 'Creation GPSvcDebugLevel parameter and setting' -ForegroundColor Green
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\currentVersion\Diagnostics' -Name GPSvcDebugLevel -PropertyType DWORD -Value '0x30002' 
}
else
{
    Write-Host 'Diagnostics Key exists' -ForegroundColor Green
    Write-Host 'Settings GPSvcDebugLevel' -ForegroundColor Green
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\currentVersion\Diagnostics' -Name GPSvcDebugLevel -Value '0x30002'
}
Write-Host 'Go to  [%windir%\debug\usermode\gpsvc.log] to see logs file about GroupPolicy in debug mode' -ForegroundColor Green
Invoke-Item $env:windir\debug\usermode\gpsvc.log
Write-Host 'Gathering debug file to later analysis' -ForegroundColor Green
Write-Host 'Also check GroupPolicy event login eventlog applications ==> Microsoft ==> Windows ==> GroupPolicy ==> Operational' -ForegroundColor Green
Write-Host 'LogFile Name : Microsoft-Windows-GroupPolicy/Operational' -ForegroundColor Green
Write-Host 'Export to a .csv file to later analysis, more efficient and faster.' -ForegroundColor Green

$Query = Get-WinEvent -FilterHashtable @{
    LogName   = 'Microsoft-Windows-GroupPolicy/Operational'
    StartTime = $StartTime
    EndTime   = $EndTime
    #ID = filtering on Id
    #Level = filtering on Level. Accepted values : LogAlways 0 - Critical 1 - Error 2 - Warning 3 - Informational 4 - Verbose 5
    #UserID = filtering on account SID
}
$Query | Out-GridView
$QuerySelectedProperties = $query | 
    Select-Object @{Label = 'TimeCreated'      ; Expression = { $_.TimeCreated } },
    @{Label = 'ID'               ; Expression = { $_.ID } },
    @{Label = 'MachineName'      ; Expression = { $_.MachineName } },
    @{Label = 'LevelDisplayName' ; Expression = { $_.LevelDisplayName } },
    @{Label = 'Message'          ; Expression = { $_.Message } }
# Check if existing c:\temp, Otherwise creating
if (-not (Test-Path -Path C:\Temp) )
{
    Write-Host "[C:\temp] doesn't exist, creating" -ForegroundColor Yellow
    New-Item -Path 'C:\Temp' -ItemType Directory
}
# Export in a .csv file
$QuerySelectedProperties | Export-Csv -Path 'C:\Temp\GroupPolicy.csv' -Delimiter ';' -NoTypeInformation -Encoding UTF8
# I'm using -Delimiter ";", cause in my culture the default is ";"
Write-Host 'Exporting events in a file : OK' -ForegroundColor Green


# Later, don't forget to remove the previous registry key created 
Remove-Item -Path 'HKLM:\software\Microsoft\Windows NT\CurrentVersion\Diagnostics' -Recurse