# Plongée dans `Foreach-Object -Parallel`

## Avant-propos
`Foreach-Object -Parallel` est apprau dans les premières previews de powershell 7. comme une fonctionnalité expérimentale. Dans les versions utlérieures elle est passé comme une cmdlet de base. 

L'objet de ce post est de parler de `foreach-Object -parallel` et non du mot-clé `foreach` qui est totalement différent. Ce dernier ne gère pas les entrées par le pipeline, mais effectue une itération sur un objet énumérable. Il n’existe actuellement aucune prise en charge parallèle pour le mot clé `foreach`.
Exemple d'usage de `foreach`
````powershell
foreach ($item in (1..5)) { "Hello $item" }
Hello 1
Hello 2
Hello 3
Hello 4
Hello 5
````

## Qu'est-ce que `Foreach-Object -Parallel`, et quels sont les changements par rapport Windows Powershell 5.1 ? 

```powershell
# Windows Powershell 5.1
ForEach-Object [-Process] <scriptblock[]> [-InputObject <psobject>] [-Begin <scriptblock>] [-End <scriptblock>] [-RemainingScripts <scriptblock[]>] [-WhatIf] [-Confirm] [<CommonParameters>]

ForEach-Object [-MemberName] <string> [-InputObject <psobject>] [-ArgumentList <Object[]>] [-WhatIf] [-Confirm] [<CommonParameters>]

# Powershell 7.4.5
ForEach-Object [-Process] <scriptblock[]> [-InputObject <psobject>] [-Begin <scriptblock>] [-End <scriptblock>] [-RemainingScripts <scriptblock[]>] [-WhatIf] [-Confirm] [<CommonParameters>]

ForEach-Object [-MemberName] <string> [-InputObject <psobject>] [-ArgumentList <Object[]>] [-WhatIf] [-Confirm] [<CommonParameters>]

ForEach-Object -Parallel <scriptblock> [-InputObject <psobject>] [-ThrottleLimit <int>] [-TimeoutSeconds <int>] [-AsJob] [-UseNewRunspace] [-WhatIf] [-Confirm] [<CommonParameters>]
````
Comme on peut le voir, avec powershell 7.x, au 2 jeux de paramètres de Windows Powershell 5.1, s'en est ajouté un 3ème qu prend en compte un nouveau paramètre `-Parallel` (avec dans le même jeu de paramètre `-UseNewRunspace`).

Normalement quand on utilise la cmdlet `Foreach-Object -Parallel`, chaque objet passé par le pipeline est traité de manière séquentielle.

Exemple :

````powershell
# Avec Windows Powershell 5.1 ou powershell 7.x
 1..5 | ForEach-Object { "Hello $_"; sleep 1 }
Hello 1
Hello 2
Hello 3
Hello 4
Hello 5
````
et si on mesure le temps d'exécution, voici ce que cela donne : 

````powershell
(Measure-Command {
    1..5 | ForEach-Object { "Hello $_"; sleep 1 } 
}).Seconds
# sortie 5 (secondes)
````
><span style="color:green;font-weight:700;font-size:20px">[Point d'attention]</span> : Sur cet exemple, il n'y aucun changement de comportement ou de temps d'exécution entre Windows Powershell 5.1 et Powershell 7.x


En revanche, si on ajoute le paramètre `-Parallel`, si le résultat est le même, le temps d'exécution sera différent.

````Powershell
# Avec powershell 7.x seulement
1..5 | ForEach-Object -Parallel { "Hello $_"; sleep 1; } -ThrottleLimit 5 
Hello 1
Hello 3
Hello 2
Hello 4
Hello 5

(Measure-Command {
    1..5 | ForEach-Object -Parallel { "Hello $_"; sleep 1; } -ThrottleLimit 5 
}).Seconds
# sortie 1 (seconde)
````

Chaque bloc de script dans l'exemple ci-dessus prend 1 seconde à s'exécuter (à cause du sleep 1 qui fait le temps d'exécution), l'exécution des cinq blocs en parallèle ne prend qu'une seconde au lieu de 5 secondes lorsqu'ils sont exécutés de manière séquentielle.

Comme les blocs de script sont chacun exécutés en parallèle quand ils passent par le pipeline, l'ordre d'exécution n'est pas garanti. Le paramètre  `-ThrottleLimit`, quans à lui, limite le nombre de blocs de script exécutés en parallèle à un moment donné, et sa **valeur par défaut est 5**.

Comme avec la cmdlet Foreach-Object de Windows powershell 5.1, celle de 7.x prend en charge les ***jobs***, où vous pouvez choisir de renvoyer un objet de jobs au lieu d'écrire les résultats dans la console.

Exemple : 
````powershell
$Job = 1..5 | ForEach-Object -Parallel { "Hello $_"; sleep 1; } -ThrottleLimit 5 -AsJob 
# ici rien ne sort
Get-Job
Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Job1            PSTaskJob       Completed     True            PowerShell            "Hello $_"; sleep 1;
# On voit qu'un job a été créé
$job | Wait-Job | Receive-Job
Hello 1
Hello 2
Hello 3
Hello 5
Hello 4
````

## Peut-on jouer avec le paramètre `-ThrottleLimit` ?
Si on ne passe pas ce paramètre, comme dit précédemment, la valeur par défaut est **5**. Si on le passe on doit préciser la valeur comme un `[Int]`.

````powershell
(Measure-Command {
    1..50 | ForEach-Object -Parallel {
         "Hello $_"
         Start-Sleep 1
     } -ThrottleLimit 5
 }).Seconds
10

(Measure-Command {
     1..50 | ForEach-Object -Parallel {
         "Hello $_"
         Start-Sleep 1
     } -ThrottleLimit 10
 }).Seconds
5

(Measure-Command {
      1..50 | ForEach-Object -Parallel {
          "Hello $_"
          Start-Sleep 1
      } -ThrottleLimit 20
  }).Seconds
3
(Measure-Command {
      1..50 | ForEach-Object -Parallel {
          "Hello $_"
          Start-Sleep 1
      } -ThrottleLimit 50
  }).Seconds
1
````
Sur les exemples ci-desus, on voit que plus on augmente la valeur du `ThrottleLimit`, moins le temps d'exécution global est long. Mais ce n'est pas toujours aussi simple (voir plus loin).

## Sous le capot

Le nouveau jeu de paramètres `ForEach-Object -Parallel` utilise les API PowerShell existantes pour exécuter des blocs de script en parallèle. Ces API existent depuis PowerShell v2, mais étaient encombrantes et difficiles à utiliser correctement. Cette nouvelle fonctionnalité facilite grandement l'exécution de blocs de script en parallèle. Mais cela implique une charge de travail considérable et, bien souvent, l'exécution de scripts en parallèle n'apporte aucun avantage. En fait, cela peut s'avérer beaucoup plus lent que l'exécution normale de `ForEach-Object`.

PowerShell prend actuellement en charge le parallélisme dans trois catégories principales.

- **PowerShell à distance (Powershell Remoting)** :  Ici, PowerShell envoie le script à des machines externes pour qu'il s'exécute, à l'aide du système de communication à distance de PowerShell.
- **tâches PowerShell (Powershell Jobs)** : C'est la même chose que pour la communication à distance, sauf que le script est exécuté dans des processus distincts sur la machine locale, plutôt que sur des machines externes.
- **Espaces d'exécution PowerShell (Powershell Runspaces)** : Ici, le script est exécuté sur la machine locale au sein du même processus, mais sur des threads distincts.

Quand on utilise `Foreach -Parallel`, cela utilise la troisième méthode pour exécuter des scripts en parallèle. Elle a la plus faible surcharge des deux autres méthodes et n'utilise pas le système de communication à distance PowerShell (WinRM). Elle est donc généralement beaucoup plus rapide que les deux autres méthodes.

Cependant, l'exécution de blocs de script en parallèle entraîne encore une surcharge assez importante. Les blocs de script s'exécutent dans un contexte appelé **espace d'exécution PowerShell (Powershell Runspaces)**. Le contexte de l'espace d'exécution contient toutes les variables définies, les fonctions et les modules chargés. L'initialisation d'un espace d'exécution dans lequel le script doit s'exécuter prend donc du temps et des ressources. Lorsque des scripts sont exécutés en parallèle, ils doivent être exécutés dans leur propre espace d'exécution. Et chaque espace d'exécution doit charger le module nécessaire et toute variable doit être explicitement transmise à partir du script appelant. La seule variable qui apparaît automatiquement dans le bloc de script parallèle est l'objet canalisé. D'autres variables sont transmises à l'aide du mot-clé `$using:`.

Exemple :

````powershell
$computers = 'computerA','computerB','computerC','computerD' 
$logsToGet = 'LogA','LogB','LogC' 

# Lire les journaux spécifiés sur chaque machine, à l'aide d'un module personnalisé
$logs = $computers | ForEach-Object -ThrottleLimit 10 -Parallel {
    Import-Module MyLogsModule
    Get-Logs -ComputerName $_ -LogName $using:logsToGet
}
````
Étant donné la surcharge requise pour exécuter des scripts en parallèle, la limite `-ThrottleLimit` devient très utile pour éviter que le système ne soit surchargé. Il existe certains cas où l'exécution d'un grand nombre de blocs de scripts en parallèle est judicieuse, mais également de nombreux cas où ce n'est pas le cas.

>[Nota] : dans le premier exemple que je donnais avec `-ThrottleLimit`, j'utilisais une grosse valeur (50) et cela était judicieux. Dans l'exemple ci-dessus, il n'est pas certain que cela le soit autant. Des tests devront être réalisées afin d'estimer la valeur qui donne les résultats les plus performants. 

Il existe deux raisons principales pour lesquelles il est nécessaire d'exécuter des blocs de script en parallèle avec la fonctionnalité `ForEach-Object -Parallel` (en gardant à l'esprit que cette fonctionnalité exécute le script sur des threads système distincts).

- **Script à forte intensité de calcul** : Si votre script traite beaucoup de données sur une période de temps significative et que les scripts peuvent être exécutés indépendamment, il est alors intéressant de les exécuter en parallèle. Mais seulement si la machine sur laquelle vous exécutez dispose de plusieurs coeurs pouvant héberger les threads de blocs de script. Dans ce cas, ***le paramètre `-ThrottleLimit` doit être défini approximativement sur le nombre de cœurs disponibles***. Si vous exécutez sur une machine virtuelle avec un seul cœur, il n'est pas très judicieux d'exécuter des blocs de script à haute intensité de calcul en parallèle, car le système doit de toute façon les sérialiser pour s'exécuter sur le seul cœur.
- **Script qui doit attendre quelque chose** : Si vous avez un script qui peut s'exécuter de manière indépendante et qui effectue un travail de longue durée qui nécessite d'attendre que certaines choses se terminent, il est alors logique d'exécuter ces tâches en parallèle. Si vous avez 5 scripts qui prennent 5 minutes chacun à s'exécuter mais passent la plupart du temps à attendre, vous pouvez les exécuter/attendre tous en même temps et terminer les 5 tâches en 5 minutes au lieu de 25 minutes. Les scripts qui effectuent beaucoup d'opérations sur des fichiers ou effectuent des opérations sur des machines externes peuvent bénéficier d'une exécution en parallèle. Étant donné que le script en cours d'exécution ne peut pas utiliser tous les coeurs de la machine, ***il est logique de définir le paramètre `-ThrottleLimit` sur une valeur supérieure au nombre de cœurs***. Si l'exécution d'un script attend plusieurs minutes pour se terminer, vous souhaiterez peut-être autoriser des dizaines ou des centaines de scripts à s'exécuter en parallèle.

````powershell
# récupérer les noms des répertoires de 1er Niveau seulement
(Measure-Command -Expression {
    $Dirs = Get-ChildItem -Path 'C:\Program Files\' -Directory
    $Dirs | ForEach-Object -Parallel {
        # Récupérer les noms de tous les fichiers
        (Get-ChildItem -Path $_ -Recurse -ErrorAction Ignore).Name
    } -ThrottleLimit 5
}).TotalMilliseconds
# 910,1619 avec 20, 915,6312 avec 10 et 1018,0769 avec 5 en throttleLimit. Au-dela le temps augmente
(Measure-Command -Expression {
    $Dir = Get-Item -Path 'C:\Program Files\'
    $Dir | ForEach-Object -Parallel {
        # Récupérer les noms de tous les fichiers
        (Get-ChildItem -Path $_ -Recurse -ErrorAction Ignore ).Name
    } -ThrottleLimit 5
}).TotalMilliseconds
# 1392,2869 avec 20, 1438,2163 avec 10, 1448,9569 avec 5 en throttleLimit. Au-dela le temps augmente
````
Sur ces 2 exemples, on peut constater que si on augmente la valeur du paramètre `-ThrottleLimit`, cela améliore les performances jusqu'à une certaine limite.
>[Nota] : La machine que j'utilise (Windows 11, avec un CPU 11th Gen Intel(R) Core(TM) i9-11900F @ 2.50GHz a 8 coeurs).

On peut noter également que dans le premier cas, j'ai découpé le travail à réaliser en travaux plus petits alors que dans le second, j'ai fait exactement la même chose au sein d'un unique travail ... mais j'ai optenu des résultats moins performants. Ceci est normal si on considère que le `-Parallel` ne s'est appliqué qu'à un seul objet. D'ailleurs, en enlevant les paramètres `-Parallel` et `-ThrottleLimit` j'obtient des perforances équivalentes (1366,6977ms). Dans ce second cas, l'utilisation du mode parallele n'a donc rien apporté de significatif.

<span style="color:green;font-weight:700;font-size:20px">[Point d'attention]</span> : J'ai renouvelé l'expérience, dans des condtions identiques, mais en ajoutant le paramètre `-AsJob` et voici les résultats : 

````powersehll
(Measure-Command -Expression {
    $Dirs = Get-ChildItem -Path 'C:\Program Files\' -Directory
    $Dirs | ForEach-Object -Parallel {
        # Récupérer les noms de tous les fichiers
        (Get-ChildItem -Path $_ -Recurse -ErrorAction Ignore).Name
    } -ThrottleLimit 5
}).TotalMilliseconds
2342,8136

(Measure-Command -Expression {
    $Dirs = Get-ChildItem -Path 'C:\Program Files\' -Directory
    $Dirs | ForEach-Object -Parallel {
        # Récupérer les noms de tous les fichiers
        (Get-ChildItem -Path $_ -Recurse -ErrorAction Ignore).Name
    } -ThrottleLimit 5 -AsJob
    Get-Job | wait-job | Receive-Job
1024,0587
````
Afin d'être rigoureusement dans des conditions identiques, j'ai du ajouter une ligne supplémentaire (sinon, l'ensemble se serait exécuté en seulement 13 ms, mais ce temps aurait correspondu au temps pour créer les jobs). On constate une très légère améliorations des performances mais non vraiment significative. J'ai renouvelé l'expérience avec différentes valeurs pour le paramètre `-ThrotleLimit` et obtenu des résulats similaires. 

Afin de vérifier si cette légère amélioration était vraiment significative ou pas, j'ai renouvelé l'expérience de nombreuses fois : 

````powershell
$Test1 = Measure-MyScript -Name "-Parallel" -Unit ms -repeat 10 -ScriptBlock {
    $Dirs = Get-ChildItem -Path 'C:\Program Files\' -Directory
    $Dirs | ForEach-Object -Parallel {
        # Récupérer les noms de tous les fichiers
        (Get-ChildItem -Path $_ -Recurse -ErrorAction Ignore).Name
    } -ThrottleLimit 20
}

$Test2 = Measure-MyScript -Name '-Parallel -AsJob' -Unit ms -repeat 10 -ScriptBlock {
    $Dirs = Get-ChildItem -Path 'C:\Program Files\' -Directory
    $Dirs | ForEach-Object -Parallel {
        # Récupérer les noms de tous les fichiers
        (Get-ChildItem -Path $_ -Recurse -ErrorAction Ignore).Name
    } -ThrottleLimit 20 -AsJob
    Get-Job | wait-job | Receive-Job
}

$Test1
$Test2

name             Avg                    Min                     Max
----             ---                    ---                     ---
-Parallel        1263,7581 Milliseconds 993,9392 Milliseconds   1795,6418 Milliseconds
-Parallel -AsJob 1241,1371 Milliseconds 1056,0049 Milliseconds  1576,5811 Milliseconds
````
L'amélioration est peu significative en utilisant le paramètre `-AsJob` (du moins dans l'exemple traité). Cependant, il est possible que dans des traitement plus intense, le résultat serait différent. Le seul intérêt évident qu'on peut trouver à l'usage du paramètre `-AsJob` est qu'il libère la console pour d'autres opérations pendant que les tâches (jobs) s'exécutent. Cependant, cela créé un légère surcharge associée à la gestion des travaux en arrière-plan ce qui peut parfois réduire les performances, surtout pour les tâches (job) courtes ou peu nombreuses.

>[Nota] : J'ai utilisé une fonction nommé `Measure-MyScript` pour ceci. Une fonction de Christophe Kumor, disponible [ici](https://github.com/christophekumor/Measure-MyScript) dont j'ai également une version légèrement différence sur mon [gist](https://gist.github.com/Rapidhands/e80c921baa08c5506d832e6fed73391b) que j'ai utilisé.



Autre exemple

````Powershell
# Avec powershell 7.4.5 et le paramètre -Parallel
$LogNames = (Get-WinEvent -ListLog 'Microsoft-Windows-s*').LogName
$logNames.count
# 77

(Measure-Command {
    # collecte des events log dans les 77 journaux en même temps
    $logs = $logNames | ForEach-Object -Parallel {
        Get-WinEvent -LogName $_ -MaxEvents 5000 2>$null
    } -ThrottleLimit 10
}).TotalMilliseconds
4472, 7707

$logs.Count
42864

# Avec powershell 7.4.5 sans utiliser le paramètre -Parallel
(Measure-Command {
    $logs = $logNames | ForEach-Object {
        Get-WinEvent -LogName $_ -MaxEvents 5000 2>$null
    }
}).TotalMilliseconds
14376,3836

$logs.Count
42864

# Avec Windows Powershell 5.1
(Measure-Command {
    $logs = $logNames | ForEach-Object {
        Get-WinEvent -LogName $_ -MaxEvents 5000 2>$null
    }
}).TotalMilliseconds
14720,1814
````
Les performances entre Windows Powershell et powershell 7.4.5 sont identiques, cependant lorsque le paramètre `-Parallel` est utlisé les performances grimpent de manière très sustancielles (30%).

Les lignes de commandez ci-dessus collectent 42 864 entrées de journal sur la machine locale à partir de 77 noms de journaux système. L'exécution en parallèle est presque trois fois plus rapide que l'exécution séquentielle, car elle implique un accès au disque relativement lent et peut également tirer parti des multiples cœurs de la machine lors du traitement des entrées de journal.


autre exemple : 
````powershell
# Avec powershell 7.4.5 avec -Parallel
(Measure-Command {
    1..1000 | ForEach-Object -Parallel { "Hello: $_" } 
}).TotalMilliseconds
1228, 8566
# Avec powershell 7.4.5 Sans -Parallel
(Measure-Command {
    1..1000 | ForEach-Object { "Hello: $_" } 
}).TotalMilliseconds
3, 541
# With Windows Powershell 5.1
(Measure-Command {
    1..1000 | ForEach-Object { "Hello: $_" } 
}).TotalMilliseconds
19, 8477
````
Et pourtant dans cet exemple on obtient exatement l'effet inverse de ce qu'attendu. Les performances sont moins bonnes en mode parallélisé.

`ForEach-Object -Parallel` ne doit pas être considéré comme quelque chose qui accélérera toujours l'exécution du script.
Et en fait, il peut ralentir considérablement l'exécution du script s'il est utilisé sans réfléchir.
Par exemple, si votre bloc de script exécute un script trivial, l'exécution en parallèle ajoute une énorme quantité de surcharge et s'exécutera beaucoup plus lentement.
[Voir Reférence](https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/)

Dans l'exemple ci-dessus, un bloc de script trivial est exécuté 1 000 fois.
La limite de traitement est de 5 par défaut, donc seuls 5 espaces d'exécution/threads sont créés à la fois, mais un espace d'exécution et un thread sont créés 1 000 fois pour effectuer une évaluation de chaîne simple.
Par conséquent, l'exécution prend plus de 12 secondes.
Mais la suppression du paramètre `-Parallel` et l'exécution normale de l'applet de commande `ForEach-Object` aboutit à une exécution en environ 3 millisecondes.

>[Nota] : on notera cependant l'amélioration entre Windows Powershell 5.1 et Powershell 7.4.5.

`ForEach-Object -Parallel` ne doit pas être considéré comme quelque chose qui accélérera toujours l'exécution du script. En fait, il peut ralentir considérablement l'exécution du script s'il est utilisé sans réfléchir. Par exemple, si votre bloc de script exécute un script trivial, l'exécution en parallèle ajoute une énorme quantité de surcharge et s'exécutera beaucoup plus lentement.

Un autre exemple : 

````powershell
(Measure-Command {
    1..1000 | ForEach-Object -Parallel { "Hello: $_" } 
}).TotalMilliseconds
1288,2957


(Measure-Command {
    1..1000 | ForEach-Object { "Hello: $_" } 
}).TotalMilliseconds
25,0489
````

Dans l'exemple ci-dessus, un bloc de script trivial est exécuté 1 000 fois. La limite de traitement est de 5 par défaut, donc seuls 5 espaces d'exécution/threads sont créés à la fois, mais un espace d'exécution et un thread sont créés 1 000 fois pour effectuer une évaluation de chaîne simple. Par conséquent, l'exécution prend plus de 12 secondes. Mais la suppression du paramètre `-Parallel` et l'exécution normale de l'applet de commande `ForEach-Object` aboutissent à une exécution en 25 millisecondes environ.

Il est donc important d'utiliser cette fonctionnalité à bon escient.

## Détails de l'implémentation

Comme mentionné précédemment, la nouvelle fonctionnalité `ForEach-Object -Parallel` utilise la fonctionnalité PowerShell existante pour exécuter des blocs de script simultanément. L'ajout principal est la possibilité de limiter le nombre de scripts simultanés exécutés à un moment donné avec le paramètre `-ThrottleLimit`. La limitation est effectuée par une classe `PSTaskPool` qui contient des tâches en cours d'exécution (scripts en cours d'exécution) et a une limite de taille paramétrable qui est définie dans la valeur throttlelimit. Une méthode `Add` permet d'ajouter des tâches au pool, mais si celui-ci est plein, la méthode se bloque jusqu'à ce qu'un nouvel emplacement soit disponible. L'ajout de tâches au pool de tâches était initialement effectué sur le thread de traitement du pipeline de `ForEach-Object`. Mais cela s'est avéré être un goulot d'étranglement des performances, et maintenant un thread dédié est utilisé pour ajouter des tâches au pool.

PowerShell lui-même impose des conditions sur la façon dont les scripts s'exécutent simultanément, en fonction de sa conception et de son historique. Les scripts doivent s'exécuter dans des contextes d'espace d'exécution (Runspace) et un seul thread de script peut s'exécuter à la fois dans un espace d'exécution. Ainsi, pour exécuter plusieurs scripts simultanément, plusieurs espaces d'exécution doivent être créés. L'implémentation actuelle de `ForEach-Object -Parallel` crée un nouvel espace d'exécution pour chaque instance d'exécution de bloc de script. Il peut être possible d'optimiser cela en réutilisant les espaces d'exécution d'un pool, mais l'un des problèmes que cela pose est la fuite d'état d'une exécution de script à une autre.

Les contextes d'espace d'exécution sont une unité d'isolation pour l'exécution de scripts et ne permettent généralement pas de partager l'état entre eux. Cependant, les variables peuvent être transmises au début de l'exécution du script via le mot-clé `$using:`, du script appelant au bloc de script parallèle. Cela a été emprunté à la couche de communication à distance qui utilise le mot-clé dans le même but mais via une connexion à distance. Mais il y a une grande différence lors de l'utilisation du mot-clé `$using:` dans `ForEach-Object -Parallel`. Et c'est pour la communication à distance, la variable transmise est une copie envoyée via la connexion à distance. Mais avec `ForEach-Object -Parallel`, la référence d'objet réelle est transmise d'un script à un autre, violant ainsi les restrictions d'isolation normales. Il est donc possible d'avoir une variable non thread-safe utilisée dans deux scripts exécutés sur des threads différents, ce qui peut conduire à un comportement imprévisible.

Exemple : 

````powershell
# This does not throw an error, but is not guaranteed to work since the dictionary object is not thread safe 
$threadUnSafeDictionary = [System.Collections.Generic.Dictionary[string, object]]::new()
Get-Process | ForEach-Object -Parallel {
    $dict = $using:threadUnSafeDictionary
    $dict.TryAdd($_.ProcessName, $_)
}

$threadUnSafeDictionary
Key                             Value
---                             -----
Aac3572DramHal_x86              System.Diagnostics.Process (Aac3572DramHal_x86)
Aac3572MbHal_x86                System.Diagnostics.Process (Aac3572MbHal_x86)
AacAmbientLighting              System.Diagnostics.Process (AacAmbientLighting)
AacKingstonDramHal_x64          System.Diagnostics.Process (AacKingstonDramHal_x64)
AacKingstonDramHal_x86          System.Diagnostics.Process (AacKingstonDramHal_x86)
AcPowerNotification             System.Diagnostics.Process (AcPowerNotification)
AppleMobileDeviceProcess        System.Diagnostics.Process (AppleMobileDeviceProcess)
ApplePhotoStreams               System.Diagnostics.Process (ApplePhotoStreams)
ApplicationFrameHost            System.Diagnostics.Process (ApplicationFrameHost)
APSDaemon                       System.Diagnostics.Process (APSDaemon)
ArmouryAudioAgent               System.Diagnostics.Process (ArmouryAudioAgent)
ArmouryCrate.Service            System.Diagnostics.Process (ArmouryCrate.Service)
ArmouryCrate.UserSessionHelper  System.Diagnostics.Process (ArmouryCrate.UserSessionHelper)
ArmouryHtmlDebugServer          System.Diagnostics.Process (ArmouryHtmlDebugServer)
ArmourySocketServer             System.Diagnostics.Process (ArmourySocketServer)
ArmourySwAgent                  System.Diagnostics.Process (ArmourySwAgent)
AsusCertService                 System.Diagnostics.Process (AsusCertService)
AsusFanControlService           System.Diagnostics.Process (AsusFanControlService)
asus_framework                  System.Diagnostics.Process (asus_framework)
atkexComSvc                     System.Diagnostics.Process (atkexComSvc)
audiodg                         System.Diagnostics.Process (audiodg)
Code                            System.Diagnostics.Process (Code)
conhost                         System.Diagnostics.Process (conhost)
CrossDeviceService              System.Diagnostics.Process (CrossDeviceService)
csrss                           System.Diagnostics.Process (csrss)
ctfmon                          System.Diagnostics.Process (ctfmon)
dasHost                         System.Diagnostics.Process (dasHost)
dllhost                         System.Diagnostics.Process (dllhost)
dwm                             System.Diagnostics.Process (dwm)
explorer                        System.Diagnostics.Process (explorer)
extensionCardHal_x86            System.Diagnostics.Process (extensionCardHal_x86)
FileCoAuth                      System.Diagnostics.Process (FileCoAuth)
FileSyncHelper                  System.Diagnostics.Process (FileSyncHelper)
firefox                         System.Diagnostics.Process (firefox)
fontdrvhost                     System.Diagnostics.Process (fontdrvhost)
GameSDK                         System.Diagnostics.Process (GameSDK)
gamingservices                  System.Diagnostics.Process (gamingservices)
gamingservicesnet               System.Diagnostics.Process (gamingservicesnet)
iCloudCKKS                      System.Diagnostics.Process (iCloudCKKS)
iCloudDrive                     System.Diagnostics.Process (iCloudDrive)
iCloudHome                      System.Diagnostics.Process (iCloudHome)
iCloudOutlookConfig64           System.Diagnostics.Process (iCloudOutlookConfig64)
iCloudPhotos                    System.Diagnostics.Process (iCloudPhotos)
iCUE                            System.Diagnostics.Process (iCUE)
Idle                            System.Diagnostics.Process (Idle)
Intel_PIE_Service               System.Diagnostics.Process (Intel_PIE_Service)
jhi_service                     System.Diagnostics.Process (jhi_service)
ledcontrolservice3              System.Diagnostics.Process (ledcontrolservice3)
LightingService                 System.Diagnostics.Process (LightingService)
LockApp                         System.Diagnostics.Process (LockApp)
LsaIso                          System.Diagnostics.Process (LsaIso)
lsass                           System.Diagnostics.Process (lsass)
Memory Compression              System.Diagnostics.Process (Memory Compression)
MicrosoftSecurityApp            System.Diagnostics.Process (MicrosoftSecurityApp)
mmgaserver                      System.Diagnostics.Process (mmgaserver)
MoUsoCoreWorker                 System.Diagnostics.Process (MoUsoCoreWorker)
MpDefenderCoreService           System.Diagnostics.Process (MpDefenderCoreService)
ms-teams                        System.Diagnostics.Process (ms-teams)
msedge                          System.Diagnostics.Process (msedge)
msedgewebview2                  System.Diagnostics.Process (msedgewebview2)
MsMpEng                         System.Diagnostics.Process (MsMpEng)
MsMpEngCP                       System.Diagnostics.Process (MsMpEngCP)
NisSrv                          System.Diagnostics.Process (NisSrv)
NoiseCancelingEngine            System.Diagnostics.Process (NoiseCancelingEngine)
...

# On voit que la variable $threadUnSafeDictionary se présente comme une hashtable ou un dictionnaire (pair key/value)
# Ici je demande l'entrée powershell
$threadUnSafeDictionary['pwsh']

NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
------    -----      -----     ------      --  -- -----------
   144   365,18     475,46      12,36   52812   1 pwsh
````


Dans l'exemple suivant je vais utiliser la classe `System.Collections.Concurrent.ConcurrentDictionary` qui permet de passer dans en thread-safe

````powershell

# # This *is* guaranteed to work because the passed in concurrent dictionary object is thread safe
$threadSafeDictionary = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()
Get-Process | ForEach-Object -Parallel {
    $dict = $using:threadSafeDictionary
    $dict.TryAdd($_.ProcessName, $_)
}

$threadSafeDictionary
Key                             Value
---                             -----
SearchIndexer                   System.Diagnostics.Process (SearchIndexer)
spoolsv                         System.Diagnostics.Process (spoolsv)
services                        System.Diagnostics.Process (services)
RuntimeBroker                   System.Diagnostics.Process (RuntimeBroker)
mmgaserver                      System.Diagnostics.Process (mmgaserver)
Aac3572MbHal_x86                System.Diagnostics.Process (Aac3572MbHal_x86)
AacKingstonDramHal_x64          System.Diagnostics.Process (AacKingstonDramHal_x64)
nvcontainer                     System.Diagnostics.Process (nvcontainer)
pwsh                            System.Diagnostics.Process (pwsh)
NisSrv                          System.Diagnostics.Process (NisSrv)
lsass                           System.Diagnostics.Process (lsass)
Secure System                   System.Diagnostics.Process (Secure System)
powershell                      System.Diagnostics.Process (powershell)
APSDaemon                       System.Diagnostics.Process (APSDaemon)
ArmouryCrate.Service            System.Diagnostics.Process (ArmouryCrate.Service)
dwm                             System.Diagnostics.Process (dwm)
taskhostw                       System.Diagnostics.Process (taskhostw)
SecurityHealthService           System.Diagnostics.Process (SecurityHealthService)
msedge                          System.Diagnostics.Process (msedge)
...

$threadSafeDictionary['pwsh']

NPM(K) PM(M) WS(M) CPU(s) Id SI ProcessName
------ ---- - ---- - ------ -- -- ---------- -
112 108.25 124.43 69.75 16272 1 pwsh
````

Cette fonctionnalité peut grandement améliorer votre vie dans de nombreux scénarios de charge de travail.
Tant que vous comprenez son fonctionnement et ses limites, vous pouvez expérimenter le parallélisme et apporter de réelles améliorations de performances à vos scripts.


## Manipulation des dictionnaires

A ce niveau de ce post, vous vous demandez peut-être "j'ai l'habitude de man,ier des objets mais comment manipule-t-on des dictionnaires ?

````powershell
$computers = @('Asus11', 'Asus12', 'Fake')
$threadSafeDictionary = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()

$computers | ForEach-Object -Parallel {
    Write-Output "Running Commands on $_"
    try 
    {
        $query = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $_ -ErrorAction stop -OutVariable $_
        $dict = $using:threadSafeDictionary
        $dict.TryAdd($_ , $query)
    }
    catch
    {
    }
}
# Voyons le contenu de notre variable $threadSafeDictionary
$threadSafeDictionary
Key    Value
---    -----
Asus11 {Win32_LogicalDisk : C: (DeviceID = "C:"), Win32_LogicalDisk : D: (DeviceID = "D:")}
Asus12 {Win32_LogicalDisk : C: (DeviceID = "C:"), Win32_LogicalDisk : D: (DeviceID = "D:")}

# Pas facile à exploiter directement, traitons cela
foreach ($key in $threadSafeDictionary.Keys)
{
    #$value = $threadSafeDictionary[$key]
    # or
    $value = $threadSafeDictionary.$key
}
$value
DeviceID DriveType ProviderName VolumeName Size          FreeSpace    PSComputerName
-------- --------- ------------ ---------- ----          ---------    --------------
C:       3                      SYSTEM     998709936128  778224766976 Asus11
D:       3                      DATA       1000186310656 586520358912 Asus11
C:       3                      SYSTEM     998709936128  154878798678 Asus12
D:       3                      DATA       1000186310656 157878688846 Asus12

# regardons quel est le type de notre variable $Value
$value | get-Member

   TypeName: Microsoft.Management.Infrastructure.CimInstance#root/cimv2/Win32_LogicalDisk

Name                         MemberType   Definition
----                         ----------   ----------
Dispose                      Method       void Dispose(), void IDisposable.Dispose()
Equals                       Method       bool Equals(System.Object obj)
GetCimSessionComputerName    Method       string GetCimSessionComputerName()
GetCimSessionInstanceId      Method       guid GetCimSessionInstanceId()
GetHashCode                  Method       int GetHashCode()
GetType                      Method       type GetType()
ToString                     Method       string ToString()
PSShowComputerName           NoteProperty bool PSShowComputerName=True
Access                       Property     ushort Access {get;}
Availability                 Property     ushort Availability {get;}
BlockSize                    Property     ulong BlockSize {get;}
Caption                      Property     string Caption {get;}
Compressed                   Property     bool Compressed {get;}
ConfigManagerErrorCode       Property     uint ConfigManagerErrorCode {get;}
ConfigManagerUserConfig      Property     bool ConfigManagerUserConfig {get;}
CreationClassName            Property     string CreationClassName {get;}
Description                  Property     string Description {get;}
DeviceID                     Property     string DeviceID {get;}
DriveType                    Property     uint DriveType {get;}
ErrorCleared                 Property     bool ErrorCleared {get;}
ErrorDescription             Property     string ErrorDescription {get;}
ErrorMethodology             Property     string ErrorMethodology {get;}
FileSystem                   Property     string FileSystem {get;}
FreeSpace                    Property     ulong FreeSpace {get;}
InstallDate                  Property     CimInstance#DateTime InstallDate {get;}
LastErrorCode                Property     uint LastErrorCode {get;}
MaximumComponentLength       Property     uint MaximumComponentLength {get;}
MediaType                    Property     uint MediaType {get;}
Name                         Property     string Name {get;}
NumberOfBlocks               Property     ulong NumberOfBlocks {get;set;}
PNPDeviceID                  Property     string PNPDeviceID {get;}
PowerManagementCapabilities  Property     ushort[] PowerManagementCapabilities {get;}
PowerManagementSupported     Property     bool PowerManagementSupported {get;}
ProviderName                 Property     string ProviderName {get;}
PSComputerName               Property     string PSComputerName {get;}
Purpose                      Property     string Purpose {get;}
QuotasDisabled               Property     bool QuotasDisabled {get;}
QuotasIncomplete             Property     bool QuotasIncomplete {get;}
QuotasRebuilding             Property     bool QuotasRebuilding {get;}
Size                         Property     ulong Size {get;}
Status                       Property     string Status {get;}
StatusInfo                   Property     ushort StatusInfo {get;}
SupportsDiskQuotas           Property     bool SupportsDiskQuotas {get;}
SupportsFileBasedCompression Property     bool SupportsFileBasedCompression {get;}
SystemCreationClassName      Property     string SystemCreationClassName {get;}
SystemName                   Property     string SystemName {get;}
VolumeDirty                  Property     bool VolumeDirty {get;}
VolumeName                   Property     string VolumeName {get;set;}
VolumeSerialNumber           Property     string VolumeSerialNumber {get;}
PSStatus                     PropertySet  PSStatus {Status, Availability, DeviceID, StatusInfo}


# C'est une `[Array]` et on a bien toutes nos propriétés récupérées, ne reste plus qu'à eventuellement filtrer si on n'en veut que quelques unes seulement
````

## A propos du mot-clé `$Using:``


