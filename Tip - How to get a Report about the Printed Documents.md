# How to get a Report about the Printed Documents

On each comptuter there is a Windows log called **'Microsoft-Windows-PrintService/Operational'**. This log file is - by default - not enabled, then first ensure that it's enabled and adjust the LogSize as needed.

## Let's do this with Powershell

````powershell
# Parameters
param(
    [string]$ComputerName = $env:COMPUTERNAME, # Replace with the name of your print server
    [DateTime]$StartTime = (Get-Date).AddDays(-7), # Time period: last 7 days, adjust to your need
    [DateTime]$EndTime = $(Get-Date) # Until now
)

# Get event logs
$AllEvents = Get-WinEvent -ComputerName $ComputerName -FilterHashtable @{
    LogName   = 'Microsoft-Windows-PrintService/Operational' # Event log name
    StartTime = $StartTime
    EndTime   = $EndTime
    ID        = 307 # Event ID for a completed print job
}

# Create the report
$Report = foreach ($event in $AllEvents)
{
    # Extract XML event details
    $xml = [xml]$event.ToXml()
    $EventData = $xml.Event.UserData.DocumentPrinted

    # Create a custom object for each event
    [PSCustomObject]@{
        Time       = $Event.TimeCreated
        User       = $EventData.Param3
        Server     = $($EventData.Param4).replace('\\', '')
        Printer    = $EventData.Param5
        SizeInKb   = [Math]::Round( $EventData.Param7 / 1KB)
        NbPages    = $EventData.Param8
    }
}

# Display the report in the console
$Report | Format-Table

# Or better export it in a .Csv file
$report | Export-Csv -Path C:\Temp\PrintReport.csv -Delimiter ';' -Encoding UTF8 -NoTypeInformation
````

## About the code

As you can see, I'm using a `-FilterhashTable` with the `Get-WinEvent cmdlet`. This way is quick, efficient and easily understandable. 

You can also see that I transform each event to the `[XML]` type. The reason will be obvious, when you'll see the following


````Powershell
$xml

Event
-----
Event

# Let's go down to the tree
$xml.Event

xmlns                                                 System UserData
-----                                                 ------ --------
http://schemas.microsoft.com/win/2004/08/events/event System UserData


# let go down to UserData
$xml.Event.UserData

DocumentPrinted
---------------
DocumentPrinted

# And now let's go down to DocumentPrinted
$xml.Event.UserData.DocumentPrinted

xmlns  : http://manifests.microsoft.com/win/2005/08/windows/printing/spooler/core/events
Param1 : 2
Param2 : Imprimer le document
Param3 : administrateur
Param4 : \\DC01
Param5 : Microsoft Print to PDF
Param6 : C:\Users\Administrateur\Desktop\PrintDoc.pdf
Param7 : 114455
Param8 : 1
````

When I'm building a `PSCustomObject`, I'm calling the interresting properties by their Name and finally store the result in the var `$Report`. Of course, `$Report` is a collection of objects (as always with Powershell), and it's easy to export it to a file. A .csv file is the easy way, but you could also choose to export in another file format (eg. export to MS Excel - without to have Excel installed on your computer - using the PS Module called **PSWriteExcel**).


## Quick check if the 'Microsoft-Windows-PrintService/Operational' log is enabled

````powershell
$LogName   = 'Microsoft-Windows-PrintService/Operational'
$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
# identify properties
$Log | Select-Object -Property *

FileSize                       : 69632
IsLogFull                      : False
LastAccessTime                 : 23/07/2024 09:01:49
LastWriteTime                  : 23/07/2024 09:01:49
OldestRecordNumber             : 1
RecordCount                    : 5
LogName                        : Microsoft-Windows-PrintService/Operational
LogType                        : Operational
LogIsolation                   : Application
IsEnabled                      : True
IsClassicLog                   : False
SecurityDescriptor             : O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0x2;;;S-1-15-3-1024-3153509613-960666767-3724611135-2725662640-12138253-543910227-1950414635-4190290187)(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x
                                 7;;;SO)(A;;0x3;;;IU)(A;;0x3;;;SU)(A;;0x3;;;S-1-5-3)(A;;0x3;;;S-1-5-33)(A;;0x1;;;S-1-5-32-573)
LogFilePath                    : %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-PrintService%4Operational.evtx
MaximumSizeInBytes             : 1052672
LogMode                        : Circular
OwningProviderName             : Microsoft-Windows-PrintService
ProviderNames                  : {Microsoft-Windows-PrintService}
ProviderLevel                  : 
ProviderKeywords               : 
ProviderBufferSize             : 64
ProviderMinimumNumberOfBuffers : 0
ProviderMaximumNumberOfBuffers : 64
ProviderLatency                : 1000
ProviderControlGuid            : 

# Check if enabled
$Log.IsEnabled
True

# Check Size
$Log.MaximumSizeInBytes
1052672
````

Hope this help