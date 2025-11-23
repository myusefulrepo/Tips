
#requires -RunAsAdministrator # Nécessite l'exécution en tant qu'administrateur

<#
.SYNOPSIS
    Génère un rapport HTML des règles de pare-feu Windows en utilisant le module PSWriteHTML.

    .DESCRIPTION
    Ce script collecte les règles de pare-feu entrantes et sortantes, actives et inactives,
    puis génère un rapport HTML interactif avec des statistiques et des tableaux filtrables.

    .PARAMETER OutputPath
    Chemin de sortie pour le fichier HTML généré.
    Par défaut, il est enregistré dans le répertoire courant du script sous le nom Rapport_Firewall_YYYYMMDD_HHMMSS.html

    .EXAMPLE
    .\Rapport_des_règles_de_PareFeu.ps1 -OutputPath "C:\Rapports\FirewallReport.html"
    Génère le rapport et l'enregistre à l'emplacement spécifié.

    .EXAMPLE
    .\Rapport_des_règles_de_PareFeu.ps1
    Génère le rapport et l'enregistre dans le dossier par défaut C:\Temp.

    .EXAMPLE
    Get-Help .\Rapport_des_règles_de_PareFeu.ps1 -ShowWindow
    Affiche l'aide détaillée du script dans une fenêtre.

    .NOTES
    Auteur     : O. FERRIERE
    Date       : 22/11/2025
    Version    : 1.0
    Changements: v1.0 - 22/11/2025 - Version initiale
#>

[CmdletBinding()]
param (
    [Parameter(HelpMessage)]
    [String]
    $OutputPath = ".\Rapport_Firewall_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
)

#region démarrage watcher
Write-Host 'Démarrage du script : Rapport des règles de PareFeu.ps1' -ForegroundColor Green
$Watcher = [System.Diagnostics.Stopwatch]::new()
$Watcher.Start() #  démarrage du timer
#endregion démarrage watcher


#region Vérification de la présence des modules PSWriteHTML et PSWriteColor et installation si nécessaire
$ModulesRequis = @('PSWriteHTML', 'PSWriteColor')
foreach ($Module in $ModulesRequis)
{
    if (-not (Get-Module -ListAvailable -Name $Module))
    {
        Write-Host "Le module $Module est requis mais introuvable. Installation en cours..." -ForegroundColor Red
        Install-Module -Name $Module -Scope CurrentUser -Force -AllowClobber
    }
    else
    {
        Write-Host "Le module $module est déjà installé." -ForegroundColor Green
    }
}
Write-Host "Importation des modules : $ModulesRequis" -ForegroundColor Cyan
Import-Module -Name Write-Color, PSWriteHTML -ErrorAction SilentlyContinue
#endregion Vérification de la présence des modules PSWriteHTML et Write-Color et installation si nécessaire

#region Collecte des règles de pare-feu
Write-Color -Text 'Collecte des règles de pare-feu...' -ForegroundColor Cyan
Write-Color -Text '✅ REGLES ENTRANTES' -ForegroundColor Cyan -StartTab 1
Write-Color -Text '✅ Collecte de TOUTES les règles entrantes (actives et inactives)' -ForegroundColor Cyan -StartTab 2
$ToutesReglesEntrantes = Get-NetFirewallRule -Direction Inbound
Write-Color -Text '✅ Comptage de TOUTES les règles entrantes (actives et inactives)' -ForegroundColor Cyan -StartTab 2
$NbreReglesEntrantes = $ToutesReglesEntrantes.Count
Write-Color -Text '✅ Collecte de TOUTES les règles entrantes (actives)' -ForegroundColor Cyan -StartTab 2
$ToutesReglesEntrantes_Actives = $ToutesReglesEntrantes | Where-Object { $_.Enabled -eq 'true' }
Write-Color -Text '✅ Comptage des données pour les règles entrantes actives' -ForegroundColor Cyan -StartTab 2
$NbreReglesEntrantesActives = $ToutesReglesEntrantes_Actives.Count
Write-Color -Text '✅ Collecte de TOUTES les règles sortantes (inactives)' -ForegroundColor Cyan -StartTab 2
$ToutesReglesEntrantes_Inactives = $ToutesReglesEntrantes | Where-Object { $_.Enabled -eq 'false' }
Write-Color -Text '✅ Comptage des données pour les règles entrantes inactives' -ForegroundColor Cyan -StartTab 2
$NbreReglesEntrantesInactives = $ToutesReglesEntrantes_Inactives.Count

