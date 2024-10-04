# A sample script to configure DNS on servers in an AD domain

## Use case

The domain's DNS servers have been modified (decommissioning for example) or remediation of existing configurations.

We want to ensure that in the IP configuration of the domain servers and domain controllers, the Best Practices are respected with regard to the configured DNS.


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

We can imagine using the provided script
- via a GPO
- via a GPO that creates a scheduled task that can be executed locally or remotely, individually or in bulk, on demand.


Hope this help
Regards