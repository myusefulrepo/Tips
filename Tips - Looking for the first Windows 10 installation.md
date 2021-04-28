# Looking for the first WIndows 10 installation

You're looking for a way to show the correct OS install date from Windows 10. Sadly, every major update, the "original install date" is overwritten.

The question, and the goal is : How to identify the first installation ?

````Powershell
Get-ChildItem -Path HKLM:\System\Setup\Source*

    Hive: HKEY_LOCAL_MACHINE\System\Setup

Name                           Property
----                           --------
Source OS (Updated on          BuildBranch               : rs4_release
1/18/2019 19:08:54)            BuildGUID                 : ffffffff-ffff-ffff-ffff-ffffffffffff
                               BuildLab                  : 17134.rs4_release.180410-1804
                               BuildLabEx                : 17134.1.amd64fre.rs4_release.180410-1804
                               CompositionEditionID      : Enterprise
                               CurrentBuild              : 17134
                               CurrentBuildNumber        : 17134
                               CurrentMajorVersionNumber : 10
                               CurrentMinorVersionNumber : 0
                               CurrentType               : Multiprocessor Free
                               CurrentVersion            : 6.3
                               DigitalProductId          : {164, 0, 0, 0...}
                               DigitalProductId4         : {248, 4, 0, 0...}
                               EditionID                 : Professional
                               EditionSubManufacturer    :
                               EditionSubstring          :
                               EditionSubVersion         :
                               InstallationType          : Client
                               InstallDate               : 1525936060
                               InstallTime               : 131704096608219832
                               MigrationScope            : 5
                               PathName                  : C:\Windows
                               ProductId                 : 00331-20300-00000-AA251
                               ProductName               : Windows 10 Pro
                               RegisteredOrganization    :
                               RegisteredOwner           : Olivier
                               ReleaseId                 : 1803
                               SoftwareType              : System
                               SystemRoot                : C:\WINDOWS
                               UBR                       : 556
Source OS (Updated on          BuildBranch               : th2_release_sec
5/10/2018 07:33:42)            BuildGUID                 : ffffffff-ffff-ffff-ffff-ffffffffffff
                               BuildLab                  : 10586.th2_release_sec.170913-1848
                               BuildLabEx                : 10586.1176.amd64fre.th2_release_sec.170913-1848
                               CurrentBuild              : 10586
                               CurrentBuildNumber        : 10586
                               CurrentMajorVersionNumber : 10
                               CurrentMinorVersionNumber : 0
                               CurrentType               : Multiprocessor Free
                               CurrentVersion            : 6.3
                               Customizations            : ModernApps
                               DigitalProductId          : {164, 0, 0, 0...}
                               DigitalProductId4         : {248, 4, 0, 0...}
                               EditionID                 : Professional
                               InstallationType          : Client
                               InstallDate               : 1525881876
                               InstallTime               : 131703554765232243
                               MigrationScope            : 5
                               PathName                  : C:\Windows
                               ProductId                 : 00331-20301-98389-AA455
                               ProductName               : Windows 10 Pro
                               RegisteredOrganization    :
                               RegisteredOwner           : Olivier
                               ReleaseId                 : 1511
                               SoftwareType              : System
                               SystemRoot                : C:\Windows
                               UBR                       : 1176
Source OS (Updated on          BuildBranch               : rs3_release_svc_escrow
5/10/2018 08:41:11)            BuildGUID                 : ffffffff-ffff-ffff-ffff-ffffffffffff
                               BuildLab                  : 16299.rs3_release_svc_escrow.180502-1908
                               BuildLabEx                : 16299.431.amd64fre.rs3_release_svc_escrow.180502-1908
                               CompositionEditionID      : Professional
                               CurrentBuild              : 16299
                               CurrentBuildNumber        : 16299
                               CurrentMajorVersionNumber : 10
                               CurrentMinorVersionNumber : 0
                               CurrentType               : Multiprocessor Free
                               CurrentVersion            : 6.3
                               DigitalProductId          : {164, 0, 0, 0...}
                               DigitalProductId4         : {248, 4, 0, 0...}
                               EditionID                 : Professional
                               EditionSubstring          :
                               InstallationType          : Client
                               InstallDate               : 1525933143
                               InstallTime               : 131704067435609704
                               MigrationScope            : 5
                               PathName                  : C:\WINDOWS
                               ProductId                 : 00331-20300-00000-AA832
                               ProductName               : Windows 10 Pro
                               RegisteredOrganization    :
                               RegisteredOwner           : Olivier
                               ReleaseId                 : 1709
                               SoftwareType              : System
                               SystemRoot                : C:\WINDOWS
                               UBR                       : 431