Write-Color -Text '✅ REGLES SORTANTES' -ForegroundColor Cyan -StartTab 1
Write-Color -Text '✅ Collecte de TOUTES les règles sortantes (actives et inactives)' -ForegroundColor Cyan -StartTab 2
$ToutesReglesSortantes = Get-NetFirewallRule -Direction Outbound
Write-Color -Text '✅ Comptage de TOUTES les règles sortantes (actives et inactives)' -ForegroundColor Cyan -StartTab 2
$NbreReglesSortantes = $ToutesReglesSortantes.Count
Write-Color -Text '✅ Collecte de TOUTES les règles sortantes (actives)' -ForegroundColor Cyan -StartTab 2
$ToutesReglesSortantes_Actives = $ToutesReglesSortantes | Where-Object { $_.Enabled -eq 'true' }
Write-Color -Text '✅ Comptage des données pour les règles sortantes actives' -ForegroundColor Cyan -StartTab 2
$NbreReglesSortantesActives = $ToutesReglesSortantes_Actives.Count
Write-Color -Text '✅ Collecte de TOUTES les règles sortantes (inactives)' -ForegroundColor Cyan -StartTab 2
$ToutesReglesSortantes_Inactives = $ToutesReglesSortantes | Where-Object { $_.Enabled -eq 'false' }
Write-Color -Text '✅ Comptage des données pour les règles sortantes inactives' -ForegroundColor Cyan -StartTab 2
$NbreReglesSortantesInactives = $ToutesReglesSortantes_Inactives.Count
#endregion Collecte des règles de pare-feu

#region preparation des données
Write-Color -Text '✅ Préparation des données des règles ENTRANTES...' -ForegroundColor Cyan
Write-Color -Text '✅ Préparer les données pour les règles ENTRANTES ACTIVES' -ForegroundColor Cyan -StartTab 1
$DataEntrantes = foreach ($regle in $ToutesReglesEntrantes_Actives)
{
    $portFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $regle
    $appFilter = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $regle
    $addressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $regle

    [PSCustomObject]@{
        'Nom'              = $regle.DisplayName
        'Activée'          = if ($regle.Enabled)
        {
            'Oui'
        }
        else
        {
            'Non'
        }
        'Action'           = $regle.Action
        'Protocole'        = if ($portFilter.Protocol)
        {
            $portFilter.Protocol
        }
        else
        {
            'Tous'
        }
        'Port Local'       = if ($portFilter.LocalPort)
        {
            $portFilter.LocalPort -join ', '
        }
        else
        {
            'Tous'
        }
        'Port Distant'     = if ($portFilter.RemotePort)
        {
            $portFilter.RemotePort -join ', '
        }
        else
        {
            'Tous'
        }
        'Adresse Distante' = if ($addressFilter.RemoteAddress)
        {
            $addressFilter.RemoteAddress -join ', '
        }
        else
        {
            'Toutes'
        }
        'Profil'           = $regle.Profile
        'Programme'        = if ($appFilter.Program)
        {
            $appFilter.Program
        }
        else
        {
            'Tous'
        }
        'Description'      = $regle.Description
    }
}
Write-Color -Text '✅ Préparer les données pour les règles ENTRANTES INACTIVES' -ForegroundColor Cyan -StartTab 1
$DataEntrantes_Inactives = foreach ($regle in $ToutesReglesEntrantes_Inactives)
{
    $portFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $regle
    $appFilter = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $regle
    $addressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $regle

    [PSCustomObject]@{
        'Nom'              = $regle.DisplayName
        'Activée'          = if ($regle.Enabled)
        {
            'Oui'
        }
        else
        {
            'Non'
        }
        'Action'           = $regle.Action
        'Protocole'        = if ($portFilter.Protocol)
        {
            $portFilter.Protocol
        }
        else
        {
            'Tous'
        }
        'Port Local'       = if ($portFilter.LocalPort)
        {
            $portFilter.LocalPort -join ', '
        }
        else
        {
            'Tous'
        }
        'Port Distant'     = if ($portFilter.RemotePort)
        {
            $portFilter.RemotePort -join ', '
        }
        else
        {
            'Tous'
        }
        'Adresse Distante' = if ($addressFilter.RemoteAddress)
        {
            $addressFilter.RemoteAddress -join ', '
        }
        else
        {
            'Toutes'
        }
        'Profil'           = $regle.Profile
        'Programme'        = if ($appFilter.Program)
        {
            $appFilter.Program
        }
        else
        {
            'Tous'
        }
        'Description'      = $regle.Description
    }
}

