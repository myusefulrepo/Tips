# A sample script to configure DNS on servers in an AD domain

## Use case

The domain's DNS servers have been modified (decommissioning for example) or remediation of existing configurations.

We want to ensure that in the IP configuration of the domain servers and domain controllers, the Best Practices are respected with regard to the configured DNS.

I can cite several good practices:

- The DNS server configured in DNS1 in the IP settings must not be the local DNS server of the computer to be configured (*in the case where the computer is a DC/DNS server. In the same case, we shouldn't set the loopback IP address either as DNS1*).
- It's preferable, as much as possible, to configure DNS servers located on the same AD site as the computer to be configured in order to limit network traffic.

## The script

````powershell
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $InterfaceAlias = 'Production',

    [Parameter()]
    [String]
    $DefaultSite = 'Headquarter'
)

Write-Verbose -Message 'Gathering the computer site name'
$ClientADSite = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name

if ($ClientADSite)
{
    Write-Verbose -Message 'Gathering IP Addresses from DCs on site'
    $DCIPAddresses = (Get-ADDomainController -Discover -SiteName $ClientADSite -ForceDiscover).IPv4Address
    Write-Verbose -Message 'Gathering the Computer IP Address'
    $LocalIp = (Get-NetIPConfiguration | Where-Object InterfaceAlias -EQ $InterfaceAlias).IPV4Address.IPAddress

    if ($DCIPAddresses -contains $LocalIp)
    {
        Write-Verbose -Message 'Move the first element of the $DCIPAddresses to the end'
        $DCIPAddresses = $DCIPAddresses[1..($DCIPAddresses.Length - 1)] + $DCIPAddresses[0]
    }
    Write-Verbose -Message 'Set the DnsClientServerAddress using the array $DCIPAddresses'
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DCIPAddresses
}
else
{
    Write-Verbose -Message 'The computer is not on a AD Site, using the DefaultSite DC as DNS'
    Write-Verbose -Message 'Gathering IP Addresses from DCs on the Default site'
    $DCIPAddresses = (Get-ADDomainController -Discover -SiteName $DefaultSite -ForceDiscover).IPv4Address
    Write-Verbose -Message 'Gathering the Computer IP Address'
    $LocalIp = (Get-NetIPConfiguration | Where-Object InterfaceAlias -EQ $InterfaceAlias).IPV4Address.IPAddress

    if ($DCIPAddresses -contains $LocalIp)
    {
        Write-Verbose -Message 'Move the first element of the $DCIPAddresses to the end'
        $DCIPAddresses = $DCIPAddresses[1..($DCIPAddresses.Length - 1)] + $DCIPAddresses[0]
    }
    Write-Verbose -Message 'Set the DnsClientServerAddress using the array $DCIPAddresses'
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DCIPAddresses
}
````

This code is provided as is as an example and can be improved or modified to adapt it to different needs such as:
- Execution of the script remotely, against all servers in the AD domain

We can also imagine using the provided script
- via a GPO
- via a GPO that creates a scheduled task that can be executed locally or remotely, individually or in bulk, on demand.

## Warning
Take some precautions before using this code.
- **Preparation** :
  - Make sure you have the necessary administrative permissions on the server.
  - Verify that the required PowerShell modules (ActiveDirectory and NetTCPIP) are installed.
- **Backup** :
  - Backup the current DNS configuration so that you can restore it if needed. You can use the following command to backup the current DNS addresses :

````Powershell
Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias | Export-Csv -Path 'C:\Backup\DnsBackup.csv'
````

- **Running the script** :
  - Copy the enhanced script to a .ps1 file on your server, for example ConfigureDNS.ps1.
  - Log in to PowerShell as an administrator.
  - Run the script using the following command:

````Powershell
.\ConfigureDNS.ps1 -InterfaceAlias 'Production' -DefaultSite 'Headquarter'
````

- **Verification** :
  - Verify that the DNS addresses have been configured correctly using the following command :

````Powershell
Get-DnsClientServerAddress -InterfaceAlias 'Production'
````

- **Additional tests** :
  - Test DNS resolution to ensure that the configured DNS servers are working properly. For example:

````Powershell 
Resolve-DnsName google.com
````

- **Restore (if needed)** :
  - If you encounter any problems, you can restore the previous DNS configuration using the backup file :

````Powershell 
$Backup = Import-Csv -Path 'C:\Backup\DnsBackup.csv'
Set-DnsClientServerAddress -InterfaceAlias ​​'Production' -ServerAddresses $Backup.ServerAddresses
````
By following these steps, you should be able to safely test and validate the script on your server. 

Always remember ***"we hope for the best, but we must prepare for the worst"***

Hope this help
Regards