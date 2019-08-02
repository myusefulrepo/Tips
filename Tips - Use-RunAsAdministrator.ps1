Write-host "Check if script is running as Administrator, and if not, use RunAs to launch a new shell in RunAs" -ForegroundColor Magenta
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$MyWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($myWindowsPrincipal.IsInRole($adminRole))   # We are running "as Administrator"
{
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    #Clear-Host
} # End if
else  # we are not running "as administrator"
{
    # We are not running "as Administrator" - so relaunch as administrator

    <# Old and long way
    Create a new process object that starts PowerShell
    $NewProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell_ISE" # Or Powershell
    # Specify the current script path and name as a parameter
    $NewProcess.Arguments = $myInvocation.MyCommand.Definition
    # Indicate that the process should be elevated
    $NewProcess.Verb = "runas"
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess)
    #>
    # New and short way
    Start-Process PowerShell_ise -Verb Runas -ArgumentList ($myInvocation.MyCommand.Definition)
    # Exit from the current, unelevated, process

    exit
} # End else

Write-Host "The Script is Running As Administrator" -ForegroundColor Magenta
