 # How to check if NLA Network Level Authentication is enabled on a list of remote computers 
Invoke-Command -ComputerName srv1,srv2 -ScriptBlock{
        Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption |
        Select-Object -Property @{label='OSVersion';expression={$_.Caption}},
                                @{label='RDPEnabled';expression={-not([bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections').fDenyTSConnections)}},
                                @{label='NLAEnabled';expression={[bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication').UserAuthentication}} | 
        Select-Object -Property PSComputerName, OSVersion, RDPEnabled, NLAEnabled
}

# And how to remediate it ... on OS > Windows XP or Windows 2003
Invoke-Command -ComputerName srv1,srv2  -scriptBlock{
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1
}

<#
 ... and if yhe remote computers (servers) are running with a core environment (with no GUI). There's even less of a reason to connect to them 
 with remote desktop. Install the necessary management tools on your workstation or a jump server and manage them remotely. 
 I’ll go ahead and disable remote desktop on the servers that it’s enabled on.
 #>
	
Invoke-Command -ComputerName srv1, srv2 -ScriptBlock {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 1
}
# and confirm RDP is disabled on these computers
Invoke-Command -ComputerName srv1,srv2 -ScriptBlock{
        Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption |
        Select-Object -Property @{label='OSVersion';expression={$_.Caption}},
                                @{label='RDPEnabled';expression={-not([bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections').fDenyTSConnections)}},
                                @{label='NLAEnabled';expression={[bool](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication').UserAuthentication}} | 
        Select-Object -Property PSComputerName, OSVersion, RDPEnabled, NLAEnabled
}

<# I.E.
PSComputerName OSVersion                                        RDPEnabled NLAEnabled
-------------- ---------                                        ---------- ----------
srv1           Microsoft Windows server2012 R2 Datacenter       False      False
#>

# Since RDP is now disabled, there is no reason for Remote Desktop to be allowed in the Windows Firewall on theses systems, so we'll also disable it.
Invoke-Command -ComputerName srv2, srv2 -ScriptBlock {
    Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Enabled False -PassThru
}

# Careful, if you're working with OS installed in your current Language, the Dipslay Group corresponding to Remote Desktop could be named differently
# I identify the Display Group by the following
Get-NetFirewallRule | Select-Object Name, DisplayName, DisplayGroup | Sort-Object displayGroup
# Now I've identify the DisplayGroup, it's something like "Bureau à distance*", then I'm running the following
Get-NetFirewallRule -DisplayGroup "Bureau à distance*" | Select-Object Name, DisplayName, DisplayGroup, Enabled, Direction | Sort-Object displayGroup -Unique
# Now I can disable the Remote Desktop Display Group : replacing 'Remote Desktop' by "Bureau à distance*"


# ref https://mikefrobbins.com/2019/06/14/mitigating-bluekeep-with-powershell/
# and https://blogs.technet.microsoft.com/msrc/2019/05/14/prevent-a-worm-by-updating-remote-desktop-services-cve-2019-0708/

