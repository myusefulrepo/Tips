# Récupérer Logon/Logoff des utilisateurs + Machine

## Le challenge
Alimenter un fichier de log qui peut être exploité facilement plus tard, typiquement un .csv
avec tous les logon/logoff des utilisateurs mais également le nom de la machine et le LogonServer


## Les différentes voies possibles et leur limitation
**Query AD-Users** : on peut obtenir la Date de last login, mais pas la machine. De plus, on ne peut obtenir que la date du lastLogin : cela ne répond donc pas au besoin
**EventLog Securité** : possible d'avoir toutes les informations recherchées mais il faut interroger tous les DCs, et ensuite "parser" les informations afin de ne récupérer que ce qu'on veut. Possible donc, mais pas facile à mettre en oeuvre
**LogonScript/LogoffScript** : On peut récupérer toutes les info dans un fichier type .csv facilement pour l'exploiter plus tard

## Les étapes
- Etape 1 : Créer un partage. Permissions NTFS Modification au groupe "Domain Computers" (c'est le compte machine qui exécute les GPOs)
- Etape 2 : GPO avec LogonScript/LogoffScript - Lié à l'OU racine ou se trouve les comptes utilisateurs, on évitera autant que possible la racine du domaine. Ci-après les logonScript et LogoffScript


### LogonScript
````powershell
$logon = [PSCustomObject]@{
    Login = $env:USERNAME
    ComputerName = $env:COMPUTERNAME
    Date  = Get-Date -f "dd-MM-yyyy"
    Heure = Get-Date -Format "hh:mm:ss"
    LogonServer = $env:LOGONSERVER -replace("\\","")
    Action = "Logon"
    }

# Afin d'éviter d'avoir un fichier qui deviendra énorme, on va générer un fichier par jour
$Date = Get-Date -Format "dd-MM-yyyy"
$logon | Export-Csv -Path \\Server\Share\LoginLogoff-$Date.csv -Encoding UTF8 -Delimiter ";" -NoTypeInformation -Append
````
Vu le peu d'informations que l'on met à chaque fois dans le fichier, cela ne devrait pas poser de pb de contension. Cela reste cependant à vérifier dans un contexte important.

Faire la même chose pour le Logoff soit dans le même fichier soit dans un fichier différent.

### LogoffScript
````powershell
$logoff = [PSCustomObject]@{
    Login = $env:USERNAME
    ComputerName = $env:COMPUTERNAME
    Date  = Get-Date -f "dd-MM-yyyy"
    Heure = Get-Date -Format "hh:mm:ss"
    LogonServer = $env:LOGONSERVER -replace("\\","")
    Action = "Logoff"
    }
$Date = Get-Date -Format "dd-MM-yyyy"
$logoff | Export-Csv -Path \\Server\Share\LoginLogoff-$Date.csv -Encoding UTF8 -Delimiter ";" -NoTypeInformation -Append
````


## Le mot final

Simple, rapide, efficace
