# Différentes manières d'exécuter un script avec une entrée utisateur
Il arrive parfois que vous ayez besoin d'exécuter un script PowerShell qui nécessite une entrée utilisateur.
Voici quelques exemples de la façon dont vous pouvez obtenir une entrée utilisateur dans un script PowerShell.


## Utiliser de la cmdlet `Read-Host`
Le code suivant demande à l'utilisateur de saisir un nom et un âge, puis affiche un message de bienvenue.
Il utilise la cmdlet `Read-Host` pour obtenir l'entrée de l'utilisateur.

Exemple de code PowerShell : 

````Powershell

# Demander à l'utilisateur de saisir son nom
$nom = Read-Host "Veuillez entrer votre nom"
# Demander à l'utilisateur de saisir son âge
$age = Read-Host "Veuillez entrer votre âge"
# Afficher un message de bienvenue
Write-Host "Bienvenue $nom, vous avez $age ans."
````
C'est une méthode simple et efficace pour obtenir des entrées utilisateur dans un script PowerShell.


## Utiliser `$Host.UI.PromptForChoice`
Le code suivant demande à l'utilisateur de choisir une option parmi plusieurs choix prédéfinis.
Il utilise la méthode `$Host.UI.PromptForChoice` pour afficher un menu de choix.

>[Nota] : Rappel concernant `$Host` : `$Host` est une variable automatique qui représente l'environnement d'hébergement de PowerShell. Il fournit des informations sur l'environnement d'exécution et permet d'interagir avec l'utilisateur.
Il est souvent utilisé pour afficher des messages, des boîtes de dialogue et d'autres éléments d'interface utilisateur dans PowerShell.
> 
> Il est important de noter que `$Host.UI.PromptForChoice` n'est pas disponible dans la console PowerShell standard, mais il fonctionne bien dans PowerShell ISE (Integrated Scripting Environment) et d'autres environnements d'hébergement qui prennent en charge les interfaces utilisateur graphiques.

````Powershell
$host.UI | Get-Member -MemberType method


   TypeName : System.Management.Automation.Internal.Host.InternalHostUserInterface

