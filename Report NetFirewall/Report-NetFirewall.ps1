<#
.SYNOPSIS
    Génère un rapport détaillé des règles et configurations du pare-feu Windows.

.DESCRIPTION
    Ce script collecte et analyse les configurations du pare-feu Windows, notamment :
    - Les profils de pare-feu (Domain, Private, Public)
    - Les règles actives et inactives
    - Les paramètres globaux
    - Les filtres d'adresses, de ports et d'applications

    Il génère ensuite plusieurs fichiers de sortie :
    - Un rapport HTML interactif
    - Un export CSV des règles détaillées
    - Un export JSON des règles
    - Un export JSON des profils

.PARAMETER OutDir
    Répertoire de sortie pour les rapports générés.
    Par défaut : %TEMP%\Report NetFirewall

.PARAMETER LogFile
    Chemin complet du fichier journal.
    Par défaut : [OutDir]\FirewallReport_[Date].log

.PARAMETER VerboseMode
    Active le mode verbeux pour un suivi détaillé de l'exécution.
    Par défaut : $true

.EXAMPLE
    .\Report-NetFirewall.ps1
    Exécute le script avec les paramètres par défaut.

.EXAMPLE
    .\Report-NetFirewall.ps1 -OutDir "C:\Reports\Firewall" -VerboseMode $false
    Génère les rapports dans le dossier spécifié sans mode verbeux.

.EXAMPLE
    Get-Help .\Report-NetFirewall.ps1 -ShowWindow
    Ouvre l'aide du script dans une fenêtre dédiée.

.NOTES
    Version         : 1.0
    Auteur          : O. FERRIERE
    Date création   : 21 oct 2025
    Prérequis      : PowerShell 5.1 ou supérieur
                     Module PSWriteHTML (installation automatique si nécessaire)
                     Droits administrateur recommandés
    Changements     :
        - 1.0 - 21 oct 2025 -  Version initiale
#>


#Requires -Version 5.1
#Requires -RunAsAdministrator
#Requires -Modules NetSecurity
[CmdletBinding()]
param (
    # Répertoire de sortie pour les rapports générés
    [Parameter(HelpMessage = 'Répertoire de sortie pour les rapports générés.')]
    [ValidateScript({
            if (-not (Test-Path $_))
            {
                try
                {
                    New-Item -Path $_ -ItemType Directory -Force -ErrorAction Stop
                    $true
                }
                catch
                {
                    throw "Impossible de créer le répertoire $_"
                }
            }
            else
            {
                $true
            }
        })]
    [string]$OutDir = $(Join-Path -Path C:\temp\ -ChildPath 'Report NetFirewall'),

    #Full Path du fichier de log
    [Parameter(HelpMessage = 'Full Path du fichier de log')]
    [string]
    $LogFile = $(Join-Path -Path $OutDir -ChildPath "FirewallReport_$(Get-Date -Format yyyy-MM-dd_HHmmss).log"),

    # Activation du mode verbeux
    [Parameter(HelpMessage = 'Activer le mode verbeux.')]
    [switch]
    $VerboseMode
)

#region création d'un Watcher
Write-Verbose -Message "Création d'un Watcher pour mesurer le temps d'exécution du script" -Verbose:$VerboseMode
$ScriptWatcher = [System.Diagnostics.Stopwatch]::StartNew()
#endregion création d'un Watcher

#region Création du répertoire de sortie s'il n'existe pas
Write-Verbose -Message 'Créer répertoire de sortie' -Verbose:$VerboseMode
if (-not (Test-Path -Path $OutDir))
{
    try
    {
        New-Item -ItemType Directory -Path $OutDir -Force -ErrorAction Stop | Out-Null
    }
    catch
    {
        Write-Verbose -Message "Erreur lors de la création du répertoire de sortie: $_" -Verbose:$VerboseMode
        Write-Verbose -Message 'Vérifiez que le chemin spécifié est correct et que vous avez les permissions nécessaires.' -Verbose:$VerboseMode
        exit 1
    }
}
#endregion Création du répertoire de sortie s'il n'existe pas

