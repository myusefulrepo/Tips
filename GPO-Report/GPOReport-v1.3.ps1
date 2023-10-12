<#
 .Synopsis
    Script de report détaillé sur les serveurs GPOs

 .DESCRIPTION
    Script de report détaillé sur les serveurs GPOs
    Toutes les informations recueillies sont dynamiques : Aucune information n'est demandée à l'utilisateur

    - Collecte dynamique des GPOs dans le domaine Active Directory
    - Collecte dynamique des liaisons (linked to) des GPOs
    - Collecte dynamique des Stats pour les Scopes
    - Collecte dynamique de différents points d'attention
        GPOs avec les setions Computers et Users désactivées
        GPOs qui ne sont liées à aucune OU
        GPOs vides de tout paramètre
        GPOs sans propriétaire
        GPOs enforced et ordre d'application des GPO par OU.
        OUs avec Héritage des GPOs bloqué.
        GPOs avec un logon Script (Utilisateur - Computer - Utilisateur et/ou Computer)
    - Export (GPO report) au format html pour chaque GPO (optionnel si passé en param)
    - Génération du Rapport au format Html avec l'ensemble de ces informations
        Utilise le module Powershell PSWriteHtml pour les sorties

    Les informations importantes et conformes apparaissent sur fond vert
    Les informations importantes et conforme, mais non "standards" apparaissent sur fond orange
    Les informations importantes non conformes apparaissent sur fond rouge

.PARAMETER IndividualReport
    [Switch]
    Valeur par défaut true
    Si ce paramètre est passé (sans valeur) la valeur du switch prend la valeur true
    Si ce paramètre est omis, la valeur du swith reste à false

 .INPUTS
    Aucune

 .OUTPUTS
    Fichier Rapport au format Html
    Localisation par défaut : $PSScriptRoot (répertoire courant du script)

 .NOTES
    Auteur             : O. FERRIERE
    Date               : 12/10/2023
    Version            : 1.3
    Changement/version : 1.0 19/01/2021 - Version Initiale - basée sur les infos et l'exemple suivant : https://evotec.xyz/active-directory-dhcp-report-to-html-or-email-with-zero-html-knowledge/
                         1.1 20/01/2020 - Ajout OUs avec Héritage des GPOs bloqué.
                                          Ajout de la liste des GPO avec un logon Script
                                          Ajout d'un export (GPO report) au format html pour chaque GPO - Optionnel en param
			            1.2 22/01/2021 - Paramétrage pour utiliser TLS1.2 pour mettre à jour les modules sur powershellGallery à partir du 01/04/2020
							ref: https: //devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
                        1.3 12/10/2023 - Ajout Zones de texte explicatives, Chart et panels dans la sortie HTML
                                         Ajout paramètre TranscriptLog (switch) pour avoir ou non un fichier de log

 .EXAMPLE
    .\GPO_Report-v1.3.ps1
    Exécute le script et génère le rapport

 .EXAMPLE
    .\GPO_Report-v1.3.ps1 -IndividualReport
    Exécute le script, génère le rapport ainsi que le rapport individuel (GPO report) pour chaque GPO

 .EXAMPLE
    Get-Help .\GPO_Report-v1.3.ps1 -Full
    Aide complète sur ce script
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

#region Utilisation de TLS1.2
# Paramétrage pour utiliser TLS1.2 pour mettre à jour les modules sur powershellGallery à partir du 01/04/2020
# ref : https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#endregion Utilisation de TLS1.2


#region Vérification si les modules sont installés, si non téléchargement ou arrêt
Write-Output 'Vérification que le module GroupPolicy est installé'
If (-not (Get-Module -ListAvailable -Name GroupPolicy))
{
    Write-Output "Le Module n'existe pas sur la machine"
    break
}

Write-Output 'Vérification que le module PSWriteHtml est installé'
If (-not (Get-Module -ListAvailable -Name PSWriteHtml))
{
    # On fait l'installation pour l'utilisateur courant, on pourrait le faire pour tous les utilisateurs de la machine tout aussi bien, mais il faudrait pour ce faire exécuter le script en "Run As Administrator"
    Try
    {
        Write-Output "Le module PSWriteHtml n'est pas installé"
        Write-Output 'Téléchargement et installation ... : '
        Install-Module PSWriteHTML -Force -Scope CurrentUser -ErrorAction stop
    }
    Catch
    {
        Write-Output "Le module n'a pu être installé. Fin du script."
        Write-Output "Une erreur est survenue. Message d'erreur : $_."
        Break
    }
}
#endregion Vérification si les modules sont installés, si non téléchargement ou arrêt

