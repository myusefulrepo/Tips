# Ref. : https://4sysops.com/archives/disable-windows-10-telemetry-with-a-powershell-script/#comment-656904
# Run as admin

Function ChangeReg {
  param ([string] $RegKey,
         [string] $Value,
         [string] $SvcName,
         [Int] $CheckValue,
         [Int] $SetData)
  Write-Host "Checking if $SvcName is enabled" -ForegroundColor Green
  if (!(Test-Path $RegKey)){
      Write-Host "Registry Key for service $SvcName does not exist, creating it now" -ForegroundColor Yellow
      New-Item -Path (Split-Path $RegKey) -Name (Split-Path $RegKey -Leaf) 
     }
 $ErrorActionPreference = 'Stop'
 try{
      Get-ItemProperty -Path $RegKey -Name $Value 
      if((Get-ItemProperty -Path $RegKey -Name $Value).$Value -eq $CheckValue) {
          Write-Host "$SvcName is enabled, disabling it now" -ForegroundColor Green
          Set-ItemProperty -Path $RegKey -Name $Value -Value $SetData -Force
         }
      if((Get-ItemProperty -Path $RegKey -Name $Value).$Value -eq $SetData){
             Write-Host "$SvcName is disabled" -ForegroundColor Green
         }
     } catch [System.Management.Automation.PSArgumentException] {
       Write-Host "Registry entry for service $SvcName doesn't exist, creating and setting to disable now" -ForegroundColor Yellow
       New-ItemProperty -Path $RegKey -Name $Value -Value $SetData -Force
      }
   }
  
 # Disabling Advertising ID
 $RegKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
 $Value = "Enabled"
 $SvcName = "Advertising ID"
 $CheckValue = 1
 $SetData = 0
 ChangeReg -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData
 #Telemetry Disable
 $RegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
 $Value = "AllowTelemetry"
 $SvcName = "Telemetry"
 $CheckValue = 1
 $SetData = 0        
 ChangeReg -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData        
 #SmartScreen Disable
 $RegKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost\EnableWebContentEvaluation"
 $Value = "Enabled"
 $SvcName = "Smart Screen"
 $CheckValue = 1
 $SetData = 0
 ChangeReg -RegKey $RegKey -Value $Value -SvcName $SvcName -CheckValue $CheckValue -SetData $SetData
 Write-Host "Disabling DiagTrack Services" -ForegroundColor Green 
 Get-Service -Name DiagTrack | Set-Service -StartupType Disabled | Stop-Service
 Get-Service -Name dmwappushservice | Set-Service -StartupType Disabled | Stop-Service
 Write-Host "DiagTrack Services are disabled" -ForegroundColor Green 
 Write-Host "Disabling telemetry scheduled tasks" -ForegroundColor Green
 $tasks ="SmartScreenSpecific",
         "ProgramDataUpdater",
         "Microsoft Compatibility Appraiser",
         "AitAgent",
         "Proxy",
         "Consolidator",
         "KernelCeipTask",
         "BthSQM",
         "CreateObjectTask",
         "Microsoft-Windows-DiskDiagnosticDataCollector",
         "WinSAT",
         "GatherNetworkInfo",
         "FamilySafetyMonitor",
         "FamilySafetyRefresh",
         "SQM data sender",
         "OfficeTelemetryAgentFallBack",
         "OfficeTelemetryAgentLogOn"
 $ErrorActionPreference = 'Stop'
 $tasks | %{
    try{
       Get-ScheduledTask -TaskName $_ | Disable-ScheduledTask
       } catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] { 
    "task $($_.TargetObject) is not found"
    }
 }