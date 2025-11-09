<#
.SYNOPSIS
Génère un tableau de bord HTML des postes de travail à partir de l'Active Directory.

.DESCRIPTION
Ce script récupère les postes non-serveurs de l'AD, analyse leur OS, leur activité récente,
et produit un rapport interactif HTML avec tableaux et graphiques via PSWriteHTML.

.PARAMETER CheminHTML
Chemin de sortie du fichier HTML.
valeur par défaut : .\Dashboard_Postes.html

.PARAMETER DelaiInactiviteJours
Nombre de jours sans authentification pour considérer un poste comme inactif.
valeur par défaut : 90 jours.

.EXAMPLE
.\PostesAD-Dashboard.ps1 -DelaiInactiviteJours 60 -CheminHTML ".\rapport60.html"
execute le script en considérant les postes inactifs depuis plus de 60 jours et génère le rapport dans rapport60.html.

.EXAMPLE
Get-Help .\PostesAD-Dashboard.ps1 -ShowWindow
affiche l'aide du script dans une fenêtre interactive.

.NOTES
Auteur : Olivier FERRIERE
Date : 29/06/2025
Version : 1.0
Change : v1.0 - 29/06/2025 - Initialisation du script
#>

[CmdletBinding(SupportsShouldProcess = $true)] # Permet l'utilisation de -WhatIf et -Confirm
# Spécifie que le script supporte les paramètres d'aide et de confirmation
param (
    [Parameter(HelpMessage = 'Chemin complet du fichier Html de sortie')]
    [string]
    $CheminHTML = '.\Dashboard_Postes.html',

    [Parameter(HelpMessage = 'Chemin complet du fichier liste des postes de travail au format CSV')]
    [string]
    $CheminExportCSV = '.\ListePostes.csv',

    [Parameter(HelpMessage = "Distinguished Name du répertoire Active Directory des postes de travail. Mettre '*' pour rechercher dans tout l'AD.")]
    [string]
    $RepertoireAD = 'OU=Workstations,DC=mondomaine,DC=local',

    [Parameter(HelpMessage = "délai d'inactivité en jours pour considérer un poste comme inactif")]
    [int]
    $DelaiInactiviteJours = 90
)

#region intialisation d'un compteur d'exéction du script utilisant un Stopwatch
# initialiser un watcher pour mesurer le temps d'exécution du script
$watcher = [System.Diagnostics.Stopwatch]::new()
# démarrer le watcher
$watcher.Start()
#endregion intialisation d'un compteur d'exéction du script utilisant un Stopwatch

#region valeurs par défaut pour certains paramètres
# définir les valeurs par défaut de certains paramètres. Cela évite de les spécifier à chaque fois et raccourcit le code.
$PSDefaultParameterValues = @{
    'Export-Csv:NoTypeInformation'           = $true
    'Export-Csv:Encoding'                    = 'utf8'
    'New-HTML:FilePath'                      = $CheminHTML
    'New-HTML:Online'                        = $true
    'New-HTML:Show'                          = $true
    'New-htmlsection:cancollapse'            = $true
    'New-HTMLPanel:BackgroundColor'          = '#d4edda' # Couleur de fond verte pâle
    'New-HTMLPanel:BorderColor'              = '#c3e6cb'
    'Get-ADComputer:Properties'              = 'OperatingSystem', 'LastLogonDate', 'IPv4Address', 'Enabled', 'OperatingSystem', 'LastLogonDate'
}
# si mode verbose activé, on ajoute un paramètre pour afficher les messages de débogage
if ($pscmdlet.containkey('Verbose'))
{
    # afficher les paramètres et leur valeur dans la console si le mode verbose est activé
    $PSDefaultParameterValues
}
#endregion valeurs par défaut pour certains paramètres

#region Vérifier si le module Active Directory est installé
if (-not (Get-Module -ListAvailable -Name ActiveDirectory))
{
    Write-Error "Le module Active Directory n'est pas installé. Veuillez l'installer avant d'exécuter ce script."
    exit 1
}
else
{
    Import-Module ActiveDirectory -Force
}
#endregion Vérifier si le module Active Directory est installé

#region Vérifier si le module PSWriteHTML est installé et installation si nécessaire
if (-not (Get-Module -ListAvailable -Name PSWriteHTML))
{
    if ($PSCmdlet.ShouldProcess('PSWriteHTML', 'Install module PSWriteHTML'))
    {
        Install-Module -Name PSWriteHTML -Scope CurrentUser -Force -AllowClobber
    }
}
else
{
    Import-Module PSWriteHTML -Force
}
#endregion Vérifier si le module PSWriteHTML est installé et installation si nécessaire