#region Importation des modules pour avoir les cmdlets disponibles
Write-Output 'Import du module PSWriteHtml ... '
Import-Module PSWriteHTML
Write-Output 'Import du module GroupPolicy ... '
Import-Module GroupPolicy
#endregion Importation des modules pour avoir les cmdlets disponibles

#region Declarations
# Date utiliée pour horodater les noms de fichier
$Date = Get-Date -Format 'dd_MM_yyyy'

# FullName du fichier de sortie du script
#$ReportPath = "c:\temp\GPOReport-du-$Date.html" # pour test only
$ReportPath = "$PSScriptRoot\GPOReport-du-$Date.html" # version finale
Write-Output "Nom du fichier rapport qui sera généré : $ReportPath"
#endregion Declarations

#region Paramétrage du comportement par défaut de certaines cmdlets
Write-Output 'Paramétrage du comportement par défaut de certaines cmdlets : '
$PSDefaultParameterValues = @{
    'New-HTMLSection:HeaderBackGroundColor' = 'Green'
    'New-HTMLSection:CanCollapse'           = $true
}
$PSDefaultParameterValues
#endregion Paramétrage du comportement par défaut de certaines cmdlets

#region Log file initialization
if ($PSBoundParameters.ContainsKey('TranscriptLog'))
{
    # FullName du fichier de log du script
    $LogFile = "$PSScriptRoot\AuditGPOs-$Date.log"
    Write-Output "Nom du fichier de log qui sera généré : $LogFile"
    Start-Transcript -Path $LogFile
}
#endregion Log file initialization

#region Collecte de toutes les GPOs
Write-Output 'Collecte de toutes les GPOs'
$AllGpos = Get-GPO -All
$AllGpos
#endregion Collecte de toutes les GPOs

#region Collecte d'info sélectives sur chaque GPO
Write-Output "Collecte d'info sélectives sur chaque GPO"
$AllGpoInfo = foreach ($Item in $Allgpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    [PSCustomObject]@{
        'Nom'                            = $Gpoxml.GPO.Name
        'Description'                    = $Item.Description
        'Date de Création'               = $Gpoxml.GPO.CreatedTime
        'Date de Modification'           = $Gpoxml.GPO.ModifiedTime
        'Propriétaire'                   = $item.Owner
        'Computer Configuration activée' = $gpoxml.GPO.Computer.Enabled
        'User Configuration activée '    = $gpoxml.GPO.User.Enabled
        'Liée à'                         = $Gpoxml.GPO.LinksTo.SOMPath
        'Filtre WMI'                     = $Gpoxml.GPO.FilterName
        'Filtre WMI Description'         = $Gpoxml.GPO.FilterDescription
    }
}
$AllGpoInfo
#endregion Collecte d'info sélectives sur chaque GPO

#region Collecte des GPOs et leurs liens (séparés pour chaque OU distincte)
Write-Output 'Collecte des GPOs et leurs liens (séparés pour chaque OU distincte)'
$GpoLinks = foreach ($Item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    foreach ($Lien in $Gpoxml.GPO.LinksTo)
    {
        [PSCustomObject]@{
            'Nom'         = $Gpoxml.GPO.Name
            'Lié à '      = $Lien.SOMPath
            'Lien activé' = $Lien.Enabled
        }
    }
}
$GpoLinks | Sort-Object Name
#endregion Collecte des GPOs et leurs liens (séparés pour chaque OU distincte)

