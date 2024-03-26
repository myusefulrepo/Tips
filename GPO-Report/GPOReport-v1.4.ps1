<#
 .Synopsis
    Report Script about GPOs

 .DESCRIPTION
    Report Script about GPOs
    all information collected is dynamic: No information is requested from the user
     - Dynamic Gathering of GPOs in the Active Directory domain
     - Dynamic Gathering of links (linked to) from GPOs
     - Dynamic Gathering of different points of attention
         GPOs linked to the Domain Root
         GPOs with Computers and Users sections disabled
         GPOs that are not linked to any OU
         GPOs empty of any parameters
         GPOs with computer section empty but enabled
         GPOs with user section empty but enabled
         Ownerless GPOs
         GPOs enforced and application order
         OUs with Inheritance of GPOs blocked.
         GPOs with a LogonScript/LogoffScript in User Configuration
         POs with a LogonScript/LogoffScript in Computer Configuration
         GPOs with a LogonScript in User and Computer Configuration
     - Export (GPO report) in html format for each GPO (optional if passed in param)
     - Generation of the report in Html format with all of this information
         Uses the Powershell PSWriteHtml module for output
    - Export (GPO report) in html format for each GPO (optional if passed in param)
    - Generation of the report in Html format with all of this information
         Uses the Powershell PSWriteHtml module for output

     Important and compliant information appears on a green background
     Important and compliant, but not "standard" information appears on an orange background
     Important non-compliant information appears on a red background

.PARAMETER IndividualReport
    [Switch]
    Default value false
    If this parameter is passed (without value) the value of the switch takes the value true
    If this parameter is omitted, the swith value remains false
    Also generates an individual report for each GPO

.PARAMETER TranscriptLog
    [Switch]
    Default value false
    If this parameter is passed (without value) the value of the switch takes the value true
    If this parameter is omitted, the swith value remains false
    Generates a script log transcript file (automatic path)

 .INPUTS
    none

 .OUTPUTS
    Report file in Html format
    Default location : $PSScriptRoot (current script directory)

 .NOTES
    Author             : O. FERRIERE
    Date               : 26/03/2024
    Version            : 1.4
    Changement/version : 1.0 19/01/2021 - Version Initiale - basée sur les infos et l'exemple suivant : https://evotec.xyz/active-directory-dhcp-report-to-html-or-email-with-zero-html-knowledge/
                         1.1 20/01/2020 - Ajout OUs avec Héritage des GPOs bloqué.
                                          Ajout de la liste des GPO avec un logon Script
                                          Ajout d'un export (GPO report) au format html pour chaque GPO - Optionnel en param
			            1.2 22/01/2021 - Paramétrage pour utiliser TLS1.2 pour mettre à jour les modules sur powershellGallery à partir du 01/04/2020
							ref: https: //devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
                        1.3 12/10/2023 - Ajout Zones de texte explicatives, Chart et panels dans la sortie HTML
                                         Ajout paramètre TranscriptLog (switch) pour avoir ou non un fichier de log
                        1.4 26/04/2023 - Fix help (forgot TranscriptLog parameter)
                                       - Integral Translation to English
                                       - Taking information into account in verbose mode
                                       - some additional info in the 2nd Tab

 .EXAMPLE
    .\GPO_Report-v1.4.ps1
    Runs the script and generates the report

 .EXAMPLE
    .\GPO_Report-v1.4.ps1 -IndividualReport
    Runs the script, generates the report as well as the individual report (GPO report) for each GPO

 .EXAMPLE
    Get-Help .\GPO_Report-v1.4.ps1 -ShowWindow
    Full help on this script on a separate Windows
 #>

[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $IndividualReport,

    [Parameter()]
    [Switch]
    $TranscriptLog
)

#region Settings to use TLS1.2
# Setting to use TLS1.2 for updating module since 04/01/2020
# ref : https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#endregion Settings to use TLS1.2

#region Check if All necessary modules are installed, if not download or stop
Write-Verbose -Message 'Check if the GroupPolicy module is installed'
If (-not (Get-Module -ListAvailable -Name GroupPolicy))
{
    Write-Warning "Module GroupePolicy doesn't exist on this computer. End of script"
    break
}

Write-Verbose -Message 'Check if the module PSWriteHtml is installed'
If (-not (Get-Module -ListAvailable -Name PSWriteHtml))
{
    # On fait l'installation pour l'utilisateur courant, on pourrait le faire pour tous les utilisateurs de la machine tout aussi bien, mais il faudrait pour ce faire exécuter le script en "Run As Admin"
    # We do the installation for the current user, we could do it for all users of the machine just as easily, but to do this we would have to execute the script in "Run As Admin"
    Try
    {
        Write-Information 'The PSWriteHtml module not installed, Download and Install ... : '
        Install-Module PSWriteHTML -Force -Scope CurrentUser -ErrorAction stop
    }
    Catch
    {
        Write-Error "The PSWriteHTML Module could not be installed. An error occurs. Erreur Message : $_. . End of script."
        Break
    }
}
#endregion Check if All necessary modules are installed, if not download or break

