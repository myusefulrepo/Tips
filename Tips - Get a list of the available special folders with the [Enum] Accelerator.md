# Quick Tips : Get a list of the available special folders with the [Enum] Accelerator

````powershell
[Enum]::GetNames([System.Environment+SpecialFolder])
````
this return
````
Desktop
Programs
MyDocuments
Personal
Favorites
Startup
Recent
SendTo
StartMenu
MyMusic
MyVideos
DesktopDirectory
MyComputer
NetworkShortcuts
Fonts
Templates
CommonStartMenu
CommonPrograms
CommonStartup
CommonDesktopDirectory
ApplicationData
PrinterShortcuts
LocalApplicationData
InternetCache
Cookies
History
CommonApplicationData
Windows
System
ProgramFiles
MyPictures
UserProfile
SystemX86
ProgramFilesX86
CommonProgramFiles
CommonProgramFilesX86
CommonTemplates
CommonDocuments
CommonAdminTools
AdminTools
CommonMusic
CommonPictures
CommonVideos
Resources
LocalizedResources
CommonOemLinks
CDBurning
````

We can put the cmd line in a variable
````powershell
$Special = [Enum]::GetNames([System.Environment+SpecialFolder])
````