#region Collecte des GPOs avec les sections Computer et User Désactivées (GPO A SUPRIMER)
Write-Output 'Collecte des GPOs avec les section Computer et User Désactivées (GPO A SUPRIMER)'
$AllSettingsDisabledGpos = Get-GPO -All | Where-Object { $_.GpoStatus -eq 'AllSettingsDisabled' }
$GpoWithAllSettingsDisabled = foreach ($item in $AllSettingsDisabledGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    [PSCustomObject]@{
        'Nom'                            = $Gpoxml.GPO.Name
        'Date de Création'               = $Gpoxml.GPO.CreatedTime
        'Date de Modification'           = $Gpoxml.GPO.ModifiedTime
        'Computer Configuration activée' = $gpoxml.GPO.Computer.Enabled
        'User Configuration activée'     = $gpoxml.GPO.User.Enabled
        'Liée à'                         = $Gpoxml.GPO.LinksTo.SOMPath
        'Filtre WMI'                     = $Gpoxml.GPO.FilterName
        'Filtre WMI Description'         = $Gpoxml.GPO.FilterDescription
        'action corrective'              = 'GPO A SUPPRIMER'
    }
}
$GpoWithAllSettingsDisabled
#endregion Collecte des GPOs avec les sections Computer et User Désactivées (GPO A SUPRIMER)

#region Collecte des GPOs non liées à une OU (GPO A SUPPRIMER)
Write-Output 'Collecte des GPOs non liées à une OU (GPO A SUPPRIMER)'
$AllGposUnlinked = foreach ($item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    if (-not ($Gpoxml.GPO.LinksTo.SOMPath))
    {
        # La GPO n'est liée à aucune OU
        [PSCustomObject]@{
            'Nom'                            = $Gpoxml.GPO.Name
            'Date de Création'               = $Gpoxml.GPO.CreatedTime
            'Date de Modification'           = $Gpoxml.GPO.ModifiedTime
            'Computer Configuration activée' = $gpoxml.GPO.Computer.Enabled
            'User Configuration activée'     = $gpoxml.GPO.User.Enabled
            'Liée à'                         = $Gpoxml.GPO.LinksTo.SOMPath
            'Filtre WMI'                     = $Gpoxml.GPO.FilterName
            'Filtre WMI Description'         = $Gpoxml.GPO.FilterDescription
            'action corrective'              = 'GPO A SUPPRIMER'
        }
    }
}
$AllGposUnlinked
#endregion Collecte des GPOs non liées à une OU (GPO A SUPPRIMER)

#region Collecte des GPOs vides (GPO A SUPPRIMER)
Write-Output 'Collecte des GPOs vides (GPO A SUPPRIMER)'
$AllGposEmpty = foreach ($item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    if ( ($null -eq ($Gpoxml.GPO.Computer.ExtensionData)) -and ($null -eq ($Gpoxml.GPO.User.extensionData)) )
    {
        # La GPO n'a aucun paramètre Computer ou User
        [PSCustomObject]@{
            'Nom'                  = $Gpoxml.GPO.Name
            'Date de Création'     = $Gpoxml.GPO.CreatedTime
            'Date de Modification' = $Gpoxml.GPO.ModifiedTime
            'Paramètres Computer'  = if ($gpoxml.GPO.computer.ExtensionData -like '')
            {
                'Pas de paramètre'
            }
            else
            {
                'Paramètres présents'
            }
            'Paramètres User'      = if ($gpoxml.GPO.User.ExtensionData -like '')
            {
                'Pas de paramètre'
            }
            else
            {
                'Paramètres présents'
            }
            'action corrective'    = 'Aucun paramètre Computer ou User de configuré : GPO A SUPPRIMER'
        }
    }
}
$AllGposEmpty
#endregion Collecte des GPOs vides (GPO A SUPPRIMER)

#region Collecte des GPOs dont le propriétaire n'existe plus (tombstone) (GPO A corriger)
Write-Output "Collecte des GPOs dont le propriétaire n'existe plus (tombstone) (GPO A corriger)"

$AllGposTombstone = foreach ($item in $AllGpos)
{
    [xml]$Gpoxml = Get-GPOReport -ReportType Xml -Guid $Item.Id
    if ($Null -eq $Gpoxml.GPO.SecurityDescriptor.Owner.Name.'#text')
    {
        # La GPO n'a aucun compte propriétaire encore existant
        [PSCustomObject]@{
            'Nom'                  = $Gpoxml.GPO.Name
            'Date de Création'     = $Gpoxml.GPO.CreatedTime
            'Date de Modification' = $Gpoxml.GPO.ModifiedTime
            'Propriétaire'         = $Gpoxml.GPO.SecurityDescriptor.Owner.Name.'#text'
            'action corrective'    = 'A CORRIGER'
        }
    }
}
$AllGposTombstone
#endregion Collecte des GPOs dont le propriétaire n'existe plus (tombstone) (GPO A corriger)

