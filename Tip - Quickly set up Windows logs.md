# Quickly set up Windows logs

## Introduction
In this now [old article](https://4sysops.com/archives/managing-event-logs-with-powershell-part-1/#comment-1255920), the respectable Jeffery Hicks describes a method to configure Windows logs.
While this method is quite valid, it nevertheless has several drawbacks nowadays:
- It uses the `Get-EventLog`, `Set-EventLog` and `Limit-Eventlog` cmdlets (from the *Microsoft.PowerShell.Management* module) but the 3 cmdlets used can only configure "standard" logs and not all available logs.
- In another approach, Jeffery uses the `Get-WMIObject` cmdlet and this cmdlet is deprecated (use instead `Get-CimInstance`), and the class called *Win32_NTEventlogfile*. This class also limits to standard logs.
````Powershell
Get-CimInstance -ClassName Win32_NTEventlogfile

 FileSize LogfileName                          Name    NumberOfRecords
 -------- -----------                          ----    ---------------
 20975616 Application                          C:\WINDOWS\System32\Winevt\Logs\Application.evtx                          36737
    69632 HardwareEvents                       C:\WINDOWS\System32\Winevt\Logs\HardwareEvents.evtx                           0
    69632 Internet Explorer                    C:\WINDOWS\System32\Winevt\Logs\Internet Explorer.evtx                        0
    69632 Key Management Service               C:\WINDOWS\System32\Winevt\Logs\Key Management Service.evtx                   0
  1118208 Microsoft-ServerManagementExperience C:\WINDOWS\System32\Winevt\Logs\Microsoft-ServerManagementExperience.evtx  2252
  1052672 OAlerts                              C:\WINDOWS\System32\Winevt\Logs\OAlerts.evtx                                659
    69632 Parameters                           C:\WINDOWS\System32\Winevt\Logs\Parameters.evtx                               0
204804096 Security                             C:\WINDOWS\System32\Winevt\Logs\Security.evtx                            201002
    69632 State                                C:\WINDOWS\System32\Winevt\Logs\State.evtx                                    0
 20975616 System                               C:\WINDOWS\System32\Winevt\Logs\System.evtx                               40128
    69632 Visual Studio                        C:\WINDOWS\System32\Winevt\Logs\Visual Studio.evtx                            0
 26284032 Windows PowerShell                   C:\WINDOWS\System32\Winevt\Logs\Windows PowerShell.evtx                    7136
 ````


>[Nota : ] The "Standards" Event Logs are the following :
>
> ````Powershell
>Get-EventLog -LogName *
>
>  Max(K) Retain OverflowAction        Entries Log
>  ------ ------ --------------        ------- ---
>  20 480      0 OverwriteAsNeeded      36 732 Application
>  20 480      0 OverwriteAsNeeded           0 HardwareEvents
>     512      7 OverwriteOlder              0 Internet Explorer
>  20 480      0 OverwriteAsNeeded           0 Key Management Service
>  15 168      7 OverwriteOlder          2 252 Microsoft-ServerManagementExperience
>     128      0 OverwriteAsNeeded         659 OAlerts
> 200 000      0 OverwriteAsNeeded     200 813 Security
>  20 480      0 OverwriteAsNeeded      40 128 System
>     512      7 OverwriteOlder              0 Visual Studio
>  32 768      0 OverwriteAsNeeded       7 039 Windows PowerShell
>  ````

However the `Get-WinEvent` cmdlet can return all log files.


````powershell
Get-WinEvent -ListLog *

LogMode   MaximumSizeInBytes RecordCount LogName
-------   ------------------ ----------- -------
Circular            33554432        7087 Windows PowerShell
Circular             1052672           0 Visual Studio
Circular            20971520       40128 System
Circular           204800000      200903 Security
Circular             1052672         659 OAlerts
Circular            15532032        2252 Microsoft-ServerManagementExperience
Circular            20971520           0 Key Management Service
Circular             1052672           0 Internet Explorer
Circular            20971520           0 HardwareEvents
Circular            20971520       36736 Application
Circular             1052672             Windows Networking Vpn Plugin Platform/OperationalVerbose
Circular             1052672             Windows Networking Vpn Plugin Platform/Operational
Circular             1052672           0 SMSApi
Circular             1052672         361 Setup
Circular            15728640        3415 PowerShellCore/Operational
Circular             1052672           0 OpenSSH/Operational
Circular             1052672           0 OpenSSH/Admin
Circular             1052672             Network Isolation Operational
Circular             1052672           0 Microsoft-WindowsPhone-Connectivity-WiFiConnSvc-Channel
Circular             1052672             Microsoft-Windows-ZTraceMaps/Operational
Circular             1052672           0 Microsoft-Windows-WWAN-SVC-Events/Operational
Circular             1052672        2337 Microsoft-Windows-WPD-MTPClassDriver/Operational
Circular             1052672           0 Microsoft-Windows-WPD-CompositeClassDriver/Operational
Circular             1052672           1 Microsoft-Windows-WPD-ClassInstaller/Operational
Circular             1052672           0 Microsoft-Windows-Workplace Join/Admin
Circular             1052672           0 Microsoft-Windows-WorkFolders/WHC
Circular             1052672           0 Microsoft-Windows-WorkFolders/Operational
Circular             1052672             Microsoft-Windows-Wordpad/Admin
Circular             1052672           0 Microsoft-Windows-WMPNSS-Service/Operational
Circular             1052672        1306 Microsoft-Windows-WMI-Activity/Operational
Circular             1052672             Microsoft-Windows-wmbclass/Trace
Circular             1052672          75 Microsoft-Windows-WLAN-AutoConfig/Operational
Circular             1052672           0 Microsoft-Windows-Wired-AutoConfig/Operational
Circular             1052672           0 Microsoft-Windows-Winsock-WS2HELP/Operational
Circular             1052672             Microsoft-Windows-Winsock-NameResolution/Operational
Circular             1052672             Microsoft-Windows-Winsock-AFD/Operational
Circular            10223616       23690 Microsoft-Windows-WinRM/Operational
Circular             1052672             Microsoft-Windows-WinNat/Oper
Circular             1052672        2570 Microsoft-Windows-Winlogon/Operational
Circular             1052672           0 Microsoft-Windows-WinINet/Operational
Circular             1052672           1 Microsoft-Windows-WinINet-Config/ProxyConfigChanged
Circular             1052672             Microsoft-Windows-WinINet-Capture/Analytic
Circular             1052672           0 Microsoft-Windows-WinHttp/Operational
Circular             1052672             Microsoft-Windows-WinHTTP-NDF/Diagnostic
Circular             1052672        2073 Microsoft-Windows-WindowsUpdateClient/Operational
Circular             1052672             Microsoft-Windows-WindowsUIImmersive/Operational
Circular             1052672         513 Microsoft-Windows-WindowsSystemAssessmentTool/Operational
Circular             1052672             Microsoft-Windows-WindowsColorSystem/Operational
Circular             1052672           0 Microsoft-Windows-WindowsBackup/ActionCenter
Circular             1052672             Microsoft-Windows-Windows Firewall With Advanced Security/FirewallVerbose
Circular             1052672           4 Microsoft-Windows-Windows Firewall With Advanced Security/FirewallDiagnostics
Circular             1052672        1126 Microsoft-Windows-Windows Firewall With Advanced Security/Firewall
Circular             1052672             Microsoft-Windows-Windows Firewall With Advanced Security/ConnectionSecurityVerbose
Circular             1052672           0 Microsoft-Windows-Windows Firewall With Advanced Security/ConnectionSecurity
Circular             1052672           0 Microsoft-Windows-Windows Defender/WHC
Circular            16777216       17508 Microsoft-Windows-Windows Defender/Operational
Circular             1052672        1634 Microsoft-Windows-Win32k/Operational
Circular             1052672          19 Microsoft-Windows-WFP/Operational
Circular             1052672         103 Microsoft-Windows-WerKernel/Operational
Circular             1052672         520 Microsoft-Windows-WER-PayloadHealth/Operational
Circular             1052672         238 Microsoft-Windows-WER-Diag/Operational
Circular             1052672             Microsoft-Windows-WEPHOSTSVC/Operational
Circular             1052672           0 Microsoft-Windows-WebIO/Operational
Circular             1052672             Microsoft-Windows-WebIO-NDF/Diagnostic
Circular             5242880       12955 Microsoft-Windows-WebAuthN/Operational
Circular             1052672             Microsoft-Windows-WebAuth/Operational
Circular             1052672           0 Microsoft-Windows-WDAG-PolicyEvaluator-GP/Operational
Circular             1052672           0 Microsoft-Windows-WDAG-PolicyEvaluator-CSP/Operational
Circular             1052672        2650 Microsoft-Windows-Wcmsvc/Operational
Circular             1052672           0 Microsoft-Windows-VPN/Operational
Circular             1052672           0 Microsoft-Windows-VPN-Client/Operational
Circular             1052672        1977 Microsoft-Windows-VolumeSnapshot-Driver/Operational
Circular             1052672           0 Microsoft-Windows-Volume/Diagnostic
Circular             1052672        1735 Microsoft-Windows-VHDMP-Operational
Circular             1052672             Microsoft-Windows-VerifyHardwareSecurity/Operational
Circular             1052672           0 Microsoft-Windows-VerifyHardwareSecurity/Admin
Circular             1052672           0 Microsoft-Windows-VDRVROOT/Operational
Circular             1052672         680 Microsoft-Windows-UserSettingsBackup-Orchestrator/Operational
Circular             1052672           0 Microsoft-Windows-UserSettingsBackup-EarlyDownloader/Operational
Circular             1052672           0 Microsoft-Windows-UserSettingsBackup-BackupUnitProcessor/Operational
Circular             1052672        2079 Microsoft-Windows-UserPnp/DeviceInstall
Circular             1052672           0 Microsoft-Windows-UserPnp/ActionCenter
Circular             1052672           0 Microsoft-Windows-User-Loader/Operational
Circular             4194304        3557 Microsoft-Windows-User Profile Service/Operational
Circular             1052672         539 Microsoft-Windows-User Device Registration/Admin
Circular             1052672           0 Microsoft-Windows-User Control Panel/Operational
Circular             1052672         361 Microsoft-Windows-UniversalTelemetryClient/Operational
Circular             1052672           9 Microsoft-Windows-UAC/Operational
Circular             1052672         864 Microsoft-Windows-UAC-FileVirtualization/Operational
Circular             1052672           0 Microsoft-Windows-TZUtil/Operational
Circular             1052672         116 Microsoft-Windows-TZSync/Operational
Circular             1052672        1189 Microsoft-Windows-TWinUI/Operational
Circular             1052672           0 Microsoft-Windows-Troubleshooting-Recommended/Operational
Circular             1052672           0 Microsoft-Windows-Troubleshooting-Recommended/Admin
Circular             1052672         645 Microsoft-Windows-Time-Service/Operational
Circular             1052672           0 Microsoft-Windows-Time-Service-PTP-Provider/PTP-Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-ServerUSBDevices/Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-ServerUSBDevices/Admin
Circular             1052672        1997 Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin
Circular             1052672          77 Microsoft-Windows-TerminalServices-RDPClient/Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-Printers/Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-Printers/Admin
Circular             1052672           0 Microsoft-Windows-TerminalServices-PnPDevices/Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-PnPDevices/Admin
Circular             1052672        1873 Microsoft-Windows-TerminalServices-LocalSessionManager/Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-LocalSessionManager/Admin
Circular             1052672           0 Microsoft-Windows-TerminalServices-ClientUSBDevices/Operational
Circular             1052672           0 Microsoft-Windows-TerminalServices-ClientUSBDevices/Admin
Circular             1052672           0 Microsoft-Windows-TenantRestrictions/Operational
Circular             1052672             Microsoft-Windows-TCPIP/Operational
Circular            10485760             Microsoft-Windows-TaskScheduler/Operational
Circular             1052672        2351 Microsoft-Windows-TaskScheduler/Maintenance
Circular             1052672           0 Microsoft-Windows-SystemSettingsThreshold/Operational
Circular            16777216         976 Microsoft-Windows-Storsvc/Diagnostic
Circular            20000000       23638 Microsoft-Windows-Store/Operational
Circular             1052672           0 Microsoft-Windows-StorageSpaces-SpaceManager/Operational
Circular            16777216           0 Microsoft-Windows-StorageSpaces-SpaceManager/Diagnostic
Circular             1052672           0 Microsoft-Windows-StorageSpaces-Parser/Operational
Circular            16777216           0 Microsoft-Windows-StorageSpaces-Parser/Diagnostic
Circular             1052672           0 Microsoft-Windows-StorageSpaces-ManagementAgent/WHC
Circular             1052672        1218 Microsoft-Windows-StorageSpaces-Driver/Operational
Circular            16777216           0 Microsoft-Windows-StorageSpaces-Driver/Diagnostic
Circular             1052672           0 Microsoft-Windows-StorageSpaces-Api/Operational
Circular            67108864         970 Microsoft-Windows-StorageSettings/Diagnostic
Circular            33554432        1167 Microsoft-Windows-StorageManagement/Operational
Circular             1052672           0 Microsoft-Windows-StorageManagement-PartUtil/Operational
Circular             1052672           0 Microsoft-Windows-Storage-Tiering/Admin
Circular            33554432       25122 Microsoft-Windows-Storage-Storport/Operational
Circular             6291456        1446 Microsoft-Windows-Storage-Storport/Health
Circular             1052672             Microsoft-Windows-Storage-Storport/Admin
Circular            33554432           0 Microsoft-Windows-Storage-NvmeDisk/Operational
Circular             1052672             Microsoft-Windows-Storage-Disk/Operational
Circular             1052672             Microsoft-Windows-Storage-Disk/Admin
Circular             6291456         611 Microsoft-Windows-Storage-ClassPnP/Operational
Circular             1052672             Microsoft-Windows-Storage-ClassPnP/Admin
Circular             1052672             Microsoft-Windows-Storage-ATAPort/Operational
Circular             1052672             Microsoft-Windows-Storage-ATAPort/Admin
Circular             1052672           0 Microsoft-Windows-StateRepository/Restricted
Circular             5242880        9607 Microsoft-Windows-StateRepository/Operational
Circular             1052672           0 Microsoft-Windows-SMBWitnessClient/Informational
Circular             1052672           0 Microsoft-Windows-SMBWitnessClient/Admin
Circular             8388608        3299 Microsoft-Windows-SMBServer/Security
Circular             8388608       18857 Microsoft-Windows-SMBServer/Operational
Circular             8388608           0 Microsoft-Windows-SMBServer/Connectivity
Circular             8388608           0 Microsoft-Windows-SMBServer/Audit
Circular             1052672           0 Microsoft-Windows-SMBDirect/Admin
Circular             8388608        1344 Microsoft-Windows-SmbClient/Security
Circular             8388608           0 Microsoft-Windows-SMBClient/Operational
Circular             8388608       18013 Microsoft-Windows-SmbClient/Connectivity
Circular             8388608           0 Microsoft-Windows-SmbClient/Audit
Circular             1052672             Microsoft-Windows-SmartScreen/Debug
Circular             1052672           0 Microsoft-Windows-SmartCard-TPM-VCard-Module/Operational
Circular             1052672           0 Microsoft-Windows-SmartCard-TPM-VCard-Module/Admin
Circular             1052672           0 Microsoft-Windows-SmartCard-DeviceEnum/Operational
Circular             1052672           0 Microsoft-Windows-SmartCard-Audit/Authentication
Circular             1052672        1171 Microsoft-Windows-ShellCommon-StartLayoutPopulation/Operational
Circular             1052672        2305 Microsoft-Windows-Shell-Core/Operational
Circular             1052672           0 Microsoft-Windows-Shell-Core/LogonTasksChannel
Circular             1052672        1673 Microsoft-Windows-Shell-Core/AppDefaults
Circular             1052672           0 Microsoft-Windows-Shell-Core/ActionCenter
Circular             1052672           0 Microsoft-Windows-Shell-ConnectedAccountState/ActionCenter
Circular             1052672           0 Microsoft-Windows-SettingSync/Operational
Circular             1052672           0 Microsoft-Windows-SettingSync/Debug
Circular             1052672           0 Microsoft-Windows-SettingSync-OneDrive/Operational
Circular             1052672           0 Microsoft-Windows-SettingSync-OneDrive/Debug
Circular             1052672           0 Microsoft-Windows-SettingSync-Azure/Operational
Circular             1052672           0 Microsoft-Windows-SettingSync-Azure/Debug
Circular             1052672             Microsoft-Windows-ServiceReportingApi/Debug
Circular             1052672           8 Microsoft-Windows-ServerManager-MultiMachine/Operational
Circular             1052672           0 Microsoft-Windows-ServerManager-MultiMachine/Admin
Circular             1052672           0 Microsoft-Windows-SenseIR/Operational
Circular             1052672           0 Microsoft-Windows-SENSE/Operational
Circular             1052672           0 Microsoft-Windows-SecurityMitigationsBroker/Operational
Circular             1052672             Microsoft-Windows-SecurityMitigationsBroker/Admin
Circular             1052672           0 Microsoft-Windows-Security-UserConsentVerifier/Audit
Circular             1052672           1 Microsoft-Windows-Security-SPP-UX-Notifications/ActionCenter
Circular             1052672           0 Microsoft-Windows-Security-SPP-UX-GenuineCenter-Logging/Operational
Circular             1052672           0 Microsoft-Windows-Security-Netlogon/Operational
Circular             1052672           0 Microsoft-Windows-Security-Mitigations/UserMode
Circular             1052672         607 Microsoft-Windows-Security-Mitigations/KernelMode
Circular             1052672        1943 Microsoft-Windows-Security-LessPrivilegedAppContainer/Operational
Circular             1052672           0 Microsoft-Windows-Security-Isolation-BrokeringFileSystem/Operational
Circular             1052672             Microsoft-Windows-Security-IdentityListener/Operational
Circular             1052672             Microsoft-Windows-Security-ExchangeActiveSyncProvisioning/Operational
Circular             1052672           0 Microsoft-Windows-Security-EnterpriseData-FileRevocationManager/Operational
Circular             1052672           0 Microsoft-Windows-Security-Audit-Configuration-Client/Operational
Circular             1052672           0 Microsoft-Windows-Security-Adminless/Operational
Circular             1052672             Microsoft-Windows-SecureAssessment/Operational
Circular             1052672           0 Microsoft-Windows-SearchUI/Operational
Circular             1052672             Microsoft-Windows-RRAS/Operational
Circular             1052672           0 Microsoft-Windows-RetailDemo/Operational
Circular             1052672           0 Microsoft-Windows-RetailDemo/Admin
Circular             1052672           0 Microsoft-Windows-RestartManager/Operational
Circular             1052672         305 Microsoft-Windows-Resource-Exhaustion-Resolver/Operational
Circular             1052672        1153 Microsoft-Windows-Resource-Exhaustion-Detector/Operational
Circular             1052672             Microsoft-Windows-Remotefs-Rdbss/Operational
Circular             1052672           0 Microsoft-Windows-RemoteDesktopServices-SessionServices/Operational
Circular             1052672           0 Microsoft-Windows-RemoteDesktopServices-RemoteFX-Synth3dvsc/Admin
Circular             1052672        1580 Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational
Circular             1052672           0 Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Admin
Circular             1052672          72 Microsoft-Windows-RemoteAssistance/Operational
Circular             1052672           0 Microsoft-Windows-RemoteAssistance/Admin
Circular             1052672           0 Microsoft-Windows-RemoteApp and Desktop Connections/Operational
Circular             1052672           0 Microsoft-Windows-RemoteApp and Desktop Connections/Admin
Circular             1052672             Microsoft-Windows-RemoteAccess-MgmtClientPerf/Operational
Circular             1052672           0 Microsoft-Windows-RemoteAccess-MgmtClient/Operational
Circular             1052672           0 Microsoft-Windows-Regsvr32/Operational
Circular            33554432           0 Microsoft-Windows-ReFS/Operational
Circular             1052672           0 Microsoft-Windows-ReadyBoostDriver/Operational
Circular             1052672         504 Microsoft-Windows-ReadyBoost/Operational
Circular             1052672             Microsoft-Windows-RasAgileVpn/Operational
Circular             1052672        1597 Microsoft-Windows-PushNotification-Platform/Operational
Circular             1052672           0 Microsoft-Windows-PushNotification-Platform/Admin
Circular             1052672             Microsoft-Windows-Proximity-Common/Diagnostic
Circular             1052672           0 Microsoft-Windows-Provisioning-Diagnostics-Provider/ManagementService
Circular             1052672           0 Microsoft-Windows-Provisioning-Diagnostics-Provider/AutoPilot
Circular             1052672        1609 Microsoft-Windows-Provisioning-Diagnostics-Provider/Admin
Circular             1052672           0 Microsoft-Windows-Program-Compatibility-Assistant/CompatAfterUpgrade
Circular             1052672             Microsoft-Windows-Program-Compatibility-Assistant/Analytic
Retain             104857600          93 Microsoft-Windows-Privacy-Auditing/Operational
Circular             1052672             Microsoft-Windows-Privacy-Auditing-PermissiveLearningMode/Operational
Circular             1052672          25 Microsoft-Windows-PrintService/Operational
Circular             1052672           8 Microsoft-Windows-PrintService/Admin
Circular             1052672           0 Microsoft-Windows-PrintBRM/Admin
Circular            20971520        5585 Microsoft-Windows-PowerShell/Operational
Retain            1048985600           0 Microsoft-Windows-PowerShell/Admin
Circular             1052672           0 Microsoft-Windows-PowerShell-DesiredStateConfiguration-FileDownloadManager/Operational
Circular             1052672           0 Microsoft-Windows-Policy/Operational
Circular             6291456           0 Microsoft-Windows-PersistentMemory-ScmBus/Operational
Circular             1052672           0 Microsoft-Windows-PersistentMemory-ScmBus/Certification
Circular             6291456           0 Microsoft-Windows-PersistentMemory-PmemDisk/Operational
Circular             6291456           0 Microsoft-Windows-PersistentMemory-Nvdimm/Operational
Circular             1052672        1894 Microsoft-Windows-Perflib/Operational
Circular             1052672           0 Microsoft-Windows-PerceptionSensorDataService/Operational
Circular             1052672           0 Microsoft-Windows-PerceptionRuntime/Operational
Circular            16777216        1587 Microsoft-Windows-Partition/Diagnostic
Circular             1052672           0 Microsoft-Windows-ParentalControls/Operational
Circular             1052672           0 Microsoft-Windows-PackageStateRoaming/Operational
Circular             1052672             Microsoft-Windows-OtpCredentialProvider/Operational
Circular             1052672           0 Microsoft-Windows-OOBE-Machine-DUI/Operational
Circular             1052672             Microsoft-Windows-OneX/Operational
Circular             1052672           0 Microsoft-Windows-OneBackup/Debug
Circular             1052672           0 Microsoft-Windows-OfflineFiles/Operational
Circular             1052672           0 Microsoft-Windows-OcpUpdateAgent/Operational
Circular             1052672           0 Microsoft-Windows-NTLM/Operational
Circular             1052672         512 Microsoft-Windows-Ntfs/WHC
Circular            33554432       17488 Microsoft-Windows-Ntfs/Operational
Circular             1052672           0 Microsoft-Windows-NlaSvc/Operational
Circular             1052672           0 Microsoft-Windows-NetworkProvisioning/Operational
Circular             1052672           0 Microsoft-Windows-NetworkProvider/Operational
Circular             1052672        2122 Microsoft-Windows-NetworkProfile/Operational
Circular             1052672           0 Microsoft-Windows-NetworkLocationWizard/Operational
Circular             1052672             Microsoft-Windows-Network-ExecutionContext/Operational
Circular             1052672           0 Microsoft-Windows-NdisImPlatform/Operational
Circular             1052672             Microsoft-Windows-NDIS/Operational
Circular             1052672        2291 Microsoft-Windows-NCSI/Operational
Circular             1052672         128 Microsoft-Windows-NcdAutoSetup/Operational
Circular             1052672             Microsoft-Windows-Ncasvc/Operational
Circular             1052672          60 Microsoft-Windows-MUI/Operational
Circular             1052672           0 Microsoft-Windows-MUI/Admin
Circular             1052672             Microsoft-Windows-MSPaint/Admin
Circular             1052672           0 Microsoft-Windows-Mprddm/Operational
Circular             1052672             Microsoft-Windows-MosHost/Operational
Circular             1052672           0 Microsoft-Windows-ModernDeployment-Diagnostics-Provider/ManagementService
Circular             1052672           0 Microsoft-Windows-ModernDeployment-Diagnostics-Provider/Diagnostics
Circular             1052672           0 Microsoft-Windows-ModernDeployment-Diagnostics-Provider/Autopilot
Circular             1052672           0 Microsoft-Windows-ModernDeployment-Diagnostics-Provider/Admin
Circular             1052672           0 Microsoft-Windows-Mobile-Broadband-Experience-Parser-Task/Operational
Circular             1052672           0 Microsoft-Windows-MemoryDiagnostics-Results/Debug
Circular             1052672             Microsoft-Windows-MediaFoundation-Performance/SARStreamResource
Circular             1052672             Microsoft-Windows-LSA/Operational
Circular             1052672         489 Microsoft-Windows-LiveId/Operational
Circular             1052672             Microsoft-Windows-LinkLayerDiscoveryProtocol/Operational
Circular            52428800           0 Microsoft-Windows-LAPS/Operational
Circular             1052672         254 Microsoft-Windows-LanguagePackSetup/Operational
Circular             1052672        1975 Microsoft-Windows-Known Folders API Service
Circular             1052672             Microsoft-Windows-KeyboardFilter/Performance
Circular             1052672             Microsoft-Windows-KeyboardFilter/Operational
Circular             1052672           0 Microsoft-Windows-KeyboardFilter/Admin
Circular            33554432        4584 Microsoft-Windows-Kernel-WHEA/Operational
Circular            33554432           0 Microsoft-Windows-Kernel-WHEA/Errors
Circular             1052672           0 Microsoft-Windows-Kernel-WDI/Operational
Circular             1052672           0 Microsoft-Windows-Kernel-StoreMgr/Operational
Circular             1052672        2016 Microsoft-Windows-Kernel-ShimEngine/Operational
Circular             1052672           0 Microsoft-Windows-Kernel-PRM/Operational
Circular             1052672           0 Microsoft-Windows-Kernel-Power/Thermal-Operational
Circular             1052672        1036 Microsoft-Windows-Kernel-PnP/Driver Watchdog
Circular             5242880        9847 Microsoft-Windows-Kernel-PnP/Device Management
Circular             1052672        1410 Microsoft-Windows-Kernel-PnP/Configuration
Circular             1052672          52 Microsoft-Windows-Kernel-LiveDump/Operational
Circular             1052672           0 Microsoft-Windows-Kernel-IO/Operational
Circular             1052672        1398 Microsoft-Windows-Kernel-EventTracing/Admin
Circular             1052672         514 Microsoft-Windows-Kernel-Dump/Operational
Circular             1052672           0 Microsoft-Windows-Kernel-CPU-Starvation/Operational
Circular             1052672         755 Microsoft-Windows-Kernel-Cache/Operational
Circular             1052672        1609 Microsoft-Windows-Kernel-Boot/Operational
Circular             1052672           0 Microsoft-Windows-Kernel-ApphelpCache/Operational
Circular             1052672             Microsoft-Windows-Kerberos/Operational
Circular             1052672           0 Microsoft-Windows-KdsSvc/Operational
Circular             1052672           0 Microsoft-Windows-IPxlatCfg/Operational
Circular             1052672           0 Microsoft-Windows-Iphlpsvc/Operational
Circular             1052672             Microsoft-Windows-IPAM/Operational
Circular             1052672           0 Microsoft-Windows-IPAM/ConfigurationChange
Circular             1052672           0 Microsoft-Windows-IPAM/Admin
Circular             1052672           2 Microsoft-Windows-International-RegionalOptionsControlPanel/Operational
Circular             1052672           0 Microsoft-Windows-IKE/Operational
Circular             1052672           0 Microsoft-Windows-IdCtrls/Operational
Circular             1052672         696 Microsoft-Windows-Hyper-V-Worker-Operational
Circular             1052672        1478 Microsoft-Windows-Hyper-V-Worker-Admin
Circular            33554432        5265 Microsoft-Windows-Hyper-V-VmSwitch-Operational
Circular             1052672           0 Microsoft-Windows-Hyper-V-VID-Admin
Circular             1052672           3 Microsoft-Windows-Hyper-V-StorageVSP-Admin
Circular             1052672        2417 Microsoft-Windows-Hyper-V-Hypervisor-Operational
Circular             1052672        1535 Microsoft-Windows-Hyper-V-Hypervisor-Admin
Circular             1052672             Microsoft-Windows-Hyper-V-Guest-Drivers/Operational
Circular             1052672           0 Microsoft-Windows-Hyper-V-Guest-Drivers/Admin
Circular           134217728       13558 Microsoft-Windows-Hyper-V-Compute-Operational
Circular             1052672         512 Microsoft-Windows-Hyper-V-Compute-Admin
Circular             1052672             Microsoft-Windows-HttpService/Trace
Circular             1052672             Microsoft-Windows-HttpService/Log
Circular             1052672           0 Microsoft-Windows-HotspotAuth/Operational
Circular           105267200           0 Microsoft-Windows-HostGuardianService-Client/Operational
Circular             1052672           0 Microsoft-Windows-HostGuardianService-Client/Admin
Circular             1052672          61 Microsoft-Windows-Host-Network-Service-Operational
Circular             1052672          73 Microsoft-Windows-Host-Network-Service-Admin
Circular             1052672           0 Microsoft-Windows-HomeGroup Provider Service/Operational
Circular             1052672           0 Microsoft-Windows-HomeGroup Listener Service/Operational
Circular             1052672           0 Microsoft-Windows-HomeGroup Control Panel/Operational
Circular             1052672           0 Microsoft-Windows-hidcfu/Operational
Circular             1052672           0 Microsoft-Windows-Help/Operational
Circular             1052672        2239 Microsoft-Windows-HelloForBusiness/Operational
Circular             1052672           0 Microsoft-Windows-Guest-Network-Service-Operational
Circular             1052672           0 Microsoft-Windows-Guest-Network-Service-Admin
Circular             4194304       10110 Microsoft-Windows-GroupPolicy/Operational
Circular             1052672             Microsoft-Windows-glcnd/Admin
Circular             1052672           0 Microsoft-Windows-GenericRoaming/Admin
Circular             1052672          36 Microsoft-Windows-Forwarding/Operational
Circular             4194304           0 Microsoft-Windows-Folder Redirection/Operational
Circular             1052672           0 Microsoft-Windows-FMS/Operational
Circular             1052672           0 Microsoft-Windows-FileServices-ServerManager-EventProvider/Operational
Circular             1052672           0 Microsoft-Windows-FileServices-ServerManager-EventProvider/Admin
Circular             1052672           0 Microsoft-Windows-FileHistory-Engine/BackupLog
Circular             1052672           0 Microsoft-Windows-FileHistory-Core/WHC
Circular             1052672           0 Microsoft-Windows-FederationServices-Deployment/Operational
Circular             1052672           0 Microsoft-Windows-FeatureConfiguration/Operational
Circular             1052672         124 Microsoft-Windows-Fault-Tolerant-Heap/Operational
Circular           104857600             Microsoft-Windows-FailoverClustering-Manager/Tracing
Circular            52428800             Microsoft-Windows-FailoverClustering-Manager/Diagnostic
Circular             1052672           0 Microsoft-Windows-FailoverClustering-Manager/Admin
Circular             1052672           0 Microsoft-Windows-EventCollector/Operational
Circular             1052672             Microsoft-Windows-ESE/Operational
Circular             1052672           0 Microsoft-Windows-EnrollmentWebService/Admin
Circular             1052672           0 Microsoft-Windows-EnrollmentPolicyWebService/Admin
Circular             1052672        1686 Microsoft-Windows-EnhancedStorage-EhStorClass/Operational
Circular             1052672             Microsoft-Windows-Energy-Estimation-Engine/EventLog
Circular             5242880           0 Microsoft-Windows-EFS/Operational
Circular             1052672           0 Microsoft-Windows-EDP-Audit-TCB/Admin
Circular             1052672           0 Microsoft-Windows-EDP-Audit-Regular/Admin
Circular             1052672           0 Microsoft-Windows-EDP-Application-Learning/Admin
Circular             1052672           0 Microsoft-Windows-EapMethods-Ttls/Operational
Circular             1052672           0 Microsoft-Windows-EapMethods-Sim/Operational
Circular             1052672           0 Microsoft-Windows-EapMethods-RasTls/Operational
Circular             1052672           0 Microsoft-Windows-EapMethods-RasChap/Operational
Circular             1052672           3 Microsoft-Windows-EapHost/Operational
Circular             1052672          25 Microsoft-Windows-DxgKrnl-Operational
Circular             1052672           0 Microsoft-Windows-DxgKrnl-Admin
Circular             1052672           0 Microsoft-Windows-DucUpdateAgent/Operational
Circular             1052672           0 Microsoft-Windows-DSC/Operational
Circular             1052672           0 Microsoft-Windows-DSC/Admin
Circular             1052672             Microsoft-Windows-DriverFrameworks-UserMode/Operational
Circular             1052672             Microsoft-Windows-DNS-Client/Operational
Circular             1052672             Microsoft-Windows-DisplayColorCalibration/Operational
Circular             1052672           0 Microsoft-Windows-DiskDiagnosticResolver/Operational
Circular             1052672           0 Microsoft-Windows-DiskDiagnosticDataCollector/Operational
Circular             1052672           0 Microsoft-Windows-DiskDiagnostic/Operational
Circular             1052672           0 Microsoft-Windows-DirectoryServices-Deployment/Operational
Circular             1052672        1239 Microsoft-Windows-Diagnostics-Performance/Operational
Circular             1052672           6 Microsoft-Windows-Diagnostics-Networking/Operational
Circular             1052672          56 Microsoft-Windows-Diagnosis-ScriptedDiagnosticsProvider/Operational
Circular             1052672         300 Microsoft-Windows-Diagnosis-Scripted/Operational
Circular             1052672          70 Microsoft-Windows-Diagnosis-Scripted/Admin
Circular             1052672         409 Microsoft-Windows-Diagnosis-Scheduled/Operational
Circular             1052672          25 Microsoft-Windows-Diagnosis-PLA/Operational
Circular             1052672        1951 Microsoft-Windows-Diagnosis-PCW/Operational
Circular             1052672        1825 Microsoft-Windows-Diagnosis-DPS/Operational
Circular             1052672             Microsoft-Windows-Dhcpv6-Client/Operational
Circular             1052672           0 Microsoft-Windows-Dhcpv6-Client/Admin
Circular             1052672             Microsoft-Windows-Dhcp-Client/Operational
Circular             1052672          29 Microsoft-Windows-Dhcp-Client/Admin
Circular             1052672           0 Microsoft-Windows-DeviceUpdateAgent/Operational
Circular             1052672           0 Microsoft-Windows-DeviceSync/Operational
Circular             1052672         683 Microsoft-Windows-DeviceSetupManager/Operational
Circular             1052672        2202 Microsoft-Windows-DeviceSetupManager/Admin
Circular             1052672           2 Microsoft-Windows-Devices-Background/Operational
Circular             1052672        1714 Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Operational
Circular             1052672           0 Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Autopilot
Circular             1052672        1067 Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin
Circular             1052672           0 Microsoft-Windows-DeviceGuard/Operational
Circular            10485760           0 Microsoft-Windows-Deduplication/Scrubbing
Circular            10485760           0 Microsoft-Windows-Deduplication/Operational
Circular           104857600           0 Microsoft-Windows-Deduplication/Diagnostic
Circular             1052672           0 Microsoft-Windows-DateTimeControlPanel/Operational
Circular             1052672           0 Microsoft-Windows-DataIntegrityScan/CrashRecovery
Circular             1052672           0 Microsoft-Windows-DataIntegrityScan/Admin
Circular             1052672           0 Microsoft-Windows-DAL-Provider/Operational
Circular             1052672        1222 Microsoft-Windows-Crypto-NCrypt/Operational
Circular             1052672           0 Microsoft-Windows-Crypto-NCrypt/CertInUse
Circular             1052672        2093 Microsoft-Windows-Crypto-DPAPI/Operational
Circular             1052672             Microsoft-Windows-Crypto-DPAPI/Debug
Circular             1052672           0 Microsoft-Windows-Crypto-DPAPI/BackUpKeySvc
Circular             1052672           0 Microsoft-Windows-Crashdump/Operational
Circular             1052672           0 Microsoft-Windows-CorruptedFileRecovery-Server/Operational
Circular             1052672           0 Microsoft-Windows-CorruptedFileRecovery-Client/Operational
Circular             1052672           0 Microsoft-Windows-CoreSystem-SmsRouter-Events/Operational
Circular             1052672           0 Microsoft-Windows-CoreApplication/Operational
Circular             1052672           0 Microsoft-Windows-Containers-Wcnfs/Operational
Circular             1052672         512 Microsoft-Windows-Containers-Wcifs/Operational
Circular             1052672           0 Microsoft-Windows-Containers-CCG/Admin
Circular             1052672         512 Microsoft-Windows-Containers-BindFlt/Operational
Circular             1052672           0 Microsoft-Windows-Compat-Appraiser/Operational
Circular             1052672        2408 Microsoft-Windows-CodeIntegrity/Operational
Circular             1052672           0 Microsoft-Windows-ClusterAwareUpdating-Management/Admin
Circular             1052672        2043 Microsoft-Windows-CloudStore/Operational
Circular             1052672         392 Microsoft-Windows-CloudStore/Initialization
Circular            10485760             Microsoft-Windows-CloudStore/Debug
Circular             1052672        1747 Microsoft-Windows-CloudRestoreLauncher/Operational
Circular             8388608           0 Microsoft-Windows-Cleanmgr/Diagnostic
Circular             1052672             Microsoft-Windows-CertPoleEng/Operational
Circular             1052672         113 Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational
Circular             1052672         151 Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational
Circular             1052672             Microsoft-Windows-CertificateServicesClient-CredentialRoaming/Operational
Circular             1052672           0 Microsoft-Windows-CertificateServices-Deployment/Operational
Circular             1052672             Microsoft-Windows-CAPI2/Operational
Circular             1052672           0 Microsoft-Windows-BranchCacheSMB/Operational
Circular             1052672           0 Microsoft-Windows-BranchCache/Operational
Circular             1052672             Microsoft-Windows-Bluetooth-Policy/Operational
Circular             1052672           0 Microsoft-Windows-Bluetooth-MTPEnum/Operational
Circular             1052672             Microsoft-Windows-Bluetooth-Bthmini/Operational
Circular             1052672           0 Microsoft-Windows-Bluetooth-BthLEPrepairing/Operational
Circular             1052672        1432 Microsoft-Windows-Bits-Client/Operational
Circular             1052672             Microsoft-Windows-Bits-Client/Analytic
Circular             1052672             Microsoft-Windows-BitLocker/BitLocker Operational
Circular             1052672        1274 Microsoft-Windows-BitLocker/BitLocker Management
Circular             1052672           0 Microsoft-Windows-BitLocker-DrivePreparationTool/Operational
Circular             1052672           0 Microsoft-Windows-BitLocker-DrivePreparationTool/Admin
Circular             1052672        1311 Microsoft-Windows-Biometrics/Operational
Circular             1052672          25 Microsoft-Windows-BestPractices/Operational
Circular             1052672             Microsoft-Windows-Base-Filtering-Engine-Resource-Flows/Operational
Circular             1052672             Microsoft-Windows-Base-Filtering-Engine-Connections/Operational
Circular             1052672           0 Microsoft-Windows-Backup
Circular             1052672             Microsoft-Windows-BackgroundTransfer-ContentPrefetcher/Operational
Circular             1052672         709 Microsoft-Windows-BackgroundTaskInfrastructure/Operational
Circular             1052672             Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController
Circular             1052672             Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController
Circular             1052672             Microsoft-Windows-Authentication/ProtectedUser-Client
Circular             1052672             Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController
Circular             1052672          12 Microsoft-Windows-Authentication User Interface/Operational
Circular             1052672        1400 Microsoft-Windows-Audio/PlaybackManager
Circular             1052672        1912 Microsoft-Windows-Audio/Operational
Circular             1052672             Microsoft-Windows-Audio/Informational
Circular             1052672             Microsoft-Windows-Audio/GlitchDetection
Circular             1052672           0 Microsoft-Windows-Audio/CaptureMonitor
Circular             1052672             Microsoft-Windows-AssignedAccessBroker/Operational
Circular             1052672           0 Microsoft-Windows-AssignedAccessBroker/Admin
Circular             1052672             Microsoft-Windows-AssignedAccess/Operational
Circular             1052672           0 Microsoft-Windows-AssignedAccess/Admin
Circular             1052672             Microsoft-Windows-ASN1/Operational
Circular             1052672        1834 Microsoft-Windows-AppxPackaging/Operational
Retain               1052672         582 Microsoft-Windows-AppXDeploymentServer/Restricted
Circular             5242880        4849 Microsoft-Windows-AppXDeploymentServer/Operational
Circular             1052672        2248 Microsoft-Windows-AppXDeployment/Operational
Circular             5242880         197 Microsoft-Windows-AppXDeployment-Server/Operational
Circular             5242880        1255 Microsoft-Windows-AppReadiness/Operational
Circular             5242880        8456 Microsoft-Windows-AppReadiness/Admin
Circular             1052672        1564 Microsoft-Windows-AppModel-Runtime/Admin
Circular             1052672           0 Microsoft-Windows-AppLocker/Packaged app-Execution
Circular             1052672           0 Microsoft-Windows-AppLocker/Packaged app-Deployment
Circular             1052672           0 Microsoft-Windows-AppLocker/MSI and Script
Circular             1052672           0 Microsoft-Windows-AppLocker/EXE and DLL
Circular             1052672           0 Microsoft-Windows-Application-Experience/Steps-Recorder
Circular             1052672        1522 Microsoft-Windows-Application-Experience/Program-Telemetry
Circular             1052672           0 Microsoft-Windows-Application-Experience/Program-Inventory
Circular             1052672           0 Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter
Circular             1052672         418 Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant
Circular             1052672           0 Microsoft-Windows-Application Server-Applications/Operational
Circular             1052672           0 Microsoft-Windows-Application Server-Applications/Admin
Circular             1052672           0 Microsoft-Windows-ApplicabilityEngine/Operational
Circular             1052672           0 Microsoft-Windows-AppID/Operational
Circular             1052672           0 Microsoft-Windows-AppHost/Admin
Circular             1052672           0 Microsoft-Windows-AllJoyn/Operational
Circular             1052672           0 Microsoft-Windows-All-User-Install-Agent/Admin
Circular             1052672         296 Microsoft-Windows-AAD/Operational
Circular             1052672           0 Microsoft-User Experience Virtualization-SQM Uploader/Operational
Circular             1052672           0 Microsoft-User Experience Virtualization-IPC/Operational
Circular             1052672           0 Microsoft-User Experience Virtualization-App Agent/Operational
Circular             1052672           0 Microsoft-User Experience Virtualization-Agent Driver/Operational
Circular             1052672           8 Microsoft-System-Diagnostics-DiagnosticInvoker/Operational
Circular             1052672           0 Microsoft-Rdms-UI/Operational
Circular             1052672           0 Microsoft-Rdms-UI/Admin
Circular             1052672             Microsoft-Management-UI/Admin
Circular             1052672        2347 Microsoft-Client-Licensing-Platform/Admin
Circular             1052672           0 Microsoft-Client-License-Flexible-Platform/Admin
Circular            10485760           0 Microsoft-AppV-Client/Virtual Applications
Circular            10485760           0 Microsoft-AppV-Client/Operational
Circular            10485760           0 Microsoft-AppV-Client/Admin
Circular             1052672             Intel-iaLPSS2-GPIO2/Performance
Circular             1052672             Intel-iaLPSS2-GPIO2/Debug
Circular            20971520             ForwardedEvents
````

## Setting up a log file
The first thing to do is to identify the log file to use using the following command line :
````Powershell
Get-WinEvent -ListLog *
````

Once we have identified the name of the log file, we will use the .NET class **[System.Diagnostics.Eventing.Reader.EventLogConfiguration](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.eventing.reader.eventlogconfiguration?view=net-8.0)**

Example : 
````powershell
$logName = "Microsoft-Windows-PowerShell/Operational"
$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration -ArgumentList $logName
$Log.LogMode =  "circular" # Possible values : Circular - AutoBackup - Retain
$log.IsEnabled = $true
$log.MaximumSizeInBytes = 20MB
$log.SaveChanges()
````

## Function to configure an event log
Based on the previous code, we can design a function to do the job.

````Powershell
function Set-EventLogConfig
{
    param (
        [string]$LogName,
        [bool]$Enabled = $true,
        [long]$MaxSizeInBytes = 1GB
    )
    
    try
    {
        $log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $LogName
        $log.IsEnabled = $Enabled
        $log.MaximumSizeInBytes = $MaxSizeInBytes
        $log.SaveChanges()
        Write-Host "Journal '$LogName' configured successfully." -ForegroundColor Green
    }
    catch
    {
        Write-Host "Error setting up log '$LogName': $_" -ForegroundColor Red
    }
}
````

And now we can apply this function to a set of logs.

# List of logs to configure
````Powershell
$logs = @(
    'Microsoft-Windows-PowerShell/Operational',
    'Microsoft-Windows-TaskScheduler/Operational',
    'Microsoft-Windows-DriverFrameworks-UserMode/Operational'
    # Add more logs as needed
)

# Apply the configuration to all logs in the list
foreach ($logName in $logs)
{
    Set-EventLogConfig -LogName $logName -Enabled $true -MaxSizeInBytes 2GB
}

# Verify the configurations
foreach ($logName in $logs)
{
    Get-WinEvent -ListLog $logName | Select-Object LogName, IsEnabled, MaximumSizeInBytes
}
````

><span style="color:green;font-weight:700;font-size:20px">[Attention Point]</span> : All these actions require RunAsAdmin.


## But is the best method?

Not necessarily. The previous code is perfectly functional, you can even consider adapting it in order to apply it remotely to a set of machines but nothing will prevent the desired configuration from being modified in an inappropriate manner later by an administrator or a machine is forgotten.

A GPO is much more efficient for doing this. This is configured here for standard logs : **Computer Configuration > Windows Settings > Security Settings > Event Logs**
Here you can configure settings for standard logs (Application, Security, System):
- Maximum log size
- Retention method (overwrite events if needed, overwrite events older than X days, do not overwrite events)


For more specific logs like *"Microsoft-Windows-PowerShell/Operational"* you will need to use **Registry Configuration**:
- Go to **Computer Configuration > Preferences > Windows Settings > Registry**
- Add a new registry entry

For the PowerShell Operational log, for example:
- *Path*: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PowerShell/Operational
- *Value Name*: Enabled
- *Type*: REG_DWORD
- *Data*: 1 (to enable)

For Size:
- *Value Name*: MaxSize
- *Type*: REG_DWORD
- *Data*: Size in bytes (for example, 1073741824 for 1 GB)

To set the retention type:
- *Value Name*: Retention
- *Type*: REG_DWORD
- *Data*:
  - 0 = Circular (overwrite if necessary)
  - 1 = AutoBackup (archive and delete)
  - 2 = Retain (do not overwrite)

If AutoBackup is used, to set the retention duration:
- *Value Name*: AutoBackupLogFiles
- *Type*: REG_DWORD
- *Data*: Number of days to keep archives


## Important things to keep in mind and last words.
- Changes via GPO are persistent and apply at every start/policy refresh.
- They can be applied to many computers at once.
- Using GPO requires domain administrator rights.
- Changes may take some time to propagate, depending on your policy refresh settings.

The main benefit of using GPOs is the centralization and standardization of configuration in an enterprise environment. However, for quick changes or smaller environments, the PowerShell script we saw earlier can be more flexible and immediate.