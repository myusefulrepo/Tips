To examine the WSManagement configuration we can navigate in the WSMan Drive

````powershell
 Get-ChildItem WSMan:\localhost
````
The result looks like this :
````
   WSManConfig : Microsoft.WSMan.Management\WSMan::localhost
Type            Name                           SourceOfValue   Value
----            ----                           -------------   -----
System.String   MaxEnvelopeSizekb                              500
System.String   MaxTimeoutms                                   60000
System.String   MaxBatchItems                                  32000
System.String   MaxProviderRequests                            4294967295
Container       Client
Container       Service
Container       Shell
Container       Listener
Container       Plugin
Container       ClientCertificate
````
# WS-MAN CLIENT CONFIGURATION
Run the following
```` powershell
Get-ChildItem WSMan:\localhost\Client
````
````
   WSManConfig : Microsoft.WSMan.Management\WSMan::localhost\Client
Type            Name                           SourceOfValue   Value
----            ----                           -------------   -----
System.String   NetworkDelayms                                 5000
System.String   URLPrefix                                      wsman
System.String   AllowUnencrypted                               false
Container       Auth
Container       DefaultPorts
System.String   TrustedHosts                                   Server01,Server02
````
As we can see, we have some interesting informations
- By Default : ````AllowUnencrypted```` is set up to ````False````.
- And we have 2 Trusted Hosts (here, Server01 and Server02)

We can isolate quickly these trusted Host like this
````powershell
(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value
Server01,Server02
````

And we have also access to other informations
````powershell
Get-ChildItem WSMan:\localhost\Client\DefaultPorts
   WSManConfig : Microsoft.WSMan.Management\WSMan::localhost\Client\DefaultPorts
Type            Name                           SourceOfValue   Value
----            ----                           -------------   -----
System.String   HTTP                                           5985
System.String   HTTPS                                          5986
````
Default WSMan IP Port are 5985 and 5986

Now, let's examine the Service section
````powershell
Get-ChildItem WSMan:\localhost\Service
   WSManConfig : Microsoft.WSMan.Management\WSMan::localhost\Service
Type            Name                           SourceOfValue   Value
----            ----                           -------------   -----
System.String   RootSDDL                                       O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)
System.String   MaxConcurrentOperations                        4294967295
System.String   MaxConcurrentOperationsPerUser                 1500
System.String   EnumerationTimeoutms                           240000
System.String   MaxConnections                                 300
System.String   MaxPacketRetrievalTimeSeconds                  120
System.String   AllowUnencrypted                               false
Container       Auth
Container       DefaultPorts
System.String   IPv4Filter                                     *
System.String   IPv6Filter                                     *
System.String   EnableCompatibilityHttpList...                 false
System.String   EnableCompatibilityHttpsLis...                 false
System.String   CertificateThumbprint
System.String   AllowRemoteAccess                              true
````
Wow, ````300 ```` connections by Default, and ````1 500```` concurrent operations Per User
We can also see the following
- ````AllowRemoteAccess```` : Here set to true
- and many other informations.
All these values could be set by a GPO (in a domain) or a Local Policy.

````powershell
Get-ChildItem WSMan:\localhost\Shell
   WSManConfig : Microsoft.WSMan.Management\WSMan::localhost\Shell
Type            Name                           SourceOfValue   Value
----            ----                           -------------   -----
System.String   AllowRemoteShellAccess                         true
System.String   IdleTimeout                                    7200000
System.String   MaxConcurrentUsers                             2147483647
System.String   MaxShellRunTime                                2147483647
System.String   MaxProcessesPerShell                           2147483647
System.String   MaxMemoryPerShellMB                            2147483647
System.String   MaxShellsPerUser                               2147483647
````
For This computer, ````Allow Remote Shell Access ```` is set to ````true````

````powershell
Get-ChildItem WSMan:\localhost\Listener
   WSManConfig : Microsoft.WSMan.Management\WSMan::localhost\Listener
Type            Keys                                Name
----            ----                                ----
Container       {Transport=HTTP, Address=*}         Listener_1084132640
````
For this computer, there is only one listener (http). Https is not set.


