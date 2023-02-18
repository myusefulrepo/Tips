## 1ère étape définir ce qu'on veut faire

Prenons un exemple concret : je souhaiterais faire un script de reporting de différents paramètres de serveurs distants.
Je voudrais, la CPU, la mémoire, l'utilisation du stockage.
Une fois collectées, les données pourront être exportées vers un rapport aux formats .csv et .html
Et puis, soyons généreux, les rapports pourront être envoyés par mail.

## Seconde étape : Préparation de la collecte de données

### Utilisation du Processor
On peut obtenir cela via un requête WMI, mais on préfèrera utiliser une requête CIM pour son côté standard (Powershell 3 et sup). On mettra le résultat dans une *variable*, avec un ***nommage représentatif de son contenu***, pour un usage ultérieur.

````powershell
Get-CimInstance -ClassName win32_processor
DeviceID Name                                     Caption                              MaxClockSpeed SocketDesignation Manufacturer
-------- ----                                     -------                              ------------- ----------------- ------------
CPU0     Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz Intel64 Family 6 Model 94 Stepping 3 4001          LGA1151           GenuineIntel
````

Toutes les propriétés ne sont pas présentées, je vais donc les faire afficher pour pouvoir déterminer celles que je veux précisément.

````powershell
Get-CimInstance -ClassName win32_processor | Select-Object -Property *

Availability                            : 3
CpuStatus                               : 1
CurrentVoltage                          : 12
DeviceID                                : CPU0
ErrorCleared                            :
ErrorDescription                        :
LastErrorCode                           :
LoadPercentage                          : 2
Status                                  : OK
StatusInfo                              : 3
AddressWidth                            : 64
DataWidth                               : 64
ExtClock                                : 100
L2CacheSize                             : 1024
L2CacheSpeed                            :
MaxClockSpeed                           : 4001
PowerManagementSupported                : False
ProcessorType                           : 3
Revision                                : 24067
SocketDesignation                       : LGA1151
Version                                 :
VoltageCaps                             :
Caption                                 : Intel64 Family 6 Model 94 Stepping 3
Description                             : Intel64 Family 6 Model 94 Stepping 3
InstallDate                             :
Name                                    : Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz
ConfigManagerErrorCode                  :
ConfigManagerUserConfig                 :
CreationClassName                       : Win32_Processor
PNPDeviceID                             :
PowerManagementCapabilities             :
SystemCreationClassName                 : Win32_ComputerSystem
SystemName                              : ASUS10
CurrentClockSpeed                       : 1700
Family                                  : 198
OtherFamilyDescription                  :
Role                                    : CPU
Stepping                                :
UniqueId                                :
UpgradeMethod                           : 1
Architecture                            : 9
AssetTag                                : To Be Filled By O.E.M.
Characteristics                         : 252
L3CacheSize                             : 8192
L3CacheSpeed                            : 0
Level                                   : 6
Manufacturer                            : GenuineIntel
NumberOfCores                           : 4
NumberOfEnabledCore                     : 4
NumberOfLogicalProcessors               : 8
PartNumber                              : To Be Filled By O.E.M.
ProcessorId                             : BFEBFBFF000506E3
SecondLevelAddressTranslationExtensions : False
SerialNumber                            : To Be Filled By O.E.M.
ThreadCount                             : 8
VirtualizationFirmwareEnabled           : False
VMMonitorModeExtensions                 : False
PSComputerName                          :
CimClass                                : root/cimv2 : Win32_Processor
CimInstanceProperties                   : {Caption, Description, InstallDate, Name...}
CimSystemProperties                     : Microsoft.Management.Infrastructure.CimSystemProperties
````
Trouvé ! La propriété qui m'intéresse est ````LoadPercentage````
Affinons la requête afin de calculer la moyenne de la mémoire utilisée

````powershell
Get-CimInstance -ClassName win32_processor | Measure-Object -Property LoadPercentage -Average

Count    : 1
Average  : 10
Sum      :
Maximum  :
Minimum  :
Property : LoadPercentage
````

Très bien, maintenant je ne veux que la propriété ````Property````

````powershell
Get-CimInstance -ClassName win32_processor | Measure-Object -Property LoadPercentage -Average  | Select-Object Average
Average
-------
     12
````

Et plus précisément maintenant ````Average````

