Import-Module EZLog

############################
# Exemple d'utilisation
############################



$Date = Get-Date -Format "dd-MM-yyyy-hh-MM-ss" 
#$LogFile = Join-Path -Path $PSScriptRoot MylogFile-$Date.log est préférable
$LogFile = Join-Path -Path c:\temp -ChildPath  MylogFile-$Date.log

# Commencer par définir les paramètres une fois pour toutes pour se faciliter la tâche dans le script plus tard
$PSDefaultParameterValues  = @{ 'Write-EZLog:LogFile'   = $LogFile ;  # On dit à la cmdlet Write-EZlog que son paramètre Logfile a la valeur $Logfile
                                'Write-EZLog:Delimiter' = ';' ;       # On dit à la cmdlet Write-EZlog que son paramètre défimiter est un ;
                                'Write-EZLog:ToScreen'  = $true }     # On dit à la cmdlet Write-EZlog que son paramètre ToScreen est à $true (affichage en console en plus d'inscription en fichier de log)
####" une fonction est définie dans mon script
Function Myfunction
{
[CmdletBinding()]
 Param
    (
        # Name help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$Name
    )
Begin
    {
    Write-EZLog -Category INF -Message "Le nom qui a été saisi est $Name"
    }
    Process
    {
    Try { # On essaie de faire ce qu'on doit faire
        Write-Ezlog -Category INF -Message "On fait les actions qu'on a à faire sur $Name"
        Remove-Item -Path $Name -ErrorAction stop # je fais une action totalement bidon juste pour générer une erreur
        }
    Catch 
        { # si ça claque des erreurs, on les logs également 
        $ErrorMessage = $_.Exception.Message
        Write-EZLog -Category ERR -Message "Le message d'erreur est $ErrorMessage"
        }
    }
    End
    {
    Write-EZLog -Category INF -Message "Les actions sont terminées"
    }
}

#### MAIN SCRIPT

# On initie la création du fichier de log
Write-EZLog -Header
# On appelle la fonction
Myfunction -Name toto
Write-EZLog -Footer # on ajoute le footer et ça ferme le fichier de log en ajoutant des infos qui vont bien

<# La tête du fichier de log
+----------------------------------------------------------------------------------------+
Script fullname          : 
When generated           : 2019-06-12 11:50:36
Current user             : INTRA\OF773298
Current computer         : IS220050
Operating System         : Microsoft Windows 7 Entreprise 
OS Architecture          : 64 bits
+----------------------------------------------------------------------------------------+

2019-06-12 11:50:36; INF; Le nom qui a été saisi est toto
2019-06-12 11:50:36; INF; On fait les actions qu'on a à faire sur toto
2019-06-12 11:50:36; ERR; Le message d'erreur est Cannot find path 'C:\Temp\toto' because it does not exist.
2019-06-12 11:50:36; INF; Les actions sont terminées

+----------------------------------------------------------------------------------------+
End time                 : 2019-06-12 11:50:36
Total duration (seconds) : 0
Total duration (minutes) : 0
+----------------------------------------------------------------------------------------+
#>
# C'est propre, rapide et efficace !