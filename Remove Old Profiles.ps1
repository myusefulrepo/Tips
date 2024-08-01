function Remove-OldProfile
{
    <#
.SYNOPSIS
    Remove old profiles on remote computer

.DESCRIPTION
    Remove old profile on remote computer
    All profiles reponding to the following conditions
        - Not loaded
        - And with a LocalPath
        - And Not special profil
        - And with LastUseTime later than the $MaxDay variable
    could be eligible for deletion

.PARAMETER MaxDay
    Number of Day to keep a profile before deletion
    It's a positive number

.PARAMETER ComputerName
    Name of the remote computer.

.INPUTS
    None

.OUTPUTS
    [SystemObject]

.NOTES
File Name       : Remove-OldProfile.ps1
Version         : V.1.0
Date            : 08/01/2024
Author          : O. FERRIERE
Change          : V.1.0 - 08/01/2024 - initial version

.EXAMPLE
    Remove-OldProfile -Computer 'ASUS11' -MaxDay 30 -WhatIf -Verbose
    Simulation mode only + verbose

.EXAMPLE
    Remove-OldProfile -Computer 'ASUS11' -MaxDay 30 -WhatIf
    Simulation mode only

.EXAMPLE
    Remove-OldProfile -Computer 'ASUS11' -MaxDay 30
    Action mode using the value passed for parameters

.EXAMPLE
    Remove-OldProfile -Computer 'Asus11'
    Action mode using the default value of MaxDay parameter

.EXAMPLE
    Get-Help Remove-OldProfile -ShowWindow
    Full help about the function in a separate windows
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Number of Day to keep a profile before deletion
        [Parameter()]
        [int]
        $MaxDay = '30',

        # Remote computer Name
        [Parameter()]
        [string]
        $Computer = $Env:COMPUTERNAME
    )

    begin
    {
        if ($PSBoundParameters.ContainsKey('verbose') )
        {
            Write-Verbose -Message 'PSBoundParameters and values'
            $PSBoundParameters
        }
    }

    process
    {
        Write-Verbose -Message "Gathering profiles Not loaded And with a LocalPaht And Not special And with LastUseTime later than $MaxDay days"
        $UnloadedProfiles = Get-CimInstance -ClassName Win32_UserProfile -ComputerName $Computer |
            Where-Object {(!$_.Special) -and (!$_.Loaded) -and ($null -ne $_.LocalPath) -and ($_.LastUseTime -lt (Get-Date).AddDays(-$MaxDay))}

        Write-Verbose -Message "Number of profiles count : $($UnloadedProfiles.count)"
        Write-Verbose -Message "List of unloaded profiles on computer : $($Unloadedprofiles.LocalPath -join ("`r`n")) "
    }
    end
    {
        if ($UnloadedProfiles)
        {
            Write-Verbose -Message "there are [$($UnloadedProfiles.count)] old profiles to remove"
            if ($PSBoundParameters.ContainsKey('Whatif') )
            {
                Write-Verbose -Message 'Enter in simulation mode only'
                $UnloadedProfiles | Remove-CimInstance -ComputerName $Computer -WhatIf
            }
            else
            {
                Write-Verbose -Message 'Enter in action mode'
                $UnloadedProfiles | Remove-CimInstance -ComputerName $Computer
            }
        }
    }
}

