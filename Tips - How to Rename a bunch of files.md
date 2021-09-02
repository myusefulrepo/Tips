# How to rename a bunch of files

## the case
You have a large number of files that are all named something like this
````
James Bob- Certificate - 09012021
Johnson Steve - Certificate-09012021
Thompson John - Certificate- 09012021
````
... and you would like to rename them kike the following :

````
James Bob
Johnson Steve
Thompson John
````

How to achieve this goal ?

## The solution
For this i would simulate the case using an array of names. This is useful to find the appropriate way to reach the goal.


````Powershell
$a="James Bob- Certificate - 09012021","Johnson Steve - Certificate-09012021","Thompson John - Certificate- 09012021"
$a
James Bob- Certificate - 09012021
Johnson Steve - Certificate-09012021
Thompson John - Certificate- 09012021
````
As you can see, this reflects the situation

As a first step, I'm using the ````split```` separator withe the separator character ````"-"````
The result will be :

````powershell
$a | foreach{$_.split("-")}
James Bob
 Certificate
 09012021
Johnson Steve
 Certificate
09012021
Thompson John
 Certificate
 09012021
````
As you can see, this split the array on the separator character.

As a second step, I'm using the ````[0]```` to return only the fisrt string of the split


````powershell
$a | foreach{$_.split("-")[0]}
James Bob
Johnson Steve
Thompson John
````

As you can see (yes, yes look carefully :-) ), there are still some trailing spaces at the end of each lines

as the third step, I'm removing these trailing space using de ````TrimEnd```` method

> [Nota : ] if you have some trailing space at the beginning, you could use the ````Trim```` Method.

````powershell
$a | Foreach {$_.split("-")[0].trimend()}
James Bob
Johnson Steve
Thompson John
````
As you can see, there is no trailing space, and we have achieve the goal.

## Now apply the method to a bunch of files

````powershell
$AllFiles = Get-ChildItem -Path \\path\to\files\
foreach ($File in $AllFiles)
    {
    $ActualName = $File.Name
    # Nota 1 : The Path parameter must be the FullName of the file
    # Nota 2 : The NewName parameter must be the Name with the extension
    # but we haven't it, resulting of using the split method and keep only the first string using [0]
    # Then, we're adding the actual extension to the NewName, to reach this goal
    Rename-Item -Path $File.FullName -NewName "$($ActualName.split("-")[0].trimEnd())$($file.Extension)"
    }

# another way, it to use the following :
Get-ChildItem -Path \\path\to\files\ |
    Foreach-Object
    {
    $ActualName = $_.Name
    # Nota 1 : The Path parameter must be the full name of the file
    # Nota 2 : The NewName parameter must be the Name with the extension
    # but we haven't it, resulting of using the split method and keep only the first string using [0]
    # Then we're adding the actual extension to the NewName, to reach this goal
    Rename-Item -Path $_.FullName -NewName "$($ActualName.split("-")[0].trimEnd())$($_.Extension)"
    }
````

### Some words about differences between the 2 ways

The ````Foreach-Object```` is **more efficient in terms of memory utilization** but **lacks the performance**

The ````foreach```` loop control is **more efficient in terms of performance** but might **utilize more memory** depending on the objects you are looping through.

You can easily understand this because, the Foreach-Object is used via Pipeline that means one object is passed to this at a time so there is no need to store anything when you are processing huge data.
When it comes to foreach loop control statement, data should be in one variable which you will loop through one at a time so requires some space in memory.

## The final word

I hope this could be useful to everyone read (and understand :-) ) this.