#region Import Module
Write-Verbose -Message 'Import PSWriteHtml Module ... '
Write-Verbose -Message 'Import module GroupPolicy module ... '
Import-Module PSWriteHTML
Import-Module GroupPolicy
#endregion Import Module

#region Declarations
# Date utiliée pour horodater les noms de fichier
$Date = Get-Date -Format 'dd_MM_yyyy'

# FullName du fichier de sortie du script
#$ReportPath = "c:\temp\GPOReport-du-$Date.html" # pour test only
$ReportPath = "$PSScriptRoot\GPOReport-du-$Date.html" # version finale
Write-Verbose -Message "FullName of the report file that will be generated : $ReportPath"
#endregion Declarations

#region Setting the default behavior of certain cmdlets
Write-Verbose 'Setting the default behavior of certain cmdlets : '
$PSDefaultParameterValues = @{
    'New-HTMLSection:HeaderBackGroundColor' = 'Green'
    'New-HTMLSection:CanCollapse'           = $true
}

if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $PSDefaultParameterValues
}
#endregion Setting the default behavior of certain cmdlets

#region Log file initialization
if ($PSBoundParameters.ContainsKey('TranscriptLog'))
{
    # FullName of Script log file
    $LogFile = "$PSScriptRoot\AuditGPOs-$Date.log"
    Write-Output " Full name of the script log file that will be generated : $LogFile"
    Start-Transcript -Path $LogFile
}
#endregion Log file initialization

#region Gathering all GPOs info
Write-Verbose -Message 'Gathering All GPOs info'
$AllGpos = Get-GPO -All
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $AllGpos
}
#endregion Gathering all GPOs info

#region Gathering Selective info about GPOs
Write-Verbose -Message 'Gathering Selective info about GPOs'
$AllGpoInfo = foreach ($Item in $Allgpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    [PSCustomObject]@{
        'Name'                 = $Gpoxml.GPO.Name
        'Description'          = $Item.Description
        'CreationTime'         = $Gpoxml.GPO.CreatedTime
        'ModifiedTime'         = $Gpoxml.GPO.ModifiedTime
        'Owner'                = $item.Owner
        'ComputerEnabled'      = $Gpoxml.GPO.Computer.Enabled
        'UserEnabled'          = $Gpoxml.GPO.User.Enabled
        'LinksTo'              = $Gpoxml.GPO.LinksTo.SOMPath
        'WMIFilterName'        = $Gpoxml.GPO.FilterName
        'WMIFilterDescription' = $Gpoxml.GPO.FilterDescription
    }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $AllGpoInfo
}

#endregion Gathering Selective info about GPOs

#region Gathering GPO Links
Write-Verbose -Message 'Gathering GPO Links'
$GpoLinks = foreach ($Item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    foreach ($Link in $Gpoxml.GPO.LinksTo)
    {
        [PSCustomObject]@{
            'Name'        = $Gpoxml.GPO.Name
            'LinksTo'     = $Link.SOMPath
            'LinkEnabled' = $Lien.Enabled
        }
    }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $GpoLinks | Sort-Object Name
}
#endregion Gathering GPO Links

#region Gathering GPOs linked to the Domain Root
Write-Verbose -Message 'Gathering Domain DistinguishedName'
$domainDN = (Get-ADDomain).DistinguishedName
Write-Verbose -Message 'Gathering GPOs linled to the domain root'
$gpoLinks = Get-GPInheritance -Target $domainDN | Select-Object -ExpandProperty GpoLinks
$GPOLinkedToDomainRoot = foreach ($Item in $gpoLinks)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.GpoId
    [PSCustomObject]@{
        'Name'            = $Gpoxml.GPO.Name
        'Description'     = $Item.Description
        'CreationTime'    = $Gpoxml.GPO.CreatedTime
        'ModifiedTime'    = $Gpoxml.GPO.ModifiedTime
        'Owner'           = $gpoxml.GPO.SecurityDescriptor.Owner.Name.'#text'
        'ComputerEnabled' = $Gpoxml.GPO.Computer.Enabled
        'UserEnabled'     = $Gpoxml.GPO.User.Enabled
    }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $GPOLinkedToDomainRoot
}
#endregion Gathering GPOs linked to the Domain Root