#region fonction Write-Log
Write-Verbose -Message "Création d'une fonction de log sous un format .csv" -Verbose:$VerboseMode
function Write-Log
{
    param (
        # Message de log
        [Parameter(HelpMessage = 'Message de log',
            Mandatory = $True)]
        [string]
        $Message,

        # Niveau de log
        [Parameter(HelpMessage = 'Niveau de log: INFO, WARN, ERROR',
            Mandatory = $false)]
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [String]
        $Level = 'INFO'
    )

    if (-not (Test-Path -Path $LogFile))
    {
        Add-Content -Path $LogFile -Value 'TimeStamp;Level;Message'
    }

    $TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogEntry = "$TimeStamp,$Level,$Message"
    Add-Content -Path $LogFile -Value $LogEntry
} #End Write-Log
#endregion fonction Write-Log

#region Initialisation du fichier de log
Write-Verbose -Message 'Initialisation du fichier de log' -Verbose:$VerboseMode
try
{
    New-Item -ItemType File -Path $LogFile -Force -ErrorAction stop | Out-Null
    'TimeStamp;Level;Message' | Out-File -FilePath $LogFile -Encoding UTF8
}
catch
{
    Write-Verbose -Message "Erreur lors de la création du fichier de log : $_" -Verbose:$VerboseMode
    Write-Verbose -Message 'Vérifiez que le chemin spécifié est correct et que vous avez les permissions nécessaires.' -Verbose:$VerboseMode
    exit 1
}
#endregion Initialisation du fichier de log

#region Collecte des données du pare-feu
Write-Verbose -Message 'Collecte des profils (global settings par profil)' -Verbose:$VerboseMode
try
{
    $Profiles = Get-NetFirewallProfile -ErrorAction Stop | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction, AllowLocalFirewallRules, AllowLocalIPsecRules, NotificationSettings, LogFileName, LogFileMaxSizeKilobytes, LogAllowed, LogBlocked
}
catch
{
    Write-Verbose -Message "Erreur lors de la collecte des profils du pare-feu: $_" -Verbose:$VerboseMode
}

Write-Verbose -Message 'Collecte des règles (Actives + Inactives)' -Verbose:$VerboseMode
try
{
    $AllRules = Get-NetFirewallRule -ErrorAction Stop

    if ($PSBoundParameters.ContainsKey('VerboseMode') -and $VerboseMode)
    {
        Write-Verbose -Message "Règles actives: $($EnabledRules.Count)" -Verbose:$VerboseMode
        Write-Verbose -Message "Règles inactives: $($DisabledRules.Count)" -Verbose:$VerboseMode
        Write-Verbose -Message "Total règles: $($AllRules.Count)" -Verbose:$VerboseMode
    }
}
catch
{
    Write-Error -Message "Erreur lors de la collecte des règles du pare-feu: $_"
    exit 1
}


