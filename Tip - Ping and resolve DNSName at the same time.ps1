<#
The purpose of this Tip is to show how to build quickly a graceful script to :
  > Ping several remote computers
  > resolve DNSName in the same time
  > Gather all informations in a PSCustomObject
  > Export the PSCustomObject to a file (.txt, .csv, html, xml, ... as you want)
#>

#region Define Input
<# This could be :
    > IP adresses list,
    HostNames/IPs in a .csv file
    HostNames/IPs in a .txt file.
#>
$Entries = "192.168.0.14", "192.168.0.15", "192.168.0.16"
#$csv = Import-Csv -Path C:\Temp\IPAddresses.csvs
#$txt = Get-Content -Path C:\temp\ipAddress.txt
#endregion

#region Defin Path for Export file
$ExportFile = "C:\temp\Result.csv"
#endregion

#region execution
# replace $Entries by $csv or $txt as your need
$Collection = foreach ($Server in $Entries)
{
    # Define an Ordered PSCustomObject with some interesting properties
    $Status = [PsCustomObject][Ordered] @{
        'Destination' = $Server
        'TimeStamp'   = Get-Date -Format g
        'Results'     = 'Down'
        'IP'          = 'N/A'
        'HasDNS'      = [bool](Resolve-DnsName -Name $Server -ErrorAction SilentlyContinue)
        'HostName'    = 'N/A'
    }
    # test connection (ping)
    $Ping = Test-Connection $server -Count 1 -ErrorAction SilentlyContinue

    if ($true -eq $Ping)
    {
        # Update values in the PSCustomObject
        $Status.Results = 'Up'
        $Status.IP = ($Ping.IPV4Address).IPAddressToString
    }
    if ($true -eq $Status.HasDNS)
    {
        # Update values in the PSCustomObject
        $Status.HostName = (Resolve-DnsName -Name $Server -ErrorAction SilentlyContinue).NameHost
    }
    $Status
}
#endregion

#region Show result in the console shell
$collection
#endregion

#region Export the result in a .csv file
$collection | Export-Csv -Path $ExportFile -Delimiter ";" -NoTypeInformation -Encoding UTF8
#endregion

#region open the result file
& $ExportFile
#endregion