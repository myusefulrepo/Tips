$MyStack = New-Object System.collections.stack
$MyStack.Push("A")
$MyStack.Push("B")
$MyStack.Push("C")
$MyStack.Push("D")
$MyStack
# on peut constater que on a quelque chose qui ressemble à un array
# on peut constater également, que dans le stack, le dernier objet ajouté et le premier retourné. 

# la méthode "Push" alimente le stack en mode FILO (first In, last Out)
$MyStack.pop()
$MyStack
# La méthode Pop récupère le dernier objet qui a été ajouté dans le stack, et Il n'est plus dans la stack après.
$MyStack.peek()
$MyStack
# la méthode Peek récupère le dernier objet qui a été ajouté dans le stack, mais il reste dans la stack après.
$MyStack.count
# la propriété count (c'est une propriété, pas une méthode), retourne le nombre d'objets dans la collection


######## Les usages possibles : 
# Affichage des éléments de $Mystack et vidange
Write-Host 'Affichage des éléments de $Mystack et vidange' -ForegroundColor Cyan
while($mystack.count -gt 0)
    {
    Write-Host "Returning Element -> $($mystack.Peek())" -ForegroundColor Green
    start-sleep -Seconds 3
    $mystack.Pop()
    }
Write-Host "End of example" -ForegroundColor Cyan

# Plus courant : se déplacer dans une arborescence vers une répertoire enfant et remonter
$MyStack = New-Object System.collections.stack
$Parent = "c:\temp"
$MyStack.Push($Parent) # Ma position actuelle
$MyStack
$Enfant = "C:\Temp\Archives"
$MyStack.push($Enfant)
$MyStack
Set-Location c:\   # ma position actuelle
Get-Location
set-location ($MyStack.Pop()) # me voici dans l'enfant
Get-Location
Set-Location ($MyStack.Pop()) # me voici dans le parent
Get-Location
# On peut ainsi descendre et remonter facilement dans une arborescence

$MyStack.psbase | Get-Member