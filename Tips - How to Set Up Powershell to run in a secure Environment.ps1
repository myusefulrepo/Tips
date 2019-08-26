<#
The Context : 
> Servers and Admin Servers/Workstations haven't any Internet Access
> You would like to have external help updated ( a .xml file) for these computers
> You would like to have only Approval modules installed on your servers
> You would like to manage Powershell activity

Solution : 
> Create a SBM share to store help files and Modules
  
> Put all reference for modules and help files in this share, and feed it with the corresponding files

> Set up Servers and Admin Servers/workstation to look at this share to update their modules and help files

> Set up Servers and Admin Servers/workstation to follow your Policy about Powershell

#>

#region Step 1 - Create a SBM share to store help files and Modules
<# See : Tips - How to Update-Help in a secure Environment
It's exactly the same for modules and Help File
You can use one SMB share for all or 2 differents SMB Shares
#>
#endregion

#region Step 2 - Put all reference for modules and help files in this share, and feed it with the corresponding files
<# See : Tips - How to Update-Help in a secure Environment
It's exactly the same for modules and Help File
#>
#endregion

#region Step 3 - Set up Servers and Admin Servers/workstation to look at this share to update their modules and help files
<#
To do this, a simple and secure way in to set a Group Policy Object (GPO)

Computer Configuration > Policies > Administratives Templates > Windows Components > Windows Powershell
> Set the default source path for Update-Help 
    EnableUpdateHelpDefaultSourcePath = True
    Path = "\\server\PSHelpFile"
Formally : 
    HKLM\Software\Policies\Microsoft\Windows\PowerShell\UpdatableHelp!EnableUpdateHelpDefaultSourcePath

> Turn on Module Logging
    EnableModuleLogging = True
    ModuleName = *
Formally : 
   HKLM\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging!EnableModuleLogging

>Turn on PowerShell Script Block Logging
   EnableScriptBlockLogging = true
   EnableScriptBlockInvocationLogging = true
Formally : 
   HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging!EnableScriptBlockLogging
   HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging!EnableScriptBlockInvocationLogging

> Turn on PowerShell Transcription
  EnableTranscripting = true
  EnableInvocationHeader= true
  OutputDirectory = C:\PSLogs
Formally
   HKLM\Software\Policies\Microsoft\Windows\PowerShell\Transcription!EnableTranscipting
   HKLM\Software\Policies\Microsoft\Windows\PowerShell\Transcription!EnableInvocationHeader


> Turn on Script Execution
   EnableScripts = true
   ExecutionPolicy = RemoteSigned
Formally 
   HKLM\Software\Policies\Microsoft\Windows\PowerShell!EnableScripts
   HKLM\Software\Policies\Microsoft\Windows\PowerShell!ExecutionPolicy

A next step to perform is to set up the Internal Share as a "trusted" PSRepository and Set up the 
> Create a .pS1 file named Microsoft.PowerShell_profile.ps1 (an another named Microsoft.PowerShellISE_profile.ps1 for ISE, and another Microsoft.VSCode_profile.PS1 for VSCode).
> Feed the .ps1 file with the following 
                Import-Module PowerShellGet
                $Path = '\\Server\Share\PSInternalRepo'
                $Myrepository = @{
                    Name = 'PSInternalRepository'
                    SourceLocation = $Path
                    PublishLocation = $Path
                    InstallationPolicy = 'Trusted'
                }
                Register-PSRepository @Myrepository
Put this .ps1 file in '\\Server\Share\PSProfiles'
Nota : Some other things could populate the profile files as your need. 

> Create another .ps1 script Profiles.ps1 an put it on a DC in the following %SystemRoot%\SYSVOL\sysvol\<domain DNS name>\Policies\{GUID}\User\Scripts\Logon
        $Source = '\\Server\Share\PSProfiles'
        $Destination = 'C:\users\*\WindowsPowerShell\'
        Get-ChildItem $Destination | ForEach-Object {Copy-Item -Path $Source -Destination $_ -Force -Recurse}

> Force the application of this last .ps1 script by the logon script in a GPO
Computer Configuration > Policies > Windows Settings > Scripts
   Name : Profile.ps1

At this step, all users receive by a GPO a "Compliance" profile that Register-PSrepository with your Internal Repository
#>
#endregion