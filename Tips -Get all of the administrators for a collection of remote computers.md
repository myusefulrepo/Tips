# Get all of the administrators for a collection of remote computers

Never mind how you get the list of remote computers : we have a list (and we have previously store it in a var called $Computers), then use it.

## Principle
For this, we're looking in the CIM Class *Win32_Group* a well-known SID : **S-1-5-32-544**
This is the DIS of the Administrators (local) group.
Then, in this group, we're looking for the CIM Class associated : *Win32_UserAccount*

## In action

````powershell
# Gathering info
$Result = Get-CimInstance -ClassName Win32_Group -Filter 'SID = "S-1-5-32-544"' -ComputerName $computerName |
    Get-CimAssociatedInstance -ResultClassName Win32_UserAccount

# Exporting
$Result | Select-Object -Properties * | Export-Csv -Path C:\temp\localAdmins.csv -Delimiter ";" -NoTypeInformation
````

[Nota ] : Feel free to select only the properties you would like to have.

## Out-dated WMF
If the target servers are 2008R2 or older they may have outdated WMF, in which case you'd have to use a cim session. It's a quick step, though you probably don't need it :

````powershell
# Gathering Info
$cimSession = New-CimSession -ComputerName $computerName -SessionOption (New-CimSessionOption -Protocol Dcom)
$Result = Get-CimInstance -ClassName Win32_Group -Filter 'SID = "S-1-5-32-544"' -CimSession $cimSession |
    Get-CimAssociatedInstance -ResultClassName Win32_UserAccount

# Exporting
$Result | Select-Object -Properties * | Export-Csv -Path C:\temp\localAdmins.csv -Delimiter ";" -NoTypeInformation
````
Like the previous sample, feel free to select the needed properties before exporting.


Hope this help
