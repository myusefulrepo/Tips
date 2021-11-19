<#
 .Synopsis
    Script de report sur les serveurs d'impression, les queues d'impression partagées et les ports

 .DESCRIPTION
    Script de report sur les serveurs d'impression, les queues d'impression partagées et les ports
    Toutes les informations recueillies sont dynamiques : Aucune information n'est demandée à l'utilisateur
    - Collecte Dynamique du domaine
    - Collecte dynamique de tous les serveurs dans le domaine Active Directory
    - Collecte dynamique de tous les serveurs aynat les service d'impression installés
    - Collecte dynamique des queues d'impression, partagées uniquement, pour tous les serveurs d'impression
    - Collecte dynamique des ports, TCP/IP Standard uniquement, pour tous les serveurs d'impression
    - Génération du Rapport au format Html avec l'ensemble de ces informations
        Utilise le module Powershell PSWriteHtml pour les sorties

    Les informations importantes et conformes apparaissent sur fond vert
    Les informations importantes et conformes, mais non "standards" apparaissent sur fond orange
    Les informations importantes non conformes apparaissent sur fond rouge


 .INPUTS
    Aucune

 .OUTPUTS
    Fichier Rapport au format Html
    Localisation par défaut : $PSScriptRoot (répertoire courant du script)

 .NOTES
    Auteur             : O. FERRIERE
    Date               : 22/01/2021
    Version            : 1.1
    Changement/version : 1.0 : 24/07/2020 - Version Initiale - basée sur les infos et l'exemple suivant : https://evotec.xyz/active-directory-dhcp-report-to-html-or-email-with-zero-html-knowledge/
                                            Ajout du comportement par défaut des certaines cmdlets - Amélioration sortie après Tests approfondis
			 1.1 22/01/2021 - Paramétrage pour utiliser TLS1.2 pour mettre à jour les modules sur powershellGallery à partir du 01/04/2020
					 ref : https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/


 .EXAMPLE
    .\Printer_Report.ps1
    Exécute le script et génère le rapport

 .EXAMPLE
    Get-Help .\Printer_Report.ps1 -Full
    Aide complète sur ce script
 #>
#region Collecte de tous les serveurs du domaine
Write-Host "Collecte de tous les serveurs du domaine ..." -ForegroundColor Green -NoNewline
$AllServers = Get-ADComputer -Filter * -Properties OperatingSystem | Where-Object {$_.OperatingSystem -like "Windows Server *"} | Select-Object -Property Name, Distinguishedname, OperatingSystem
Write-Host "Terminé" -ForegroundColor Yellow
#endregion Collecte de tous les serveurs du domaine

#region collecte de tous les serveurs ayant les services d'impression installés
Write-Host "collecte de tous les serveurs ayant les services d'impression installés ..." -ForegroundColor Green -NoNewline
$AllPrintServers =@() # initialisation
foreach($server in $AllServers)
    {
    $obj = Get-WindowsFeature -ComputerName $server.Name -name "Print-server" |
        Where-Object {$_.InstallState -eq "Installed"} |
        Select-Object -Property @{Label = "Server"      ; Expression = {$($server.name) } },
                                @{Label = "Name"        ; Expression = {$_.Name} },
                                @{Label = "DisplayName" ; Expression = {$_.DisplayName} },
                                @{Label = "Installed"   ; Expression = {$_.Installed} }
    $AllPrintServers =$AllPrintServers + $obj
    }
Write-Host "Terminé" -ForegroundColor Yellow
#endregion collecte de tous les serveurs ayant les services d'impression installés

#region Utilisation de TLS1.2
# Paramétrage pour utiliser TLS1.2 pour mettre à jour les modules sur powershellGallery à partir du 01/04/2020
# ref : https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#endregion Utilisation de TLS1.2


#region Vérification si le module est installé, si non téléchargement
Write-Host "Vérification que le module PSWriteHtml est installé" -ForegroundColor Green
If (-not (Get-Module -ListAvailable -Name PSWriteHtml))
{
    # On fait l'installation pour l'utilisateur courant, on pourrait le faire pour tous les utilisateurs de la machine tout aussi bien, mais il faudrait pour ce faire exécuter le script en "Run As Administrator"
    Try
    {
        Write-Host "Le module PSWriteHtml n'est pas installé" -ForegroundColor yellow
        Write-Host "Téléchargement et installation ... : " -ForegroundColor Green -NoNewline
        Install-Module PSWriteHTML -Force -Scope CurrentUser
        Write-Host "Terminé" -ForegroundColor Yellow
    }
    Catch
    {
        Write-Host "Le module n'a pu être installé. Fin du script." -ForegroundColor Red
        Write-Host "Une erreur est survenue. Message d'erreur : $_." -ForegroundColor Red
        Break
    }
}
#endregion Vérification si le module est installé, si non téléchargement

#region Importation du module pour avoir les cmdlets disponibles
Write-Host "Import du module PSWriteHtml ... " -ForegroundColor Green -NoNewline
Import-Module PSWriteHTML
Write-Host "Terminé" -ForegroundColor Yellow
Write-Host "Import du module DNSServer... " -ForegroundColor Green -NoNewline
Import-Module DNSserver
Write-Host "Terminé" -ForegroundColor Yellow
Write-Host "Import du module ActiveDirectory... " -ForegroundColor Green -NoNewline
Import-Module ActiveDirectory
Write-Host "Terminé" -ForegroundColor Yellow
#endregion Importation du module pour avoir les cmdlets disponibles

