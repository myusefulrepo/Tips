# Best way to disable IPV6 in Windows Computers

## Preface

We can often read everything and its opposite, so where is the truth ?

According to MS, IPV6 is a manadatory part of Operating System since Windows Vista and Windows server 2008 and newer version. 

ref. : [Configure IPv6 in Windows](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows)

Totally disable this component could produce somme troubles as : 
-  Startup delay after you disable IPv6 in Windows 7 SP1 or Windows Server 2008 R2 SP1.
- Additionally, system startup will be delayed for five seconds if IPv6 is disabled by incorrectly, setting the DisabledComponents registry setting to a value of 0xffffffff. The correct value should be 0xff.
- The DisabledComponents registry value doesn't affect the state of the check box. This can be confusing ! Even if the DisabledComponents registry key is set to disable IPv6, the check box in the Networking tab for each interface can be checked. This is an expected behavior.
- You cannot completely disable IPv6 as IPv6 is used internally on the system for many TCPIP tasks. For example, you will still be able to run ping ::1 after configuring this setting.


## What do we choose ?

The recommended value is "**Prefer IPV4 over IPv6**". 

### Way 1 : unit change
- Opend Regedit and browse to **HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\**
- Identify the Key **DisabledComponents** (this is a REG_DWORD)
- Set the value **32** (decimal) or **0x20** (Hexadecimal). Note that the default value is 0x00.

[Nota] : This registry value doesn't affect the state of the check box **Ethernet Property**. Even if the registry key is set to disable IPv6, the check box in the Networking tab for each interface can be selected. This is an expected behavior.

But this way is not the more efficient for a large scope of computers. The Best way is to use Group Policy to do this (see Way 3 bellow)

### Way 3 : using powershell

````powershell 
Get-NetAdapter | Get-NetAdapterBinding| Where-Object -FilterScript {$_.ComponentID -eq "ms_tcpip6"}

Name                           DisplayName                                        ComponentID          Enabled     
----                           -----------                                        -----------          -------
Wi-Fi                          Protocole Internet version 6 (TCP/IPv6)            ms_tcpip6            False
Ethernet                       Protocole Internet version 6 (TCP/IPv6)            ms_tcpip6            False
Ethernet 2                     Protocole Internet version 6 (TCP/IPv6)            ms_tcpip6            False
vEthernet (Wi-Fi)              Protocole Internet version 6 (TCP/IPv6)            ms_tcpip6            True
vEthernet (Ethernet 2)         Protocole Internet version 6 (TCP/IPv6)            ms_tcpip6            True
Connexion réseau Bluetooth     Protocole Internet version 6 (TCP/IPv6)            ms_tcpip6            False
vEthernet (Ethernet)           Protocole Internet version 6 (TCP/IPv6)            ms_tcpip6            True
````

Adapt the code to select only the Adapter you need, then 
````powershell
Disable-NetAdapterBinding -Name <AdapterName> -ComponentID "ms_tcpip6"
````

[Nota : ] this way is exactly when you unckeck "*Internet Protocol Version 6 (TCP/IPv6)*" ith the Property windows of the adapter.


### Way 3 : mass change

Of course, this way, is the best way to choose. :smiley:

- Open Group Policy Management Console (gpmc.msc)
- In the **Group Policy Objects** container create a new Policy. Call it : Custom Default Domain Policy (if not existing else edit it).
- Edit this policy and browse to **Computer Configuration > Policies > Administrative Templates > Network > IPv6 Configuration**.
- There is only one entry named "IPV6 Configuration", double-click to set it. 
- Set to **Enabled** and in the IPV6 Configuration picking-list, choose "**Prefer IPV4 to IPV6**".
- close the Group Policy editor
- Link the GPO "Custom Default Domain Policy" to the domain root and make it higher priority thant the Default Domain Policy.

[Nota 1 : ] Why prefer create a new policy and not directly modify the Default Domain Policy ? Because it's a bad practice to modify Default Domain Policy and Default Domain Controller Policy. In case of Human Error, it's easy to make un backtrack by quickly disable the Custom Default Domain Policy. 

[Nota 2 : ] If you proceed to a ***gpupdate /force*** on a computer, then later run a ***ipconfig /all***, you will notice that you always see "**Link Local IPV6 Address**" in the prompt, it's normal. After, retarting the computer, this information is no longer displayed. 


ref. : [how-to-disable-ipv6-through-group-policy](https://social.technet.microsoft.com/wiki/contents/articles/5927.how-to-disable-ipv6-through-group-policy.aspx)

## Final Word

Disable IPV6 is a bad practice, it's a necessary component, but you can modify the priority between IPv4 and IPv6 to reach your goal.

