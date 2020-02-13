# Build a custom error info function

Often, when in scripts, we must use Try ... Catch statement to grab errors. However, the output displayed is not really friendly.

Let's show this with a sample

````powershell
Write-Host "Stop On Error Example"
try
{
    Stop-Service -Name FakeService -ErrorAction Stop
}
catch
{
    $_.
    Write-Host "Or another way"
     $_.Exception.Message
}
Stop On Error Example
Stop-Service : Impossible de trouver un service assorti du nom « FakeService ».
Au caractère Ligne:4 : 5
+     Stop-Service -Name FakeService -ErrorAction Stop
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (FakeService:String) [Stop-Service], ServiceCommandException
    + FullyQualifiedErrorId : NoServiceFoundForGivenName,Microsoft.PowerShell.Commands.StopServiceCommand
Or another way
Impossible de trouver un service assorti du nom « FakeService ».
````

The first way is a bid bazaar, and the second is too short.

>[Nota] $_ represent the current var in the ````catch```` Statement. It's the same thing that ````$Error[0]````

Deep dive in the $error

````powershell
$error[0] |Select-Object -Property *
PSMessageDetails      :
Exception             : Microsoft.PowerShell.Commands.ServiceCommandException: Impossible de trouver un service assorti du nom «FakeService».
TargetObject          : FakeService
CategoryInfo          : ObjectNotFound: (FakeService:String) [Stop-Service], ServiceCommandException
FullyQualifiedErrorId : NoServiceFoundForGivenName,Microsoft.PowerShell.Commands.StopServiceCommand
ErrorDetails          :
InvocationInfo        : System.Management.Automation.InvocationInfo
ScriptStackTrace      : à <ScriptBlock>, <Aucun fichier> : ligne 4
PipelineIterationInfo : {}

$error[0].Exception | Select-Object -Property *
ServiceName    : FakeService
Message        : Impossible de trouver un service assorti du nom « FakeService ».
Data           : {}
InnerException :
TargetSite     :
StackTrace     :
HelpLink       :
Source         :
HResult        : -2146233087
````

$Error.Exception.Message is an interesting thing

````powershell
$error[0].CategoryInfo |Select-Object -Property *
Category   : ObjectNotFound
Activity   : Stop-Service
Reason     : ServiceCommandException
TargetName : FakeService
TargetType : String
````

$Error.CategoryInfo.Reason and $Error.CategoryInfo.Activity too.

````powershell
$Error[0].InvocationInfo
MyCommand             : Stop-Service
BoundParameters       : {}
UnboundArguments      : {}
ScriptLineNumber      : 4
OffsetInLine          : 5
HistoryId             : 42
ScriptName            :
Line                  :     Stop-Service -Name FakeService -ErrorAction Stop

PositionMessage       : Au caractère Ligne:4 : 5
                        +     Stop-Service -Name FakeService -ErrorAction Stop
                        +     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PSScriptRoot          :
PSCommandPath         :
InvocationName        : Stop-Service
PipelineLength        : 0
PipelinePosition      : 0
ExpectingInput        : False
CommandOrigin         : Internal
DisplayScriptPosition :
````

The property ````line```` display useful info, like ````ScriptLineNumber````, ànd ````OffsetInLine````.

Of course, We could put the result of all these properties on a ````[PSCustomObject]```` in the ````catch```` statement, and display it, but it could be more efficient to build a function to do this (Code reuse is the power :-) )

## Build a custom function to display error like we want

First examine the type of $Error

````powershell
$error | gm
    TypeName : System.Management.Automation.ErrorRecord
````

Now we can build our function

````powershell
function Get-Error
{
  param
  (
    [Parameter(ValueFrompipeline)]
    [Management.Automation.ErrorRecord]$ErrorRecord
  )


  process
  {
    $Info = [PSCustomObject]@{
      Exception = $ErrorRecord.Exception.Message
      Reason    = $ErrorRecord.CategoryInfo.Reason
      Target    = $ErrorRecord.CategoryInfo.TargetName
      Script    = $ErrorRecord.InvocationInfo.ScriptName
      Line      = $ErrorRecord.InvocationInfo.ScriptLineNumber
      Column    = $ErrorRecord.InvocationInfo.OffsetInLine
      Date      = Get-Date
      User      = $ENV:UserName
    }
    $Info
  }
}
````

***Question*** : Why the var is named ErrorRecord and not just Record ?
***Answer*** : Error is reserved for the corresponding Automatic Variable.

Function In action

````powershell
Write-Host "Stop On Error Example"
try
{
    Stop-Service -Name FakeService -ErrorAction Stop
}
catch
{
    $_ | Get-Error
}

Stop On Error Example

Exception : Impossible de trouver un service assorti du nom « FakeService ».
Reason    : ServiceCommandException
Target    : FakeService
Script    :
Line      : 4
Column    : 5
Date      : 13/02/2020 10:52:11
User      : Olivier
````

this way works fine too.

````powershell
Write-Host "Stop On Error Example"
try
{
    Stop-Service -Name FakeService -ErrorAction Stop
}
catch
{
    Get-Error -ErrorRecord $_
}
````

Reference :
<https://github.com/imseandavis/PowerShell/blob/master/Error%20Handling/Get-ErrorInfo.ps1>
