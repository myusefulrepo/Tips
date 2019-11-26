# Inside $MyInvocation automatic Variable

This variable contains information about the current command, such as the name, parameters, parameter values, and information about how the command was started, called, or invoked, such as the name of the script that called the current command.

````powershell
$MyInvocation
````

this returns :

````powershell
MyCommand             : test.ps1
BoundParameters       : {}
UnboundArguments      : {}
ScriptLineNumber      : 0
OffsetInLine          : 0
HistoryId             : 4
ScriptName            :
Line                  :
PositionMessage       :
PSScriptRoot          :
PSCommandPath         :
InvocationName        : C:\Users\UserName\Desktop\test.ps1
PipelineLength        : 2
PipelinePosition      : 1
ExpectingInput        : False
CommandOrigin         : Internal
DisplayScriptPosition :
````

As we can see, there are several interesting properties that we can use

````powershell
$MyInvocation.MyCommand
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
ExternalScript  test.ps1                                                      C:\Users\%UserName%\Desktop\test.ps1
````

If i try ````$MyInvocation.MyCommand.Name```` this returns the name of the script that launchs the script.
But it's the name with the extension. It's not very practical when you would like to use the script name for naming convention of a log file.
I would like to **get the short Name of the script**.

Ok, let's try to split this with using the ````.split```` method

````powershell
($MyInvocation.MyCommand.Name).split(".",2)
test
ps1
# The parameter of the split method will be the "." separing Name and extension. In this particular case ($MyInvocation.MyCommand.Name).split(".")[0] is good too.

($MyInvocation.MyCommand.Name).split(".")[0]
Test

($MyInvocation.MyCommand.Name).split(".")[1]
.ps1

# The [0] return only the first part of the split, then the name. If I use [1] is will be the second part (Extension)
````

If i would like to **get the full path name of the script**, i'll use the following

````powershell
$MyInvocation.InvocationName
C:\Users\%UserName%\Desktop\test.ps1

# Another method
$PSCommandPath
C:\Users\%UserName%\Desktop\test.ps1
````

I could get the same information with the default variable ````$PSCommandPath````

To **get the Parent Dir of the script**, we can use

````powershell
$MyInvocation.$PSScriptRoot
# or directly
$PSScriptRoot
````
