# Useful Events to monitor

# 1 - System Events
<# 
ID 104 An event log was cleared
#>
$SystemEvents = Get-WinEvent -FilterHashtable @{
                               LogName = "System"
                               id = "104"
                               } -MaxEvents 50 -ErrorAction SilentlyContinue

# 2 - Security Events
<# 
ID 4656 - Auditing of configured files, registry keys:
                PowerShell profiles (*profile*.ps1)
                Security settings (HKLM:\Software\Policies\*)
#>
$SecurityEvents = Get-WinEvent -FilterHashtable @{
                               LogName = "Security"
                               id = "4656"
                               } -MaxEvents 50 -ErrorAction SilentlyContinue

# 3 - Windows Powershell Events
<#
ID 400 - PowerShell Startup, including hosting application, version
ID 800 - Command and Parameter Logging
#>
$PSEvents = Get-WinEvent -FilterHashtable @{
                               LogName = "Windows Powershell"
                               id = "400", "800"
                               } -MaxEvents 50 -ErrorAction SilentlyContinue

# 3 - Microsoft-Windows-PowerShell/Operational Events
<#
ID 4104 - Warning - ScriptBlock automatic logging – used APIs or techniques commonly associated with malware
ID 4104 - Verbose - ScriptBlock logging
ID 53507 - PowerShell debugger attached to a process

Nota : 4104/Warning is NOT a replacement for an intrusion detection system.
#>
$PSOperationalEvents = Get-WinEvent -FilterHashtable @{
                               LogName = "Microsoft-Windows-Powershell/Operational"
                               id = "4104","53507"
                               } -ErrorAction SilentlyContinue

# 4 - Microsoft-Windows-WinRM/Operational Events
<# 
ID 91 - User connected to system with PowerShell Remoting
#>

$WinRMEvents = Get-WinEvent -FilterHashtable @{
                               LogName = "Microsoft-Windows-WinRM/Operational"
                               id = "91"
                               } -ErrorAction SilentlyContinue

$Result =@()
$Result += $SecurityEvents
$Result += $PSEvents 
$Result += $PSOperationalEvents
$Result += $WinRMEvents
$Result

# Source Jon Fow  in "Security 102 - Defending Against Powershell Attacks" (SEC102-PowerShell-Attacks.pptx)
# Adapted from a presentation by Lee Holmes, Lead Security Architect, Azure Management
# Ref. : https://github.com/rtpsug/PowerShell-Saturday/blob/master/2019-NC.State/2019-09-21-PowerShell.Security.102-Jon.Fox/SEC102-PowerShell-Attacks.pptx


# ADDENDUM
<#
The PowerShell Injection Hunter module looks for many instances of unsafe coding practices when
PowerShell scripts are exposed to untrusted input

https://devblogs.microsoft.com/powershell/powershell-injection-hunter-security-auditing-for-powershell-scripts/

- Install Module : Install-Module InjectionHunter
- Retreive Install Path : Get-Module InjectionHunter -List | Foreach-Object Path
- Create a file Named PSScriptAnalyzerSettings.psd1 in a location of your choice and put the following content inside it : 
@{
 IncludeDefaultRules = $true
 CustomRulePath = "Your\Retreive\Install\Path\InjectionHunter.psd1"
}
- In VS code, Modify the User Settings with the following line
"powershell.scriptAnalysis.settingsPath": "Your\Path\ToFile\PSScriptAnalyzerSettings.psd1"

When you open a PowerShell script with possible code injection risks, 
you should now see Script Analyzer warnings that highlight what they are and how to fix them.

Ref. : https://devblogs.microsoft.com/powershell/powershell-injection-hunter-security-auditing-for-powershell-scripts/
#>