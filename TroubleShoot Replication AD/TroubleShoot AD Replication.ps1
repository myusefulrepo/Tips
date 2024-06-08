# Ajouter Synopsys
<#
.SYNOPSIS
    Troubleshoot de la réplication AD

.DESCRIPTION
    Troubleshoot de la réplication AD
    Résolution des pbs liée à une réplication AD non initialisée

        TO DO :
    On pourrait ajouter ceci en fin d script
        - compter les fichier sur \\$refDC\SYSVOL\domain\Policies et \\$refDC\SYSVOL\domain\Scripts (Netlogon)
        - Compter les fichiers sur les autres Dcs
        Si ce sont les mêmes c'est que tout est OK

.EXAMPLE
    Get-Help .\TroubleShootReplicationAD.ps1 -ShowWindows
    Aide complète sur le script

.EXAMPLE
    .\TroubleShootReplicationAD.ps1
    Exécution du script

.INPUTS
    Aucune

.OUTPUTS
    Console uniquement

.NOTES
    Auteur       : L'auteur
    Version      : 1.1
    Date         : 13/06/2023
    Changements  : V1.0 - Basée sur le script de xxxx du ... - jj/dd/yy - Version initiale
                   V1.1 - Amélioration de la gestion d'erreur - suppression de toute variable "hard-codée"
                          ajout d'étapes manquantes - Amélioration de la verbosité utilisateur
                          Passage au PSCriptAnalyzer

.LINK
    Liste de documents de référence
    https://docs.microsoft.com/fr-fr/troubleshoot/windows-server/networking/troubleshoot-missing-sysvol-and-netlogon-shares
    ou en US : https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/troubleshoot-missing-sysvol-and-netlogon-shares

    https://docs.microsoft.com/fr-FR/troubleshoot/windows-server/group-policy/force-authoritative-non-authoritative-synchronization
    ou en US : https://docs.microsoft.com/en-us/troubleshoot/windows-server/group-policy/force-authoritative-non-authoritative-synchronization

    https://helpdeskgeek.com/how-to/active-directory-force-replication/

    https://jackstromberg.com/2014/07/sysvol-and-group-policy-out-of-sync-on-server-2012-r2-dcs-using-dfsr/
#>

#region Etape 1: Collecte des DCs et détermination du DC de référence
$AllDCs = (Get-ADDomainController -Filter *)
$RefDC = $AllDcs.Name | Out-GridView -Title 'Sélectionner le DC de réfence' -OutputMode Single
Write-Host "Le Contrôleur de domaine qui va servir de DC de référence est : [$RefDC]"-ForegroundColor Green
$OtherDCs = $($AllDCs.Name) -replace ($RefDC, '')
Write-Host 'Les autres controlleurs de domaine sont : ' -ForegroundColor Green
$OtherDCs
#endregion Etape 1: Collecte des DCs et détermination du DC de référence

#region Etape2: Vérification du mode de réplication AD
$Result = foreach ($DC in $AllDCs)
{
    Invoke-Command -ComputerName $DC -ScriptBlock { Get-Service NTFRS }
}
foreach ($Item in $Result)
{
    if ($Item.Status -eq 'Stopped')
    {
        Write-Host "Le service $($Item.Name) de $($Item.PSComputerName) est $($item.Status) : réplication en mode DFS-R" -ForegroundColor Green
    }
    else
    {
        {
            Write-Host "Le service $($Item.Name) de $($Item.PSComputerName) est $($item.Status) : réplication en mode NTFRS" -ForegroundColor Yellow
            Write-Host 'Veuillez changer le mode de réplication. Arrêt du script' -ForegroundColor Yellow
            throw
        }
    }
}
#endregion Etape2: Vérification du mode de réplication AD

#region Étape 3: Sauvegarde du dossier Sysvol
$SysvolPath = 'C:\Windows\SYSVOL'
$BackupFolder = "$env:USERPROFILE\Desktop\SysvolBackup"
New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
Copy-Item -Path $SysvolPath -Destination $BackupFolder -Recurse -Force
Write-Host "le Sysvol a été sauvegardé ici : [$BackupFolder]" -ForegroundColor Green
#endregion Étape 3: Sauvegarde du dossier Sysvol