#region Collecte des GPOs "Enforced"
Write-Output 'Collecte des GPOs enforced'
# Collecte de toutes les OUs du domaine
$OU = Get-ADOrganizationalUnit -Filter * | Select-Object -Property DistinguishedName
$AllGposEnforced = @() #initialisation de l'Array
foreach ($item in $OU)
{
    $AllGposEnforced += Get-GPInheritance -Target $item.DistinguishedName | Select-Object -ExpandProperty GpoLinks
}
$AllGposEnforced
#endregion Collecte des GPOs "Enforced"

#region Collecte des OUs avec Héritage (inheritance) des GPO bloqué
Write-Output 'Collecte des OUs avec Héritage (inheritance) des GPO bloqué'
# Collecte de toutes les OUs du domaine
$OUs = Get-ADOrganizationalUnit -Filter * | Select-Object -Property DistinguishedName
$AllInheritanceOU = foreach ($ou in $ous)
{
    Get-GPInheritance -Target $OU.DistinguishedName |
        Where-Object { $_.GPOInheritanceBlocked } |
        Select-Object -Property @{ Label = 'GpoInheritanceBlocked' ; Expression = { $_.GpoInheritanceBlocked } },
        @{ Label = 'Nom OU'                ; Expression = { $_.Name } },
        @{ Label = 'ContainerType'         ; Expression = { $_.ContainerType } }
}
$AllInheritanceOU
#endregion Collecte des OUs avec Héritage (inheritance) des GPO bloqué

#region Collecte des GPOs qui ont un LogonScript
Write-Output 'Collecte des GPOs qui ont un Logon Script'
try
{
    $Allgpos = @(Get-GPO -All)
    $i = 0
    $userlogon = @() # initialisation de l'array
    $Computerlogon = @() # initialisation de l'array
    ForEach ($gpo in $Allgpos)
    {
        #Start-Sleep -Seconds 5
        $i++
        $xml = [xml]($gpo | Get-GPOReport -ReportType XML)
        #User logon script
        $userScripts = @($xml.GPO.User.ExtensionData | Where-Object { $_.Name -eq 'Scripts' })
        If ($userScripts.count -gt 0)
        {
            $userScripts.extension.Script | ForEach-Object {
                $objUser = [PSCustomObject] @{
                    GPOName    = $gpo.DisplayName
                    ID         = $gpo.ID
                    GPOState   = $gpo.GpoStatus
                    GPOType    = 'User'
                    Type       = $_.Type
                    Script     = $_.command
                    ScriptType = $_.command -replace '.*\.(.*)', '$1'
                }
                $userlogon += $objUser
            }# end foreach
        } # end if user

        #Computer logon script
        $computerScripts = @($xml.GPO.Computer.ExtensionData | Where-Object { $_.Name -eq 'Scripts' })
        If ($computerScripts.count -gt 0)
        {
            $computerScripts.extension.Script | ForEach-Object {
                $objcomputer = [PSCustomObject] @{
                    GPOName    = $gpo.DisplayName
                    ID         = $gpo.ID
                    GPOState   = $gpo.GpoStatus
                    GPOType    = 'Computer'
                    Type       = $_.Type
                    Script     = $_.command
                    ScriptType = $_.command -replace '.*\.(.*)', '$1'
                }
                $Computerlogon += $objcomputer
            } # end foreach
        } # end if computer
    } # end foreach gpo
    $AllGposWittLogonScript = $userlogon + $Computerlogon
    $AllGposWittLogonScript
}

Catch
{
    Write-Warning ('{0}' -f $_.exception.message)
}

#endregion Collecte des GPOs qui ont un LogonScript

#region Sortie HTML
Write-Output 'Génération du rapport ...'

