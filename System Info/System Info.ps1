<#
.SYNOPSIS
    Collects system information and generates an HTML report.

.DESCRIPTION
    This script collects various system information such as CPU, drive, network, operating system, and system details.
    It then generates an HTML report using the PSWriteHTML module.

.PARAMETER ReportPath
    The path to save the HTML report.
    Default is "C:\temp\SystemInfo-At-$(Get-Date -f 'dd-MM-yyyy').html".

.EXAMPLE
    .\System Info.ps1
    Runs the script to collect system information and generate an HTML report.

.EXAMPLE
    Get-Help .\System Info.ps1 -ShowWindow
    Displays the help file for this script.

.INPUTS
    None

.OUTPUTS
    An HTML report saved to the specified path.

.NOTES
Author : O. FERRIERE (Lee Holmes for the Get-PCSystemTypeName function)
Date   : 09/11/2025
Version: 4.1
Change :
    - v4.1 : 09/11/2025
        * Added function Get-PCSystemTypeName to convert PCSystemType ID to string name.
        * Updated HTML report generation to use PSWriteHTML module.
    - v4.0 : 06/06/2024
        * Initial version of the script by Lee Holmes.
#>
[CmdletBinding()]
param (
    [Parameter(HelpMessage = 'Path to save the HTML report')]
    [String]
    $ReportPath = "C:\temp\SystemInfo-At-$(Get-Date -f 'dd-MM-yyyy').html"
)

#region Creating Watcher
Write-Verbose -Message "Création d'un Watcher pour mesurer le temps d'exécution du script" -Verbose:$VerboseMode
$ScriptWatcher = [System.Diagnostics.Stopwatch]::StartNew()
#endregion Creating Watcher


#region save and set Information Preference
$Old_I_Pref = $InformationPreference
# enable Information output
$InformationPreference = 'Continue'
#endregion save and set Information Preference

#region Function: Get-PCSystemTypeName
<#
.SYNOPSIS
    Converts the PCSystemType integer ID into a string name.

.DESCRIPTION
    Converts the PCSystemType integer ID into a string name.

.PARAMETER PCSystemType
    The integer ID of the PCSystemType.

.EXAMPLE
    Get-PCSystemTypeName -PCSystemType 2
    Returns 'Laptop_Or_Mobile'.

.EXAMPLE
    Get-PCSystemTypeName -PCSystemType 5
    Returns 'SOHO_Server'.

.EXAMPLE
    Get-Help Get-PCSystemTypeName -ShowWindow
    Displays the help file for this function.

.INPUTS
    int
    The PCSystemType integer ID.

.OUTPUTS
    string
    The name of the PCSystemType.

.NOTES
Author : Lee Holmes
Date   : June 2024
#>
function Get-PCSystemTypeName
{
    [CmdletBinding()]
    param
    (
        [Parameter (
            Mandatory,
            Position = 0
        )]
        [int]
        $PCSystemType
    )
    switch ($PCSystemType)
    {
        0
        {
            'Unspecified'; break
        }
        1
        {
            'Desktop'; break
        }
        2
        {
            'Laptop_Or_Mobile'; break
        }
        3
        {
            'Workstation'; break
        }
        4
        {
            'Enterprise_Server'; break
        }
        5
        {
            'SOHO_Server'; break
        }
        6
        {
            'Appliance_PC'; break
        }
        7
        {
            'Performance_Server'; break
        }
        8
        {
            'Maximum'; break
        }
        default
        {
            'Unknown_ID'
        }
    }
}
#endregion Function: Get-PCSystemTypeName

#region >> create ordered dictionaries for system information
Write-Information 'Creating some ordered dictionaries to hold the properties'
$CPUInfo = [ordered]@{}
$DriveInfo = [ordered]@{}
$Net_DomainInfo = [ordered]@{}
$Net_AdapterInfo = [ordered]@{}
$OperatingSystemInfo = [ordered]@{}
$SystemInfo = [ordered]@{}
#endregion >> create ordered dictionaries for system information