````powershell
(Get-CimInstance -ClassName win32_processor | Measure-Object -Property LoadPercentage -Average  | Select-Object Average).average
12
````

Exactement, ce que je veux. Ne reste plus qu'à mettre tout cela dans une variable

````powershell
$Processor = (Get-CimInstance -ClassName win32_processor | Measure-Object -Property LoadPercentage -Average  | Select-Object Average).average
````

La même démarche est utilisée pour la mémoire

````powershell
Get-CimInstance -ClassName -Class win32_OperatingSystem | select-Object -Property *
# On examine les différentes propriétés pour trouver celles qu'on cherche exactement.
<# I
ci c'est la mémoire totale (TotalVisibleMemorySize) à laquelle on va soustraire la mémoire libre (FreePhysicalMemory) et le tout qu'on va diviser par la mémoire totale afin de déterminer le % de mémoire occupé

Afin de faciliter la lecture je vais poser la précédente ligne dans une variable et l'appeler dans la suivante via ses propriétés
#>
$ComputerMemory = Get-CimInstance -ClassName -Class win32_OperatingSystem
$Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
# Comme le résultat est décimal, ce n'est pas forcément très pratique et je vais arrondir cela à 2 décimales seulement
$RoundMemory = [math]::Round($Memory, 2)
````

Maintenant, passons à l'espace disque
````powershell
$Disk = Get-CimInstance -ClassName win32_LogicalDisk | Select-Object -Property DeviceId,
                                                                               @{Label = "Taille" ; Expression = {[math]::Round($_.Size/1GB,2)}},
                                                                               @{Label = "Espace Libre" ; Expression = {[math]::Round($_.FreeSpace/1GB,2)}}

DeviceId  Taille Espace Libre
--------  ------ ------------
C:        464,38       274,29
D:       8383,43      7720,31
E:         28,83        24,72

````

On notera ici que j'ai utilisé un formatage particulier. Je souhaitais avoir des en-têtes (headers) en français et formater le résultat  en GB (au lieu de Bytes par défaut) avec 2 décimales.

A cette étape on a donc recueilli nos données dans 3 variables : ````$Processor````, ````$RoundMemory```` et ````$Disk````
Il est temps de passer à l'étape de construction

## Construction du script
On va faire cela avec un ````Try ... Catch```` afin de pouvoir gérer le erreurs. Le principe est simple : On essaie quelque chose dans ````try```` si ça marche on continue, sinon ça passe au ````catch```` et là on gère les erreurs.

````powershell
 Try
    {
    # Processor utilization
    $Processor = (Get-CimInstance -ComputerName $Server -ClassName win32_processor -ErrorAction Stop |
                    Measure-Object -Property LoadPercentage -Average |
                    Select-Object Average).Average

    # Memory utilization
    $ComputerMemory = Get-CimInstance -ComputerName $Server -ClassName win32_OperatingSystem
    $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
    $RoundMemory = [math]::Round($Memory, 2)

    #DiskSpace
    $disk = Get-CimInstance -ClassName win32_LogicalDisk |
             Select-Object -property DeviceId,
                                     @{Label = "Taille"; Expression ={[math]::Round($_.Size/1GB,2)}},
                                     @{Label ="Espace Libre" ; Expression ={[math]::Round($_.FreeSpace/1GB,2)}}
    }

Catch
    {
    Write-Host "Something went wrong" -ForegroundColor Red
    Write-Host "Erreur :  $_.Exception.Message" -ForegroundColor Red
    Continue
    }
````

>[Nota 1] On notera l'utilisation du paramètre ````-ErrorAction Stop```` pour la gestion des erreurs

>[Nota 2] On notera également l'utilisation du paramètre ````-ComputerName```` parce que dans une étape suivante nous allons traiter plusieurs machines distantes à travers une boucle
````foreach````

````powershell
foreach ($Server in $Servers)
{
    Try
        {
        # Processor utilization
        $Processor = (Get-CimInstance -ComputerName $Server -ClassName win32_processor -ErrorAction Stop |
                        Measure-Object -Property LoadPercentage -Average |
                        Select-Object Average).Average

        # Memory utilization
        $ComputerMemory = Get-CimInstance -ComputerName $Server -ClassName win32_OperatingSystem
        $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
        $RoundMemory = [math]::Round($Memory, 2)

        #DiskSpace
        $disk = Get-CimInstance -ClassName win32_LogicalDisk |
                 Select-Object -property DeviceId,
                                         @{Label = "Taille"; Expression ={[math]::Round($_.Size/1GB,2)}},
                                         @{Label ="Espace Libre" ; Expression ={[math]::Round($_.FreeSpace/1GB,2)}}
        }

    Catch
        {
        Write-Host "Quelque chose c'est mal passé" -ForegroundColor Red
        Write-Host "Erreur :  $_.Exception.Message" -ForegroundColor Red
        Continue
        }
}
````