#region Paramétrage du comportement par défaut de certaines cmdlets
Write-Host "Paramétrage du comportement par défaut de certaines cmdlets : " -ForegroundColor Green -NoNewline
$PSDefaultParameterValues =@{
    "New-HTMLSection:HeaderBackGroundColor" = "Green"
    "New-HTMLSection:CanCollapse"= $true
    }
Write-Host "Terminé" -ForegroundColor Yellow
#endregion Paramétrage du comportement par défaut de certaines cmdlets

#region obtention du nom de domaine courant
Write-Host "Collecte du nom de domaine : " -ForegroundColor Green -NoNewline
$Domain = (Get-ADDomain).DnsRoot
Write-Host "$Domain" -ForegroundColor Yellow
#endregion obtention du nom de domaine courant

#region Sortie HTML d'informations multiples dans différents onglets d'une même page html
$ReportPath = "$PSScriptRoot\PrinterReport-du-$(Get-Date -f "dd-MM-yyyy").html"
Write-Host "Collecte des Info et génération du rapport ..." -ForegroundColor Green -NoNewline
New-HTML -FilePath $ReportPath  -Online -ShowHTML {
    #1er Onglet Sommaire
    New-HTMLTab -Name 'PRINT SERVERS' {
        New-HTMLSection -HeaderText "TOUS LES PRINT SERVERS du domaine $Domain" {
            New-HTMLTable -DataTable $AllPrintServers {
                New-TableContent -ColumnName "Name", "DisplayName", "Installed" -Alignment center
                New-TableContent -Name "Server" -BackGroundColor Green -Color White -Alignment center
                }#end new-htmltable
            }#end new-htmlSection
     }#New-htmltab

foreach ($server in $AllPrintServers)
    {
    #Ajout d'un onglet par serveur d'impression
    New-HTMLTab -Name "$($Server.Server)" {
        New-HTMLSection -HeaderText "QUEUES d'IMPRESSION PARTAGEES pour $($server.name)"  {
                #region Collecte dynamique des Imprimantes
                try {
                    $Printers = Get-Printer -ComputerName $server.Server |
                        Where-Object {$_.Shared -eq $true} |
                        Select-Object -Property @{Label = "Server" ; Expression = {$Server.Server} },
                                                @{Label = "PortName" ; Expression = {$_.PortName} },
                                                @{Label = "Shared" ; Expression = {$_.Shared} },
                                                @{Label = "ShareName" ; Expression = {$_.ShareName} },
                                                @{Label = "Published" ; Expression = {$_.Published} },
                                                @{Label = "PrinterStatus" ; Expression = {$_.PrinterStatus} },
                                                @{Label = "Comment" ; Expression = {$_.Comment} },
                                                @{Label = "Location" ; Expression = {$_.Location} },
                                                @{Label = "DriverName" ; Expression = {$_.DriverName} }
                    }
                catch{
                    continue
                    }
                #endregion Collecte dynamique des Imprimantes
                New-HTMLTable -DataTable $Printers {
                        New-TableContent -ColumnName "Server","PortName","Shared","Comment","Location","DriverName"  -Alignment center
                        New-TableContent -ColumnName "ShareName" -BackGroundColor Green -Color White -Alignment center
                        New-TableCondition -Name "Published" -ComparisonType string -Operator eq -Value $true  -Color white -BackgroundColor Green -Alignment center
                        New-TableCondition -Name "Published" -ComparisonType string -Operator eq -Value $false -Color white -BackgroundColor Orange   -Alignment center
                        New-TableCondition -Name "PrinterStatus" -ComparisonType string -Operator eq -Value "Paused, Offline" -Color white -BackgroundColor Red   -Alignment center
                        New-TableCondition -Name "PrinterStatus" -ComparisonType string -Operator eq -Value "Normal"          -Color white -BackgroundColor Green -Alignment center
                    }#end new-htmltable
        }#end new-htmlsection

        New-HTMLSection -HeaderText "PORTS d'IMPRESSION PCP/IP pour $($server.Server)"  {
                #region Collecte dynamique des ports
                try {
                    $Ports = Get-PrinterPort -ComputerName $($server.server) |
                        Where-Object {$_.Description -eq "Port TCP/IP standard"} |
                        Select-Object -Property @{Label = "Server" ; Expression = {$Server.server} },
                                                @{Label = "Name" ; Expression = {$_.Name} },
                                                @{Label = "Description" ; Expression = {$_.Description} },
                                                @{Label = "SNMPCommunity" ; Expression = {$_.SNMPCommunity} },
                                                @{Label = "SNMPEnabled" ; Expression = {$_.SNMPEnabled} }
                    }
                catch{
                    continue
                    }
                #endregion Collecte dynamique des ports
                New-HTMLTable -DataTable $Ports {
                        New-TableContent -ColumnName "Server" , "Name", "Description", "SNMPCommunity"  -Alignment center
                        New-TableCondition -Name "SNMPEnabled" -ComparisonType string -Operator eq -Value $True  -Alignment center -BackgroundColor Orange -Color white
                        New-TableCondition -Name "SNMPEnabled" -ComparisonType string -Operator eq -Value $false -Alignment center -BackgroundColor Green -Color white
                    }#end new-htmltable
        }#end new-htmlsection

    }#end new-htmltab
    }#end foreach

}#end new-html
#endregion Sortie HTML d'informations multiples dans différents onglets d'une même page html
Write-Host "Terminé" -ForegroundColor Yellow
Write-Host "Le rapport est disponible ici : " -ForegroundColor Green -NoNewline
Write-Host $ReportPath -ForegroundColor Yellow