````powershell
$arr = 1..10
$printvar = 'Value'

$arr | ForEach-Object -Parallel {
    $val = $_
    "$($printvar) : $val"
}
 : 1
 : 2
 : 3
 : 4
 : 5
 : 6
 : 7
 : 8
 : 9
 : 10


$arr = 1..10
$printvar = 'Value'
$arr | ForEach-Object -Parallel {
    $val = $_
    "$($using:printvar) : $val"
}

Value : 1
Value : 2
Value : 3
Value : 4
Value : 5
Value : 6
Value : 7
Value : 8
Value : 9
Value : 10
````
Dans le 1er exemple, on peut voir que la valeur  de la variable $printvar n'est pas sortie.

> **Pour utiliser une variable déclarée en dehors de la boucle `foreach -parallel``, utilisez la variable intégrée `$using`.**

Assurez-vous cependant que l'utilisation d'une variable est uniquement destinée à l'affectation et non à d'autres opérations telles que l'addition ou la soustraction.

Par exemple : 

````powershell
$arr = 1..10
$output = 0
$arr | ForEach-Object -Parallel {
    $val = $_
    $using:output += $val
}

ParserError: 
Line |
   3 |      $using:output += $val
     |      ~~~~~~~~~~~~~
````

Tout comme nous ne pouvons pas utiliser la variable externe à la boucle `foreach` directement à l'intérieur de la boucle (nous devons utiliser `$using`), **la portée de la variable à l'intérieur de la boucle `foreach -parallel` est restreinte.** 

Exemple : 

````Powershell
$arr = 1..10
$newarray = @()
$arr | ForEach-Object -Parallel {
    $newarray = $using:newArray
    $newarray += $arr
}
"New Array: $newarray"

New Array:
````
On ne voit pas les valeurs dans $newarray car la portée est restreinte. Pour stocker la sortie de la boucle, enregistrez la boucle entière dans une `[Array]`

Comme ceci : 
````powershell
$arr = 1..10
$newarray = @()
$newarray += $arr | ForEach-Object -Parallel { $_ }
"New Array: $newarray"

New Array: 1 2 3 4 5 6 7 8 9 10
````