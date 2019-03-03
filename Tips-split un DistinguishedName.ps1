# Split un DistinguishedName pour en extraire une information précise
$DistinguishedName = "CN=PC12345,OU=_Ordinateurs,OU=secteur,OU=direction,OU=entreprise,DC=domaine,DC=intra"
$DistinguishedName
# On voit que ce qui sépare le ComputerName du reste c'est "," ou encore ",OU="
# On va utiliser l'opérateur de comparaison SPLIT
# Le premier paramètre est "ce que recherché", le second paramètre est le nombre de fragments de recherche max
$result = $DistinguishedName -split ",OU=", 2 
$result                         # On a bien le DistinguishedName de l'OU
$result = $DistinguishedName -split ",", 2    
$result                         # ici aussi
$result = $DistinguishedName -split ",", 5    
$result                         # et là encore, tout dépend de ce qu'on cherche
<# 
Il suffit d'appeler le résultat et de sortir le fragment qu'on veut. 
[0] : retourne le 1er morceau : donc le CN
[1] : retourne le 2ème morceau 
[2] : retourne le 3ème morceau
...
[-1] : retourne le dernier morceau
#> 
$result = $DistinguishedName -split ",OU=", 2 
$result[0]
$result[1]
$result[-1]

# ex. d'Utilisation 
$AgeMax = "90"
$DateLimite = (get-Date).AddDays(-$AgeMax)
$Computers = Get-ADComputer -filter * -Properties Name,DistinguishedName,LastLogonDate -filter {LastLogonDate -lt $DateLimite} |
            Select-Object Name,
                      DistinguishedName,
                      LastLogonDate,
                      @{ Label = "dif"; Expression = {((Get-Date) - $_.lastlogondate).days }}, # calcul nbre de jours depuis la dernière connexion / aujourd'hui
                      @{ Label = "OU" ; Expression = {($_.DistinguishedName -split ",",2)[1]} # OU dans laquelle se situe la machine
