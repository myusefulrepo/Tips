# How to check the Active Directory related ports with powershell

## the AD related ports are:

| Service                |    Port     | Protocol | Description                                                             |
| :--------------------- | :---------: | :------: | :---------------------------------------------------------------------- |
| LDAP                   |     389     | TCP/UDP  | Lightweight Directory Access Protocol for directory queries and updates
| LDAP over SSL/TLS      |     636     |   TCP    | LDAP over SSL for secure communication
| Kerberos               |     88      | TCP/UDP  | Authentication protocol used in AD
| DNS                    |     53      | TCP/UDP  | Domain Name System for name resolution and service discovery
| Global Catalog (LDAP)  |    3268     |   TCP    | Directory access to the global catalog (without SSL)
| Global Catalog (LDAPS) |    3269     |   TCP    | Global Catalog over SSL for secure directory queries and updates
| Netlogon               |     445     |   TCP    | Netlogon service for authentication and replication
| SMB/CIFS               |     445     |   TCP    | Server Message Block for file sharing and AD replication
| RPC                    |     135     |   TCP    | Remote Procedure Call | often used for DCOM services
| Dynamic RPC Ports      | 49152-65535 |   TCP    | Dynamically assigned ports for RPC connections | often used for replication

The list above highlights the most critical ports. However, if your server hosts additional roles and features, there will inevitably be other open ports.

# How to check the ports with PowerShell

````Powershell
Get-NetTCPConnection -State Established
````

Alternatively, you can use the `netstat` command. This is combined in the following example:

````DOS 
Netstat -an | Select-String ":389|:636|:88|:53|:3268|:3269|:445|:135|49152-65535"
````

**Get more process details**

If you want detailed information about the processes running on different ports, use the following command:
````Powershell
Get-Process -Id (Get-NetTCPConnection | Where-Object { $_.LocalPort -eq 389 }).OwningProcess

Handles NPM(K)  PM(K)   WS(K)   CPU(s)  Id  SI ProcessNameNPM()
------- ------  -----   -----   ------  --  -- ----------- ---
1986    281     128692  119888  126.41   844  0 lsass
````
This command lets you determine which processes are running on a specific port (in this case, 389 for LDAP).


**Check Firewall configuration**

Sometimes, checking firewall settings to ensure that needed ports are open is useful. PowerShell is also great for this:
````Powershell
Get-NetFirewallRule | Where-Object { $_.LocalPort -in 389, 636, 88, 53, 3268, 3269, 445, 135 }
````

This command lists all firewall rules for the major Active Directory ports.