Write-Color -Text '✅ Préparation des données des règles SORTANTES...' -ForegroundColor Cyan
Write-Color -Text '✅ Préparation des données pour les règles SORTANTES ACTIVES' -ForegroundColor Cyan -StartTab 1
$DataSortantes = foreach ($regle in $ToutesReglesSortantes_Actives)
{
    $portFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $regle
    $appFilter = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $regle
    $addressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $regle

    [PSCustomObject]@{
        'Nom'              = $regle.DisplayName
        'Activée'          = if ($regle.Enabled)
        {
            'Oui'
        }
        else
        {
            'Non'
        }
        'Action'           = $regle.Action
        'Protocole'        = if ($portFilter.Protocol)
        {
            $portFilter.Protocol
        }
        else
        {
            'Tous'
        }
        'Port Local'       = if ($portFilter.LocalPort)
        {
            $portFilter.LocalPort -join ', '
        }
        else
        {
            'Tous'
        }
        'Port Distant'     = if ($portFilter.RemotePort)
        {
            $portFilter.RemotePort -join ', '
        }
        else
        {
            'Tous'
        }
        'Adresse Distante' = if ($addressFilter.RemoteAddress)
        {
            $addressFilter.RemoteAddress -join ', '
        }
        else
        {
            'Toutes'
        }
        'Profil'           = $regle.Profile
        'Programme'        = if ($appFilter.Program)
        {
            $appFilter.Program
        }
        else
        {
            'Tous'
        }
        'Description'      = $regle.Description
    }
}
Write-Color -Text '✅ Préparation des données pour les règles SORTANTES INACTIVES' -ForegroundColor Cyan -StartTab 1
$DataSortantes_Inactives = foreach ($regle in $ToutesReglesSortantes_Inactives)
{
    $portFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $regle
    $appFilter = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $regle
    $addressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $regle

    [PSCustomObject]@{
        'Nom'              = $regle.DisplayName
        'Activée'          = if ($regle.Enabled)
        {
            'Oui'
        }
        else
        {
            'Non'
        }
        'Action'           = $regle.Action
        'Protocole'        = if ($portFilter.Protocol)
        {
            $portFilter.Protocol
        }
        else
        {
            'Tous'
        }
        'Port Local'       = if ($portFilter.LocalPort)
        {
            $portFilter.LocalPort -join ', '
        }
        else
        {
            'Tous'
        }
        'Port Distant'     = if ($portFilter.RemotePort)
        {
            $portFilter.RemotePort -join ', '
        }
        else
        {
            'Tous'
        }
        'Adresse Distante' = if ($addressFilter.RemoteAddress)
        {
            $addressFilter.RemoteAddress -join ', '
        }
        else
        {
            'Toutes'
        }
        'Profil'           = $regle.Profile
        'Programme'        = if ($appFilter.Program)
        {
            $appFilter.Program
        }
        else
        {
            'Tous'
        }
        'Description'      = $regle.Description
    }
}
#endregion preparation des données

#region Préparation des statistiques
Write-Color -Text 'Préparation des statistiques' -ForegroundColor Cyan
$NbreReglesEntrantes
$NbreReglesEntrantesActives
$NbreReglesSortantes
$NbreReglesSortantesActives
$NbreReglesSortantesInactives
$totalReglesActives = $NbreReglesEntrantesActives + $NbreReglesSortantesActives
$DateRapport = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'
$NomOrdinateur = $env:COMPUTERNAME
#endregion Préparation des statistiques

#region Paramétrages du comportement par défaut de certaines cmdlets
Write-Color -Text 'Paramétrages du comportement par défaut de certaines cmdlets'
$PSDefaultParameterValues = @{
    'New-HTML:TitleText'                    = "Rapport Parefeu Windows - $NomOrdinateur"
    'New-HTML:FilePath'                     = $outputPath
    'New-HTML:ShowHTML'                     = $true
    'New-Html:Online'                       = $true
    'New-HTMLTab:TextTransform'             = 'uppercase'
    'New-HTMLTab:TextSize'                  = 12
    'New-HTMLTab:TextColor'                 = 'AliceBlue'
    'New-HTMLTab:IconSize'                  = 16
    'New-HTMLTab:IconBrands'                = 'accessible-icon'
    'New-HTMLSection:HeaderTextSize'        = 16
    'New-HTMLSection:HeaderBackGroundColor' = 'Green'
    'New-HTMLSection:CanCollapse'           = $true
}
$PSDefaultParameterValues
#endregion Paramétrages du comportement par défaut de certaines cmdlets

