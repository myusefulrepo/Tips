# How to get the Process Owner from TCP Connection established ?
- [How to get the Process Owner from TCP Connection established ?](#how-to-get-the-process-owner-from-tcp-connection-established-)
  - [1 - Using the `Get-NetTPConnection` cmdlet](#1---using-the-get-nettpconnection-cmdlet)
  - [2 - Using the `Get-Process` cmdlet](#2---using-the-get-process-cmdlet)
  - [3 - Let's put these cmdlets together using the pipeline](#3---lets-put-these-cmdlets-together-using-the-pipeline)
  - [4 - Improving the output](#4---improving-the-output)
    - [4.1 - Output in the console](#41---output-in-the-console)
    - [4.2 - Output in a .csv file](#42---output-in-a-csv-file)
    - [4.3 - Exporting to a .json file](#43---exporting-to-a-json-file)
    - [4.4 - Export to a .html file](#44---export-to-a-html-file)
    - [4.5 - Export to a .xlsx file](#45---export-to-a-xlsx-file)
  - [4.5 - Final Words](#45---final-words)


## 1 - Using the `Get-NetTPConnection` cmdlet

If you're using the `Get-NetTPConnection` cmdlet, you could have TCP connections, but to avoid useless information, we'll filtering : 
- on the Status property with a value "Established"
- On the RemoteAddress not the loopback address.


````powershell
Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -and $_.RemoteAddress -ne "127.0.0.1" }

LocalAddress                        LocalPort RemoteAddress                       RemotePort State       AppliedSetting OwningProcess
------------                        --------- -------------                       ---------- -----       -------------- -------------
192.168.0.20                        62466     162.159.61.4                        443        Established Internet       23304
192.168.0.20                        58710     20.199.120.151                      443        Established Internet       28420
192.168.0.20                        56640     1.1.1.1                             443        Established Internet       2724
192.168.0.20                        56568     34.107.221.82                       80         Established Internet       23304
192.168.0.20                        56567     34.107.221.82                       80         Established Internet       23304
192.168.0.20                        56522     20.111.1.3                          443        Established Internet       53768
192.168.0.20                        56424     77.136.137.199                      443        Established Internet       23304
192.168.0.20                        56406     77.136.137.199                      443        Established Internet       23304
192.168.0.20                        56400     3.251.50.149                        443        Established Internet     
...
````

Interresting, but at this step, we haven't the Process Owner Name.

````powershell
Get-NetTCPConnection |Get-Member -MemberType Properties


   TypeName : Microsoft.Management.Infrastructure.CimInstance#ROOT/StandardCimv2/MSFT_NetTCPConnection

Name                     MemberType     Definition
----                     ----------     ----------
AggregationBehavior      Property       uint16 AggregationBehavior {get;set;}
AvailableRequestedStates Property       uint16[] AvailableRequestedStates {get;set;}
Caption                  Property       string Caption {get;set;}
CommunicationStatus      Property       uint16 CommunicationStatus {get;set;}
CreationTime             Property       CimInstance#DateTime CreationTime {get;}
Description              Property       string Description {get;set;}
DetailedStatus           Property       uint16 DetailedStatus {get;set;}
Directionality           Property       uint16 Directionality {get;set;}
ElementName              Property       string ElementName {get;set;}
EnabledDefault           Property       uint16 EnabledDefault {get;set;}
EnabledState             Property       uint16 EnabledState {get;set;}
HealthState              Property       uint16 HealthState {get;set;}
InstallDate              Property       CimInstance#DateTime InstallDate {get;set;}
InstanceID               Property       string InstanceID {get;set;}
LocalAddress             Property       string LocalAddress {get;}
LocalPort                Property       uint16 LocalPort {get;}
Name                     Property       string Name {get;set;}
OperatingStatus          Property       uint16 OperatingStatus {get;set;}
OperationalStatus        Property       uint16[] OperationalStatus {get;set;}
OtherEnabledState        Property       string OtherEnabledState {get;set;}
OwningProcess            Property       uint32 OwningProcess {get;}
PrimaryStatus            Property       uint16 PrimaryStatus {get;set;}
PSComputerName           Property       string PSComputerName {get;}
RemoteAddress            Property       string RemoteAddress {get;}
RemotePort               Property       uint16 RemotePort {get;}
RequestedState           Property       uint16 RequestedState {get;set;}
Status                   Property       string Status {get;set;}
StatusDescriptions       Property       string[] StatusDescriptions {get;set;}
TimeOfLastStateChange    Property       CimInstance#DateTime TimeOfLastStateChange {get;set;}
TransitioningToState     Property       uint16 TransitioningToState {get;set;}
AppliedSetting           ScriptProperty System.Object AppliedSetting {get=[Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetTCPConnection.AppliedSetting... 
OffloadState             ScriptProperty System.Object OffloadState {get=[Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetTCPConnection.OffloadState]($t... 
State                    ScriptProperty System.Object State {get=[Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetTCPConnection.State]($this.PSBase.Cim... 
````
No available property to get this. 

## 2 - Using the `Get-Process` cmdlet

````powershell
Get-Process -Name Aac3572DramHal_x86 | Get-Member -MemberType Properties


   TypeName : System.Diagnostics.Process

Name                       MemberType     Definition                                                                         
----                       ----------     ----------                                                                         
Handles                    AliasProperty  Handles = Handlecount                                                              
Name                       AliasProperty  Name = ProcessName                                                                 
NPM                        AliasProperty  NPM = NonpagedSystemMemorySize64                                                   
PM                         AliasProperty  PM = PagedMemorySize64                                                             
SI                         AliasProperty  SI = SessionId                                                                     
VM                         AliasProperty  VM = VirtualMemorySize64                                                           
WS                         AliasProperty  WS = WorkingSet64                                                                  
__NounName                 NoteProperty   string __NounName=Process                                                          
BasePriority               Property       int BasePriority {get;}                                                            
Container                  Property       System.ComponentModel.IContainer Container {get;}                                  
EnableRaisingEvents        Property       bool EnableRaisingEvents {get;set;}                                                
ExitCode                   Property       int ExitCode {get;}                                                                
ExitTime                   Property       datetime ExitTime {get;}                                                           
Handle                     Property       System.IntPtr Handle {get;}                                                        
HandleCount                Property       int HandleCount {get;}                                                             ````
HasExited                  Property       bool HasExited {get;}                                                              
Id                         Property       int Id {get;}                                                                      
MachineName                Property       string MachineName {get;}                                                          
MainModule                 Property       System.Diagnostics.ProcessModule MainModule {get;}                                 
MainWindowHandle           Property       System.IntPtr MainWindowHandle {get;}                                              
MainWindowTitle            Property       string MainWindowTitle {get;}                                                      
MaxWorkingSet              Property       System.IntPtr MaxWorkingSet {get;set;}                                             
MinWorkingSet              Property       System.IntPtr MinWorkingSet {get;set;}                                             
Modules                    Property       System.Diagnostics.ProcessModuleCollection Modules {get;}                          
NonpagedSystemMemorySize   Property       int NonpagedSystemMemorySize {get;}                                                
NonpagedSystemMemorySize64 Property       long NonpagedSystemMemorySize64 {get;}                                             
PagedMemorySize            Property       int PagedMemorySize {get;}                                                         
PagedMemorySize64          Property       long PagedMemorySize64 {get;}                                                      
PagedSystemMemorySize      Property       int PagedSystemMemorySize {get;}                                                   
PagedSystemMemorySize64    Property       long PagedSystemMemorySize64 {get;}                                                
PeakPagedMemorySize        Property       int PeakPagedMemorySize {get;}                                                     
PeakPagedMemorySize64      Property       long PeakPagedMemorySize64 {get;}                                                  
PeakVirtualMemorySize      Property       int PeakVirtualMemorySize {get;}                                                   
PeakVirtualMemorySize64    Property       long PeakVirtualMemorySize64 {get;}                                                
PeakWorkingSet             Property       int PeakWorkingSet {get;}                                                          
PeakWorkingSet64           Property       long PeakWorkingSet64 {get;}                                                       
PriorityBoostEnabled       Property       bool PriorityBoostEnabled {get;set;}                                               
PriorityClass              Property       System.Diagnostics.ProcessPriorityClass PriorityClass {get;set;}                   
PrivateMemorySize          Property       int PrivateMemorySize {get;}                                                       
PrivateMemorySize64        Property       long PrivateMemorySize64 {get;}                                                    
PrivilegedProcessorTime    Property       timespan PrivilegedProcessorTime {get;}                                            
ProcessName                Property       string ProcessName {get;}                                                          
ProcessorAffinity          Property       System.IntPtr ProcessorAffinity {get;set;}                                         
Responding                 Property       bool Responding {get;}                                                             
SafeHandle                 Property       Microsoft.Win32.SafeHandles.SafeProcessHandle SafeHandle {get;}                    
SessionId                  Property       int SessionId {get;}                                                               
Site                       Property       System.ComponentModel.ISite Site {get;set;}                                        
StandardError              Property       System.IO.StreamReader StandardError {get;}                                        
StandardInput              Property       System.IO.StreamWriter StandardInput {get;}                                        
StandardOutput             Property       System.IO.StreamReader StandardOutput {get;}                                       
StartInfo                  Property       System.Diagnostics.ProcessStartInfo StartInfo {get;set;}                           
StartTime                  Property       datetime StartTime {get;}                                                          
SynchronizingObject        Property       System.ComponentModel.ISynchronizeInvoke SynchronizingObject {get;set;}            
Threads                    Property       System.Diagnostics.ProcessThreadCollection Threads {get;}                          
TotalProcessorTime         Property       timespan TotalProcessorTime {get;}                                                 
UserProcessorTime          Property       timespan UserProcessorTime {get;}                                                  
VirtualMemorySize          Property       int VirtualMemorySize {get;}                                                       
VirtualMemorySize64        Property       long VirtualMemorySize64 {get;}                                                    
WorkingSet                 Property       int WorkingSet {get;}                                                              
WorkingSet64               Property       long WorkingSet64 {get;}                                                           
Company                    ScriptProperty System.Object Company {get=$this.Mainmodule.FileVersionInfo.CompanyName;}          
CPU                        ScriptProperty System.Object CPU {get=$this.TotalProcessorTime.TotalSeconds;}                     
Description                ScriptProperty System.Object Description {get=$this.Mainmodule.FileVersionInfo.FileDescription;}  
FileVersion                ScriptProperty System.Object FileVersion {get=$this.Mainmodule.FileVersionInfo.FileVersion;}      
Path                       ScriptProperty System.Object Path {get=$this.Mainmodule.FileName;}                                
Product                    ScriptProperty System.Object Product {get=$this.Mainmodule.FileVersionInfo.ProductName;}          
ProductVersion             ScriptProperty System.Object ProductVersion {get=$this.Mainmodule.FileVersionInfo.ProductVersion;}
````
Yes, we have a property called `Name` that give us the information requested.

## 3 - Let's put these cmdlets together using the pipeline

````powershell
$Query = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' -and $_.RemoteAddress -ne "127.0.0.1" } | ForEach-Object {
    $ProcessId = $_.OwningProcess
    [PSCustomObject]@{
        ProcessName    = (Get-Process -Id $ProcessId -ErrorAction SilentlyContinue).Name
        #ProcessPath    = $Process.Path
        LocalAddress   = $_.LocalAddress
        LocalPort      = $_.LocalPort
        RemoteAddress  = $_.RemoteAddress
        RemotePort     = $_.RemotePort
        State          = $_.State
    }
}
````

the output will be like the following

````powershell
$query

ProcessName   : firefox
LocalAddress  : 192.168.0.20
LocalPort     : 62466
RemoteAddress : 162.159.61.4
RemotePort    : 443
State         : Established

ProcessName   : OneDrive
LocalAddress  : 192.168.0.20
LocalPort     : 58710
RemoteAddress : 20.199.120.151
RemotePort    : 443
State         : Established
...
````
## 4 - Improving the output

Like always with powershell, everything is object (in this case, a collection of objects).

We could have different outputs : Console, or file (.txt, .csv, .html, .xlsx, .json, ...). This is the reason why I previously put the result in a variable.

<span style="color:green;font-weight:700;font-size:20px">[Point d'attention]</span> : There is little point in exporting to a .txt file because not only does it provides a basic presentation, but it's also generally not usable for later use. This is done via the `Out-File` cmdlet.

 ````powershell
$Query | Out-File -FilePath c:\temp\tcpConnections.txt
````

### 4.1 - Output in the console

````powershell
 $query | Format-Table -AutoSize

ProcessName LocalAddress LocalPort RemoteAddress   RemotePort       State
----------- ------------ --------- -------------   ----------       -----
firefox     192.168.0.20     62466 162.159.61.4           443 Established
OneDrive    192.168.0.20     58710 20.199.120.151         443 Established
svchost     192.168.0.20     57025 1.1.1.1                443 Established
firefox     192.168.0.20     57019 142.250.179.68         443 Established
firefox     192.168.0.20     56976 52.202.14.178          443 Established
...
````

### 4.2 - Output in a .csv file

This is done via the `Export-Csv` cmdlet.
````powershell
$Query|Export-csv -Path c:\temp\TCPConnections.csv
````

The file is, however, raw, without enrichment, which can be a shame for a report.


### 4.3 - Exporting to a .json file

this could be accomplished using successively the `ConvertTo-Json` cmdlet (from the ***Microsoft.PowerShell.Utility*** Powershell module) and the `Out-File` cmdlet (from the ***Microsoft.PowerShell.Utility Powershell*** module too).

````powershell
$Query|ConvertTo-Json | Out-File -FilePath C:\temp\TCPConnections.json
````

the output is like the following : 
````powershell
[
    {
        "ProcessName":  "firefox",
        "LocalAddress":  "192.168.0.20",
        "LocalPort":  62466,
        "RemoteAddress":  "162.159.61.4",
        "RemotePort":  443,
        "State":  5
    },
    {
        "ProcessName":  "OneDrive",
        "LocalAddress":  "192.168.0.20",
        "LocalPort":  58710,
        "RemoteAddress":  "20.199.120.151",
        "RemotePort":  443,
        "State":  5
    },
...
````
### 4.4 - Export to a .html file

this could be accomplished using successively the `CinvertTo-Html` cmdlet (from the ***Microsoft.PowerShell.Utility*** Powershell module) and the `Out-File` cmdlet (from the ***Microsoft.PowerShell.Utility Powershell*** module too).

````powershell
$Query |ConvertTo-html | Out-File -FilePath c:\temp\TCPConnections.html
````
In this case, the output file is really basic, without enrichment. It's possible to enrich the output using a internal css. Let's do it.

````powershell
#region Define CSS style
$css = @"
<Style>
h1, h5, th { text-align: center; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</Style>
"@
#endregion
#region Export the result in a beautiful html page
$Query | ConvertTo-Html -Head $css | Out-File -FilePath c:\temp\TCPConnections.html
````
Of course, we could have a .html file with a better presentation. The PS Module called **PSWriteHTML** (available on the PS Gallery) could do this.

Example

````powershell
New-HTML -FilePath C:\temp\TCPConnections.html -Online -ShowHTML {
    New-HTMLSection -HeaderText "TCP Connections Established at $(Get-Date)" {
        New-HTMLTable -DataTable $query {
            New-TableContent -ColumnName ProcessName, LocalAddress, LocalPort, RemoteAddress, RemotePort, State -Alignment center
            New-TableContent -ColumnName ProcessName   -Alignment center -Color white -BackGroundColor Green
        } #end-newhtmltable
    } #end Newhtmlsection
}
````
Nice isn't it, but we could also add conditional formatting

````powershell
New-HTML -FilePath C:\temp\TCPConnections.html -Online -ShowHTML {
    New-HTMLSection -HeaderText "TCP Connections Established at $(Get-Date)" {
        New-HTMLTable -DataTable $query {
            New-TableContent -ColumnName ProcessName, LocalAddress, LocalPort, RemoteAddress, RemotePort, State -Alignment center
            New-TableContent -ColumnName ProcessName   -Alignment center -Color white -BackGroundColor Green
            New-HTMLTableCondition -Name ProcessName -Operator eq -ComparisonType string -Value "Firefox" -color blue -BackgroundColor orange
        } #end-newhtmltable
    } #end Newhtmlsection
}
````

<span style="color:green;font-weight:700;font-size:20px">[Nota]</span> : The different columns are sortable (like in a .xlsx file). You have also somme capabilities like Exporting to Excel, in a .csv file or .pdf file, advanced filtering, and many other things like collapsing the tab using the parameter `-CanCollapse`. There are lot of sample on the module [Github site](https://github.com/EvotecIT/PSWriteHTML).

````powershell
New-HTML -FilePath C:\temp\TCPConnections.html -Online -ShowHTML {
    New-HTMLSection -HeaderText "TCP Connections Established at $(Get-Date)" -CanCollapse {
        New-HTMLTable -DataTable $query {
            New-TableContent -ColumnName ProcessName, LocalAddress, LocalPort, RemoteAddress, RemotePort, State -Alignment center
            New-TableContent -ColumnName ProcessName   -Alignment center -Color white -BackGroundColor Green
            New-HTMLTableCondition -Name ProcessName -Operator eq -ComparisonType string -Value "Firefox" -color blue -BackgroundColor orange
        } #end-newhtmltable
    } #end Newhtmlsection
}
````

### 4.5 - Export to a .xlsx file

As you probably know, a .xlsx file is not a raw file, but a a proprietary file format. The simplest way to do this is to use the **ImportExcel** Module. No need to have MS Excel installed (this is often the case in servers), beautiful exports and so on. 

Let's do a sample

````Powershell
Query | Export-Excel -Path c:\temp\TCPConnections.xlsx -WorksheetName "TCP Connections" -AutoSize -FreezeTopRowFirstColumn -AutoFilter -TableStyle Medium2 -Show
````
This is a very long command line, using a splat for a more readable presentation is the way.

````powershell
$ExportParams = @{
    Path                    = 'c:\temp\TCPConnections.xlsx'
    WorksheetName           = 'TCP Connections'
    AutoSize                = $true
    FreezeTopRowFirstColumn = $true
    AutoFilter              = $true
    TableStyle              = 'Medium2'
    Show                    = $true
}

$Query | Export-Excel @ExportParams
````

Of course, there are lot of parameter to enrich the .xlsx file like conditional formatting, Pivot Table and so on. See the Examples on the module [Github Site](https://github.com/dfinke/ImportExcel).

## 4.5 - Final Words

This concludes this overview. Your turn to play.












