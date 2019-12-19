# How to work with network settings

Source : <https://destruktive.one/powershell-and-how-to-work-with-network-settings/>

## Enable and Disable NIC

### List all network adapters

````Get-NetAdapter````

### Disable a specific network adapter, for instance the Wi-Fi adapter

***by name***

````Disable-NetAdapter -Name "Wi-Fi"````

***by piping a specific adapter***

````Disable-NetAdapter -Name "Wi-Fi"````
````Get-NetAdapter -InterfaceIndex 5 | Disable-NetAdapter````

### Activate a specific network adapter

***by name***

````Enable-NetAdapter -Name "Wi-Fi"````

***by piping a specific adapter***

````Get-NetAdapter -InterfaceIndex 5 | Enable-NetAdapter````

## Get and set IP address

### Get the IP-address of a specific adapter

````Get-NetIPAddress -InterfaceIndex 5````

### Get just the IPv4-address

````Get-NetIPAddress -InterfaceIndex 5 -AddressFamily IPv4````

### Just the address itself

````(Get-NetIPAddress -InterfaceIndex 5 -AddressFamily IPv4).IPAddress````

### Set IPv4-address, using splatting for better readability

````powershell
$ipParameter = @{
    InterfaceIndex = 22
    IPAddress = "10.0.0.22"
    PrefixLength = 24
    AddressFamily = "IPv4"
}
New-NetIPAddress @ipParameter
````

### Set the adapter to DHCP

````Set-NetIPInterface -InterfaceIndex 22 -Dhcp Enabled````

## Set DNS server for NIC and reset DNS Cache

### Set DNS-server addresses on a specific NIC

````powershell
$dnsParameter = @{
    InterfaceIndex = 5
    ServerAddresses = ("8.8.8.8","8.8.4.4")
}
Set-DnsClientServerAddress @dnsParameter
````

### Clear DNS cache

````Clear-DnsClientCache````