#region Gathering GPOs with the Computer and User sections Disabled (GPO to delete)
Write-Verbose -Message 'Gathering GPOs with the Computer and User sections Disabled (GPO to delete)'
$AllSettingsDisabledGpos = $AllGpos | Where-Object { $_.GpoStatus -eq 'AllSettingsDisabled' }
$GpoWithAllSettingsDisabled = foreach ($item in $AllSettingsDisabledGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    [PSCustomObject]@{
        'Name'                        = $Gpoxml.GPO.Name
        'CreationTime'                = $Gpoxml.GPO.CreatedTime
        'ModifiedTime'                = $Gpoxml.GPO.ModifiedTime
        'ComputerEnabled'             = $gpoxml.GPO.Computer.Enabled
        'UserEnabled'                 = $gpoxml.GPO.User.Enabled
        'LinksTo'                     = $Gpoxml.GPO.LinksTo.SOMPath
        'WmiFilterName'               = $Gpoxml.GPO.FilterName
        'WmiFilterDescription'        = $Gpoxml.GPO.FilterDescription
        'Suggested Corrective Action' = 'GPO to remove'
    }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $GpoWithAllSettingsDisabled
}
#endregion Gathering GPOs with the Computer and User sections Disabled (GPO to delete)

#region Gathering unlinked to an OU (GPO to be deleted)
Write-Verbose -Message 'Gathering unlinked to an OU (GPO to be deleted)'
$AllGposUnlinked = foreach ($item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    if (-not ($Gpoxml.GPO.LinksTo.SOMPath))
    {
        # Current GPO links to no OU
        [PSCustomObject]@{
            'Name'                        = $Gpoxml.GPO.Name
            'Description'                 = $Item.Description
            'CreationTime'                = $Gpoxml.GPO.CreatedTime
            'ModifiedTime'                = $Gpoxml.GPO.ModifiedTime
            'ComputerEnabled'             = $gpoxml.GPO.Computer.Enabled
            'UserEnabled'                 = $gpoxml.GPO.User.Enabled
            'LinksTo'                     = $Gpoxml.GPO.LinksTo.SOMPath
            'WmiFilterName'               = $Gpoxml.GPO.FilterName
            'WmiFilterDescription'        = $Gpoxml.GPO.FilterDescription
            'Suggested Corrective Action' = 'GPO to remove'
        }
    }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $AllGposUnlinked
}
#endregion Gathering unlinked to an OU (GPO to be deleted)

#region Gathering empty GPO (GPO to be deleted)
Write-Verbose -Message ' Gathering empty GPO (GPO to be deleted)'
$AllGposEmpty = [System.Collections.Generic.list[PSObject]]::new()
$AllGposWithEmptyComputerSection = [System.Collections.Generic.list[PSObject]]::new()
$AllGposWithEmptyUserSection = [System.Collections.Generic.list[PSObject]]::new()
foreach ($item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    if ( ($null -eq ($Gpoxml.GPO.Computer.ExtensionData)) -and ($null -eq ($Gpoxml.GPO.User.extensionData)) )
    {
        # the current GPO has no Computer or User settings
        $Obj = [PSCustomObject]@{
            'Name'                        = $Gpoxml.GPO.Name
            'CreationTime'                = $Gpoxml.GPO.CreatedTime
            'ModifiedTime'                = $Gpoxml.GPO.ModifiedTime
            'ComputerSettings'            = if ($gpoxml.GPO.computer.ExtensionData -like '')
            {
                'No parameter'
            }
            else
            {
                'Present parameter'
            }
            'UserSettings'                = if ($gpoxml.GPO.User.ExtensionData -like '')
            {
                'No parameter'
            }
            else
            {
                'Present parameter'
            }
            'Suggested Corrective Action' = 'GPO to remove'
        }
        # Adding to $AllGposEmpty variable
        $AllGposEmpty.add($Obj)
    }

    if ( ($null -eq ($Gpoxml.GPO.Computer.ExtensionData) -and ($Item.GpoStatus -ne 'ComputerSettingsDisabled')) )
    {
        # the current GPO has no Computer settings but the section is enabled
        $Obj = [PSCustomObject]@{
            'Name'                        = $Gpoxml.GPO.Name
            'CreationTime'                = $Gpoxml.GPO.CreatedTime
            'ModifiedTime'                = $Gpoxml.GPO.ModifiedTime
            'gpoStatus'                   = $Item.GPOStatus
            'ComputerSettings'            = if ($gpoxml.GPO.Computer.ExtensionData -like '')
            {
                'No parameter'
            }
            else
            {
                'Present parameter'
            }
            'Suggested Corrective Action' = 'Disable Computer Settings section'
        }
        # Adding to $AllGposWithEmptyComputerSection variable
        $AllGposWithEmptyComputerSection.add($Obj)
    }

    if ( ($null -eq ($Gpoxml.GPO.User.ExtensionData) -and ($Item.GpoStatus -ne 'UserSettingsDisabled')) )
    {
        # the current GPO has no Computer settings but the section is enabled
        $Obj = [PSCustomObject]@{
            'Name'                        = $Gpoxml.GPO.Name
            'CreationTime'                = $Gpoxml.GPO.CreatedTime
            'ModifiedTime'                = $Gpoxml.GPO.ModifiedTime
            'gpoStatus'                   = $Item.GPOStatus
            'ComputerSettings'            = if ($gpoxml.GPO.User.ExtensionData -like '')
            {
                'No parameter'
            }
            else
            {
                'Present parameter'
            }
            'Suggested Corrective Action' = 'Disable User Settings section'
        }
        # Adding to $AllGposWithEmptyComputerSection variable
        $AllGposWithEmptyuserSection.add($Obj)
    }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $AllGposEmpty
    $AllGposWithEmptyComputerSection
    $AllGposWithEmptyuserSection
}
#endregion Gathering empty GPO (GPO to be deleted))

