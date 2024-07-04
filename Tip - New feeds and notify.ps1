<#
.SYNOPSIS
    Search for new Feeds on one or more site,
    Display in the console and in Windows Notifications

.DESCRIPTION
    Search for new Feeds on one or more site,
    Ddisplay in the console (default) and/or in Windows Notifications with clickable button dependaing of the method choosen.

.PARAMETER NumberofItems
    Number of New feeds to retrieve
    Default value : 5

.PARAMETER URIs
    Array of URL strings to query for new feeds

.PARAMETER method
    Posible values : Console, Toast, Both
    Advice : if you use Toast, decrease the NumberOfItems otherwise you will have a lot of notifications.

.INPUTS
    None

.OUTPUTS
    The scripts creates an array of one or more objects with the following properties

.EXAMPLE
    & '.\new feeds and notify.ps1' -NumberOfItems 5 -URIs "http://powershellisfun.com/feed"
    Run the script using the values of the passed parameters, in this case all paramaters are set.

    The output in console is like :
    New feeds for : [http://powershellisfun.com/feed]

Publication date                Title                                                                                   Link
----------------                -----                                                                                   ----
Fri, 31 May 2024 19:38:17 +0000 PowerShell Arrays                                                                       https://powershellisfun.com/2024/05/31/powershell-arrays/
Fri, 07 Jun 2024 18:30:36 +0000 Discovering the required Microsoft Graph Permissions using PowerShell or Graph Explorer https://powershellisfun.com/2024/06/07/discovering-the-required-microsoft-gra
                                                                                                                        ph-permissions-using-powershell-or-graph-explorer/
Fri, 14 Jun 2024 12:39:26 +0000 Using Measure-Command and Measure-Object in PowerShell                                  https://powershellisfun.com/2024/06/14/using-measure-command-and-measure-obje
                                                                                                                        ct-in-powershell/
Fri, 21 Jun 2024 18:32:38 +0000 Using Debug and Verbose parameters in PowerShell                                        https://powershellisfun.com/2024/06/21/using-debug-and-verbose-parameters-in-
                                                                                                                        powershell/
Sun, 23 Jun 2024 21:22:25 +0000 PSConfEU 2024                                                                           https://powershellisfun.com/2024/06/23/psconfeu-2024/

.EXAMPLE
    & '.\new feeds and notify.ps1' -URIs "http://powershellisfun.com/feed"
    Run the script using the values of the passed parameters, in this case all paramaters are set except NumberOfItem using the default value (2)
    A Windows Notification is displayed too.

    The output is like :
    New feeds for : [http://powershellisfun.com/feed]

Publication date                Title                                            Link
----------------                -----                                            ----
Fri, 21 Jun 2024 18:32:38 +0000 Using Debug and Verbose parameters in PowerShell https://powershellisfun.com/2024/06/21/using-debug-and-verbose-parameters-in-powershell/
Sun, 23 Jun 2024 21:22:25 +0000 PSConfEU 2024                                    https://powershellisfun.com/2024/06/23/psconfeu-2024/

.EXAMPLE
    Get-Help '.\new feeds and notify.ps1' -ShowWindow
    COmplete help about the script in a separate window


.EXAMPLE
    & '.\new feeds and notify.ps1'
    Run the script with the default values for parameters
    DON'T USE IT, The site links are doubled just to serve as an example.

.NOTES
Version         : 1.1
Date            : 04/07/2024
Author          : O. FERRIERE
Change          : v1.0 - 04/07/2024 - Initial Version
                  Based on https://powershellisfun.com/2022/05/30/reading-rss-feeds-in-powershell/
                  Adding Windows Notifications using BurnToast Module
                  v1.1 - Change [Switch] Notify by a [String] Way with a validateSet
#>

[CmdletBinding()]
param (
    [Parameter(HelpMessage = 'Number of New feeds to retrieve')]
    [Int]
    $NumberOfItems = 5,

    [Parameter(HelpMessage = 'Array of URL strings to query for new feeds')]
    [string[]]
    $URIs = @('http://powershellisfun.com/feed', 'http://powershellisfun.com/feed'),

    [Parameter(HelpMessage = 'The Way the output will be displayed')]
    [ValidateSet('Console', 'Toast', 'Both')]
    [string]
    $Method
)

#region import necessary Modules
function Test-Module
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $ModuleName
    )

    If (-not (Get-Module -ListAvailable -Name $ModuleName))
    {
        try
        {
            Install-Module -Name $ModuleName -Scope CurrentUser -ErrorAction Stop
        }
        catch
        {
            Write-Output "The Module $ModuleName was not found on the PSGallery"
            Throw
        }
    }
    Import-Module -Name $ModuleName
}
Test-Module -ModuleName BurntToast
#endregion import necessary Modules

#region verbose mode
if ($PSBoundParameters.Containskey('Verbose') )
{
    $PSBoundParameters
}
#endregion verbose mode

#region Gathering Data
foreach ($link in $URIs)
{
    $Total = foreach ($item in Invoke-RestMethod -Uri $link )
    {
        [PSCustomObject]@{
            'Publication date' = $item.pubDate
            Title              = $item.Title
            Link               = $item.Link
            #Description        = $item.description
        }
    }
}
#endregion Gathering Data

#region display
if ($PSBoundParameters.ContainsKey('Console') )
{
    Write-Verbose -Message 'Display on the console'
    $Total |
        Sort-Object { $_.'Publication Date' -as [datetime] } |
        Select-Object -Last $NumberOfItems |
        Format-Table -AutoSize -Wrap
    Write-Output ' '
}

elseif ($PSBoundParameters.ContainsKey('Toast') )
{
    Write-Verbose -Message 'Launch BurnToast notifications'
    $RSSLinks = ($Total |
            Sort-Object { $_.'Publication Date' -as [datetime] } |
            Select-Object -Last $NumberOfItems).Link
    foreach ($item in $RSSLinks)
    {
        $Button = New-BTButton -Content 'Go to the site' -Arguments "$link"
        $Splat = @{
            Text   = "New feed for $Link", " ==> $Item"
            Sound  = 'IM'
            Button = $Button
        }
        New-BurntToastNotification @Splat
    }
}
#endregion display