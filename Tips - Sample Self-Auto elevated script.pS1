# Set ExecutionPolicy for current user (TEST)
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser

# Auto Elevate
Write-Output 'Checking for Elevated privileges for this process'
# Self-elevate the script if required

# Get the ID and security principal of the current user account
$MyWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$MyWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($MyWindowsID)

# Get the security principal for the Administrator role
$AdminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($MyWindowsPrincipal.IsInRole($AdminRole))
{
    # We are running "as Administrator" - so change the title and background color to indicate this
    # $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    # $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    # Clear-Host
    # Set execution policy to unrestricted
    # Echo Write-Host "Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser" | PowerShell.exe -noprofile
}
else
{
    # We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $NewProcess = New-Object System.Diagnostics.ProcessStartInfo 'PowerShell'

    # Specify the current script path and name as a parameter
    $NewProcess.Arguments = $MyInvocation.MyCommand.Definition

    # Indicate that the process should be elevated
    $NewProcess.Verb = 'runas'

    # Start the new process
    [System.Diagnostics.Process]::Start($NewProcess)

    # Exit from the current, unelevated, process
    exit
}


# Sample script code (replace by your own)
Write-Output 'Hello PS is running in RunAsAdmin mode'
Pause # in this sample code, pause is just to avoir the close the shell after executing the code
