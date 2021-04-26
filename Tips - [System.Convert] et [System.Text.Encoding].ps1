# obtenir la liste des methodes de conversion via la classe .Net [System.Convert]
[System.Convert]
[System.Convert] | Get-Member -Static

# On veut "cacher" (offuscation) une chaine de texte. Ex. :
$Data2Encode = ‘PowerShell is Great!’
# Il existe dans la classe .Net [System.Convert] une méthode ToBase64String, essayons dessus
$EncodedText = [System.Convert]::ToBase64String($Data2Encode)
# no way ! Cette méthode requiert que l'entrée soit convertie en Byte avant
[System.Convert] | Get-Member -Static -Name ToBase64String | Select-Object -ExpandProperty definition
# ToBase64String      Method     static string ToBase64String(byte[] inArray), static string ToBase64String(byte[] inArray, System.Base64Form...

# Transformons donc $Data2Encode [SystemString] en Bytes
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Data2Encode)
# Maintenant on est bien en [System.Byte]
# transformons cela en base64
$EncodedText = [System.Convert]::ToBase64String($Bytes)
$EncodedText
# $EncodedText a été transformé en [System.string]
$EncodedText | Get-Member

<#
Pour cacher une chaine de caractères, il faut donc
1 - Encode cette chaine en Byte via [System.Text.Encoding]::Unicode.GetBytes
2 - Convertir ces Bytes en Base64String via [System.Convert]::ToBase64String

Cette chaine de caractères peut être une simple chaine de texte comme présenté, mais également
des commandes exécutables, par ex.
$command = 'Start-BitsTransfer -Source "http://www.funnycatpix.com/_pics/Playing_A_Game.jpg" -Destination "$env:USERPROFILE\desktop\cat.jpg"'
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
Lignes de commande qui peut être encodées en Base64String
$encodedCommand = [Convert]::ToBase64String($bytes)
$EncodedCommand
afin de la cacher, ou de répondre à une exigence particulière (ex. création d'une clé de registre qui attend une string)
New-ItemProperty -Path HKLM:\software -Name "updater" -Value $encodedCommand -PropertyType multistring
#>

# pour décoder tout cela, il faut faire les opérations inverses
# chargement des données encodées à décoder

$Data2Decode = $EncodedText  # pour une clé de registre cela serait (Get-ItemProperty HKLM:\software).updater
# conversion depuis Base64String vers Byte
$bytes = [System.Convert]::FromBase64String($Data2Decode)
$Bytes
# transformation de Byte en String
$DecodedText = [System.Text.Encoding]::Unicode.GetString($bytes)
$DecodedText
