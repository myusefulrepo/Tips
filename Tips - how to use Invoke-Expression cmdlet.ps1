# how to use Invoke-Expression cmdlet
# ref : https://adamtheautomator.com/invoke-expression/



#Run a PowerShell command via Invoke-Expression
$Command = 'Get-Process'
Invoke-Expression -Command $Command

#Execute a script via Invoke-Expression
$MyScript = '.\MyScript.ps1'
Invoke-Expression -Command $MyScript


# These don't work
$MyScript = "C:\Folder Path\MyScript.ps1"
#or
$MyScript = "'C:\Folder Path\MyScript.ps1'"
Invoke-Expression $MyScript

# this works
$MyScript = "C:\'Folder Path'\MyScript.ps1"
Invoke-Expression $MyScript

# another way
$scriptPath = 'C:\Scripts\MyScript.ps1'
$params = '-Path "C:\file.txt" -Force'
Invoke-Expression "$scriptPath $params"
# or
$string = 'C:\Scripts\MyScript.ps1 -Path "C:\file.txt" -Force'
Invoke-Expression $string

$a = "Get-Process"
## Doesn't work
& "$a pwsh"
# this works
Invoke-Expression -Command "$a pwsh"

<# Invoke-Command vs Invoke-Expression 
Invoke-Command is preferable if you are writing the executed commands now, 
as you retain intellisense in your IDE 
whereas Invoke-Expression would be preferable if you wanted to call another script from within your current one.
#>
#These both work the same way, but we lost our intellisense with the Invoke-Expression example.
Invoke-Command -ScriptBlock {
    Get-Process Chrome
    Get-Process Powershell
}

Invoke-Expression -Command "
Get-Process Chrome
Get-Process Powershell
"

<# If you have multiple commands to execute, even though Invoke-Expression only accepts a string rather than an array, 
we can use the PowerShell pipeline to send objects down the pipeline one at a time.
#>
# Doesn't work
$MyCollection = @(
    'Get-Process firefox',
    'Get-Service bits'
)
Invoke-Expression $MyCollection

# Works
'Get-Process firefox', 'Get-Service bits' | Invoke-Expression
#this works too
$MyCollection | Invoke-Expression
<#
You should be very cautious with using Invoke-Expression with user input. 
If you allow a prompt to a user in a way that gives them access outside of the command you are intending to execute, 
it could create an unwanted vulnerability. Here is one way you can safely implement user input with Invoke-Expression.
#>
do{
    $Response = Read-Host "Please enter a process name"
    $RunningProcesses = Get-Process

    #Validate the user input here before proceeding
    if($Response -notin $RunningProcesses.Name){
        Write-Host "That process wasn't found, please try again.`n" #Avoid using $Response here
    }
} until ($Response -in $RunningProcesses.Name)

$Command = "Get-Process $Response"
Invoke-Expression $Command



