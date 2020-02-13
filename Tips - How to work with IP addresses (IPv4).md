# How to work with IP addresses  (IPv4)

## Declare an IP Address in a var

````powershell
[System.Net.IPAddress]$Address = "192.168.0.1"
[IPAddress]$Address = "192.168.0.1"
$Address
Address            : 16820416
AddressFamily      : InterNetwork
ScopeId            :
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv4MappedToIPv6 : False
IPAddressToString  : 192.168.0.1
````

>[Nota] : [System.Net.IPAddress] and [IPAddress] are similar

````powershell
[IPAddress].FullName
System.Net.IPAddress
````

## create an IP range

A function could be practical, isn't it ?

````powershell
function New-IPRange ($Start, $End) {
 # created by Dr. Tobias Weltner, MVP PowerShell
 $ip1 = ([IPAddress]$Start).GetAddressBytes()
 [Array]::Reverse($ip1)
 $ip1 = ([IPAddress]($ip1 -join '.')).Address
 $ip2 = ([IPAddress]$End).GetAddressBytes()
 [Array]::Reverse($ip2)
 $ip2 = ([IPAddress]($ip2 -join '.')).Address
 for ($x=$ip1; $x -le $ip2; $x++) {
 $ip = ([IPAddress]$x).GetAddressBytes()
 [Array]::Reverse($ip)
 $ip -join '.'
 }
}
````

in action

````powershell
$Range = New-IPRange -Start 192.168.0.1 -End 192.168.0.254
````

### How does it work

First, transform the $Start IP Address from [String] to [IPAddress] then to [System.Array] of bytes  : ````$ip1 = ([IPAddress]$Start).GetAddressBytes()````

````powershell
ip1.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Byte[]                                   System.Array
````

Second, reverse the order of this array using ````Reverse```` method :  ````[Array]::Reverse($ip1)````
At this Step,$IP1 will be like the following :

````powershell
$ip1
1
0
168
192
````

Third : Join all pieces of this array, transform it in a [IPAddress] :  ````$ip1 = ([IPAddress]($ip1 -join '.')).Address````

````powershell
$ip1
3232235521

$ip1.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Int64                                    System.ValueType
````

As we can see, $IP1 is now a [INT64]. A number ? We know how to count from one number to another using a ````For```` Statement.
Let's do it again with the End IP, and build the ````For```` Statement.
Of course, in the loop, the result will have the same treatment : [String] to [IPAddress] to [Bytes] in an [Array]; reverse the [Array] and join the pieces.

>[Nota] : you can also notice that the result of the previous function is an array

````powershell
$range.GetType()
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Object[]                                 System.Array
````

Easy to use, isn't it ?

## Convert an IP address string to IP Address Instance

We can use .NET [IpAddress] class with the method ````Parse````

````powershell
[IPAddress]::Parse("10.10.10.10")

Address            : 168430090
AddressFamily      : InterNetwork
ScopeId            :
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv4MappedToIPv6 : False
IPAddressToString  : 10.10.10.10
````

## Convert an IP Address Instance back to IP Address string

````powershell
([IPAddress]168430090).ToString()
10.10.10.10
````

## Sort IP Addresses coming as an [Array]

````powershell
$IPAddresses = @(
'10.11.12.13'
'10.11.102.3'
'10.11.10.26'
'10.11.10.252'
)
$IPAddresses | Sort-Object
10.11.10.252
10.11.10.26
10.11.102.3
10.11.12.13
````

This is not the expected result we would like.
The easy way to sort this cleanly is to use [System.version] or its alias [Version]

````powershell
$IPAddresses | Sort { [system.version]$_ }
10.11.10.26
10.11.10.252
10.11.12.13
10.11.102.3
````

## Sort IP addresses coming as an [Object]

````powershell
$IPs = {192.168.1.10, 192.168.1.9, 192.168.1.8, 192.168.1.1}
$IPs.gettype()
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     ScriptBlock                              System.Object
````

The way to use is to transform this object to [string], as en [Array], then split it with a comma, and finally sort the result.

````powershell
$IPs = $IPs.ToString()
192.168.1.10, 192.168.1.9, 192.168.1.8, 192.168.1.1

$a   = $IPs.Split(",")
$a
192.168.1.10
 192.168.1.9
 192.168.1.8
 192.168.1.1
$a | Sort-Object
````

## Final words

Hope with help someone else than me.


Sources and references :
<https://docs.microsoft.com/en-us/dotnet/api/system.net.ipaddress?view=netframework-4.8>
<https://ficilitydotnet.wordpress.com/2013/03/16/powershell-example-how-to-work-with-the-ip-addresses-ipv4/>
<https://www.madwithpowershell.com/2016/03/sorting-ip-addresses-in-powershell-part.html>
<https://stackoverflow.com/questions/36091414/how-to-sort-the-list-if-ip-address-fetched-using-win32-networkadapterconfigurati>