#region >> create & fill in the properties
Write-Information 'Starting SysInfo collection ...'
Write-Information '    getting CIM_BIOSElement info ...'
$CIM_BIOS = Get-CimInstance -ClassName CIM_BIOSElement
Write-Information '    getting CIM_Processor info ...'
$CIM_Processor = Get-CimInstance -ClassName CIM_Processor
Write-Information '    getting CIM_PhysicalMemory info ...'
$CIM_PhysicalMemory = Get-CimInstance -ClassName CIM_PhysicalMemory
Write-Information '    getting CIM_ComputerSystem info ...'
$CIM_ComputerSystem = Get-CimInstance -ClassName CIM_ComputerSystem
Write-Information '    getting CIM_OperatingSystem info ...'
$CIM_OperatingSystem = Get-CimInstance -ClassName CIM_OperatingSystem
Write-Information '    getting Win32_TimeZone info ...'
$CIM_TimeZone = Get-CimInstance -ClassName Win32_TimeZone
Write-Information '    getting CIM_LogicalDisk info ...'
$CIM_LogicalDisk = Get-CimInstance -ClassName CIM_LogicalDisk |
    Where-Object { $_.Name -eq $CIM_OperatingSystem.SystemDrive }
Write-Information '    getting CIM_NetworkAdapter & Win32_NetworkAdapterConfiguration info ...'
# this is a regex OR, so put a '|' between each item you want to exclude
#$ExcludedNetAdapterList = 'Npcap|VirtualBox'
$ExcludedNetAdapterList = 'Npcap'
$CIM_NetAdapter = Get-CimInstance -ClassName CIM_NetworkAdapter
$CIM_NetConfig = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration |
    Where-Object {
        $_.IPEnabled -and 
        $_.Description -notmatch $ExcludedNetAdapterList
    }

Write-Information '    collecting CPU info ...'
# these CPU items likely need to be changed for multi-CPU boxes
$CPUInfo.Add('CPU_Name', $CIM_Processor.Name)
$CPUInfo.Add('CPU_Description', $CIM_Processor.Description)
$CPUInfo.Add('CPU_Maker', $CIM_Processor.Manufacturer)
$CPUInfo.Add('CPU_LoadPct', $CIM_Processor.LoadPercentage)
$CPUInfo.Add('CPU_LogicalCoreCount', $CIM_ComputerSystem.NumberOfLogicalProcessors)
$CPUInfo.Add('CPU_SocketCount', $CIM_ComputerSystem.NumberOfProcessors)
$CPUInfo.Add('CPU_SocketDesignation', $CIM_Processor.SocketDesignation)
$CPUInfo.Add('CPU_Speed_Mhz', $CIM_Processor.MaxClockSpeed)

Write-Information '    collecting Drive info ...'
$DriveInfo.Add('Drive_System', $CIM_OperatingSystem.SystemDrive)
$DriveInfo.Add('Drive_System_FreeSpace_GB', '{0:N2}' -f ($CIM_LogicalDisk.FreeSpace / 1GB))
$DriveInfo.Add('Drive_System_FreeSpace_Pct', '{0:N0}' -f (($CIM_LogicalDisk.FreeSpace / $CIM_LogicalDisk.Size) * 100))
$DriveInfo.Add('Drive_System_Size_GB', '{0:N2}' -f ($CIM_LogicalDisk.Size / 1GB))

Write-Information '    collecting Network & Domain info ...'
$Net_DomainInfo.Add('Net_Domain', $CIM_ComputerSystem.Domain)
$Net_DomainInfo.Add('Net_DomainJoined', $CIM_ComputerSystem.PartOfDomain)

