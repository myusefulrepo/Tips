# Resolving Get-TCPConnection owning service and Remote Address

## The Challenge
When using The Get-NetTCPConnection, we can see the RemoteAddresses but we haven't any idea of the Process Name calling these RemoteAddresses and we haven't any idea of the remote site using these RemoteAddresses
They could be legitimate or illegitimate.

Let's do this

````Powershell
#Remote port you're looking for. If you use multi, separate with comma.
$RemotePort = '443','80'


# Identify the process Names
$Process = @{
    Name = 'ProcessName'
    Expression = { (Get-Process -Id $_.OwningProcess).Name }
    }

# Identify RemoteIP to Remote organisation using a public service
$DarkAgent = @{
    Name = 'ExternalIdentity'
    Expression = {
        $IP = $_.RemoteAddress
        (Invoke-RestMethod -Uri "http://ipinfo.io/$IP/json" -UseBasicParsing -ErrorAction Ignore).org
        }
    }

# And now, let's the magic works !
Get-NetTCPConnection -RemotePort $RemotePort -State Established |
    Select-Object -Property RemoteAddress, OwningProcess, RemotePort, $Process, $DarkAgent |
    Format-Table
````

[Nota] We could also use as alternatives

````powershell
(Invoke-RestMethod -Uri "http://ipwhois.app/json/$IP").org
(Invoke-RestMethod -Uri "http://iplist.cc/api/$IP").asn.name
(Invoke-RestMethod -Uri "https://ipapi.co/$IP/json").org
````

Thanks to u/Postanote in https://new.reddit.com/r/PowerShell/comments/mo1kyb/resolving_getnettcpconnection_owning_service/ to give this way. 
