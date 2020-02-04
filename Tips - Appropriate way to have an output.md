# Quick Tips about appropriate ways to have an output

## Good : Only for on-screen output

````powershell
Get-Stuff |
    Format-Table Prop1, @{n='CalculatedProp';e={$_.ExtraStuff}}
````

## Bad : Format cmdlet passing down the pipe

````powershell
Get-Stuff |
    Format-Table Prop1, @{n='CalculatedProp';e={$_.ExtraStuff}} |
    Export-Csv "C:\results.csv"
````

The ````Format-Table```` cmdlet is designed to ````Out-```` cmdlets only

## Fixed  : Selecting when passing down the pipeline

````powershell
Get-Stuff |
    Select-Object Prop1, @{n='CalculatedProp';e={$_.ExtraStuff}} |
    Export-Csv "C:\results.csv" Appropriate way to have an output
````

## Explanations

Let's take some samples

````powershell
Get-Service |
    Format-Table Name, @{n='DisplayName';e={$_.DisplayName}} | Get-Member
   TypeName : Microsoft.PowerShell.Commands.Internal.Format.FormatStartData

Name                                    MemberType Definition
----                                    ---------- ----------
Equals                                  Method     bool Equals(System.Object obj)
GetHashCode                             Method     int GetHashCode()
GetType                                 Method     type GetType()
ToString                                Method     string ToString()
autosizeInfo                            Property   Microsoft.PowerShell.Commands.Internal.Format.AutosizeInfo, System.Management.Automation...
ClassId2e4f51ef21dd47e99d3c952918aff9cd Property   string ClassId2e4f51ef21dd47e99d3c952918aff9cd {get;}
groupingEntry                           Property   Microsoft.PowerShell.Commands.Internal.Format.GroupingEntry, System.Management.Automatio...
pageFooterEntry                         Property   Microsoft.PowerShell.Commands.Internal.Format.PageFooterEntry, System.Management.Automat...
pageHeaderEntry                         Property   Microsoft.PowerShell.Commands.Internal.Format.PageHeaderEntry, System.Management.Automat...
shapeInfo                               Property   Microsoft.PowerShell.Commands.Internal.Format.ShapeInfo, System.Management.Automation, V...


   TypeName : Microsoft.PowerShell.Commands.Internal.Format.GroupStartData

Name                                    MemberType Definition
----                                    ---------- ----------
Equals                                  Method     bool Equals(System.Object obj)
GetHashCode                             Method     int GetHashCode()
GetType                                 Method     type GetType()
ToString                                Method     string ToString()
ClassId2e4f51ef21dd47e99d3c952918aff9cd Property   string ClassId2e4f51ef21dd47e99d3c952918aff9cd {get;}
groupingEntry                           Property   Microsoft.PowerShell.Commands.Internal.Format.GroupingEntry, System.Management.Automatio...
shapeInfo                               Property   Microsoft.PowerShell.Commands.Internal.Format.ShapeInfo, System.Management.Automation, V...
# ...

Get-Service |
    Select-Object -Property Name, @{n='DisplayName';e={$_.DisplayName}} | Get-Member
   TypeName : Selected.System.ServiceProcess.ServiceController

Name        MemberType   Definition
----        ----------   ----------
Equals      Method       bool Equals(System.Object obj)
GetHashCode Method       int GetHashCode()
GetType     Method       type GetType()
ToString    Method       string ToString()
DisplayName NoteProperty System.String DisplayName=Agent Activation Runtime_1058c1
Name        NoteProperty string Name=AarSvc_1058c1
````

What you are seeing is that ````Format-Table```` transforms the objects into a stream of formatting directives.
These are then consumed by one of the ````Out-```` Cmdlets (````Out-Host````, ```Out-File```, ````Out-String````, ````Out-Printer````).

This is why you ***can’t pipe format-table*** to ````Export-Csv````.