Write-Verbose -Message "Création d'une fonction pour enrichir une règle avec ses filtres" -Verbose:$VerboseMode
function Get-FirewallRuleDetail
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Microsoft.Management.Infrastructure.CimInstance]
        $Rule
    )

    try
    {
        # Initialisation de l'objet de base
        $base = [ordered]@{
            PSTypeName          = 'Custom.FirewallRule'
            Name                = $Rule.Name
            DisplayName         = $Rule.DisplayName
            Description         = $Rule.Description
            Enabled             = $Rule.Enabled
            Direction           = $Rule.Direction
            Action              = $Rule.Action
            Profile             = $Rule.Profile
            PolicyStore         = $Rule.PolicyStore
            EdgeTraversalPolicy = $Rule.EdgeTraversalPolicy
            Platform            = $Rule.Platform
            Program             = $Rule.Program
            Service             = $Rule.Service
            InterfaceType       = $Rule.InterfaceType
            InterfaceAlias      = $Rule.InterfaceAlias
            ApplicationName     = $Rule.ApplicationName
            ServiceName         = $Rule.ServiceName
            Group               = $Rule.Group
            Owner               = $Rule.Owner
            DisplayGroup        = $Rule.DisplayGroup
            EnabledToString     = if ($Rule.Enabled)
            {
                'True'
            }
            else
            {
                'False'
            }
            RuleState           = if ($Rule.Enabled -and ($null -ne $Rule.Action))
            {
                'Active'
            }
            else
            {
                'Inactive'
            }
            LocalAddresses      = ''
            RemoteAddresses     = ''
            LocalPorts          = ''
            RemotePorts         = ''
            Protocol            = ''
            Application         = ''
            IPsec               = ''
            Filters             = ''
        }

        # Récupération des filtres avec gestion d'erreurs
        try
        {
            $addrFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $Rule -ErrorAction Stop
            $base['LocalAddresses'] = $addrFilter.LocalAddress -join ';'
            $base['RemoteAddresses'] = $addrFilter.RemoteAddress -join ';'
        }
        catch
        {
            Write-Verbose "Impossible de récupérer les filtres d'adresse pour $($Rule.Name)"
        }

        try
        {
            $portFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $Rule -ErrorAction Stop
            $base['LocalPorts'] = $portFilter.LocalPort -join ';'
            $base['RemotePorts'] = $portFilter.RemotePort -join ';'
            $base['Protocol'] = $portFilter.Protocol -join ';'
        }
        catch
        {
            Write-Verbose "Impossible de récupérer les filtres de port pour $($Rule.Name)"
        }

        try
        {
            $applicationFilter = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $Rule -ErrorAction Stop
            $base['Application'] = $applicationFilter.Program -join ';'
        }
        catch
        {
            Write-Verbose "Impossible de récupérer les filtres d'application pour $($Rule.Name)"
        }

        try
        {
            $ipsecFilter = Get-NetIPsecRule -ErrorAction Stop | Where-Object Name -EQ $Rule.Name
            $base['IPsec'] = $ipsecFilter.Name -join ';'
        }
        catch
        {
            Write-Verbose "Impossible de récupérer les règles IPsec pour $($Rule.Name)"
        }

        # Création et retour de l'objet
        return [PSCustomObject]$base
    }
    catch
    {
        Write-Error "Erreur lors de l'analyse de la règle $($Rule.Name): $_"
        return $null
    }
}

Write-Verbose -Message 'Exécution de la fonction pour chaque règle collectée' -Verbose:$VerboseMode
$Details = [System.Collections.Generic.List[psobject]]::new()
Write-Verbose -Message 'Enrichissement des règles avec leurs filtres associés' -Verbose:$VerboseMode
foreach ($Rule in $allRules)
{

    Write-Verbose -Message "traitement de la règle: $($Rule.Name)" -Verbose:$VerboseMode
    $Details.Add( $(Get-FirewallRuleDetail -Rule $Rule))
}
Write-Verbose -Message 'Séparer actives / inactives' -Verbose:$VerboseMode
$ActiveRules = $Details | Where-Object { $_.Enabled -eq 'True' }
$InactiveRules = $Details | Where-Object { $_.Enabled -ne 'True' }

Write-Verbose -Message 'Compter les règles actives et inactives' -Verbose:$VerboseMode
$ActiveRulesCount = $ActiveRules.Count
$InactiveRulesCount = $InactiveRules.Count
$TotalRulesCount = $Details.Count

Write-Verbose -Message 'Collecte des paramètres globaux du pare-feu' -Verbose:$VerboseMode
$FWSettings = Get-NetFirewallSetting | Select-Object -Property Name, Description, Exemptions, EnableStatefulFtp , EnableStatefulPptp, ActiveProfile, RequireFullAuthSupport, CertValidationLevel, AllowIPsecThroughNAT, MaxSAIdleTimeSeconds, KeyEncoding, EnablePacketQueuing
#endregion Collecte des données du pare-feu