Write-Information '    collecting Network Adapter info ...'
foreach ($CNC_Item in $CIM_NetConfig)
{
    $Index = '{0:D2}' -f $CNC_Item.Index
    $Net_AdapterInfo.Add("Net_${Index}_AdapterIndex", $CNC_Item.Index)
    $Net_AdapterInfo.Add("Net_${Index}_AdapterName", $CNC_Item.Description)
    $Net_AdapterInfo.Add("Net_${Index}_AdapterManufacturer", $CIM_NetAdapter[$Index].Manufacturer)
    # using 1e9 instead of 1GB since the NIST uses base 10
    $Net_AdapterInfo.Add("Net_${Index}_AdapterSpeed_Gbit", $CIM_NetAdapter[$Index].Speed / 1e9)

    $DefaultGateway = if ($CNC_Item.DefaultIPGateway -is [array])
    {
        $CNC_Item.DefaultIPGateway[0]
    }
    else
    {
        $Null
    }
    $Net_AdapterInfo.Add("Net_${Index}_DefaultGateway", $DefaultGateway)
    $Net_AdapterInfo.Add("Net_${Index}_DHCP_Enabled", $CNC_Item.DHCPEnabled)
    $Net_AdapterInfo.Add("Net_${Index}_DHCP_Server", $CNC_Item.DHCPServer)
    $Net_AdapterInfo.Add("Net_${Index}_DNS_HostName", $CNC_Item.DNSHostName)

    # on my system the addresses are stored [0]=IPv4, [1]=IPv6
    #    the [ipaddress] conversion fails with ipv6 subnet info
    #    "64" becomes "0.0.0.64" [ipv4] instead of "64" or "::64" [ipv6]
    $Net_AdapterInfo.Add("Net_${Index}_IPv4_Address",
        ([ipaddress[]]$CNC_Item.IPAddress).
        Where({ $_.AddressFamily -eq 'Internetwork' }) -join '; ')
    $Net_AdapterInfo.Add("Net_${Index}_IPv4_AddressSubnet", $CNC_Item.IPSubnet[0])
    $Net_AdapterInfo.Add("Net_${Index}_IPv4_DNS_Servers",
        ([ipaddress[]]$CNC_Item.DNSServerSearchOrder).
        Where({ $_.AddressFamily -eq 'Internetwork' }) -join '; ')

    $Net_AdapterInfo.Add("Net_${Index}_IPv6_Address",
        ([ipaddress[]]$CNC_Item.IPAddress).
        Where({ $_.AddressFamily -eq 'InternetworkV6' }) -join '; ')
    $Net_AdapterInfo.Add("Net_${Index}_IPv6_AddressSubnet", $CNC_Item.IPSubnet[1])
    # IPV6 DNS servers are shown in "ipconfig /all", but not with CIM
    #    so this will be blank on my system
    $Net_AdapterInfo.Add("Net_${Index}_IPv6_DNS_Servers",
        ([ipaddress[]]$CNC_Item.DNSServerSearchOrder).
        Where({ $_.AddressFamily -eq 'InternetworkV6' }) -join '; ')

    $Net_AdapterInfo.Add("Net_${Index}_MAC_Address", $CNC_Item.MACAddress)
}

Write-Information '    collecting Operating System info ...'
$OperatingSystemInfo.Add('OS_Architecture', $CIM_OperatingSystem.OSArchitecture)
$CultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo([int]$CIM_OperatingSystem.OSLanguage)
$OperatingSystemInfo.Add('OS_Language_DisplayName', $CultureInfo.DisplayName)
$OperatingSystemInfo.Add('OS_Language_LCID', $CultureInfo.LCID)
$OperatingSystemInfo.Add('OS_Language_Name', $CultureInfo.Name)
$OperatingSystemInfo.Add('OS_LastBootUpTime', $CIM_OperatingSystem.LastBootUpTime)
$OperatingSystemInfo.Add('OS_TimeZone', $CIM_TimeZone.Caption)
$OperatingSystemInfo.Add('OS_TimeZone_DST_Active', $CIM_ComputerSystem.DaylightInEffect)
$OperatingSystemInfo.Add('OS_TimeZone_Offset', $CIM_TimeZone.Bias)
$OperatingSystemInfo.Add('OS_TimeZone_Offset_Current', $CIM_OperatingSystem.CurrentTimeZone)
$OperatingSystemInfo.Add('OS_Version', $CIM_OperatingSystem.Version)
$OperatingSystemInfo.Add('OS_Version_BuildNumber', $CIM_OperatingSystem.BuildNumber)
$OperatingSystemInfo.Add('OS_Version_Caption', $CIM_OperatingSystem.Caption)
$OperatingSystemInfo.Add('OS_Version_ServicePack', $CIM_OperatingSystem.CSDVersion)
# the original number returned is in KBytes, not Bytes
$OperatingSystemInfo.Add('RAM_Free_GB', [math]::Round($CIM_OperatingSystem.FreePhysicalMemory / 1MB, 2))
# this presumes each RAM bank will run at the same speed - almost certainly true [*grin*] 
$OperatingSystemInfo.Add('RAM_Speed_Mhz', $CIM_PhysicalMemory[0].Speed)
# the original number returned is in Bytes
$OperatingSystemInfo.Add('RAM_Total_GB', [math]::Round($CIM_ComputerSystem.TotalPhysicalMemory / 1GB, 2))