#region Requête AD pour récupérer uniquement les postes (filtrés sur OperatingSystem ou autre critère)
if ($RepertoireAD -eq '*')
{
    # Si le paramètre $RepertoireAD est '*' (tous les postes de travail), on récupère tous les postes de travail Windows non-serveurs
    # On utilise le filtre 'OperatingSystem -like "*Windows*" -and OperatingSystem -notlike "*Server*"' pour exclure les serveurs
    # On n'utilise pas le paramètre -SearchBase car on veut rechercher dans tout l'AD
    # On utilise le paramètre -SearchScope Subtree pour rechercher dans tous les sous-répertoires de l'AD
    $postes = Get-ADComputer -Filter 'OperatingSystem -like "*Windows*" -and OperatingSystem -notlike "*Server*"' -SearchScope Subtree

}
else
{
    # Si le paramètre $RepertoireAD est spécifié, on récupère les postes de travail Windows non-serveurs dans ce répertoire spécifique
    # On utilise le filtre 'OperatingSystem -like "*Windows*" -and OperatingSystem -notlike "*Server*"' pour exclure les serveurs
    # On utilise le paramètre -SearchBase pour spécifier le répertoire AD à partir duquel effectuer la recherche
    # On utilise le paramètre -SearchScope Subtree pour rechercher dans tous les sous-répertoires de l'AD
    $postes = Get-ADComputer -Filter 'OperatingSystem -like "*Windows*" -and OperatingSystem -notlike "*Server*"' -SearchBase $RepertoireAD -SearchScope Subtree
}

# On notera que dans les 2 cas, le paramètre -Properties qui permet de récupérer les propriétés nécessaires pour le tableau de bord n'a pas été spécifié ici car il est déjà défini dans les valeurs par défaut du paramètre $PSDefaultParameterValues.

# exporter la liste des postes de travail, trié par la propriété Nom dans un fichier CSV
$postes | Sort-Object Name | Export-Csv -Path $CheminExportCSV

#endregion Requête AD pour récupérer uniquement les postes (filtrés sur OperatingSystem ou autre critère)

#region calculs de variables pour le tableau de bord
# Total des postes
$totalPostes = $postes.Count
# Date limite pour considérer un poste comme inactif
$dateLimite = (Get-Date).AddDays(-$DelaiInactiviteJours)

# Regroupement par version d'OS
$parOS = $postes | Group-Object -Property OperatingSystem | Sort-Object Name

# Postes inactifs depuis +90 jours
$postesInactifs = $postes | Where-Object
{
    $_.LastLogonDate -lt $dateLimite -or -not $_.LastLogonDate
    # explication :
    # - $_.LastLogonDate -lt $dateLimite : vérifie si la date de dernière connexion est antérieure à la date limite
    # - -not $_.LastLogonDate : vérifie si la date de dernière connexion est absente (postes jamais connectés)
}
#endregion calculs de variables pour le tableau de bord

#region Construction du tableau HTML avec PSWriteHTML
New-HTML -TitleText 'Tableau de bord des postes de travail' {

    New-HTMLTab -Name 'Tableau de bord' {
        
        New-HTMLSection -HeaderText '📊 Résumé global' {
            New-HTMLPanel {
                New-HTMLText -Text "Nombre total de postes de travail : **$totalPostes**"
                New-HTMLText -Text "Nombre de postes inactifs depuis +90j : **$($postesInactifs.Count)**"
            }
        }

        New-HTMLSection -HeaderText '📈 Répartition par OS' {
            $labels = $parOS.Name
            $data = $parOS.Count

            New-Chart -Type Pie -Labels $labels -Values $data -Title 'Répartition des OS'

            New-HTMLTable -DataTable ($parOS | ForEach-Object {
                    [PSCustomObject]@{
                        "Système d'exploitation" = $_.Name
                        'Nombre'                 = $_.Count
                    }
                }) -HideFooter
        }

        New-HTMLSection -HeaderText '🖥️ Activité des postes' {
            $actifs = $totalPostes - $postesInactifs.Count
            $inactifs = $postesInactifs.Count

            New-Chart -Type Bar -Labels @('Actifs', 'Inactifs (+90j)') -Values @($actifs, $inactifs) -Title "État d'activité des postes"
        }

        New-HTMLSection -HeaderText '🛑 Postes inactifs depuis plus de 90 jours' {
            New-HTMLTable -DataTable (
                $postesInactifs | Sort-Object Name | Select-Object Name, OperatingSystem, LastLogonDate
            )
        }
    }

    # ✅ Second onglet : liste complète des postes
    New-HTMLTab -Name 'Liste des postes' {
        New-HTMLSection -HeaderText '🗂️ Tous les postes de travail' {
            New-HTMLTable -DataTable (
                $postes | Sort-Object Name | Select-Object Name, OperatingSystem, LastLogonDate, IPv4Address, Enabled
            )
        }
    }
}
#endregion Construction du tableau HTML avec PSWriteHTML

#region fin de l'exécution du script
# arrêter le watcher
$watcher.Stop()
# afficher le temps d'exécution du script
Write-Host "Le script a été exécuté en $($watcher.Elapsed.TotalSeconds) secondes." -ForegroundColor Green
# afficher le chemin du fichier HTML généré 
Write-Host "Le rapport a été généré dans le fichier : $CheminHTML" -ForegroundColor Green
#endregion fin de l'exécution du script