Ca commence à prendre forme, mais encore faut-il qu'on teste également :

- Si le serveur distant est joignable,
- Si les  3 variables qu'on cherche à recueillir n'ont rien retournées pour différentes raisons (insuffisance de droits par ex)

On va aussi à chaque tour de la boucle ````foreach```` alimenter un **PSCustomObject** qui lui-même alimentera une ````Array````

````powershell
$Servers =  Get-Content "C:\users\$env:username\desktop\servers.txt" # Ici on lit le contenu d'un fichier qui contient une liste de machines. Mais on pourrait faire également une requête AD avec Get-ADComputer
# J'utilise ici une Array Généric List qui consomme moins de mémoire
$Result = [System.Collections.Generic.List[PSObject]]::New() # Initialisation

ForEach($Server in $Servers)
{
    $Server = $Server.trim() # simple précaution pour supprimer les espaces blancs avec et après

    Write-Host "Traitement de $Server"

    # Initialisation ou réinitialisation des variables
    $Check = $null
    $Processor = $null
    $ComputerMemory = $null
    $RoundMemory = $null
    $Object = $null
    $disk = $null

    $Result.Add([PSCustomObject]@{"Nom du Serveur" = $Server }

    $Check = Test-Connection -ComputerName $Server -ErrorAction SilentlyContinue
    If($Null -ne $Check) # S'il y a quelque chose dans le résultat: le serveur est joignable
    {
        $Status = "True" # on positionne une variable à $true

        Try
        {
            # Utilisation du processeur
            $Processor = (Get-CimInstance -ComputerName $Server -ClassName win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average

            # Utilisation de la mémoire
            $ComputerMemory = Get-CimInstance -ComputerName $Server -ClassName win32_OperatingSystem
            $Memory = ((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
            $RoundMemory = [math]::Round($Memory, 2)

            # Espace disque
            $disk = Get-CimInstance -ClassName win32_LogicalDisk |
                    Select-Object -Property DeviceId,
                                            @{Label = "Taille" ; Expression ={[math]::Round($_.Size/1GB,2)}},
                                            @{Label = "Espace Libre" ; Expression ={[math]::Round($_.FreeSpace/1GB,2)}}
        }
        Catch
        {
        Write-Host "Quelque chose c'est mal passé" -ForegroundColor Red
        Write-Host "Erreur :  $_.Exception.Message" -ForegroundColor Red
        Continue
        }

        If(-not $Processor -and $RoundMemory -and $disk) # On traite le cas ou on on ne remonte rien
        {
            $RoundMemory = "(null)"
            $Processor = "(null)"
            $disk = "(null)"
        }

        # Et maintenant, on va peupler notre PSCustomObject et alimenter l'array
         $Result.Add([PSCustomObject]@{
            "est En Ligne ?"      = $Status
            "Mémoire %"           = $RoundMemory
            "CPU %"               = $Processor
            "Espace Disque en Go" = $disk
            }

        # et on alimente notre Array pour la sortie
        $Result += $Object
    }
    Else # Cas on n'arrive pas à joindre le serveur
    {
        $Result.Add([PSCustomObject]@{
            "Est en ligne ?"      = "False"
            "Mémoire %"           = "(null)"
            "CPU %"               = "(null)"
            "Espace Disque en Go" = "(null)"
    }
}
````
A cette étape, déjà bien avancée, on a :

- Collecté toutes les données
- Gérer les erreurs

Il nous reste à faire l'export

- En console
- dans un Out-GridView
- dans un ou des fichiers de sortie à des formats différents


````powershell
    If($Result)
    {
        $Result | Sort-Object "Is online?"

        $Result | Out-GridView

        $Result | Export-Csv -Path "C:\users\$env:username\desktop\results.csv" -NoTypeInformation -Force
    }
````