Write-Information '    collecting System info ...'
$SystemInfo.Add('System_Manufacturer', $CIM_ComputerSystem.Manufacturer)
$SystemInfo.Add('System_Model', $CIM_ComputerSystem.Model)
$SystemInfo.Add('System_Name', $CIM_ComputerSystem.Name)
$SystemInfo.Add('System_PCSystemType', $CIM_ComputerSystem.PCSystemType)
$PCSystemTypeName = Get-PCSystemTypeName -PCSystemType $CIM_ComputerSystem.PCSystemType
$SystemInfo.Add('System_PCSystemType_Name', $PCSystemTypeName)
$SystemInfo.Add('System_SerialNumber', $CIM_BIOS.SerialNumber)
$SystemInfo.Add('System_SystemType', $CIM_ComputerSystem.SystemType)
#endregion >> create & fill in the properties

#region Check if addionnal module is installed, if not download
Write-Host 'Check if the PSWriteHtml module is installed' -ForegroundColor Green
if (-not (Get-Module -ListAvailable -Name PSWriteHtml))
{
    # We are performing the installation for the current user; we could just as easily do it for all users on the machine, but to do so, the script would need to be run as "Run As Administrator".
    try
    {
        Write-Host 'The PSWriteHtml module is not installed' -ForegroundColor yellow
        Write-Host 'Downloading and installing ... : ' -ForegroundColor Green -NoNewline
        Install-Module PSWriteHTML -Force -Scope CurrentUser
        Write-Host 'Done' -ForegroundColor Yellow
    }
    catch
    {
        Write-Host 'The module could not be installed. Exiting script.' -ForegroundColor Red
        Write-Host "An error occurred. Error message: $_." -ForegroundColor Red
        break
    }
}
#endregion Check if addionnal module is installed, if not download

#region Import the module to have the available cmdlets
Write-Host 'Import the PSWriteHtml Module ... ' -ForegroundColor Green -NoNewline
Import-Module PSWriteHTML
Write-Host 'Done' -ForegroundColor Yellow
#endregion Import the module to have the available cmdlets

#region Set default behavior for certain cmdlets
Write-Host 'Set default behavior for certain cmdlets: ' -ForegroundColor Green -NoNewline
$PSDefaultParameterValues = @{
    'New-HTML:FilePath'                     = $ReportPath
    'New-HTML:Online'                       = $true
    'New-HTML:ShowHTML'                     = $true
    'New-HTMLTab:CanClose'                  = $true
    'New-HTMLTab:TextSize'                  = 'Medium'
    'New-HTMLSection:HeaderBackGroundColor' = 'Green'
    'New-HTMLSection:CanCollapse'           = $true
    'New-TableContent:Alignment'            = 'Center'
}
Write-Host 'Done' -ForegroundColor Yellow
#endregion Set default behavior for certain cmdlets

#region convert OrderedDictionaries to DataTables
Write-Host 'Converting OrderedDictionaries to DataTables ... ' -ForegroundColor Green -NoNewline
$CPUInfoObj = [PSCustomObject]@{}
$CPUInfo.GetEnumerator() | ForEach-Object {
    $CPUInfoObj | Add-Member -MemberType NoteProperty -Name $_.Key -Value $_.Value
}
$DriveInfoObj = [PSCustomObject]@{}
$DriveInfo.GetEnumerator() | ForEach-Object {
    $DriveInfoObj | Add-Member -MemberType NoteProperty -Name $_.Key -Value $_.Value
}
$Net_DomainInfoObj = [PSCustomObject]@{}
$Net_DomainInfo.GetEnumerator() | ForEach-Object {
    $Net_DomainInfoObj | Add-Member -MemberType NoteProperty -Name $_.Key -Value $_.Value
}
$Net_AdapterInfoObj = [PSCustomObject]@{}
$Net_AdapterInfo.GetEnumerator() | ForEach-Object {
    $Net_AdapterInfoObj | Add-Member -MemberType NoteProperty -Name $_.Key -Value $_.Value
}
$OperatingSystemInfoObj = [PSCustomObject]@{}
$OperatingSystemInfo.GetEnumerator() | ForEach-Object {
    $OperatingSystemInfoObj | Add-Member -MemberType NoteProperty -Name $_.Key -Value $_.Value
}
$SystemInfoObj = [PSCustomObject]@{}
$SystemInfo.GetEnumerator() | ForEach-Object {
    $SystemInfoObj | Add-Member -MemberType NoteProperty -Name $_.Key -Value $_.Value
}
Write-Host 'Done' -ForegroundColor Yellow
#endregion convert OrderedDictionaries to DataTables

