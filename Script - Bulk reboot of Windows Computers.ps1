<#
.SYNOPSIS
   Bulk reboot of Windows Computers
   Script de reboot en masse de machines Windows

.DESCRIPTION
    Bulk reboot of Windows Computers
    Uses WinRM (Windows Remote Management)

    Script de reboot en masse de machines Windows
    S'appuie sur WinRM (Windows Remote Management)

.EXAMPLE
   .\Reboot-Serveurs.ps1
   Running script with the name of the default servers imput .txt file

   Exécution du script avec le nom du fichier .txt d'imput des serveurs par défaut

.EXAMPLE
   .\Reboot-Serveurs.ps1 -Computers $(Get-Content -Path "\\MuPath\To\servers.txt"
   Running script with a name of the server input .txt file provided

   Exécution du script avec un nom du fichier .txt d'imput des serveurs fourni

.EXAMPLE
   Get-Help .\Reboot-Serveurs.ps1 -Full
   Full script help

   Aide complète sur le script

.EXAMPLE
   Get-Help .\Reboot-Serveurs.ps1 - ShowWindows
   Full script help in a separate window

   Aide complète sur le script dans une fenêtre séparée

.INPUTS
    .txt File : List of servers
    Fichier .txt : Liste des serveurs

.OUTPUTS
   log file : log file
    Display console and Out-GridView

   Fichier .log : fichier de log
   Display console et Out-Gridview

.NOTES
   Auteur                : O. FERRIERE
   Version               : 1.0
   Date                  : 25/02/2022
   Revisions/Changements : 1.0 - 25/02/2022 -  Initiale Version
#>

#region Param
param
(
    # Full Path of the server list .txt file  - Full Path du fichier .txt liste des serveurs
    [Parameter(Mandatory = $False,
        Position = 0)]
    [String]$Computers = $(Get-Content -Path "$PSScriptRoot\servers.txt"),

    # Credentials
    [Parameter(Position = 1)]
    [System.Management.Automation.PSCredential]$DomainCreds = $(Get-Credential)
)
#endregion Param

#region function internal
function RebootSystem
{
    param(
        [Parameter(Mandatory)]$Computer,

        [Parameter(Mandatory)]$Creds
    )
    try
    {
        Restart-Computer -Credential $Creds -ComputerName $Computer -Wait -Force -ErrorAction Stop
        $Props = [ordered]@{
            Name   = $Computer
            Result = 'Success'
        }
    }
    catch
    {
        $Props = [ordered]@{
            Name   = $Computer
            Result = "Failed $($_.exception.message)"
        }
    }
    return (New-Object PSCustomObject -Property $Props)
}
#endregion function internal

#region treatment - traitement
foreach ($Computer in $Computers)
{
    Write-Output "Beginning restarting $Computer"
    <#
    We launch a job, which allows to recover the hand immediately, and we pass $Computer and the Credentials as parameter
    Note that Credentials are only needed if the account running the script does not have the privileges
    ex. : Local account
    On lance un job, ce qui permet de récupérer la main tout de suite, et on lui passe en paramètre $Computer et les Credentials

    A noter que les Credentials ne sont nécessaires que si le compte qui exécute le script n'a pas les privilèges
    ex. : Compte local
    #>
    Start-Job -ScriptBlock ${function:RebootSystem} -ArgumentList $Computer, $DomainCreds | Out-Null
}
# At this step, there have been as many jobs created as servers to process - A cette étape, il y a eu autant de jobs de créés que de serveurs à traiter

while (Get-Job | Where-Object -Property State -EQ 'Running')
{
    # We count the jobs that are still running, and if there are any that are still running, we wait - On compte les jobs qui tournent encore, et s'il y en a qui tournent encore, on attend
    $JobCount = (Get-Job | Where-Object -Property State -EQ 'Running').count
    Write-Output "Nous attendons encore que $JobCount job de reboots se terminent, dodo pour 10 secondes et on re-check"
    Start-Sleep -Seconds 10
}
# At this step, all the jobs are finished. - A cette étape, tous les jobs sont terminés.
#endregion treatment - traitement

#region cleaning - nettoyage
$EndResult = Get-Job | Receive-Job -Force -Wait
# Deletion of all jobs (since completed) - Suppression de tous les jobs (puisque terminés)
Get-Job | Remove-Job
#endregion cleaning - Nettoyage

#region Display - Affichage
#Display in an out-gridview of the result of all jobs - Affichage dans un out-gridview du résultat de tous les jobs
$EndResult | Select-Object -Property Name, Result | Out-GridView
#endregion Display - Affichage

#region logging
# Determination of the FullPathName for the log file. We make a timestamped log file - Determination du FullPathName pour le fichier de log. On fait un fichier de log Horodaté
$LogFile = "$PSScriptRoot\Reboot-$(Get-Date -Format 'yy-MM-dd-hh-mm-ss').log"
foreach ($Result in $EndResult)
{
    # We add the result of each job in the log file - On ajoute le résultat de chaque job dans le fichier de log
    "$($Result.Name), $($Result.Result)" | Out-File $logfile -Append
}
<#
We can do all sorts of things for logging.
For example :
- Make a log file for failed jobs, and one for successful ones.
- A single log file for only failed jobs
- A single log file for all jobs. (what presented)

Nous pouvons faire toutes sortes de choses pour le logging.
Par exemple :
- Faire un fichier de log pour les jobs qui ont échoués, et un pour ceux réussi.
- Un seul fichier de log pour seulement les jobs échoués
- Un seul fichier de log pour tous les jobs. (ce que présenté)
#>
#endregion logging
