# Tests de performances pour la lecture d'un gros fichier
J'ai un fichier (ici un fichier .html comprenant des lignes vides) de 541 537 lignes soit 29 828 Ko.

Je vais utiliser différentes méthodes pour le lire afin de voir laquelle est la plus performante. 

Pour que mes tests soient représentatifs, il faut les exécuter plusieurs fois. Je vais m'appuer sur la fonction Measure-MyScript disponible [Ici](https://powershellyo.ga/powershell/2017/07/Benchmark.html).

## Utilisation de ````Get-Content````

````powershell 
$LargeFile = "C:\temp\MSRCAprilSecurityUpdates.html"

Measure-MyScript -Name "Get-Content" -Repeat 3 -Unit s -ScriptBlock {
$File = Get-Content $LargeFile
foreach ($Line in $File)
{
	$lines++
}
$lines
}
````

Le résultat donne :
````Powershell
Name    Value
----    -----
name    Get-Content
Avg     7,7664024 Seconds
Min     7,0436888 Seconds
Max     8,2881394 Seconds
````

## Utilisation de ````Get-Content```` avec le paramètre ````-Raw````
````Powershell
Measure-MyScript -Name "Get-Content -Raw" -Repeat 3 -Unit s -ScriptBlock {
$File = Get-Content $LargeFile -Raw
foreach ($Line in $File)
{
	$lines++
}
$lines
}
````

Le résultat donne :

````Powershell
Name    Value
----    -----
name    Get-Content -Raw
Avg     0,2273585 Seconds
Min     0,1749896 Seconds
Max     0,2818227 Seconds
````
## Utilisation de ````Get-Content```` avec le paramètre ````-ReadCount````

````powershell 
Measure-MyScript -Name "Get-Content -ReadCount" -Repeat 3 -Unit s -ScriptBlock {
$File = Get-Content $LargeFile -ReadCount 5000
foreach ($Line in $File)
{
	$lines++
}
$lines
}
````

Le résultat donne :

````Powershell

Name    Value
----    -----
name    Get-Content -ReadCount
Avg     0,3116051 Seconds
Min     0,2455855 Seconds
Max     0,351709 Seconds
````

J'ai fait varier la valeur du paramètre -ReadCount entre 1000 et 100 000. Peu de varations, mais il faut dire que ma machine est bien chargée en RAM (32 GB), cela doit aider. 

## Utilisation de ````System.io.File````
C'est une class .Net. 

````powershell
Measure-MyScript -Name "System.io.file" -Repeat 3 -Unit s -ScriptBlock {
$File = [system.io.file]::ReadAllLines($LargeFile)
foreach ($Line in $File)
{
	$lines++
}
$lines
}
````

Le résultat donne :

````Powershell
Name    Value
----    -----
name    System.io.file
Avg     0,5839085 Seconds
Min     0,5008151 Seconds
Max     0,6313006 Seconds
````

## Utilisation de ````System.IO.StreamReader````
C'est une class .Net. 

````powershell
Measure-MyScript -Name "System.IO.StreamReader" -Repeat 3 -Unit s -ScriptBlock {
$sread = [System.IO.StreamReader]::new($largefile) 
while ($sread.ReadLine()) {
    $lines++
}
$lines
}
````

Le résultat donne :

````Powershell
Name    Value
----    -----
name    System.IO.StreamReader
Avg     0,0020753 Seconds
Min     0,0001001 Seconds
Max     0,0060067 Seconds
````

## Utilisation de ````System.IO.StreamReader```` avec la méthode ````EndOfStream````
C'est une class .Net. 

````powershell
Measure-MyScript -Name "System.IO.StreamReader -EndOfStream" -Repeat 3 -Unit s -ScriptBlock {
$sread = [System.IO.StreamReader]::new($largefile) 
while ($sread.EndOfStream -eq $false) 
{
    $line = $sread.ReadLine()
    $lines++
}
$lines
}
````

Le résultat donne :

````Powershell
Name    Value
----    -----
name    System.IO.StreamReader -EndOfStream
Avg     0,5179554 Seconds
Min     0,5105636 Seconds
Max     0,5235286 Seconds
````

## Utilisation de ````System.IO.StreamReader```` avec la méthode ````Peek````

````powershell 
Measure-MyScript -Name "System.IO.StreamReader -Peek" -Repeat 3 -Unit s -ScriptBlock {
$sread = [System.IO.StreamReader]::new($largefile) 
while ($sread.Peek() -gt -1) 
{
    $sread.ReadLine() | Out-Null
    $lines++
}
$lines
}
````

Le résultat donne :

````Powershell
Name    Value
----    -----
name    System.IO.StreamReader -Peek
Avg     103,5731561 Seconds
Min     101,5419525 Seconds
Max     104,7409683 Seconds
````

Heu .... comment dire ? Les résultats ne sont pas là. Mais peut-être que cette méthode n'est pas faite pour cela exactement ou que je l'utilise mal. 



## Utilisation de ````Switch````
````powershell
Measure-MyScript -Name "switch" -Repeat 3 -Unit s -ScriptBlock {
switch -File ($LargeFile)
{
    Default {
        $lines++
    }
}
$lines
}
````

Le résultat donne :

````Powershell
Name    Value
----    -----
name    switch
Avg     0,4353833 Seconds
Min     0,4292166 Seconds
Max     0,4405963 Seconds
````

# Synthese

Le meilleur résultat est obtenu - et de loin - par la class .Net ````[System.io.StreamReader````.
Se trouve ensuite dans un mouchoir de poche ````Get-Content -Raw````, ````Get-Content -ReadCount````, ````[System.io.StreamReader]::EndofFile```` et ````[System.io.File]````.

````Get-Content```` sans paramètre est peu performant, mais ````[System.io.StreamReader]::Peek```` s'avère plus que très lent (à proscrire pour cet usage donc).