#region Create the HTML Report
Write-Host "Creating HTML Report at: $ReportPath" -ForegroundColor Green
New-HTML -Title "System Information Report - $(Get-Date -Format 'dd-MM-yyyy')" {
    # 1st Tab : Hardware Information
    New-HTMLTab -Name 'Hardware Information' {
        New-HTMLSection -HeaderText 'CPU Information' {
            New-HTMLSectionStyle -BorderRadius 0px -HeaderBackGroundColor Grey -RemoveShadow
            New-HTMLTable -DataTable $CPUInfoObj {
                New-TableContent -ColumnName CPU_Name, CPU_Description -Alignment Center -BackGroundColor Green -Color White
                New-TableContent -ColumnName CPU_Maker, CPU_LoadPct, CPU_LogicalCoreCount, CPU_SocketCount, CPU_SocketDesignation, CPU_Speed_Mhz -Alignment Center
            }#end  New-HTMLTable
        } #end New-HTMLSection
    } #end New-HTMLTab

    # 2nd Tab : System Information
    New-HTMLTab -Name 'System Information' {
        New-HTMLSection -HeaderText 'Drive Information' {
            New-HTMLTable -DataTable $DriveInfoObj {
                New-TableContent -ColumnName Drive_System -Alignment Center -BackgroundColor Green -Color White
                New-TableContent -ColumnName Drive_System_FreeSpace_GB, Drive_System_FreeSpace_Pct, Drive_System_Size_GB -Alignment Center
            }#end  New-HTMLTable
        } #end New-HTMLSection
    
        New-HTMLSection -HeaderText 'Network & Domain Information' {
            New-HTMLTable -DataTable $Net_DomainInfoObj {
                New-TableContent -ColumnName Net_Domain -Alignment Center -BackGroundColor Green -Color White
                New-TableContent -ColumnName Net_DomainJoined -Alignment Center
            }#end  New-HTMLTable
        } #end New-HTMLSection
    } #end New-HTMLTab

    # 3rd Tab : Network Adapter Information
    New-HTMLTab -Name 'Network Adapter Information' {
        New-HTMLSection -HeaderText 'Network Adapter Information' {
            New-HTMLTable -DataTable $Net_AdapterInfoObj {
                New-TableContent -ColumnName Net_02_AdapterIndex, Net_02_AdapterName, Net_02_AdapterManufacturer, Net_02_AdapterSpeed_Gbit, Net_02_DefaultGateway, Net_02_DHCP_Enabled, Net_02_DHCP_Server, Net_02_DNS_HostName, Net_02_IPv4_Address -Alignment Center
                New-TableContent -ColumnName Net_02_IPv4_AddressSubnet, Net_02_IPv4_DNS_Servers, Net_02_IPv6_Address, Net_02_IPv6_AddressSubnet, Net_02_IPv6_DNS_Servers, Net_02_MAC_Address, Net_03_AdapterIndex, Net_03_AdapterName, Net_03_AdapterManufacturer -Alignment Center
                New-TableContent -ColumnName Net_03_AdapterSpeed_Gbit, Net_03_DefaultGateway, Net_03_DHCP_Enabled, Net_03_DHCP_Server, Net_03_DNS_HostName, Net_03_IPv4_Address, Net_03_IPv4_AddressSubnet, Net_03_IPv4_DNS_Servers, Net_03_IPv6_Address -Alignment Center
                New-TableContent -ColumnName Net_03_IPv6_AddressSubnet, Net_03_IPv6_DNS_Servers, Net_03_MAC_Address, Net_04_AdapterIndex, Net_04_AdapterName, Net_04_AdapterManufacturer, Net_04_AdapterSpeed_Gbit, Net_04_DefaultGateway, Net_04_DHCP_Enabled -Alignment Center
                New-TableContent -ColumnName Net_04_DHCP_Server, Net_04_DNS_HostName, Net_04_IPv4_Address, Net_04_IPv4_AddressSubnet, Net_04_IPv4_DNS_Servers, Net_04_IPv6_Address, Net_04_IPv6_AddressSubnet, Net_04_IPv6_DNS_Servers, Net_04_MAC_Address -Alignment Center
            }#end  New-HTMLTable
        } #end New-HTMLSection
    } #end New-HTMLTab

    # 4th Tab : Operating System Information
    New-HTMLTab -Name 'Operating System & System Information' {

        New-HTMLSection -HeaderText 'Operating System Information' {
            New-HTMLTable -DataTable $OperatingSystemInfoObj {
                New-TableContent -ColumnName OS_Version_Caption, OS_Architecture, OS_Language_DisplayName, OS_Version -Alignment Center -BackgroundColor Green -Color White
                New-TableContent -ColumnName OS_Architecture, OS_Language_LCI, OS_Language_Name, OS_LastBootUpTime, OS_TimeZone -Alignment Center
                New-TableContent -ColumnName OS_TimeZone_DST_Active, OS_TimeZone_Offset, OS_TimeZone_Offset_Current, OS_Version_BuildNumber -Alignment Center
                New-TableContent -ColumnName OS_Version_ServicePack, RAM_Free_GB, RAM_Speed_Mhz, RAM_Total_GB -Alignment Center
            }#end  New-HTMLTable
        } #end New-HTMLSection

        New-HTMLSection -HeaderText 'System Information' {
            New-HTMLTable -DataTable $SystemInfoObj {
                New-TableContent -ColumnName System_Name -Alignment Center -BackgroundColor Green -Color White
                New-TableContent -ColumnName System_Manufacturer, System_Model, System_PCSystemType, System_PCSystemType_Name, System_SerialNumber, System_SystemType -Alignment Center
            }#end New-HTMLTable
        } #end New-HTMLSection
    } #end New-HTMLTab
    New-HTMLFooter {
        New-HTMLText -Text "Report generated on : $(Get-Date)" -Alignment center -FontWeight bold -Color Green -BackGroundColor WhiteSmoke -FontStyle Italic
    }# End New-htmlFooter
} #end New-HTML