#region Gathering GPOs whose owner no longer exists (GPO To be corrected)
Write-Verbose -Message 'Gathering GPOs whose owner no longer exists (GPO To be corrected)'

$AllGposWithoutOwner = foreach ($item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    if ($Null -eq $Gpoxml.GPO.SecurityDescriptor.Owner.Name.'#text')
    {
        # The GPO has no existing owner accounts
        [PSCustomObject]@{
            'Name'                        = $Gpoxml.GPO.Name
            'CreationTime'                = $Gpoxml.GPO.CreatedTime
            'ModifiedTime'                = $Gpoxml.GPO.ModifiedTime
            'Owner'                       = $Gpoxml.GPO.SecurityDescriptor.Owner.Name.'#text'
            'Suggested Corrective Action' = 'GPO to be corrected'
        }
    }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $AllGposWithoutOwner
}
#endregion Gathering GPOs whose owner no longer exists (GPO To be corrected)

#region Gathering Enforced GPOs
Write-Verbose -Message 'Gathering Enforced GPOs'
# Gatheiring all OUs in the domain
$AllGposEnforced = (Get-ADOrganizationalUnit -Filter * | Get-GPInheritance).GpoLinks |
    Select-Object -Property Target, DisplayName, Enabled, Enforced, Order |
    Where-Object -Property Enforced -EQ $true
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $AllGposEnforced
}
#endregion "Gathering Enforced GPOs"

#region Gathering OUs with GPO inheritance block
Write-Verbose -Message 'Gathering All OUs of the domain'
$OUs = Get-ADOrganizationalUnit -Filter * | Select-Object -Property DistinguishedName
Write-Verbose -Message 'Gathering OUs with GPO inheritance block'
$AllInheritanceOU = foreach ($ou in $ous)
{
    Get-GPInheritance -Target $OU.DistinguishedName |
        Where-Object { $_.GPOInheritanceBlocked } |
        Select-Object -Property @{ Label = 'OU DistinguishedName' ; Expression = { $OU.DistinguishedName } },
        @{ Label = 'GpoInheritanceBlocked' ; Expression = { $_.GpoInheritanceBlocked } }
}
if ($PSBoundParameters.ContainsKey('Verbose'))
{
    $AllInheritanceOU
}
#endregion Gathering OUs with GPO inheritance block

#region Gathering GPO with LogonScript
Write-Verbose -Message 'Gathering GPO with LogonScript'
try
{
    $UserScript = @()     # Array Init
    $ComputerScript = @() # Array Init
    ForEach ($Gpo in $Allgpos)
    {
        # Start-Sleep -Seconds 5
        $xml = [xml]($Gpo | Get-GPOReport -ReportType XML)
        # User logon script
        $Scripts = @($xml.GPO.User.ExtensionData | Where-Object { $_.Name -eq 'Scripts' })
        If ($Scripts.count -gt 0)
        {
            $Scripts.extension.Script | ForEach-Object {
                $ObjUser = [PSCustomObject] @{
                    GPOName    = $gpo.DisplayName
                    GPOState   = $gpo.GpoStatus
                    GPOType    = 'User'
                    Type       = $_.Type
                    Script     = $_.command
                    ScriptType = $_.command -replace '.*\.(.*)', '$1'
                    RunOrder   = $_.RunOrder
                    Order      = $_.Order
                }
                $UserScript += $ObjUser
            }# end foreach
        } # end if user

        # Computer logon script
        $Scripts = @($xml.GPO.Computer.ExtensionData | Where-Object { $_.Name -eq 'Scripts' })
        If ($Scripts.count -gt 0)
        {
            $Scripts.extension.Script | ForEach-Object {
                $ObjComputer = [PSCustomObject] @{
                    GPOName    = $gpo.DisplayName
                    ID         = $gpo.ID
                    GPOState   = $gpo.GpoStatus
                    GPOType    = 'Computer'
                    Type       = $_.Type
                    Script     = $_.command
                    ScriptType = $_.command -replace '.*\.(.*)', '$1'
                    RunOrder   = $_.RunOrder
                    Order      = $_.Order
                }
                $ComputerScript += $ObjComputer
            } # end foreach
        } # end if computer
    } # end foreach gpo
    $AllGposWithScript = $UserScript + $ComputerScript
    if ($PSBoundParameters.ContainsKey('Verbose'))
    {
        $AllGposWithScript
    }
}