#region Génération du rapport HTML
Write-Color -Text 'Génération du rapport HTML avec PSWriteHTML...' -ForegroundColor Cyan
Write-Color -Text 'Créer le rapport HTML avec onglets' -ForegroundColor Cyan -StartTab 1
New-HTML {
    # ONGLET 1 : Vue d'ensemble et statistiques
    New-HTMLTab -Name "📊 Vue d''ensemble" {
        New-HTMLSection -Invisible {
            New-HTMLSection -HeaderText 'Informations générales' {
                New-HTMLPanel {
                    New-HTMLText -FontSize 14 -Text @"
                <h3>Informations du rapport</h3>
                <p><strong>Ordinateur :</strong> $NomOrdinateur</p>
                <p><strong>Date du rapport :</strong> $DateRapport</p>
                <p><strong>Utilisateur :</strong> $env:USERNAME</p>
"@
                }# End New-HTMLPanel
            } #end New-HTMLSection
            New-HTMLSection -HeaderText 'Statistiques globales' {
                # Panneaux de statistiques
                New-HTMLPanel -BackgroundColor WhiteSmoke {
                    New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesEntrantes</h2>"
                    New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles entrantes</p>"
                } #end New-HTMLPanel

                New-HTMLPanel -BackgroundColor WhiteSmoke {
                    New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesEntrantesActives</h2>"
                    New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles entrantes actives</p>"
                }#end New-HTMLPanel

                New-HTMLPanel -BackgroundColor WhiteSmoke {
                    New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesEntrantesInactives</h2>"
                    New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles entrantes inactives</p>"
                }#end New-HTMLPanel

                New-HTMLPanel -BackgroundColor WhiteSmoke {
                    New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesSortantes</h2>"
                    New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles sortantes</p>"
                }#end New-HTMLPanel

                New-HTMLPanel -BackgroundColor WhiteSmoke {
                    New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesSortantesActives</h2>"
                    New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles sortantes Actives</p>"
                }#end New-HTMLPanel

                New-HTMLPanel -BackgroundColor WhiteSmoke {
                    New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesSortantesInactives</h2>"
                    New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles sortantes inactives</p>"
                }#end New-HTMLPanel

                New-HTMLPanel -BackgroundColor WhiteSmoke {
                    New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$totalReglesActives</h2>"
                    New-HTMLText -Text "<p style='text-align: center; color: #666;'>Total des règles actives</p>"
                }#end New-HTMLPanel
            }#end New-HTMLSection
        } #end New-HTMLSection Invisible
    }#End New-HTMLTab

    # ONGLET 2 : Vue d'ensemble et statistiques
    New-HTMLTab -Name "📊 Vue d''ensemble" {
        New-HTMLSection -HeaderText 'Statistiques globales' {

            # Panneaux de statistiques
            New-HTMLPanel -BackgroundColor WhiteSmoke {
                New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesEntrantesActives</h2>"
                New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles entrantes actives</p>"
            }

            New-HTMLPanel -BackgroundColor WhiteSmoke {
                New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$NbreReglesSortantesActives</h2>"
                New-HTMLText -Text "<p style='text-align: center; color: #666;'>Règles sortantes actives</p>"
            }

            New-HTMLPanel -BackgroundColor WhiteSmoke {
                New-HTMLText -Text "<h2 style='color: #0078d4; text-align: center; margin: 0;'>$totalReglesActives</h2>"
                New-HTMLText -Text "<p style='text-align: center; color: #666;'>Total des règles actives</p>"
            }
        }

        New-HTMLSection -HeaderText 'Graphiques de répartition' {
            # Graphique règles entrantes
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartPie -Name 'Actives' -Value $NbreReglesEntrantesActives -Color '#28a745'
                    New-ChartPie -Name 'Inactives' -Value $NbreReglesEntrantesInactives -Color '#dc3545'
                } -Title 'Règles Entrantes' -TitleAlignment center
            }# End New-HTMLPanel

            # Graphique règles sortantes
            New-HTMLPanel {
                New-HTMLChart {
                    New-ChartPie -Name 'Actives' -Value $NbreReglesSortantesActives -Color '#28a745'
                    New-ChartPie -Name 'Inactives' -Value $NbreReglesSortantesInactives -Color '#dc3545'
                } -Title 'Règles Sortantes' -TitleAlignment center
            }# End New-HTMLPanel
        }#  End New-HTMLSection
    } # End New-HTMLTab

    # ONGLET 3 : Règles entrantes
    New-HTMLTab -Name '🔽 Règles Entrantes' {
        New-HTMLSection -HeaderText "Liste des règles entrantes actives ($NbreReglesEntrantesActives règles)" {
            New-HTMLTable -DataTable $DataEntrantes {
                New-TableCondition -Name 'Action' -Value 'Allow' -ComparisonType string -BackgroundColor Green -Color White
                New-TableCondition -Name 'Action' -Value 'Block' -ComparisonType string -BackgroundColor Orange -Color White
            }# End New-HTMLTable
        } # End New-HTMLSection
        New-HTMLSection -HeaderText "Liste des règles entrantes inactives ($NbreReglesEntrantesInactives règles)" {
            New-HTMLTable -DataTable $DataEntrantes_Inactives {
                New-TableCondition -Name 'Action' -Value 'Allow' -ComparisonType string -BackgroundColor Green -Color White
                New-TableCondition -Name 'Action' -Value 'Block' -ComparisonType string -BackgroundColor Orange -Color White
            }# End New-HTMLTable
        } # End New-HTMLSection
    }# End New-HTMLTab

    # ONGLET 4 : Règles sortantes
    New-HTMLTab -Name '🔼 Règles Sortantes' {
        New-HTMLSection -HeaderText "Liste des règles sortantes actives ($NbreReglesSortantesActives règles)" {
            New-HTMLTable -DataTable $DataSortantes {
                New-TableCondition -Name 'Action' -Value 'Allow' -ComparisonType string -BackgroundColor Green -Color White
                New-TableCondition -Name 'Action' -Value 'Block' -ComparisonType string -BackgroundColor Orange -Color White
            } # End New-HTMLTable
        } # End New-HTMLSection
        New-HTMLSection -HeaderText "Liste des règles sortantes inactives ($NbreReglesSortantesInactives règles)" {
            New-HTMLTable -DataTable $DataSortantesInactives {
                New-TableCondition -Name 'Action' -Value 'Allow' -ComparisonType string -BackgroundColor Green -Color White
                New-TableCondition -Name 'Action' -Value 'Block' -ComparisonType string -BackgroundColor Orange -Color White
            } # End New-HTMLTable
        } # End New-HTMLSection
    } # End New-HTMLTab

}# End New-HTML
#endregion Génération du rapport HTML