#region préparation des fichiers de sortie
Write-Verbose -Message 'Export dans un fichier html' -Verbose:$VerboseMode
$CsvPath = Join-Path $OutDir "Firewall_Rules_Detailed_$(Get-Date -Format yyyy-MM-dd_HHmmss).csv"
$JsonPath = Join-Path $OutDir "Firewall_Rules_$(Get-Date -Format yyyy-MM-dd_HHmmss).json"
$HtmlPath = Join-Path $OutDir "FirewallReport_$(Get-Date -Format yyyy-MM-dd_HHmmss).html"
$ProfilesPath = Join-Path $OutDir "Firewall_Profiles_$(Get-Date -Format yyyy-MM-dd_HHmmss).json"
#endregion préparation des fichiers de sortie

#region export des données collectées .csv, et .json
$Details | Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8BOM -Delimiter ';'
$Details | ConvertTo-Json -Depth 6 | Out-File -FilePath $jsonPath -Encoding utf8BOM
$Profiles | ConvertTo-Json -Depth 4 | Out-File -FilePath $ProfilesPath -Encoding utf8BOM
#endregion export des données collectées .csv, et .json

#region Vérification si le module est installé, si non téléchargement
Write-Verbose -Message'Vérification que le module PSWriteHtml est installé' -Verbose:$VerboseMode
if (-not (Get-Module -ListAvailable -Name PSWriteHtml))
{
    # On fait l'installation pour l'utilisateur courant, on pourrait le faire pour tous les utilisateurs de la machine tout aussi bien, mais il faudrait pour ce faire exécuter le script en "Run As Administrator"
    try
    {
        Write-Verbose -Message "Le module PSWriteHtml n'est pas installé" -Verbose:$VerboseMode
        Write-Verbose -Message 'Téléchargement et installation ... : ' -Verbose$VerboseMode
        Install-Module PSWriteHTML -Force -Scope CurrentUser
    }
    catch
    {
        Write-Verbose -Message "Le module n'a pu être installé. Fin du script." -Verbose:$VerboseMode
        Write-Verbose -Message"Une erreur est survenue. Message d'erreur : $_." -Verbose:$VerboseMode
        break
    }
}
#endregion Vérification si le module est installé, si non téléchargement

#region Importation du module pour avoir les cmdlets disponibles
Write-Verbose -Message 'Import du module PSWriteHtml ... ' -Verbose:$VerboseMode
Import-Module PSWriteHTML
#endregion Importation du module pour avoir les cmdlets disponibles

#region Paramétrage du comportement par défaut de certaines cmdlets
Write-Verbose -Message 'Paramétrage du comportement par défaut de certaines cmdlets : ' -Verbose:$VerboseMode
$PSDefaultParameterValues = @{
    'New-HTMLSection:HeaderBackGroundColor' = 'Green'
    'New-HTMLSection:CanCollapse'           = $true
    '*:Encoding'                            = 'utf8BOM'
}
#endregion Paramétrage du comportement par défaut de certaines cmdlets