Catch
{
    Write-Warning ('{0}' -f $_.exception.message)
}

#endregion Gathering GPO with LogonScript

#region HTM Output
Write-Verbose -Message 'Generating Report ...'

New-HTML -FilePath $ReportPath -Online -ShowHTML {
    # 1st Tab : GPO inventory
    New-HTMLTab -Name 'Inventory' {
        New-HTMLSection {
            New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
            New-HTMLPanel -BackgroundColor LightSalmon -AlignContentText right -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text 'Total number of GPOs' -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text "$($AllGpoInfo.Count)" -Alignment center -FontSize 15
                } # end New-HtmlText
            } # end New-HtmlPanel
            New-HTMLPanel -BackgroundColor LightSalmon -AlignContentText right -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text 'Total number of unlinked GPOs' -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text "$($AllGposUnlinked.Count)" -Alignment center -FontSize 15
                } # end New-HtmlText
            } # end New-HtmlPanel
            New-HTMLPanel -BackgroundColor lightSalmon -AlignContentText right -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text 'Total number of empty GPOs' -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text "$($AllGposEmpty.Count)" -Alignment center -FontSize 15
                } # end New-HtmlText
            } # end New-HtmlPanel
            New-HTMLPanel {
                New-HTMLChart -Gradient {
                    New-ChartPie -Name 'Linked GPOs' -Value $(($AllGpos.Count - $AllGposUnlinked.count) / $($AllGpos.Count) * 100)
                    New-ChartPie -Name 'Unlinked GPOs' -Value $(($AllGposUnlinked.count) / $($AllGpos.Count) * 100)
                }
            }#end New-HtmlPanel
        } #End New-HtmlSection

        # Here we'll put the information that we previously put in the variable $AllGpoInfo
        New-HTMLSection -HeaderText 'GPOs Inventory' {
            $AllGpoInfo = $AllGpoInfo | Select-Object -Property Name, Description, CreationTime, ModifiedTime, Owner, ComputerEnabled, UserEnabled, LinksTo, WMIFilterName, WMIFilterDescription
            New-HTMLTable -DataTable $AllGpoInfo {
                New-TableContent -ColumnName Description, CreationTime, ModifiedTime, Owner, ComputerEnabled, UserEnabled, LinksTo, WMIFilterName, WMIFilterDescription -Alignment center
                New-TableContent -ColumnName Name -Alignment center -Color White -BackgroundColor Green
                New-TableCondition -Name ComputerEnabled -ComparisonType string -Operator like -Value 'false' -BackgroundColor red -Color white
                New-TableCondition -Name UserEnabled -ComparisonType string -Operator like -Value 'false' -BackgroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection

        # Here we will put the information that we previously put in the variable $GpoLinks
        New-HTMLSection -HeaderText 'GPO Links' {
            New-HTMLTable -DataTable $GpoLinks {
                New-TableContent -ColumnName 'Name', 'LinksTo', 'LinkEnabled' -Alignment center
                New-TableContent -ColumnName 'Name' -Alignment center -Color White -BackgroundColor Green
                New-TableCondition -Name 'LinkEnabled' -ComparisonType string -Operator like -Value 'false' -BackgroundColor red -Color white
                New-TableCondition -Name 'LinkEnabled' -ComparisonType string -Operator like -Value 'true' -BackgroundColor green -Color white
            }#end new-htmltable
        }#end new-htmlSection
    } # end New-HtmlTab

    #2nd Tab : Attention points and anomalies
    New-HTMLTab -Name 'Attention points and anomalies' {
        # Here we will put the information that we previously put in the variable $GPOLinkedToDomainRoot
        New-HTMLSection -HeaderText 'GPOs Linked to the Domain Root' {
            New-HTMLTable -DataTable $GPOLinkedToDomainRoot {
                New-TableContent -ColumnName Name, Description, CreationTime, ModifiedTime, Owner, ComputerEnabled, UserEnabled -Alignment center
                New-TableContent -ColumnName Name -Alignment center -Color White -BackgroundColor Green
                New-TableCondition -Name UserEnabled -ComparisonType string -Operator like -Value 'false' -BackgroundColor orange -Color white
                New-TableCondition -Name ComputerEnabled -ComparisonType string -Operator like -Value 'false' -BackgroundColor orange -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info About GPOs  Linked to the the Domain Root' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above shows the GPOs linked to the domain root.'
                    'Domain root GPOs apply to all computers and users in the domain'
                    ' To avoid human error due to inappropriate use, it may be necessary to :'
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Make sur these GPOs must be linked to the domain Root (applied on the Domain Controllers, Servers, Workstations, Users)'
                    New-HTMLListItem -Text 'minimize their number as much as possible'
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $GpoWithAllSettingsDisabled
        New-HTMLSection -HeaderText 'GPOs with Computer and User sections disabled' {
            New-HTMLTable -DataTable $GpoWithAllSettingsDisabled {
                New-TableContent -ColumnName Name, Description, CreationTime, ModifiedTime, ComputerEnabled, UserEnabled, LinksTo, WmiFilterName, WmiFilterDescription, 'Suggested Corrective Action' -Alignment center
                New-TableContent -ColumnName Name -Alignment center -Color White -BackGroundColor Green
                New-TableCondition -Name 'ComputerEnabled' -ComparisonType string -Operator like -Value 'False' -BackgroundColor red -Color white
                New-TableCondition -Name 'UserEnabled' -ComparisonType string -Operator like -Value 'False' -BackgroundColor red -Color white
                New-TableContent -ColumnName 'Suggested Corrective Action' -BackGroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info About GPOs with Computer and User sections disabled' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above shows the GPOs which are completely deactivated. It is necessary to question the relevance of maintaining these GPOs'
                    ' To avoid human error due to inappropriate use, it may be necessary to :'
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Delete these GPOs'
                    New-HTMLListItem -Text "Rename these GPOs, eg by prefixing them with 'Disabled'"
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection


        # Here we will put the information that we previously put in the variable $AllGposUnlinked
        New-HTMLSection -HeaderText 'GPOs that are not linked to any OU' {
            New-HTMLTable -DataTable $AllGposUnlinked {
                New-TableContent -ColumnName Name, Description, CreationTime, ModifiedTime, ComputerEnabled, UserEnabled, LinksTo, WmiFilterName, WmiFilterDescription, 'Suggested Corrective Action' -Alignment center
                New-TableContent -ColumnName Name -Alignment center -Color White -BackgroundColor Green
                New-TableContent -ColumnName LinksTo -BackGroundColor red -Color white
                New-TableContent -ColumnName 'Suggested Corrective Action' -BackGroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations GPOs that are not linked to any OU' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above shows the GPOs that are not linked. It is necessary to question the relevance of maintaining these GPOs'
                    ' To avoid human error due to inappropriate use, it may be necessary to :'
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Delete these GPOs'
                    New-HTMLListItem -Text "Rename these GPOs, eg by prefixing them with 'ToDelete' or 'Test'"
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $AllGposEmpty
        New-HTMLSection -HeaderText 'GPOs empty of any parameters' {
            New-HTMLTable -DataTable $AllGposEmpty {
                New-TableContent -ColumnName Name, CreationTime, ModifiedTime, ComputerSettings, UserSettings, 'Suggested Corrective Action' -Alignment center
                New-TableContent -ColumnName 'Name' -Alignment center -Color White -BackgroundColor Green
                New-TableContent -ColumnName ComputerSettings -BackgroundColor red -Color White
                New-TableContent -ColumnName UserSettings -BackgroundColor red -Color White
                New-TableContent -ColumnName 'Suggested Corrective Action' -BackGroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPOs empty of any parameters' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above presents the GPOs which are completely empty of any parameters. It is necessary to question the relevance of maintaining these GPOs'
                    ' To avoid human error due to inappropriate use, it may be necessary to :'
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Delete these GPOs'
                    New-HTMLListItem -Text "Remane these GPOs, eg by prefixing them with 'ToDelete' or 'InProgress'"
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $AllGposWithEmptyComputerSection
        New-HTMLSection -HeaderText 'GPOs with computer section empty but enabled' {
            New-HTMLTable -DataTable $AllGposWithEmptyComputerSection {
                New-TableContent -ColumnName Name, CreationTime, ModifiedTime, ComputerSettings, GPOStatus, 'Suggested Corrective Action' -Alignment center
                New-TableContent -ColumnName 'Name' -Alignment center -Color White -BackGroundColor Green
                New-TableContent -ColumnName ComputerSettings, GPOStatus -BackGroundColor red -Color White
                New-TableContent -ColumnName 'Suggested Corrective Action' -BackgroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPOs with computer section empty but enabled' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above presents the GPOs which are  empty of any parameters in the computer section.'
                    ' The Computer section must be disabled to avoid time consumption'
                }#end New-htmlText
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $AllGposWithEmptyUserSection
        New-HTMLSection -HeaderText 'GPOs with user section empty but enabled' {
            New-HTMLTable -DataTable $AllGposWithEmptyUserSection {
                New-TableContent -ColumnName Name, CreationTime, ModifiedTime, UserSettings, GPOStatus, 'Suggested Corrective Action' -Alignment center
                New-TableContent -ColumnName 'Name' -Alignment center -Color White -BackgroundColor Green
                New-TableContent -ColumnName UserSettings, GPOStatus -BackgroundColor red -Color White
                New-TableContent -ColumnName 'Suggested Corrective Action' -BackGroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPOs with user section empty but enabled' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above presents the GPOs which are empty of any parameters in the user section.'
                    ' The User section must be disabled to avoid time consumption'
                }#end New-htmlText
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $AllGposWithoutOwner
        New-HTMLSection -HeaderText 'GPOs With no Owner' {
            New-HTMLTable -DataTable $AllGposWithoutOwner {
                New-TableContent -ColumnName Name, CreationTime, ModifiedTime, Owner, 'Suggested Corrective Action' -Alignment center
                New-TableContent -ColumnName Name -Alignment center -Color White -BackgroundColor Green
                New-TableContent -ColumnName 'Suggested Corrective Action' -BackgroundColor red -Color White
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPOs without owner' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The table above shows the GPOs that no longer have an owner.'
                    'This can happen when the account that created the GPO no longer exists.'
                    'By default, only domain administrators, enterprise administrators, GPO creator owners, and SYSTEM can create new GPOs.'
                    'It is necessary to apply the following corrective measure: '
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'If the domain administrator wants a non-administrator or non-administrator group to be able to create GPOs, that user or group can be added to the Group Policy Creator Owners group.'
                    New-HTMLListItem -Text 'Use the Delegation tab of the Group Policy Objects container in GPMC to delegate the creation of GPOs. When a non-administrator who is a member of the GPO Creator Owners group creates a GPO, that user becomes the creator owner of the GPO and can edit the GPO and edit permissions on the GPO. When an administrator creates a GPO, the Domain Administrators group becomes the creating owner of the GPO.'
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $AllGposEnforced
        New-HTMLSection -HeaderText 'GPO Enforced and application order' {
            New-HTMLTable -DataTable $AllGposEnforced {
                New-TableContent -ColumnName DisplayName, Enabled, Enforced, Target, Order -Alignment center
                New-TableContent -ColumnName DisplayName -Alignment center -Color White -BackgroundColor Green
                New-TableContent -ColumnName Enforced -Alignment center -Color White -BackgroundColor Red
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPO Enforced and application order ' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "The table above shows the GPOs that are in 'Appliqué' status en Fr language"
                    "This term is inappropriate in French, because the English version is 'Enforced'"
                    "Which means 'force the application."
                    "'Enforced' disrupts the order of application of GPOs (the parameters and their values of an 'Enforced' GPO take precedence over the same parameters with different values in a normally higher priority GPO)."
                    'In order to avoid any inappropriate application, it is necessary to question and limit this use as much as possible.'
                    "eg : We build a GPO whose parameters must absolutely be applied very quickly, but we do not have time to check if another more priority GPO already has the said parameters. The 'enforced' must then not be be only temporary."
                    'We can find ourselves in this situation when:'

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "Question the relevance of 'enforced application' for each GPO concerned."
                    New-HTMLListItem -Text "Remove unnecessary 'enforced application'."
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $AllInheritanceOU
        New-HTMLSection -HeaderText 'OUs with blocked GPO inheritance' {
            New-HTMLTable -DataTable $AllInheritanceOU {
                New-TableContent -ColumnName 'ContainerType' -Alignment center
                New-TableContent -ColumnName 'Name' -Alignment center -Color White -BackgroundColor Green
                New-TableContent -ColumnName 'GpoInheritanceBlocked' -Alignment center -Color White -BackgroundColor red
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about OUs with blocked GPO inheritance' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "The Table above shows the Organization Units for which 'Block Inheritance' is checked."
                    'Blocking inheritance results in the non-application of GPOs located at higher levels (Domain, higher level OU, etc.).'
                    'This may cause undesirable effects. It is necessary to limit the use of inheritance blocking as much as possible.'
                    'We will mainly reserve it for tests of limited scope.'

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "Ask yourself the relevance of 'Blocking Legacy' for each Organizational Unit concerned."
                    New-HTMLListItem -Text "Remove unnecessary 'block inheritance'."
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the $UserScript variable
        New-HTMLSection -HeaderText 'GPOs with a LogonScript/LogoffScript in User Configuration' {
            New-HTMLTable -DataTable $UserScript {
                New-TableContent -ColumnName GPOState, GPOType, Type, Script, ScriptType, Order, RunOrder -Alignment center
                New-TableContent -ColumnName GPOName -Alignment center -Color White -BackgroundColor Green
                New-TableContent -ColumnName Script -Alignment center -Color White -BackGroundColor Orange
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPOs with a LogonScript/LogoffScript in User Configuration' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above shows the GPOs that have a User logonScript/LogoffScript. '
                    'A LogonScript only applies to the Logon/Logoff, even if the GPO is refreshed.'
                    'Many actions performed in the past via LogonScript/LogoffScripts can be usefully replaced by the use of Administrative Templates.'
                    'The latter do not have the same limitations and even have many advantages (eg: Map of network drives, Map Printers). '

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Question the relevance of each LogonScript or LogoffScript.'
                    New-HTMLListItem -Text 'Replace them with an item in the Administrative Templates - where existing - whenever possible.'
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the $ComputerScript variable
        New-HTMLSection -HeaderText 'GPOs with a LogonScript/LogoffScript in Computer Configuration' {
            New-HTMLTable -DataTable $ComputerScript {
                New-TableContent -ColumnName GPOState, GPOType, Type, Script, ScriptType, Order, RunOrder -Alignment center
                New-TableContent -ColumnName GPOName -Alignment center -Color White -BackGroundColor Green
                New-TableContent -ColumnName Script -Alignment center -Color White -BackgroundColor Orange
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPOs with a LogonScript/LogoffScript in Computer Configuration' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above shows the GPOs that have a Computer logonScript/LogoffScript. '
                    'A LogonScript only applies to the Logon/Logoff, even if the GPO is refreshed.'
                    'Many actions performed in the past via LogonScript/LogoffScripts can be usefully replaced by the use of Administrative Templates.'
                    'The latter do not have the same limitations and even have many advantages (eg: Map of network drives, Map Printers). '

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Question the relevance of each LogonScript or LogoffScript.'
                    New-HTMLListItem -Text 'Replace them with an item in the Administrative Templates - where existing - whenever possible.'
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Here we will put the information that we previously put in the variable $AllGposWithScript
        New-HTMLSection -HeaderText 'GPOs with a LogonScript in User or Computer Configuration' {
            New-HTMLTable -DataTable $AllGposWithScript {
                New-TableContent -ColumnName GPOState, GPOType, Type, Script, ScriptType, Order, RunOrder -Alignment center
                New-TableContent -ColumnName GPOName -Alignment center -Color White -BackGroundColor Green
                New-TableContent -ColumnName Script -Alignment center -Color White -BackgroundColor Orange
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Info about GPOs with a LogonScript in User or Computer Configuration' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'The Table above shows the GPOs that have a Computer or User logonScript/LogoffScript. '
                    'A LogonScript only applies to the Logon/Logoff, even if the GPO is refreshed.'
                    'Many actions performed in the past via LogonScript/LogoffScripts can be usefully replaced by the use of Administrative Templates.'
                    'The latter do not have the same limitations and even have many advantages (eg: Map of network drives, Map Printers). '


                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Question the relevance of each LogonScript or LogoffScript.'
                    New-HTMLListItem -Text 'Replace them with an item in the Administrative Templates - where existing - whenever possible.'
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection
    } # end New-HtmlTab

    New-HTMLFooter {
        New-HTMLText -Text 'Report generated on : ' -Alignment center -FontWeight bold
        New-HTMLText -Text "$(Get-Date)" -Alignment center
    }# End New-htmlFooter
}#end new-html

Write-Output "Report available here : $ReportPath"
#endregion HTM Output

#region report file by GPO
if ($IndividualReport)
{
    # the switch was passed as a parameter
    Write-Output 'An export in html format of each GPO will be performed'
    $Date = Get-Date -Format 'yyyy-MM-dd_hh-mm-ss'
    (Get-GPO -All).DisplayName |
        ForEach-Object {
            Get-GPOReport -Name $_ -ReportType Html -Path "$PSScriptRoot\$_-Au-$Date.html"
        }
    Write-Output "Export of reports in html format for each GPO has been generated here : $PSScriptRoot"
}
#endregion report file by GPO

#region Log file finalisation
if ($PSBoundParameters.ContainsKey('TranscriptLog'))
{
    Stop-Transcript
}
#endregion Log file finalization