New-HTML -FilePath $ReportPath -Online -ShowHTML {
    #1er Onglet : Inventaire GPO
    New-HTMLTab -Name 'Inventaire' {
        
        New-HTMLSection {
            New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
            New-HTMLPanel -BackgroundColor lightpink -AlignContentText right -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text 'Nombre total de GPOs' -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text "$($AllGpoInfo.Count)" -Alignment center -FontSize 15
                } # end New-HtmlText
            } # end New-HtmlPanel
            New-HTMLPanel -BackgroundColor lightpink -AlignContentText right -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text 'Nombre total de GPOs non liées' -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text "$($AllGposUnlinked.Count)" -Alignment center -FontSize 15
                } # end New-HtmlText
            } # end New-HtmlPanel
            New-HTMLPanel {
                New-HTMLChart -Gradient {
                    New-ChartPie -Name 'GPOs Liées' -Value $(($AllGpos.Count - $AllGposUnlinked.count) / $($AllGpos.Count) * 100)
                    New-ChartPie -Name 'GPOs non liées' -Value $(($AllGposUnlinked.count) / $($AllGpos.Count) * 100)
                }
            }#end New-HtmlPanel
        } #End New-HtmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $AllGpoInfo
        New-HTMLSection -HeaderText 'Inventaire des GPOs' {
            $AllGpoInfo = $AllGpoInfo | Select-Object -Property 'Nom', 'Description', 'Date de Création', 'Date de Modification', 'Propriétaire', 'Computer Configuration Activée', 'User Configuration Activée', 'liée à', 'Filtre WMI', 'Filtre WMI Description'
            New-HTMLTable -DataTable $AllGpoInfo {
                New-TableContent -ColumnName 'Nom', 'Description', 'Date de Création', 'Date de Modification', 'Propriétaire', 'Computer Configuration Activée', 'User Configuration Activée', 'liée à', 'Filtre WMI', 'Filtre WMI Description' -Alignment center
                New-TableContent -ColumnName 'Nom' -Alignment center -Color White -BackGroundColor Green
                New-TableCondition -Name 'Computer Configuration Activée' -ComparisonType string -Operator like -Value 'false' -BackgroundColor red -Color white
                New-TableCondition -Name 'User Configuration Activée' -ComparisonType string -Operator like -Value 'false' -BackgroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $GpoLinks
        New-HTMLSection -HeaderText 'Liaison des GPOs' {
            New-HTMLTable -DataTable $GpoLinks {
                New-TableContent -ColumnName 'Nom', 'Lié à', 'Lien activé' -Alignment center
                New-TableContent -ColumnName 'Nom' -Alignment center -Color White -BackGroundColor Green
                New-TableCondition -Name 'Lien Activé' -ComparisonType string -Operator like -Value 'false' -BackgroundColor red -Color white
                New-TableCondition -Name 'Lien Activé' -ComparisonType string -Operator like -Value 'true' -BackgroundColor green -Color white
            }#end new-htmltable
        }#end new-htmlSection
    } # end New-HtmlTab

    #2ème Onglet : Points d'attention et anomalies
    New-HTMLTab -Name 'Points d''attention et anomalies' {
        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $GpoWithAllSettingsDisabled
        New-HTMLSection -HeaderText 'GPOs avec les sections Computer et User désactivées' {
            New-HTMLTable -DataTable $GpoWithAllSettingsDisabled {
                New-TableContent -ColumnName 'Nom', 'Description', 'Date de Création', 'Date de Modification', 'Propriétaire', 'Computer Configuration Activée', 'User Configuration Activée', 'liée à', 'Filtre WMI', 'Filtre WMI Description', 'action corrective' -Alignment center
                New-TableContent -ColumnName 'Nom' -Alignment center -Color White -BackGroundColor Green
                New-TableCondition -Name 'Computer Configuration Activée' -ComparisonType string -Operator like -Value 'False' -BackgroundColor red -Color white
                New-TableCondition -Name 'User Configuration Activée' -ComparisonType string -Operator like -Value 'False' -BackgroundColor red -Color white
                New-TableContent -ColumnName 'action corrective' -BackgroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "Le Tableau ci-dessus présente les GPOs qui sont totalement désactivées. Il est nécessaire de s'interroger sur la pertinence de maintenir ces GPOs"
                    " Afin d'éviter toute erreur humaine d'utilisation inappropriée, il peut être nécessaire de :"
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Supprimer ces GPOs'
                    New-HTMLListItem -Text "Renommer ces GPOs, par exemple en les préfixant avec 'Désactivé'"
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $AllGposUnlinked
        New-HTMLSection -HeaderText 'GPOs qui ne sont liées à aucune OU' {
            New-HTMLTable -DataTable $AllGposUnlinked {
                New-TableContent -ColumnName 'Nom', 'Description', 'Date de Création', 'Date de Modification', 'Propriétaire', 'Computer Configuration Activée', 'User Configuration Activée', 'Filtre WMI', 'Filtre WMI Description', 'action corrective' -Alignment center
                New-TableContent -ColumnName 'Nom' -Alignment center -Color White -BackGroundColor Green
                New-TableContent -ColumnName 'Liée à' -BackgroundColor red -Color white
                New-TableContent -ColumnName 'action corrective' -BackgroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "Le Tableau ci-dessus présente les GPOs qui ne sont pas liées. Il est nécessaire de s'interroger sur la pertinence de maintenir ces GPOs"
                    " Afin d'éviter toute erreur humaine d'utilisation inappropriée, il peut être nécessaire de :"
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Supprimer ces GPOs'
                    New-HTMLListItem -Text "Renommer ces GPOs, par exemple en les préfixant avec 'A_supprimer' ou 'Test'"
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $AllGposEmpty
        New-HTMLSection -HeaderText 'GPOs vides de tout paramètre' {
            New-HTMLTable -DataTable $AllGposEmpty {
                New-TableContent -ColumnName 'Nom', 'Date de Création', 'Date de Modification', 'Paramètres Computer', 'Paramètres User', 'action corrective' -Alignment center
                New-TableContent -ColumnName 'Nom' -Alignment center -Color White -BackGroundColor Green
                New-TableContent -ColumnName 'Paramètres Computer' -BackGroundColor red -Color White
                New-TableContent -ColumnName 'Paramètres User' -BackGroundColor red -Color White
                New-TableContent -ColumnName 'action corrective' -BackgroundColor red -Color white
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "Le Tableau ci-dessus présente les GPOs qui sont totalement vides de tout paramètre. Il est nécessaire de s'interroger sur la pertinence de maintenir ces GPOs"
                    " Afin d'éviter toute erreur humaine d'utilisation inappropriée, il peut être nécessaire de :"
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text 'Supprimer ces GPOs'
                    New-HTMLListItem -Text "Renommer ces GPOs, par exemple en les préfixant avec 'A_supprimer' ou 'En-Cours'"
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $AllGposTombstone
        New-HTMLSection -HeaderText 'GPO sans propriétaire' {
            New-HTMLTable -DataTable $AllGposTombstone {
                New-TableContent -ColumnName 'Nom', 'Date de Création', 'Date de Modification', 'Propriétaire', 'action corrective' -Alignment center
                New-TableContent -ColumnName 'Nom' -Alignment center -Color White -BackGroundColor Green
                New-TableContent -ColumnName 'Propriétaire' -BackGroundColor red -Color White
                New-TableContent -ColumnName 'action corrective' -BackGroundColor red -Color White
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "Le Tableau ci-dessus présente les GPOs qui n'ont plus de propriétaire. "
                    "Cela peut arriver quand le compte qui a créé la GPO n'existe plus. "
                    "Par défaut, seuls les administrateurs de domaine, les administrateurs d'entreprise, les propriétaires des créateurs de stratégie de groupe et SYSTEM peuvent créer de nouveaux objets de stratégie de groupe. "
                    "Il est nécessaire d'appliquer la mesure corrective suivante : "
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "Si l'administrateur du domaine souhaite qu'un groupe non-administrateur ou non-administrateur puisse créer des objets de stratégie de groupe, cet utilisateur ou ce groupe peut être ajouté au groupe Propriétaires du créateur de stratégie de groupe."
                    New-HTMLListItem -Text "Utiliser l'onglet Délégation du conteneur Objets de stratégie de groupe dans GPMC pour déléguer la création de GPO. Lorsqu'un non-administrateur membre du groupe Propriétaires des créateurs de stratégie de groupe crée un objet de stratégie de groupe, cet utilisateur devient le propriétaire créateur de l'objet de stratégie de groupe et peut modifier l'objet de stratégie de groupe et modifier les autorisations sur l'objet de stratégie de groupe. Lorsqu'un administrateur crée une GPO, le groupe Administrateurs de domaine devient le propriétaire créateur de l'objet Stratégie de groupe"
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $AllGposEnforced
        New-HTMLSection -HeaderText "GPO Enforced et ordre d'application par OU" {
            New-HTMLTable -DataTable $AllGposEnforced {
                New-TableContent -ColumnName 'Enabled', 'Enforced', 'Enabled', 'Enforced', 'Target' -Alignment center
                New-TableContent -ColumnName 'DisplayName', 'Order' -Alignment center -Color White -BackGroundColor Green
                New-TableCondition -ColumnName 'Enforced' -ComparisonType string -Operator eq -Value 'True' -BackgroundColor red -Alignment center
                New-TableCondition -ColumnName 'Enforced' -ComparisonType string -Operator eq -Value 'False' -BackgroundColor green -Alignment center

            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "Le Tableau ci-dessus présente les GPOs qui sont en statut 'Appliqué'. "
                    "Ce terme est inapproprié en français, car la version en anglais est 'Enforced', "
                    "Ce qui veut dire 'forcer l'application. "
                    "'Forcer l'application' bouleverse l'ordre d'application des GPOs (les paramètres et leurs valeurs d'une GPO 'Enforced' prennent le dessus sur les mêmes paramètres avec des valeurs différentes dans une GPO normalement plus prioritaire). "
                    " Afin d'éviter toute application inappropriée, il est nécessaire de s'interroger et de limiter autant que possible cet usage. "
                    "On construit rapidement une GPO dont les paramètres doivent être absolument appliqués très rapidement, mais qu'on n'a pas le temps de vérifier si une autre GPO plus prioritaire possède déjà les dits paramètres. Le 'forcer l'application' ne doit alors être que temporaire. "
                    'On peut se trouver dans ce cas quand :'

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "S'interroger sur la pertinence de 'forcer l'application' pour chaque GPO concernée."
                    New-HTMLListItem -Text "Supprimer les 'forcer l'application' non nécessaires."
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $AllInheritanceOU
        New-HTMLSection -HeaderText 'OUs avec Héritage (inheritance) des GPO bloqué' {
            New-HTMLTable -DataTable $AllInheritanceOU {
                New-TableContent -ColumnName 'ContainerType' -Alignment center
                New-TableContent -ColumnName 'Nom OU' -Alignment center -Color White -BackGroundColor Green
                New-TableContent -ColumnName 'GpoInheritanceBlocked' -Alignment center -Color White -BackGroundColor red
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    "Le Tableau ci-dessus présente les Unités d'organisation pour lesquelles 'Bloquer l'héritage' est coché. "
                    "Le blocage de l'héritage entraine la non-application des GPOs situées à des niveaux supérieurs (Domaine, OU de niveau supérieur...). "
                    "Ce peut entrainer des effets indésirables. Il est nécessaire de limiter autant que possible l'usage du blocage de l'héritage. "
                    ' On le réservera principalement à des test de portée limitée.'

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "S'interroger sur la pertinence de 'Bloquer l'héritage' pour chaque Unité d'Organisation concernée."
                    New-HTMLListItem -Text "Supprimer les 'bloquer l'héritage' non nécessaires."
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection
        
        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $UserLogon
        New-HTMLSection -HeaderText 'GPOs qui ont un LogonScript ou un LogoffScript en Configuration Utilisateur' {
            New-HTMLTable -DataTable $UserLogon {
                New-TableContent -ColumnName 'ID', 'GPOState', 'GPOType', 'Type', 'Script', 'ScriptType' -Alignment center
                New-TableContent -ColumnName 'GPOName', 'Script' -Alignment center -Color White -BackGroundColor Green
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'Le Tableau ci-dessus présente les GPOs qui ont un logonScript ou un LogoffScript Utilisateur. '
                    "Un LogonScript ne s'applique qu'au Logon, même si la GPO est raffraichie. "
                    "De nombreuses actions réalisées par le passé via LogonScript peuvent être utilement remplacées par l'utilisation des Modèles d'Administration. "
                    'Ces derniers ne possèdent pas les mêmes limitations et présentent même de nombreux avantages (ex. : Map de lecteurs réseau, Map Imprimantes). '
                    'Les remarques ci-dessus concenent également les LogoffScripts.'

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "S'interroger sur la pertinence de chaque LogonScript ou LogoffScript."
                    New-HTMLListItem -Text "Les remplacer par un élément dans les Modèles d'administration - quand existant  - autant que faire se peut."
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $ComputerLogon
        New-HTMLSection -HeaderText 'GPOs qui ont un LogonScript ou un LogoffScript en Configuration Ordinateur' {
            New-HTMLTable -DataTable $Computerlogon {
                New-TableContent -ColumnName 'ID', 'GPOState', 'GPOType', 'Type', 'Script', 'ScriptType' -Alignment center
                New-TableContent -ColumnName 'GPOName', 'Script' -Alignment center -Color White -BackGroundColor Green
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'Le Tableau ci-dessus présente les GPOs qui ont un logonScript ou un LogoffScript Ordinateur. '
                    "Un LogonScript ne s'applique qu'au Logon, même si la GPO est raffraichie. "
                    "De nombreuses actions réalisées par le passé via LogonScript peuvent être utilement remplacées par l'utilisation des Modèles d'Administration. "
                    'Ces derniers ne possèdent pas les mêmes limitations et présentent même de nombreux avantages (ex. : Map de lecteurs réseau, Map Imprimantes).'
                    'Les remarques ci-dessus concernent également les LogoffScripts.'
                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "S'interroger sur la pertinence de chaque LogonScript ou LogoffScript."
                    New-HTMLListItem -Text "Les remplacer par un élément dans les Modèles d'administration - quand existant  - autant que faire se peut."
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection

        # Ici on va mettre les informations qu'on a préalablement mis dans la variable $AllGposWittLogonScript
        New-HTMLSection -HeaderText 'GPOs qui ont un LogonScript en Configuration Utilisateur et Ordinateur' {
            New-HTMLTable -DataTable $AllGposWittLogonScript {
                New-TableContent -ColumnName 'ID', 'GPOState', 'GPOType', 'Type', 'ScriptType' -Alignment center
                New-TableContent -ColumnName 'GPOName', 'Script' -Alignment center -Color White -BackGroundColor Green
            }#end new-htmltable
        }#end new-htmlSection
        New-HTMLSection -HeaderText 'Informations' {
            New-HTMLPanel {
                New-HTMLText -TextBlock {
                    'Le Tableau ci-dessus présente les GPOs qui ont un logonScript ou un LogoffScript Utilisateur ou Ordinateur. '
                    "Un LogonScript  ne s'applique qu'au Logon, même si la GPO est raffraichie. "
                    "De nombreuses actions réalisées par le passé via LogonScript peuvent être utilement remplacées par l'utilisation des Modèles d'Administration. "
                    'Ces derniers ne possèdent pas les mêmes limitations et présentent même de nombreux avantages (ex. : Map de lecteurs réseau, Map Imprimantes). '
                    'Les remarques ci-dessus concernent également les LogoffScripts.'

                }#end New-htmlText
                New-HTMLList -Type Ordered {
                    New-HTMLListItem -Text "S'interroger sur la pertinence de chaque LogonScript ou LogoffScript."
                    New-HTMLListItem -Text "Les remplacer par un élément dans les Modèles d'administration - quand existant  - autant que faire se peut."
                }#End new-htmlList
            }#end New-HTMLPanel
        } #end New-htmlSection
    } # end New-HtmlTab

    New-HTMLFooter {
        New-HTMLText -Text 'Rapport généré le : ' -Alignment center -FontWeight bold
        New-HTMLText -Text "$(Get-Date)" -Alignment center 
    }# End New-htmlFooter
}#end new-html

Write-Output "Rapport disponible : $ReportPath"
#endregion Sortie HTML

#region sortie d'un report par GPO
if ($IndividualReport)
{
    # le switch a été passé en paramètre
    Write-Output 'Un export au format html de chaque GPO va être effectué'
    $Date = Get-Date -Format 'yyyy-MM-dd_hh-mm-ss'
    (Get-GPO -All).DisplayName |
        ForEach-Object {
            Get-GPOReport -Name $_ -ReportType Html -Path "$PSScriptRoot\$_-Au-$Date.html"
        }
    Write-Output "Un export des rapports au format html pour chaque GPO a été généré ici : $PSScriptRoot"
}
#endregion sortie d'un report par GPO

#region Log file finalisation
if ($PSBoundParameters.ContainsKey('TranscriptLog'))
{
    Stop-Transcript
}
#endregion Log file finalization