#region Sortie HTML d'informations multiples dans différents onglets d'une même page html
Write-Verbose -Message 'Génération du rapport ...' -Verbose:$VerboseMode
New-HTML -FilePath $HtmlPath -Online -ShowHTML {
    # 1er Onglet Résumé des profils
    New-HTMLTab -Name 'Données Générales' {
        New-HTMLSection -HeaderText 'Résumé des profils' { # Ici on va mettre les informations qu'on a préalablement mis dans la variable $Profiles
            New-HTMLTable -DataTable $Profiles {
                New-TableContent -ColumnName Name, Enabled, DefaultInboundAction, DefaultOutboundAction, AllowLocalFirewallRules, AllowLocalIPSecRules, NotificationSettings, LogFileName, LogFileMaxSizeKilobytes, LogAllowed, LogBlocked -Alignment center
                New-TableContent -ColumnName Name, Enabled -Alignment center -Color white -BackgroundColor Green
            }#end-newhtmltable
        }#end-newhtmlsection
        New-HTMLSection -HeaderText 'Paramètres Généraux' { # ici on va mettre les informations qu'on a préalablement mis dans la variable $FWSettings
            New-HTMLTable -DataTable $FWSettings {
                New-TableContent -ColumnName Name, Description, Exemptions, EnableStatefulFtp , EnableStatefulPptp, ActiveProfile, RequireFullAuthSupport, CertValidationLevel, AllowIPsecThroughNAT, MaxSAIdleTimeSeconds, KeyEncoding, EnablePacketQueuing -Alignment center
                New-TableContent -ColumnName Name, Enabled -Alignment center -Color white -BackgroundColor Green
            }#end-newhtmltable
        }#end-newhtmlsection
        New-HTMLSection -HeaderText 'Règles - Statistiques' { # Ici on va mettre les informations qu'on a préalablement mis dans la variable $ActiveRulesCount et $InactiveRulesCount et $TotalRulesCount
            New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
            New-HTMLPanel -BackgroundColor lightpink -AlignContentText center -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text $ActiveRulesCount -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text 'Active Rules' -Alignment center -FontSize 15
                }
            }#end-newhtmlpanel
            New-HTMLPanel -BackgroundColor lightblue -AlignContentText center -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text $InactiveRulesCount -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text 'Inactive Rules' -Alignment center -FontSize 15
                }
            }#end-newhtmlpanel
            New-HTMLPanel -BackgroundColor lightgreen -AlignContentText center -BorderRadius 10px {
                New-HTMLText -TextBlock {
                    New-HTMLText -Text $TotalRulesCount -Alignment center -FontSize 25 -FontWeight bold
                    New-HTMLText -Text 'Total Rules' -Alignment center -FontSize 15
                }
            }#end-newhtmlpanel
        }#end-newhtmlsection
        New-HTMLSection -HeaderText 'Distribution des règle' { # Ici on va mettre les informations qu'on a préalablement mis dans la variable $Profiles
            New-HTMLChart -Title 'Distribution des règles' {
                New-ChartPie -Name 'Active Rules' -Value $([Math]::round($ActiveRulesCount / $TotalRulesCount * 100, 1))
                New-ChartPie -Name 'Inactive Rules' -Value $([Math]::round($InactiveRulesCount / $TotalRulesCount * 100, 1))
            }#end-newhtmlchart
        }#end-newhtmlsection
    }#end-newhtmltab
    # 2ème Onglet Règles actives
    New-HTMLTab -Name 'Règles Actives' {
        New-HTMLSection -HeaderText 'Résumé des règles actives' {
            New-HTMLTable -DataTable $ActiveRules {
                New-TableContent -ColumnName Name, Enabled, Action -Alignment center
            }#end-newhtmltable
        }#end-newhtmlsection
    }#end-newhtmltab
    # 3ème Onglet Règles inactives
    New-HTMLTab -Name 'Règles Inactives' {
        New-HTMLSection -HeaderText 'Résumé des règles inactives' {
            New-HTMLTable -DataTable $InactiveRules {
                New-TableContent -ColumnName Name, Enabled, Action -Alignment center
            }#end-newhtmltable
        }#end-newhtmlsection
    }#end-newhtmltab

}#end-newhtml
#endregion Sortie HTML d'informations multiples dans différents onglets d'une même page html

#region ajout d'un rapport d'erreur
$ErrorReport = @{
    TotalErrors    = $Error.Count
    CriticalErrors = ($Error | Where-Object { $_.CategoryInfo.Severity -eq 'Error' }).Count
    Warnings       = ($Error | Where-Object { $_.CategoryInfo.Severity -eq 'Warning' }).Count
}
$ErrorReport
#endregion ajout d'un rapport d'erreur

#region Arrêt du watcher et affichage du temps d'exécution
$ScriptWatcher.Stop()
Write-Verbose -Message "Temps d'exécution du script : " -Verbose:$VerboseMode
$Metrics = @{
    'Script Duration'             = $ScriptWatcher.Elapsed.Minutes.ToString() + ' minutes, ' + $ScriptWatcher.Elapsed.Seconds.ToString() + ' secondes, ' + $ScriptWatcher.Elapsed.Milliseconds.ToString() + ' millisecondes'
    'Rules Processed'             = $TotalRulesCount
    'Processing Speed per second' = $TotalRulesCount / $ScriptWatcher.Elapsed.TotalSeconds
}
$Metrics
#endregion Arrêt du watcher et affichage du temps d'exécution



