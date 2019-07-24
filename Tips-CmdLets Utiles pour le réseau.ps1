# Tester la connectivité (ping)
Test-NetConnection -ComputerName I-I2I-SQL-A0
Test-NetConnection -ComputerName 10.8.149.135

# boucle de ping
1..254 | ForEach-Object { Test-NetConnection 10.8.249.$_ } | Format-Table -AutoSize

# Tester la connectivité basé sur le port ou le service
Test-NetConnection -ComputerName I-I2I-SQL-A0 -CommonTCPPort RDP  # (RDP, HTTP, SMB, WINRM) 
Test-NetConnection -ComputerName I-I2I-SQL-A0  -Port 80
# Trace route
Test-NetConnection -ComputerName I-I2I-SQL-A0 -TraceRoute
Test-NetConnection -ComputerName I-I2I-SQL-A0 -Hops 10
Test-NetConnection -ComputerName I-I2I-SQL-A0 -DiagnoseRouting 

# voir les routes
Get-NetRoute 
Get-NetRoute -InterfaceAlias Ethernet



# Obtenir la configuration IP
Get-NetIPConfiguration  
Get-NetIPConfiguration -Detailed # équivalent à IPconfig /all

# Résolution DNS 
Resolve-DnsName -Name I-I2I-SQL-A0 
Resolve-DnsName -Name I-I2I-SQL-A0 -Type A | Select-Object -Property Name, Type, IpAddress
Resolve-DnsName -Name  10.8.149.135   -Type PTR

# voir les connexions TCP courantes (équivalent de arp -a)
Get-NetTCPConnection
Get-NetTCPConnection -State Established 


# voir les informations DNS (info de l'onglet DNS dans la conf IP)
Get-DnsClient 
Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceAlias Ethernet 

# flush DNS cache (équivalent à ipconfig /flushDNS)
Clear-DnsClientCache

# Lister toutes les cartes réseaux
Get-NetAdapter
Get-NetAdapter | Select-Object -Property *
Get-NetAdapter | Select-Object -Property Name, MacAddress, InterfaceAlias, TransmitLinkSpeed 
Get-NetAdapter | Select-Object -Property Name, DriverVersion, DriverInformation, DriverFileName

# Informations Hardware
Get-NetAdapterHardwareInfo

# Activer/désactiver une carte réseau
Enable-NetAdapter -Name xxx
Disable-NetAdapter -Name xxx
Rename-NetAdapter -Name "Ethernet" -NewName "EthernetFilaire"


Get-NetIPAddress -InterfaceIndex 4
(Get-NetAdapter -Name "Local Area Connection" | Get-NetIPAddress).IPAddress
Get-NetAdapter -Name "Local Area Connection" | Get-DnsClientServerAddress

# Ajouter une adresse IP
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.0.0.10 -DefaultGateway 10.0.0.254 -AddressFamily IPv4 -PrefixLength 24
# changer une adresse IP existante 
Set-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.0.0.10 -PrefixOrigin Manual
Set-NetIPInterface -InterfaceAlias Wireless -Dhcp Enabled


# Créer un nouveau TEAM (lbfo Team ou Load-balancing with failover team)
New-NetLbfoTeam -Name NICTeam -TeamMembers Ethernet1, Ethernet2 -TeamingMode Lacp -TeamNicName NICTEAM -LoadBalancingAlgorithm Dynamic







