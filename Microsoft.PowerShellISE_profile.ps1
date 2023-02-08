Write-Host 'Loading Profil' -ForegroundColor Yellow
Write-Host 'Profil Loading Time : ' (Measure-Command { 

        #region Settings to use TLS1.2 to update modules from PowershellGallery since 01 May 2020
        Write-Host 'Setting :  Use TLS1.2 to update modules from PowershellGallery since 01 May 2020' -ForegroundColor 'DarkGray'
        # ref : https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #endregion Settings to use TLS1.2 to update modules from PowershellGallery since 01 May 2020

        #region Location Settings
        Write-Host 'Setting : Location' -ForegroundColor 'DarkGray'
        $Profile_ScriptFolder = 'C:\Temp'
        if (Test-Path $Profile_ScriptFolder) 
        {
            Set-Location -Path $Profile_ScriptFolder
        }
        #endregion Location Settings
 
        #region Default settings for some cmdlets
        #$PSDefaultParameterValues["CmdletName:ParameterName"]="DefaultValue" 
        # ref : https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameters_default_values?view=powershell-5.1
        Write-Host "Setting : Encoding using UTF8 for all cmdlets *:Encoding' = 'UTF8'" -ForegroundColor 'DarkGray'
        Write-Host 'Setting : Default Module installation with -Scope CurrentUser' -ForegroundColor 'DarkGray'
        Write-Host 'Setting : Test-NetConnection with -InformationLevel Detailed' -ForegroundColor 'DarkGray'
        Write-Host 'Setting : Test-Connection with -Count 1' -ForegroundColor 'DarkGray'
        Write-Host 'Setting : Export-Csv with -NoTypeInformation' -ForegroundColor 'DarkGray'
        Write-Host 'Setting : Export-Csv with -Delimiter ;' -ForegroundColor 'DarkGray'
        Write-Host 'Setting : EZlog with -LogFile' -ForegroundColor 'DarkGray'
        Write-Host 'Setting : EZlog with -Delimiter ; ' -ForegroundColor 'DarkGray'
        Write-Host 'Setting : EZlog with -ToScreen ' -ForegroundColor 'DarkGray'

        $PSDefaultParameterValues = @{
            '*:Encoding'                          = 'UTF8'
            'Install-Module:Scope'                = 'CurrentUser'
            'Test-NetConnection:InformationLevel' = 'detailed'
            'Test-Connection:Count'               = '1' 
            'Export-Csv:NoTypeInformation'        = $true
            'Export-Csv:delimiter'                = ';'
            'ConvertTo-Csv:NoTypeInformation'     = $true
            'Write-EZlog:LogFile'                 = $LogFile
            'Write-EZLog:Delimiter'               = ';'
            'Write-EZLog:ToScreen'                = $true
            'Get-WinEvent:LogName'                = 'System'
        }
        #endregion Default settings for some cmdlets
 
        #region "Settings to look/install modules from an Internal repository
        <#
        Write-Host "Setting to look for modules in an Internal repository" -ForegroundColor  'DarkGray'
        $PSDefaultParameterValues["Find-Module:Repository"] = 'MyRepository'
        Write-Host "Setting to install modules from the Internal Repository" -ForegroundColor  'DarkGray'
        $PSDefaultParameterValues["Install-Module:Repository"] = 'MyRepository'
        #>
        #endregion Settings to look/install modules from an Internal repository

        #region Prompt setting
        Write-Host 'Setting : Prompt' -ForegroundColor 'DarkGray'
        Function Get-Time
        {
            return $(Get-Date | ForEach-Object { $_.ToLongTimeString() } ) 
        }
        Function prompt
        {
            # Write the time 
            Write-Host '[' -NoNewline
            Write-Host $(Get-Time) -foreground yellow -NoNewline
            Write-Host '] ' -NoNewline
            # Write the path
            Write-Host $($(Get-Location).Path.replace($home, '~').replace('\', '/')) -foreground green -NoNewline
            Write-Host $(if ($nestedpromptlevel -ge 1)
                {
                    '>>' 
                }) -NoNewline
            return '> '
        }
        #endregion Prompt Setting

        #region Custom Windows Setting
        Write-Host 'Setting : Windows Title' -ForegroundColor 'DarkGray'
        [System.Security.Principal.WindowsPrincipal]$CurrentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
        if ( $CurrentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator) ) # S-1-5-32-544 is the Well-Known SID for Administrators (builtin) group
        {
            # Admin mode
            $User = '(Administrator) - ' + $CurrentUser.Identities.Name
        }
        else
        {
            # User mode
            $user = '(Non-Administrator) - ' + $global:currentUser.Identities.Name
        }
        (Get-Host).UI.RawUI.WindowTitle = $user + ' on ' + [System.Net.Dns]::GetHostName() + ' (PS version : ' + (Get-Host).Version + ')'
        #endregion Custom Windows Setting
    
        #region Setting Alias for NP and NPP
        Write-Host 'Setting : Alias for Notepad and Notepad++' -ForegroundColor 'DarkGray'
        Set-Alias -Name npp -Value 'C:\Program Files (x86)\Notepad++\notepad++.exe'
        Set-Alias -Name np -Value 'C:\Windows\system32\notepad.exe'
        #endregion Setting Alias for NP and NPP

        #region Show GUI
        $IPAddress = @(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.DefaultIpGateway })[0].IPAddress[0]
        Write-Host '# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' -ForegroundColor Yellow
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host '++++++++++'
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host "++  ++++++`tHi $($env:UserName)!"
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host '+++  +++++'
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host "++++  ++++`tComputerName`t`t`t`t" -NoNewline; Write-Host $($env:COMPUTERNAME) -ForegroundColor Cyan
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host "++++  ++++`tAdresse IP`t`t`t`t`t" -NoNewline; Write-Host $IPAddress -ForegroundColor Cyan
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host "+++  +++++`tNom Utilisateur`t`t`t`t" -NoNewline; Write-Host $env:UserDomain\$env:UserName -ForegroundColor Cyan
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host "++      ++`tVersion de PowerShell `t`t" -NoNewline; Write-Host $((Get-Host).Version) -ForegroundColor Cyan
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host "++++++++++`tExecutionPolicy `t`t`t" -NoNewline; Write-Host $(Get-ExecutionPolicy) -ForegroundColor Cyan
        Write-Host '# + ' -ForegroundColor Yellow -NoNewline; Write-Host '++++++++++'
        Write-Host "# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++`n" -ForegroundColor Yellow
        #endregion Show GUI

        #region Udpate-Help every Friday
        $Date = Get-Date
        if ($Date.DayOfWeek -eq 'friday') 
        {
            Write-Host 'Update-Help in a background job (Get-job to check)' -ForegroundColor 'DarkGray'
            Start-Job -Name 'UpdateHelp' -ScriptBlock { Update-Help } | Out-Null
        }
        #endregion Udpate-Help every Friday

        #region Update-Module every Friday
        $Date = Get-Date
        if ($Date.DayOfWeek -eq 'friday') 
        {
            Write-Host 'Update-Modules' -ForegroundColor 'DarkGray'
            # Change : 09-Oct-2022, Using a function to update module
            # Source : https://github.com/HarmVeenstra/Powershellisfun/blob/main/Update%20all%20PowerShell%20Modules/Update-Modules.ps1
            # Previously using update-AllPSModules from update-AllPSModules module
            <# loading function
            function Update-Modules
            {
                param (
                    [switch]$AllowPrerelease
                )

                # Test admin privileges without using -Requires RunAsAdministrator,
                # which causes a nasty error message, if trying to load the function within a PS profile but without admin privileges
                if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
                {
                    Write-Warning ('Function {0} needs admin privileges. Break now.' -f $MyInvocation.MyCommand)
                    return
                }

                # Get all installed modules
                Write-Host ('Retrieving all installed modules ...') -ForegroundColor Green
                $CurrentModules = Get-InstalledModule | Select-Object Name, Version | Sort-Object Name

                if (-not $CurrentModules)
                {
                    Write-Host ('No modules found.') -ForegroundColor Gray
                    return
                }
                else
                {
                    $ModulesCount = $CurrentModules.Count
                    $DigitsLength = $ModulesCount.ToString().Length
                    Write-Host ('{0} modules found.' -f $ModulesCount) -ForegroundColor Gray
                }

                # Show status of AllowPrerelease Switch
                ''
                if ($AllowPrerelease)
                {
                    Write-Host ('Updating installed modules to the latest PreRelease version ...') -ForegroundColor Green
                }
                else
                {
                    Write-Host ('Updating installed modules to the latest Production version ...') -ForegroundColor Green
                }

                # Loop through the installed modules and update them if a newer version is available
                $i = 0
                foreach ($Module in $CurrentModules)
                {
                    $i++
                    $Counter = ("[{0,$DigitsLength}/{1,$DigitsLength}]" -f $i, $ModulesCount)
                    $CounterLength = $Counter.Length
                    Write-Host ('{0} Checking for updated version of module {1} ...' -f $Counter, $Module.Name) -ForegroundColor Green
                    try
                    {
                        Update-Module -Name $Module.Name -AllowPrerelease:$AllowPrerelease -AcceptLicense -Scope:AllUsers -ErrorAction Stop
                    }
                    catch
                    {
                        Write-Host ("{0$CounterLength} Error updating module {1}!" -f ' ', $Module.Name) -ForegroundColor Red
                    }

                    # Retrieve newest version number and remove old(er) version(s) if any
                    $AllVersions = Get-InstalledModule -Name $Module.Name -AllVersions | Sort-Object PublishedDate -Descending
                    $MostRecentVersion = $AllVersions[0].Version
                    if ($AllVersions.Count -gt 1 )
                    {
                        Foreach ($Version in $AllVersions)
                        {
                            if ($Version.Version -ne $MostRecentVersion)
                            {
                                try
                                {
                                    Write-Host ("{0,$CounterLength} Uninstalling previous version {1} of module {2} ..." -f ' ', $Version.Version, $Module.Name) -ForegroundColor Gray
                                    Uninstall-Module -Name $Module.Name -RequiredVersion $Version.Version -Force:$True -ErrorAction Stop
                                }
                                catch
                                {
                                    Write-Warning ("{0,$CounterLength} Error uninstalling previous version {1} of module {2}!" -f ' ', $Version.Version, $Module.Name)
                                }
                            }
                        }
                    }
                }

                # Get the new module versions for comparing them to to previous one if updated
                $NewModules = Get-InstalledModule | Select-Object Name, Version | Sort-Object Name
                if ($NewModules)
                {
                    ''
                    Write-Host ('List of updated modules:') -ForegroundColor Green
                    $NoUpdatesFound = $true
                    foreach ($Module in $NewModules)
                    {
                        $CurrentVersion = $CurrentModules | Where-Object Name -EQ $Module.Name
                        if ($CurrentVersion.Version -notlike $Module.Version)
                        {
                            $NoUpdatesFound = $false
                            Write-Host ('- Updated module {0} from version {1} to {2}' -f $Module.Name, $CurrentVersion.Version, $Module.Version) -ForegroundColor Green
                        }
                    }

                    if ($NoUpdatesFound)
                    {
                        Write-Host ('No modules were updated.') -ForegroundColor Gray
                    }
                }
            }
        
            Update-Modules
            #>
            # Change : 25/01/2023, Using Update-PSResource cause, the previous function is down (PowershellGet is on v3.xx)
            Write-Host "Update Modules All Users" -ForegroundColor Green
            $UpdateModAllUsers = Start-Job -Name 'UpdateModAllUsers' -ScriptBlock {Get-PSResource -Scope AllUsers | Update-PSResource -Scope AllUsers -Force}
            Write-Host "Update Modules Current User" -ForegroundColor  Green
            $UpdateModCurrentUser = Start-Job -Name 'UpdateModCurrentUser' -ScriptBlock { Get-PSResource -Scope CurrentUser | Update-PSResource -Scope CurrentUser -Force}
        } # end if
        #endregion Update-Module every Friday

        #region Update SysternalsSuite le 1er du mois
        if ($Date.Day -eq "1")
            {
            Write-Host "Update Systernal Suite" -ForegroundColor DarkGray
            $SysternalSuite = Start-Job -Name SysternalSuite -ScriptBlock {. C:\Scripts\Install-SysInternalsSuite.ps1 }
            }
        
        #endregion Update SysternalsSuite le 1er du mois

        #region Learn something today (show help about a ramdom cmdlet)
        <# 
        Write-Host "Learn something today (show help about a ramdom cmdlet)" -ForegroundColor  'DarkGray'
        Get-Command -Module * | Get-Random | Get-Help -ShowWindow
        #>
        #endregion Learn something today (show help about a ramdom cmdlet)

    }).Milliseconds 'ms' -ForegroundColor Cyan

Get-Job
Write-Host 'Fully loaded profile' -ForegroundColor Yellow

#region receive jobs when they are finished
 if ($Date.Day -eq "1")
    {
    Receive-Job -Name UpdateModCurrentUser -Wait
    Receive-Job -Name UpdateModAllUsers -Wait
    Receive-Job -Name SysternalSuite -Wait
    }
#endregion receive jobs when they are finished



