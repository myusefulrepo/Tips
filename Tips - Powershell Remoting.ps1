# Tips and Tricks : POwershell remoting cheatsheet

# 1 - Enabling PowerShell Remoting
Enable-PSRemoting –force # in a console in a runasadministrator mode

# 2 - Troubleshoot
# Make sure the WinRM service is setup to start automatically
Get-service WinRM | Select-Object -Property Name, Status, startType, DisplayName # if StarType is not Automatic then...
Set-Service WinRM -StartMode Automatic # Set start mode to automatic
# Another method to get the service properties
Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}

# Check if remote hosts (not in the same AD Domain) are trusted.
# Verify trusted hosts configuration
Get-Item WSMan:\localhost\Client\TrustedHosts # show the trusted hosts
Set-Item WSMan:localhost\client\trustedhosts -value server01 # set up the trusted host
Set-Item WSMan:localhost\client\trustedhosts -value " " # remove all trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value Server02 # Add another trusted host in the existing list


# 3 - Executing Remote Commands with PowerShell Remoting
# Executing a Single Command on a Remote System
Invoke-Command –ComputerName MyServer1 -ScriptBlock {Hostname}
Invoke-Command –ComputerName MyServer1 -Credential demo\serveradmin -ScriptBlock {Hostname}
Get-ADComputer -Filter *  -properties name | select @{Name="computername";Expression={$_."name"}} | Invoke-Command -ScriptBlock {hostname}
# run scripts stored locally on your system against remote systems. 
Invoke-Command -ComputerName MyServer1 -FilePath c:\scripts\Get-Info.ps1


# 4 - Establishing an Interactive PowerShell Console on a Remote System
Enter-PsSession –ComputerName server1.domain.com
Enter-PsSession –ComputerName server1.domain.com –Credentials domain\serveradmin
Exit-PsSession # to exit the PSSession. This will send the session into the background.

# 5 - Creating Background Sessions
New-PSSession -ComputerName server1.domain.com -Name Server1 # creating PSSession
New-PSSession -ComputerName server1.domain.com -Name server1 -Credential domain\serveradmin
Enter-PSSession -Name server1 # and enter

# 6 - Listing Background Sessions
Get-PSSession

# 7 - Interacting with Background Sessions
Enter-PsSession –id 3
Enter-PSSession -Name server1

# 8 - Executing Commands through Background Sessions
Invoke-Command -Session (Get-PSSession) -ScriptBlock {Hostname} # If your goal is to execute a command on all active sessions the “Invoke-Command” and “Get-PsSession” commands can be used together.

# 9 - Removing Background Sessions
Get-PSSession | Disconnect-PSSession

# 10 - Last tips
<# 
    Use “Invoke-Command” if you’re only going to run one command against a system
    Use “Enter-PSSession” if you want to interact with a single system
    Use PSsessions when you’re going to run multiple commands on multiple systems
#>












