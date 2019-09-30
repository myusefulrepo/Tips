Write-Host "Loading profile" -ForegroundColor Yellow
write-host "Profile Running-time : "  (Measure-Command {
    Write-Verbose "Set up Location "
    $Profile_ScriptFolder = "C:\Temp"
    if(Test-Path $Profile_ScriptFolder)
    {Set-Location -Path $Profile_ScriptFolder}

    Write-Verbose "Setting somme default parameters"
    #$PSDefaultParameterValues["CmdletName:ParameterName"]="DefaultValue" ref : https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameters_default_values?view=powershell-5.1
    $PSDefaultParameterValues = @{
                                    '*:Encoding' = 'UTF8'                            # depending of your context
                                    'Install-Module:Scope' = 'CurrentUser'           # depending of your context
                                    'Test-NetConnection:InformationLevel' = 'Quiet'  # No progress bar
                                    'Test-Connection:Count' = '1'                    # replace default 4
                                    'Export-Csv:NoTypeInformation' = $true           # Efficient
                                    'Export-Csv:delimiter' = ";"                     # depending of your context. Efficient in FR language where ";" is the default separator
                                    'ConvertTo-Csv:NoTypeInformation' = $true        # Efficient
                                    'Write-EZlog:LogFile'   = $LogFile               # Only if you use EZLog Module in your scripts
                                    'Write-EZLog:Delimiter' = ';'                    # Only if you use EZLog Module in your scripts
                                    'Write-EZLog:ToScreen'  = $true                  # Only if you use EZLog Module in your scripts
                                    'Get-WinEvent:LogName'='System'                  # it is often the most common
                                    '*-Module:Repository' = 'PSInternalRepository'   # this entry is register in DNS, pointing to '\\Server\Share\PSInternalRepo'. Useful if different PSRepository are still existing
                                    Receive-Job:Keep’ = $true                        # useful is you use receive-job and always forget -keep parameter to keep the data returned by the cmdlet.
}
    Write-verbose "Setting prompt"
    Function Get-Time { return $(get-date | ForEach-Object { $_.ToLongTimeString() } ) }
    Function prompt {
            # Write the time
            write-host "[" -noNewLine
            write-host $(Get-Time) -foreground yellow -noNewLine
            write-host "] " -noNewLine
            # Write the path
            write-host $($(Get-Location).Path.replace($home, "~").replace("\", "/")) -foreground green -noNewLine
            write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
            return "> "
        }

    Write-verbose "Custom UI"
    if ($isAdmin)
    {
	    $host.UI.RawUI.WindowTitle = "Administrator: $ENV:USERNAME@$ENV:COMPUTERNAME - $env:userdomain"
    }
    else
    {
	    $host.UI.RawUI.WindowTitle = "$ENV:USERNAME@$ENV:COMPUTERNAME - $env:userdomain"
    }


    Write-Verbose "Set up common Alias"
    Set-Alias -Name npp -Value "C:\Program Files (x86)\Notepad++\notepad++.exe"
    Set-Alias -Name np -Value "C:\Windows\system32\notepad.exe"

    Write-Verbose "Set up Show GUI"
    $IPAddress=@(Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DefaultIpGateway})[0].IPAddress[0]
    $PSVersion=($Host | Select-Object -ExpandProperty Version) -replace '^.+@\s'
    Write-Host "# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Yellow
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++++++++"
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++  ++++++`tHi $($env:UserName)!"
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "+++  +++++"
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++  ++++`tComputerName`t`t`t`t" -nonewline; Write-Host $($env:COMPUTERNAME) -ForegroundColor Cyan
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++  ++++`tAdresse IP`t`t`t`t`t" -nonewline; Write-Host $IPAddress -ForegroundColor Cyan
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "+++  +++++`tNom Utilisateur`t`t`t`t" -nonewline; Write-Host $env:UserDomain\$env:UserName -ForegroundColor Cyan
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++      ++`tVersion de PowerShell `t`t" -nonewline; Write-Host $PSVersion -ForegroundColor Cyan
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++++++++`tExecutionPolicy `t`t`t" -nonewline; Write-Host $(Get-ExecutionPolicy) -ForegroundColor Cyan
    Write-Host "# + " -ForegroundColor Yellow -nonewline; Write-Host "++++++++++"
    Write-Host "# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++`n" -ForegroundColor Yellow

    Write-verbose "Set-up Update Modules Help and Modules on Friday"
    $Date = Get-Date
    if ($Date.DayOfWeek -eq "friday")
        {
        Write-Host "Update Help in a background job (Get-job to check)"
        Start-Job -Name "UpdateHelp" -ScriptBlock { Update-Help } | Out-null
        }

    if ($Date.DayOfWeek -eq "friday")
        {
        Write-Host " Update module in a background job (Get-job to check)"
        Start-Job -Name "UpdateModule" -ScriptBlock {
            Get-InstalledModule |
                foreach {
                        $New = (find-module $_.name).version
                        if ($New -ne $_.version)
                            {
                            Write-Host "$($_.name) has an update from $($_.version) to $New" -ForegroundColor green
                            Update-Module -Name ($_.name) -force
                            Write-Host "$($_.name) a été mis à jour" -ForegroundColor Yellow
                            } # end if
                        } # end foreach
            } # end scriptblock
        } # end if

    Write-verbose "Learn Something today"
    Get-Command -Module Microsoft*,Cim*,PS*,ISE | Get-Random | Get-Help -ShowWindow

    }).Milliseconds "ms"  -foregroundcolor Cyan
Get-Job
Write-Host "Profile loaded." -ForegroundColor Yellow
