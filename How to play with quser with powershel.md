# How to play with quser with powershell

````quser```` is a legacy DOS tool to identify user logged into a computer
If we want to exploit the result of a ````quser```` command, the result isn't clean for a later use in Powershell

## Quick reminder about quser

````powershell
$quserResult = quser /server:$Computer 2>&1
````

This returns something like the following

```` powershell
USERNAME SESSIONNAME ID STATE IDLE TIME LOGON TIME
User console 1 Active none 8/14/2019 6:52 AM
````

## How to works with this

The solution is to transform the previous result with regex

````powershell
$quserRegex = $quserResult | ForEach-Object -Process { $_ -replace '\s{2,}',',' }
````

Then, convert the regex result with ````ConvertFrom-Csv```` cmdlet

````powershell
$quserObject = $quserRegex | ConvertFrom-Csv
````

At this step, wa have a clean object to work with it in Powershell. :-)

## Play with the quserobject to logoff connected users

The simple command is the following

````powershell
Logoff $quserObject.ID /server:Computer
````

and we can runs this for all connected users with  a foreach loop

````powershell
foreach ($User in $quserObject)
    {
        Logoff $User.ID /server:$Computer
````

Of course ````$Computer```` is a variable previously define. It could be also an array of computers.

With an Object, Powershell can run efficiciently. The previous code is just an example.

We can also build new objects by joining the results of different objects in Powershell

Hope this help

Ref source : <https://devblogs.microsoft.com/scripting/automating-quser-through-powershell/>