Name                   MemberType Definition
----                   ---------- ----------
Equals                 Method     bool Equals(System.Object obj)
GetHashCode            Method     int GetHashCode()
GetType                Method     type GetType()
Prompt                 Method     System.Collections.Generic.Dictionary[string,psobject] Prompt(string caption, string message, System.Collections.ObjectModel.Collection[System.Management.Automation.Host.FieldDescription] descriptions)
PromptForChoice        Method     int PromptForChoice(string caption, string message, System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription] choices, int defaultChoice), System.Collections.ObjectModel.Collection[int] PromptForCh... 
PromptForCredential    Method     pscredential PromptForCredential(string caption, string message, string userName, string targetName), pscredential PromptForCredential(string caption, string message, string userName, string targetName, System.Management.Automation.PS... 
ReadLine               Method     string ReadLine()
ReadLineAsSecureString Method     securestring ReadLineAsSecureString()
ToString               Method     string ToString()
Write                  Method     void Write(string value), void Write(System.ConsoleColor foregroundColor, System.ConsoleColor backgroundColor, string value)
WriteDebugLine         Method     void WriteDebugLine(string message)
WriteErrorLine         Method     void WriteErrorLine(string value)
WriteInformation       Method     void WriteInformation(System.Management.Automation.InformationRecord record)
WriteLine              Method     void WriteLine(), void WriteLine(string value), void WriteLine(System.ConsoleColor foregroundColor, System.ConsoleColor backgroundColor, string value)
WriteProgress          Method     void WriteProgress(long sourceId, System.Management.Automation.ProgressRecord record)
WriteVerboseLine       Method     void WriteVerboseLine(string message)
WriteWarningLine       Method     void WriteWarningLine(string message)
````

Exemple de code PowerShell :
````Powershell
# Définir le titre et le message
$Titre = "Faites votre choix"
$Message = "Choisissez une option :"
# Définir les options de choix
$Options = @("Option1", "Option2", "Option3")
# Choix par défaut (0 pour la première option)
$DefaultChoice = 0
# Demander à l'utilisateur de choisir une option
$Choix = $Host.UI.PromptForChoice($Titre, $Message, $Options, $DefaultChoice)
# Afficher le choix de l'utilisateur
Write-Host "Vous avez choisi : $($options[$choix])"
````
L'exécution du code ci-dessous dans PowerShell ISE produira le résultat suivant :

![Events as a HTML report](https://github.com/myusefulrepo/Tips/blob/master/Images/DialogInput.jpg)

L'exécution de la même chose à partir de la console PowerShell ne sera cependant pas aussi sophistiquée et produira un résultat similaire à celui-ci :

````Powershell
$Titre = "Faites votre choix"
$Message = "Choisissez une option :"
# Définir les options de choix
$Options = @("&PremierChoix", "&SecondChoix", "&TroisèmeChoix")
# Choix par défaut (0 pour la première option)
$DefaultChoice = 0
# Demander à l'utilisateur de choisir une option
$Choix = $Host.UI.PromptForChoice($Titre, $Message, $Options, $DefaultChoice)
# Afficher le choix de l'utilisateur
Write-Host "Vous avez choisi : $($options[$choix])"

Faites votre choix
Choisissez une option :
[P] PremierChoix  [S] SecondChoix  [T] TroisèmeChoix  [?] Aide (la valeur par défaut est « P ») : s
Vous avez choisi : &SecondChoix
````

Dans ce cas, l'utilisateur doit entrer la lettre correspondant à son choix (P, S ou T) et appuyer sur Entrée.
L'esperluette "&" est utilisée pour indiquer que l'option doit être affichée avec une lettre d'accès rapide (sous la forme d'un raccourci clavier).


Il est important de noter que `$Host.UI.PromptForChoice` est une méthode qui affiche un menu de choix dans la console PowerShell et attend que l'utilisateur fasse une sélection.
La syntaxe de cette méthode est la suivante :


```powershell
$choix = $Host.UI.PromptForChoice($Titre, $Message, $options, $valeurParDéfaut)
```

- `Titre` : Le titre de la boîte de dialogue.
- `Message` : Le message à afficher à l'utilisateur.
- `$options` : Un tableau contenant les options de choix.
- `$valeurParDéfaut` : L'index de l'option par défaut (0 pour la première option).
- `$choix` : La variable qui stocke le choix de l'utilisateur.
- `$options[$choix]` : Utilisé pour afficher le choix de l'utilisateur.

On peut noter que ``Option` est un tableau (Array) contenant les options de choix, et que l'index de l'option par défaut est spécifié par la variable `$valeurParDéfaut`, cependant on peut également utiliser un objet de type `[System.Management.Automation.Host.ChoiceDescription]::new("Choix1", "Aide sur choix1)` pour créer un objet de choix qui peut être utilisé dans le tableau d'options.

````POwershell
[System.Management.Automation.Host.ChoiceDescription]::new("Choix &1", "Ceci est un bon choix") 

Label    HelpMessage
-----    -----------
Choix &1 Ceci est un bon choix
````
Le message d'aide est affiché lorsque l'utilisateur survole l'option avec la souris dans la boîte de dialogue.
On peut également ajouter cette aide ultérieurement dans le tableau d'options.

```powershell
$choix = $Host.UI.PromptForChoice($Titre, $Message, $options, $valeurParDéfaut)
$choix[0].HelpMessage = "Ceci est un bon choix"
```

Voici un exemple de code qui utilise cette méthode pour créer un tableau d'options avec des messages d'aide :

```powershell
# Définir le titre et le message
$Titre = "Faites votre choix"
$Message = "Choisissez une option :"
# Définir les options de choix
$Options= @()
$Option1 = [System.Management.Automation.Host.ChoiceDescription]::new("Choix &1", "Ceci est un bon choix")
$Options+=$Option1
$Option2 = [System.Management.Automation.Host.ChoiceDescription]::new("Choix &2", "Ceci est un choix moyen")
$Options+=$Option2
$Option3= [System.Management.Automation.Host.ChoiceDescription]::new("Choix &3", "Ceci est un mauvais choix")
$Options+=$Option3
$Option4 = [System.Management.Automation.Host.ChoiceDescription]::new("Choix &4", "Ceci est un choix terrible")
$Options+=$Option4
# Choix par défaut (0 pour la première option)
$DefaultChoice = 0
# Demander à l'utilisateur de choisir une option
$Choix = $Host.UI.PromptForChoice($Titre, $Message, $Options, $DefaultChoice)
# Afficher le choix de l'utilisateur
Write-Host "Vous avez choisi : $($Options[$choix].Label)"
```

En exécutant ce code, l'utilisateur verra une boîte de dialogue avec quatre options de choix, chacune ayant un message d'aide associé. L'utilisateur peut sélectionner une option en cliquant dessus ou en utilisant les touches fléchées pour naviguer dans le menu.

>[**Nota**] : Si on exécute ce code dans PowerShell ISE, la boîte de dialogue s'affichera avec les options de choix et les messages d'aide. Cependant, si on exécute le même code à partir de la console PowerShell, la boîte de dialogue affichera uniquement les options de choix sans les messages d'aide.



## Utiliser `Out-GridView` pour afficher une liste d'options
Le code suivant affiche une liste d'options dans une fenêtre graphique et permet à l'utilisateur de sélectionner une ou plusieurs options.

Il utilise la cmdlet `Out-GridView` pour afficher la liste.

Exemple de code PowerShell : 
````Powershell
# Définir une liste d'options
$options = @("Option 1", "Option 2", "Option 3")
# Afficher la liste d'options dans une fenêtre graphique

$choix = $options | Out-GridView -Title "Sélectionnez une ou plusieurs options" -PassThru
# Afficher le choix de l'utilisateur
Write-Host "Vous avez choisi : $choix"
````


## Utiliser `Get-Content` pour lire un fichier d'entrée
Le code suivant lit un fichier texte contenant des noms d'utilisateurs et les affiche un par un.
Il utilise la cmdlet `Get-Content` pour lire le contenu du fichier.

Exemple de code PowerShell :
````Powershell
# Lire le contenu d'un fichier texte
$utilisateurs = Get-Content "C:\chemin\vers\le\fichier.txt"
# Afficher chaque nom d'utilisateur
foreach ($utilisateur in $utilisateurs) {
    Write-Host "Nom d'utilisateur : $utilisateur"
}
````
Dans cet exemple, le fichier texte doit contenir une liste de noms d'utilisateurs, un par ligne.
La cmdlet `Get-Content` lit le contenu du fichier et le stocke dans la variable `$utilisateurs`, qui est ensuite parcourue pour afficher chaque nom d'utilisateur.


## Conclusion
Il existe plusieurs façons d'obtenir une entrée utilisateur dans un script PowerShell, chacune ayant ses propres avantages et inconvénients.
tableau avantages vs inconvénients
| Méthode | Avantages| Inconvénients|
| -------------------------- | ---------------------- | ---------------------------- |
| `Read-Host` | Simple à utiliser, fonctionne dans la console et ISE | Limité à une seule ligne d'entrée, pas de validation intégrée |
| `$Host.UI.PromptForChoice` | Interface utilisateur graphique, choix multiples | Pas disponible dans la console PowerShell standard |
| `Out-GridView` | Interface graphique, choix multiples | Nécessite une interface graphique, pas disponible sur tous les systèmes |
| `Get-Content` | Lecture de fichiers, traitement par lot | Nécessite un fichier d'entrée, pas d'interaction directe      |