#region Etape 4 : arrêt des services DFSR sur tous les DCs
foreach ($DC in $($AllDCs.Name))
{
    Invoke-Command -ComputerName $DC -ScriptBlock {
        Try
        {
            Stop-Service DFS-R -ErrorAction Stop
            Write-Host "Le service DFS-R été arrêté sur [$Using:DC)]" -ForegroundColor Green
        }
        catch
        {
            Write-Host "Le service DFS-R n'a pas pu être arrêté sur [$using:DC]" -ForegroundColor Yellow
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    } #end scriptblock
}
#endregion Etape 4 : arrêt des services DFSR sur tous les DCs

#region Étape 5: Initialisation de la synchronisation sur le DC faisant autorité
Write-Host 'Initialisation de la synchronisation sur le DC faisant autorité' -ForegroundColor Green
$DomainControllerDN = (Get-ADDomain).DomainControllersContainer
$ADSIPath = "LDAP://CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,CN=$RefDC,$DomainControllerDN"
$ADSIProperties = @{
    'msDFSR-Enabled' = $false
    'msDFSR-options' = 1
}

$ADSIObject = [adsi]$ADSIPath
foreach ($Prop in $ADSIProperties.Keys)
{
    $ADSIObject.Properties[$prop].Value = $ADSIProperties[$prop]
}
$ADSIObject.CommitChanges()
#endregion Étape 5 : Initialisation de la synchronisation sur le DC faisant autorité

#region Étape 6: Modification des autres contrôleurs de domaine
Write-Host 'Modification ADSI sur les autrs DCs' -ForegroundColor Green
$ADSIPathFormat = "LDAP://CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,CN={0},$DomainControllersDN"
foreach ($DC in $OtherDCs)
{
    $ADSIPath = $ADSIPathFormat -f $DC
    $ADSIObject = [adsi]$adsiPath
    $ADSIObject.Properties['msDFSR-Enabled'].Value = $false
    $ADSIObject.CommitChanges()
}
#endregion Étape 6 : Modification des autres contrôleurs de domaine

#region Étape 7 : Synchronisation AD forcée depuis le DC faisant référence (autorité)
Write-Host "Initialisation de la synchonisation forcée du domaine depuis le DC faisant autorité [$RefDC]" -ForegroundColor Green
repadmin /syncall $RefDC/APed
Write-Host 'réplication terminée' -ForegroundColor Green
#endregion Étape 7 : Synchronisation AD forcée depuis le DC faisant référence (autorité)

#region Étape 8 : Redémarrage du service DFSR sur le DC faisant autorité
Try
{
    Restart-Service DFSR -ComputerName $RefDC -ErrorAction Stop
    Write-Host "Le service DFS-R été redémarré sur [$RefDC]" -ForegroundColor Green
}
catch
{
    Write-Host "Le service DFS-R n'a pas pu être redémarré sur [$RefDC]" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
}
#endregion Étape 8 : Redémarrage du service DFSR sur le DC faisant autorité

#region Étape 9: Vérification des événements sur le DC faisant autorité
Start-Sleep -Seconds 300  # Attendre 5 minutes pour les événements
$EventId4114 = Get-WinEvent -ComputerName $RefDC -FilterHashtable @{ LogName = 'DFS Replication'
    ID                                                                       = 4114
} -MaxEvents 5
$EventId2212 = Get-WinEvent -ComputerName $RefDC -FilterHashtable @{ LogName = 'DFS Replication'
    ID                                                                       = 4114
} -MaxEvents 5
if ($eventId2212)
{
    Write-Host 'La base DFSR est corrompue. La reconstruction de la base est nécessaire.' -ForegroundColor Yellow
    $volumeGuid = $eventId2212.Properties[0].Value
    $rebuildCommand = "wmic /namespace:\\root\microsoftdfs path dfsrVolumeConfig where volumeGuid='$volumeGuid' call ResumeReplication"
    Try
    {
        & $rebuildCommand
        Restart-Service DFSR -ComputerName $primaryDC -ErrorAction Stop
    }
    catch
    {
        Write-Host 'Une erreur est survenue' -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

if ($EventId4114)
{
    Write-Host "on doit avoir un event indiquant que la réplication SYSVOL n'est plus effectuée" -ForegroundColor Gray
    $EventId4114
}
#endregion Étape 9: Vérification des événements sur le DC faisant autorité

#region Étape 10 : Synchronisation des autres contrôleurs de domaine
$sysvolPath = "\\$RefDC\SYSVOL"
Write-Host "Le DC faisant autorité a son SYSVOl situé en [$sysvolPath] " -ForegroundColor Green
$otherDCs | ForEach-Object {
    $dc = $_
    $dcSysvolPath = "\\$dc\SYSVOL"

    Write-Host "Nettoyage du SYSVOl de [$Dc]" -ForegroundColor Green
    Remove-Item -Path "$dcSysvolPath\domain\Policies" -Recurse -Force
    Remove-Item -Path "$dcSysvolPath\domain\Scripts" -Recurse -Force
}

Write-Host "Réactivation DFSR sur le DC faisant autorité [$RefDC)" -ForegroundColor Green
$adsiPath = $adsiPathFormat -f $primaryDC
$adsiObject = [adsi]$adsiPath
$adsiObject.Properties['msDFSR-Enabled'].Value = $true
$adsiObject.CommitChanges()

Write-Host 'Synchronisation AD et DFSR' -ForegroundColor Green
$otherDCs | ForEach-Object {
    $dc = $_
    dfsrdiag POLLAD /Member:$dc
    repadmin /syncall $RefDC /APed
}
#endregion Étape 10 : Synchronisation des autres contrôleurs de domaine

#region Étape 11 : Vérification des événements sur le DC faisant autorité
Start-Sleep -Seconds 300  # Attendre 5 minutes pour les événements
$EventId4602 = Get-WinEvent -ComputerName $RefDC -FilterHashtable @{ LogName = 'DFS Replication'
    ID                                                                       = 4602
} -MaxEvents 5
$EventId2212 = Get-WinEvent -ComputerName $RefDC -FilterHashtable @{ LogName = 'DFS Replication'
    ID                                                                       = 2212
} -MaxEvents 5

if ($EventId4602)
{
    Write-Host 'on doit avoir un event indiquant que la réplication SYSVOL a été initialisée' -ForegroundColor Gray
    $EventId4602
}
#endregion Étape 11 : Vérification des événements sur le DC faisant  autorité

#region Etape 12 : redémarrage du service DFS-R sur les autres DCs
foreach ($DC in $OtherDCs)
{
    Try
    {
        Restart-Service DFSR -ComputerName $DC -ErrorAction Stop
        Write-Host "Le service DFS-R eté redémarré sur [$DC]" -ForegroundColor Green
    }
    catch
    {
        Write-Host "Le service DFS-R n'a pas pu être redémarré sur [$DC]" -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}
#endregion Etape 12 : redémarrage du service DFS-R sur les autres DCs

#region Etape 13: Vérification des évênements sur les autres DCs
Start-Sleep -Seconds 300 # Attendre 5 minutes pour les événements
foreach ($DC in $OtherDCs)
{
    $EventId4114 = Get-WinEvent -ComputerName $RefDC -FilterHashtable @{ LogName = 'DFS Replication'
        ID                                                                       = 4114
    } -MaxEvents 5
}
if ($EventId4114)
{
    Write-Host "on doit avoir un event indiquant que la réplication SYSVOL n'es touours pas répliquée sur eux" -ForegroundColor Gray
    $EventId4602
}
#endregion Etape 13: Vérification des évênements sur les autres DCs

#region Etape 14: modification ADSI sur les autres DCs
Write-Host 'Modification ADSI sur les autrs DCs' -ForegroundColor Green
$ADSIPathFormat = "LDAP://CN=SYSVOL Subscription,CN=Domain System Volume,CN=DFSR-LocalSettings,CN={0},$DomainControllersDN"
foreach ($DC in $OtherDCs)
{
    $ADSIPath = $ADSIPathFormat -f $DC
    $ADSIObject = [adsi]$adsiPath
    $ADSIObject.Properties['msDFSR-Enabled'].Value = $true
    $ADSIObject.CommitChanges()
}
#endregion Etape 14: modification ADSI sur les autres DCs

#region Etape 15 : forcer la réplication sur l'ensemble des DCs
Write-Host "Synchronisation DFSR sur l'ensemble des DCs"
$AllDCs | ForEach-Object {
    $dc = $_
    dfsrdiag POLLAD /Member: $dc
}
#endregion Etape 15 : forcer la réplication sur l'ensemble des DCs