Source OS (Updated on          BuildBranch               : rs5_release
6/1/2019 09:32:35)             BuildGUID                 : ffffffff-ffff-ffff-ffff-ffffffffffff
                               BuildLab                  : 17763.rs5_release.180914-1434
                               BuildLabEx                : 17763.1.amd64fre.rs5_release.180914-1434
                               CompositionEditionID      : Enterprise
                               CurrentBuild              : 17763
                               CurrentBuildNumber        : 17763
                               CurrentMajorVersionNumber : 10
                               CurrentMinorVersionNumber : 0
                               CurrentType               : Multiprocessor Free
                               CurrentVersion            : 6.3
                               DigitalProductId          : {164, 0, 0, 0...}
                               DigitalProductId4         : {248, 4, 0, 0...}
                               EditionID                 : Professional
                               EditionSubManufacturer    :
                               EditionSubstring          :
                               EditionSubVersion         :
                               InstallationType          : Client
                               InstallDate               : 1547838165
                               InstallTime               : 131923117653460962
                               MigrationScope            : 5
                               PathName                  : C:\Windows
                               ProductId                 : 00331-20300-00000-AA425
                               ProductName               : Windows 10 Pro
                               RegisteredOrganization    :
                               RegisteredOwner           : Olivier
                               ReleaseId                 : 1809
                               SoftwareType              : System
                               SystemRoot                : C:\WINDOWS
                               UBR                       : 529
Source OS (Updated on          BaseBuildRevisionNumber   : 1
8/3/2020 09:55:19)             BuildBranch               : 19h1_release
                               BuildGUID                 : ffffffff-ffff-ffff-ffff-ffffffffffff
                               BuildLab                  : 18362.19h1_release.190318-1202
                               BuildLabEx                : 18362.1.amd64fre.19h1_release.190318-1202
                               CompositionEditionID      : Enterprise
                               CurrentBuild              : 18363
                               CurrentBuildNumber        : 18363
                               CurrentMajorVersionNumber : 10
                               CurrentMinorVersionNumber : 0
                               CurrentType               : Multiprocessor Free
                               CurrentVersion            : 6.3
                               DigitalProductId          : {164, 0, 0, 0...}
                               DigitalProductId4         : {248, 4, 0, 0...}
                               EditionID                 : Professional
                               EditionSubManufacturer    :
                               EditionSubstring          :
                               EditionSubVersion         :
                               InstallationType          : Client
                               InstallDate               : 1559377474
                               InstallTime               : 132038510740752025
                               PathName                  : C:\Windows
                               ProductId                 : 00331-20300-00000-AA573
                               ProductName               : Windows 10 Pro
                               RegisteredOrganization    :
                               RegisteredOwner           : Olivier
                               ReleaseId                 : 1909
                               SoftwareType              : System
                               SystemRoot                : C:\WINDOWS
                               UBR                       : 997
                               MigrationScope            : 5
````

Whaooo, lot of informations. Let's try to refine the query

````powershell
Get-ChildItem -Path HKLM:\System\Setup\Source* |
    ForEach-Object {Get-ItemProperty -Path Registry::$_} |
    Select-Object ProductName, ReleaseID, CurrentBuild, @{n="Install Date"; e={([DateTime]'1/1/1970').AddSeconds($_.InstallDate)}} |
    Sort-Object "Install Date"

ProductName    ReleaseId CurrentBuild Install Date
-----------    --------- ------------ ------------
Windows 10 Pro 1511      10586        09/05/2018 16:04:36
Windows 10 Pro 1709      16299        10/05/2018 06:19:03
Windows 10 Pro 1803      17134        10/05/2018 07:07:40
Windows 10 Pro 1809      17763        18/01/2019 19:02:45
Windows 10 Pro 1909      18363        01/06/2019 08:24:34
````
It's better, but my goal is to have only the first install date
Refine once again

````powershell
(Get-ChildItem -Path HKLM:\System\Setup\Source* |
    ForEach-Object {Get-ItemProperty -Path Registry::$_} |
    Select-Object ProductName, ReleaseID, CurrentBuild, @{n="Install Date"; e={([DateTime]'1/1/1970').AddSeconds($_.InstallDate)}} |
    Sort-Object "Install Date")[0]

ProductName    ReleaseId CurrentBuild Install Date
-----------    --------- ------------ ------------
Windows 10 Pro 1511      10586        09/05/2018 16:04:36
````
[Explanation] : [0] is the first entry, [1] the second, ... and [-1] the last one.

Better, really Better, but perhaps, I would like to have only the date and not the other properties after that ?

````powershell
((Get-ChildItem -Path HKLM:\System\Setup\Source* |
ForEach-Object {Get-ItemProperty -Path Registry::$_} |
Select-Object ProductName, ReleaseID, CurrentBuild, @{n="Install Date"; e={([DateTime]'1/1/1970').AddSeconds($_.InstallDate)}} |
Sort-Object "Install Date")[0])."Install Date"

mercredi 9 mai 2018 16:04:36
````
Gotcha ! Hope this is helpful for the readers.
This post is just a reminder of a comment i've done on Reddit : https://new.reddit.com/r/PowerShell/comments/n0fbmj/os_install_date/