# REMOVE ALL TRUSTED HOST : Use Clear-Item cmdlet against WSMan:\localhost\Client\TrustedHosts
i.e. an example :
````powershell
Set-Item WSMan:\localhost\Client\TrustedHosts Server03
Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value
Server03
Clear-Item WSMan:\localhost\Client\TrustedHosts
(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value
````

# REMOVE OR REPLACE One TRUSTED HOST
````powershell
# Define a variable and use the method Replace to substitute first value by another Replace ("ExistingValue","NewValue")
$new = ((Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value).Replace("server01","")
$new
Server01,Server02
# This doesn't work. Replace is Case Sensitive
$new = ((Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value).Replace("Server01,","")
$new
Server02
# Now, Set up the WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts $new
(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value
Server02
````
As you can see, Set-Item replace totally the existing value by the new value.
Now we can proceed again
````powershell
$new2 = ((Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value).replace("Server02","")
$new2
Set-Item WSMan:\localhost\Client\TrustedHosts $new
(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value

````
All value are cleared.

>[Nota] Each time we proceed to a change with Set-Item we have a windows prompt ask to approve the modification. To avoid the prompt to make the change add the paramater ````-Force````.

# ADDING ONE OR MORE TRUSTED HOST
````powershell
(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "server01,server02"
(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value
server01,server02
````
>[Nota] Only one pair of double quote, because the value is a ````|System.String]````

# ADDING A TRUSTED HOST BY IP
You can use an IPv4 or IPv6 address. In the case of IPv6, you have to type the address between [].
Here an example
````powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "10.10.10.1,[0:0:0:0:0:0:0:0]"
(Get-ChildItem WSMan:\localhost\Client\TrustedHosts).value
10.10.10.1,[0:0:0:0:0:0:0:0]
````

# ENCRYPT OR UnENCRYPT WSMan TRAFFIC ?
Even though WS-Management encrypts all traffic by default, it is possible that someone (unknowingly) transmits unencrypted data because the default configuration has been changed. I guess this is why this https://msdn.microsoft.com/en-us/library/ee309366%28v=vs.85%29.aspx about WinRM warns that “under no circumstances should unencrypted HTTP requests be sent through proxy servers.”

The bigger problem is that, if you are working with machines that are not in an Active Directory domain, you don’t have any trust relationship with the remote computers. You are then dealing only with symmetric encryption, so man-in-the-middle attacks are theoretically possible because the key has to be transferred first.

However, you **don’t improve security** just by “defining” IP addresses or computer names as trustworthy. This is just an **extra hurdle** that Microsoft added so you know that you are about to do something risky.
This is where PowerShell Remoting via SSL comes in. For one, HTTPS traffic is always encrypted. Thus, you can always automate your tasks remotely, free of worry. And, because SSL uses asymmetric encryption and certificates, you can be sure that you are securely and directly connected to your remote machine and not to the computer of an attacker that intercepts and relays your traffic.

The main problem is that you need an SSL certificate. If you just want to manage some standalone servers or workstations, you probably don’t like to acquire a publicly-signed certificate and want to work with a self-signed certificate instead.

Because many of these guides predate PowerShell 4, they recommend using **IIS Manager** or download tools such as **OpenSSL** or the **Windows SDK**, which contains **makecert.exe** and **pvk2pfx.exe** that you can use to create a self-signed certificate. I suppose these guides deter many admins from working with SSL and so they choose the easier way of running Invoke-Command and Enter-PSSession over HTTP.

However, you will now see that enabling SSL for WinRM on the client and on the server is not so difficult (although it is not as straightforward as with SSH), and you can do it all with PowerShell’s built-in cmdlets. You don’t even need the notorious winrm Windows command-line tool.

# ENABLING HTTPS FOR POWERSHELL REMOTING
## On the remote computer
The first thing we need to do is create an SSL certificate. (Note that this guide focuses on the usage of a self-signed certificate. If you have a publicly-signed certificate, things are easier and you can use Set-WSManQuickConfig -UseSSL.)
As mentioned above, since the release of PowerShell 4, we don’t require third-party tools for this purpose. The New-SelfSignedCertificate cmdlet is all we need :
````powershell
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "myHost"
````
It is important to pass the name of the computer that you want to manage remotely to the ````‑DnsName```` parameter. `
>[>Nota] If the computer has a DNS name, you should use the fully qualified domain name (FQDN).

If you want to, you can verify that the certificate has been stored correctly using the certificate add-in of the Microsoft Management Console (MMC). Type mmc on the Start screen and add the Certificates add-in for a computer account and the local computer. The certificate should be in the Personal\Certificates folder


We now have to export the certificate to a file because we will have to import it later on our local machine. You can do this with the MMC add-in, but we’ll do it in PowerShell:
````powershell
Export-Certificate -Cert $Cert -FilePath C:\temp\cert
````
The file name doesn’t matter here.
We need the certificate to start the WS-Management HTTPS listener. But we should first enable PowerShell Remoting on the host:
````powershell
Enable-PSRemoting -SkipNetworkProfileCheck -Force
````
>[Nota] ````-SkipNetworkProfileCheck```` ensures that PowerShell won’t complain if your network connection type is set to Public.

Enable-PSRemoting also starts a WS-Management listener, but only for HTTP. If you want to, you can verify this by reading the contents of the WSMan drive:
````powershell
Get-childItem wsman:\localhost\listener
   WSManConfig : Microsoft.WSMan.Management\WSMan::localhost\Listener
Type            Keys                                Name
----            ----                                ----
Container       {Transport=HTTP, Address=*}         Listener_1084132640
````

To ensure that nobody uses HTTP to connect to the computer, you can remove the HTTP listener this way :
````powershell
Get-ChildItem WSMan:\Localhost\listener | Where -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse
````
This command removes all WSMan listeners :
````powershell
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
````
Next, we add our WSMan HTTPS listener :
````powershell
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint –Force
````
We are using the $Cert variable that we defined before to read the Thumbprint, which allows the New-Item cmdlet to locate the certificate in our certificates store.

The last thing we have to do is configure the firewall on the host because the Enable-PSRemoting cmdlet only added rules for HTTP:
````powershell
New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP
````
>[Nota] Notice here that we allow inbound traffic on port 5986. WinRM 1.1 (current version is 3.0) used the common HTTPS port 443. You can still use this port if the host is behind a gateway firewall that blocks port 5986:
````powershell
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value true
````
Of course, you then have to open port 443 in the Windows Firewall. Note that this command won’t work if the network connection type on this machine is set to Public. In this case, you have to change the connection type to private :
````powershell
Set-NetConnectionProfile -NetworkCategory Private
````
For security reasons, you might want to disable the firewall rule for HTTP that Enable-PSRemoting added:
````powershell
Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
````
Our remote machine is now ready for PowerShell Remoting via HTTPS, and we can configure our local computer.

## On the local computer
Things are a bit easier here. First, you have to copy the certificate file to which we exported our certificate. You can then import the certificate with this command:
````powershell
Import-Certificate -Filepath "C:\temp\cert" -CertStoreLocation "Cert:\LocalMachine\Root"
````
>[Nota] We need to store the certificate in the *Trusted Root Certification Authorities* folder here and not in the Personal folder as we did on the remote computer. Your computer “trusts” all machines that can prove their authenticity with the help of their private keys (stored on the host) and the certificates stored here.

By the way, this is why we don’t have to add the remote machine to the TrustedHosts list. In contrast to PowerShell Remoting over HTTP, we can be sure that the remote machine is the one it claims to be, which is the main point of using HTTPS instead of HTTP.
We are now ready to enter a PowerShell session on the remote machine via HTTPS :
````powershell
Enter-PSSession -ComputerName myHost -UseSSL -Credential (Get-Credential)
````
The crucial parameter here is -UseSSL. Of course, we still have to authenticate on the remote machine with an administrator account.

The Invoke-Command cmdlet also supports the -UseSSL parameter:
````powershell
Invoke-Command -ComputerName myHost -UseSSL -ScriptBlock {Get-Process} -Credential (Get-Credential)
````
If your remote host doesn’t have a DNS entry, you can add its IP to the hosts file on your local computer. To do so, open an elevated Notepad and then navigate to %systemroot%\system32\drivers\etc\. Of course, you can also do it the PowerShell if you are working on an elevated console:
````powershell
Add-Content $Env:SystemRoot\system32\drivers\etc\hosts "10.0.0.1 myHost"
````
You will have to reboot after that.

# FINAL WORDS
Once you know how it works, you can complete the entire procedure to configure PowerShell Remoting for HTTPS in a couple of minutes.
- You just create a self-signed SSL certificate on the host
- and start an HTTPS listener using this certificate.
- Then, you create the corresponding firewall rule
- and export the certificate.

- On the local computer, you only have to import the certificate.

>[Nota] HTTPS **doesn’t just add another encryption layer**.  its main purpose is to *verify the authenticity of the remote machine*, thereby preventing ***man-in-the-middle attacks***. Thus, you *only need HTTPS if you do PowerShell Remoting through an insecure territory*.
> Inside your local network, with trust relationships between Active Directory domain members, **WSMan over HTTP** is secure enough.



# IN BRIEF
## View the computers of TrustedHosts list
````powershell
Get-Item WSMan:\localhost\Client\TrustedHosts
````
## Add all computers to the TrustedHosts list using wildcard
````powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value *
````
>[Nota] Use this with discernment

## Add all domain computers to the TrustedHosts list
````powershell
Set-Item WSMan:\localhost\Client\TrustedHosts *.yourdomain.com
````
## Set-Item WSMan:\localhost\Client\TrustedHosts *.yourdomain.com
````powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value <ComputerName1>,[<ComputerName2>]
````
## Add a computer by IP
````Powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "xx.xx.xx.xx" # for IP V4
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "[0:0:0:0:0:0:0:0]" # For IP V6
````




Ref :
https://4sysops.com/archives/powershell-remoting-over-https-with-a-self-signed-ssl-certificate/#comment-643396 an excellent article from Michael Pietroforte
https://4sysops.com/archives/enable-powershell-remoting-on-a-standalone-workgroup-computer/ another excellent article from Michael Pietroforte
https://4sysops.com/archives/enable-powershell-remoting/ (in an Active Directory domain) : an excellent article from Timothy Warner
