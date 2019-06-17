<#check of DNS for specific old records
https://hkeylocalmachine.com/?p=620

When decommissioning servers (Domain Controllers especially) there are often errand and orphaned DNS records.
This script takes a wildcard search parameter (EG below is *dc04*) and searches all zones for any trace of it,
and return the results in a handy-dandy grid view,
including the zone and location of the record (very handy when you’re searching dozens of zones).
You could further extend this script to clean up and remove these records, but I’ll leave that up to you.
#>


# The data we're looking for (MUST INCLUDE asterisks). Can use HostNames, Domain Names, IP Addresses.
$FindForMe = "*dc04*"

# Create an empty results array
$Results = @()

# Get all primary forward lookup DNS zones
# we're looking only on primary and forward zones (not reverses zones or secondary zones). howerver, It's a nonsense when the zones on the DNS server are AD integrated
$Zones = Get-DnsServerZone | # here you can use the parameter -ComputerName to define the DNS Server where you run the query
Where-Object { ($_.ZoneType -eq "primary") -and ($_.isReverseLookupZone -eq $false) }


# Now, we Loop through each zone found
foreach ($Zone in $Zones)
{
    # Get DNS records that match with the search criteria
    $Records = Get-DnsServerResourceRecord -ZoneName $Zone.zonename |
        Where-Object { ($_.RecordData.ipV4Address.ipAddressToString -like $FindForMe) -or ($_.RecordData.HostNameAlias -like $FindForMe) -or ($_.HostName -like $FindForMe) -or ($_.RecordData.NameServer -like $FindForMe) -or ($_.RecordData.MailExchange -like $FindForMe) -or ($_.RecordData.DomainName -like $FindForMe) }
    # Loop through each record found
    foreach ($Record in $Records)
    {
        # Define the data, given the different record types
        switch ($Record.recordtype)
        {
            "A"
            {
                $Data = $Record.RecordData.ipv4Address.ipAddressToString
            }
            "NS"
            {
                $Data = $Record.RecordData.NameServer
            }
            "MX"
            {
                $Data = $Record.RecordData.MailExchange
            }
            "CNAME"
            {
                $Data = $Record.RecordData.HostNameAlias
            }
            "SRV"
            {
                $Data = $Record.RecordData.DomainName;
            }
        }
        # Add row of data to results array
        $Row = "" | Select-Object ZoneName, RecordType, HostName, Data
        $Row.ZoneName = $Zone.ZoneName
        $Row.RecordType = $record.RecordType
        $Row.HostName = $record.HostName
        $Row.Data = $Data
        $Results = $Results + $Row
    } # end foreach
} # End foreach

# Display results (here in the out-gridvwiew but you can choose to display in console, export in a.txt, a .csv, a .html or a .xml file, as you want)
$Results | Sort-Object ZoneName, RecordType, HostName, Data | Out-GridView