#region Résumé et statistiques finales
Write-Color -Text "`n✅ Rapport généré avec succès !" -ForegroundColor Cyan
Write-Color -Text "`n📁 Emplacement : ", "$outputPath" -ForegroundColor cyan, green
Write-Color -Text "`n📊 Statistiques : " -ForegroundColor Cyan
Write-Color -Text '   - Règles entrantes actives   : ', "$NbreReglesEntrantesActives" -ForegroundColor cyan, green -StartTab 1
Write-Color -Text '   - Règles entrantes inactives : ', "$NbreReglesEntrantesInactives" -ForegroundColor cyan, green -StartTab 1
Write-Color -Text '   - Règles sortantes actives   : ', "$NbreReglesSortantesActives" -ForegroundColor cyan, green -StartTab 1
Write-Color -Text '   - Règles sortantes inactives : ', "$NbreReglesSortantesInactives" -ForegroundColor cyan, green -StartTab 1
Write-Color -Text '   - Total règles actives       : ', "$totalRegles" -ForegroundColor cyan, green -StartTab 1
#endregion Résumé et statistiques finales

#region arrêt watcher
$Watcher.Stop() # arrêt du timer
$Time = $Watcher.Elapsed
Write-Color -Text "`n⏱ Durée d'exécution du script : ", $Time.Minutes, ' minutes ', $Time.Seconds, ' secondes ', $Time.Milliseconds, ' millisecondes.' -ForegroundColor Cyan, Green, Cyan, Green, Cyan, Green -StartTab 1
Write-Color -Text "`n✅ Script terminé : Rapport des règles de PareFeu.ps1" -ForegroundColor Green
Write-Color -Text "`n----------------------------------------`n" -ForegroundColor DarkGray
Write-Color -Text 'Rapport disponible ici : ', "$outputPath" -ForegroundColor Green, Yellow
#endregion arrêt watcher