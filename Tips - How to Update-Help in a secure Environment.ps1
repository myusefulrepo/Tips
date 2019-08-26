<#
The Context : 
> Servers and Admin Servers/Workstations haven't any Internet Access
> You would like to have external help updated ( a .xml file) for these computers

Solution : 
> Create a SBM share to store help files
  
> Put all reference for help files in this share, and feed it with the corresponding help files

> Set up Servers and Admin Servers/workstation to look at this share to update their help

#>


# In action 

#region Step one : Create a smb Share and set up Share access And NTFS Permissions
$SMBShareParams=@{
    Path = "\\server\PSHelpFile" 
    Name = "PSHelpFile" 
    Description = "Help file for PS Modules" 
    ReadAccess = Everyone 
    FullAccess = "Domain\Domain Admins" # replace by you appropriate Admin Group for the domain
}
New-SmbShare  @SMBShareParams
$NTFSAccessUsersParams = @{
    Path = "\\server\PSHelpFile" 
    Account = "Domain\Domain Users" 
    AccessRights = ReadAndExecute 
    AccessType = Allow
}
Add-NTFSAccess @NTFSAccessAdminParams
$NTFSAccessUsersParams = @{
    Path = "\\server\PSHelpFile" 
    Account = "Domain\Domain Admins" # replace by you appropriate Admin Group for the domain
    AccessRights = FullControl
    AccessType = Allow
}
Add-NTFSAccess @NTFSAccessAdminParams
#endregion 

#region Step 2 - Put all all help files in this share
<# 
From a Admin server/Workstation where all modules you use in your environment run the following :
 This Will export in a .xml file the file containing all references for the module you use
#>
$ModuleList = "x:\PSHelpFiles\ModuleList.xml"
Get-Module -ListAvailable | Export-Clixml -Path $ModuleList

# Then go to a computer that have access to the Internet ans run the following
$ModuleList = "x:\PSHelpFiles\ModuleList.xml"
Save-Help -DestinationPath $ModuleList 
<#Assume that servers can't access to the Internet and can't feed directly the share
> Save the files on a local folder then copy it to a removable media. 
> Finally, transport the removable media back to server hosting the share.  

Nota 1 : for the next time you perform this action, you will perform only "Update-Help" instead of "Save-Help"
 In this context, you can't update by a scheduled scipt because, it requires that the removable media be present
 Don't forget to do this update task somtetimes.

Nota 2 : You can Save-Help for different Language like this: 
Save-Help -UICulture de-DE, en-US, fr-FR, ja-JP -DestinationPath $ModuleList

Nota 3 : You can Save-Help for one or more specifics modules like this : 
Save-Help -Module Microsoft.PowerShell* -DestinationPath $ModuleList


#>
$ModuleList = "x:\PSHelpFiles"
$PSHelpFile = "\\server\PSHelpFile"
Copy-Item -Path $ModuleList -Destination $PSHelpFile -Recurse -Force
#endregion

#region Step Three : Set up Servers and Admin Servers/workstation to look at this share to update their help
<#
To do this, a simple and secure way in to set a Group Policy
Computer Configuration > Policies > Administratives Templates > Windows Components > Windows Powershell
> Set the default source path for Update-Help 
    Enable = True
    Path = "\\server\PSHelpFile"
Formally : HKLM\Software\Policies\Microsoft\Windows\PowerShell\UpdatableHelp!EnableUpdateHelpDefaultSourcePath
#>
#endregion

