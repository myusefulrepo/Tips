# A SMALL INTRO
Today, **Security is not an option**. It must be thought upstream.
A few years ago Microsoft introduced a new feature called "Network Level Authentication", which improves the security of RDP connections.

There are 2 important Registry Keys
For Remote Desktop Connexion
````HKLM:\System\CurrentControlSet\Control\Terminal Server -Name fDenyTSConnections Value 1 or 0```` - 1 = Disabled, 0 = Enabled

For Network Level Authentication
````HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp -Name UserAuthentication Value 1 or 0```` - 0 = Disabled, 1 = Enabled


# HOW TO CHECK IF NLA IS ENABLED ON A LIST OF COMPUTERS
You can run the following cmdlines, to check if this feature is enabled
````powershell
Invoke-Command -ComputerName srv1,srv2 -ScriptBlock{
        Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption |
        Select-Object -Property @{Label = 'OSVersion' ; Expression = {$_.Caption}},
                                @{Label = 'RDPEnabled'; Expression = {-not([bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections').fDenyTSConnections)}},
                                @{Label = 'NLAEnabled'; Expression = {[bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication').UserAuthentication}} |
        Select-Object -Property PSComputerName, OSVersion, RDPEnabled, NLAEnabled
}
````
>[Note]
> In the previous code, it applies to srv1 and srv2 computers


# And how to remediate it (enable NLA) ... on OS > Windows XP or Windows 2003
````powershell
Invoke-Command -ComputerName srv1,srv2  -scriptBlock{
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1
}
````
>[Note]
> the registry entry ````UserAuthentication```` doesn't exist with windows versions less than or equal to Windows XP or Windows 2003 (Windows Vista or Windows 2003 R2 are the first version with this feature)


# BEST PRACTICES
There are several ways to compromise a computer using Remote Desktop feature, and there are several ways to manage remote computers too without using Remote Desktop : Remote Shell, Remote Management
Go ahead and ***disable Remote Desktop*** on the servers that it’s enabled on.

>[Note]
>If the remote computers (servers) are running with a core environment (with no GUI) : there's even less of a reason to connect to them with remote desktop.
>Install the necessary management tools on your workstation or a jump server and manage them remotely.

````powershell
Invoke-Command -ComputerName srv1, srv2 -ScriptBlock {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 1
}
````

and confirm RDP is disabled on these computers

````powershell
Invoke-Command -ComputerName srv1,srv2 -ScriptBlock{
        Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption |
        Select-Object -Property @{Label = 'OSVersion' ; Expression = {$_.Caption}},
                                @{Label = 'RDPEnabled'; Expression = {-not([bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections').fDenyTSConnections)}},
                                @{Label = 'NLAEnabled'; Expression = {[bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication').UserAuthentication}} |
        Select-Object -Property PSComputerName, OSVersion, RDPEnabled, NLAEnabled
}
````
The result looks like this :
````powershell
PSComputerName OSVersion                                        RDPEnabled NLAEnabled
-------------- ---------                                        ---------- ----------
srv1           Microsoft Windows server2012 R2 Datacenter       False      False
````

Since RDP is now disabled, there is no reason for Remote Desktop to be allowed in the Windows Firewall on theses systems, so we'll also disable it.
````powershell
Invoke-Command -ComputerName srv2, srv2 -ScriptBlock {
    Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Enabled False -PassThru
}
````
>[Note]
>Careful, if you're working with OS installed in your current Language, the Display Group corresponding to Remote Desktop could be named differently

Identify the Display Group by the following
````powershell
Get-NetFirewallRule |
    Select-Object Name, DisplayName, DisplayGroup |
    Sort-Object displayGroup
````
Now I've identify the DisplayGroup, it's something like "Bureau à distance*" in french, then I'm running the following
````powershell
Get-NetFirewallRule -DisplayGroup "Bureau à distance*" |
    Select-Object Name, DisplayName, DisplayGroup, Enabled, Direction |
    Sort-Object displayGroup -Unique
````
Now I can disable the Remote Desktop Display Group : replacing 'Remote Desktop' by "Bureau à distance*"

# WHAT NEWT AT THIS STEP
Build a script that :
- Query Active Directory to Gather computers (Servers **and** Workstations)
- Check if RDP is enabled and if NLA is enabled (see the previous code)
- Report in an friendly user way (.xlsx with the PS module Import-Excel it could be the best, but .csv in an easiest way by native cmdlets)

Now the report receiver, examine each server and decide if RDP should be enabled or not by completing the report file.
After that, the same script or a second one if it's easier to do
- Remediate all necessary computers in the asset



# IN BRIEF
1 - **Remote Desktop must be disabled as much as possible**
*Don't forget to disable the corresponding Windows Firewall DisplayGroup*

2 - **if Remote Desktop must be enabled, then**
*Network Level Authentication must be enabled*
*The Windows Firewall must be enabled and the DisplayGroup "Remote Desktop" (careful depending of your current display language) must be enabled too.*

# Ref :
https://mikefrobbins.com/2019/06/14/mitigating-bluekeep-with-powershell/
https://blogs.technet.microsoft.com/msrc/2019/05/14/prevent-a-worm-by-updating-remote-desktop-services-cve-2019-0708/