Write-Host 'The HTML Report has been created Successfully at : ' -ForegroundColor Green
Write-Host $ReportPath -ForegroundColor Yellow
#endregion Create the HTML Report

#region Display on console
Write-Information 'Displaying collected information on the console ...'
Write-Information '    CPU Information:'
$CPUInfo | Format-Table -AutoSize
Write-Information '    Drive Information:'
$DriveInfo | Format-Table -AutoSize
Write-Information '    Network Domain Information:'
$Net_DomainInfo | Format-Table -AutoSize
Write-Information '    Network Adapter Information:'
$Net_AdapterInfo | Format-Table -AutoSize
Write-Information '    Operating System Information:'
$OperatingSystemInfo | Format-Table -AutoSize
Write-Information '    System Information:'
$SystemInfo | Format-Table -AutoSize
Write-Information 'System Information collection complete.'
#endregion Display on console

#region Stop the watcher and display execution time
$ScriptWatcher.Stop()
Write-Verbose -Message "Temps d'exécution du script : " -Verbose:$VerboseMode
$Metrics = @{
    'Script Duration' = $ScriptWatcher.Elapsed.Minutes.ToString() + ' minutes, ' + $ScriptWatcher.Elapsed.Seconds.ToString() + ' secondes, ' + $ScriptWatcher.Elapsed.Milliseconds.ToString() + ' millisecondes'
}
$Metrics
#endregion Stop the watcher and display execution time

#region restore the Information Pref and reset variables
Write-Information 'Restoring the Information Preference and cleaning up variables ...'
$InformationPreference = $Old_I_Pref
$CPUInfo = $DriveInfo = $Net_DomainInfo = $Net_AdapterInfo = $OperatingSystemInfo = $SystemInfo = $null

#endregion restore the Information Pref and reset variables

