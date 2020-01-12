# BUILD SHORTCUTS WITH POWERSHELL

## INTRODUCTION

At this time, there is not yet any native cmdlet provide an easy way to create shortcuts. Then, often we must call COM Object. When I'll find other way, I'll add here.

## Then, How ? ... using COM Object

### Create a shortcut which is a file shortcut

The file could be a .exe file, on every type of file you need.

````powershell
# Create a var referencing a WScript.shell COM Object
$Shell = New-Object -ComObject ("WScript.Shell")
# Define the location and name of the shortcut - Must end in .lnk
$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\ShortcutName.lnk")
# Define Target Path
$ShortCut.TargetPath="PathToExecutable.exe"
````

At is step shortcut is already define. But we can add other parameters. Let's examine them :

````powershell
$shortcut | gm
   TypeName : System.__ComObject#{f935dc23-1cf0-11d0-adb9-00c04fd58a0b}
Name             MemberType Definition
----             ---------- ----------
Load             Method     void Load (string)
Save             Method     void Save ()
<span style="color:red">Arguments        Property   string Arguments () {get} {set}
Description      Property   string Description () {get} {set}
FullName         Property   string FullName () {get}
Hotkey           Property   string Hotkey () {get} {set}
IconLocation     Property   string IconLocation () {get} {set}
RelativePath     Property   string RelativePath () {set}
TargetPath       Property   string TargetPath () {get} {set}
WindowStyle      Property   int WindowStyle () {get} {set}
WorkingDirectory Property   string WorkingDirectory () {get} {set}</span>
````

As we can see, we can add Arguments, Description, FullName, HotKey, IconLocation, WindowsStyle, WorkingDirectory, and RelativePath

````powershell
# arguments if necessary
$ShortCut.Arguments="-ArgumentsIfRequired"
$ShortCut.WorkingDirectory = "c:\to\executable\folder\path";
$ShortCut.WindowStyle = 1;
$ShortCut.Hotkey = "CTRL+SHIFT+F";
$ShortCut.IconLocation = "Executable.exe, 0";
$ShortCut.Description = "Custom Shortcut Description";
````

And finally, we must pass the following code to close the COM Object

````powershell
$ShortCut.Save()
````

Then, the shortest code to have an operational shortcut could be :

````powershell
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\ShortcutName.lnk")
$ShortCut.TargetPath="PathToExecutable.exe"
$ShortCut.Save()
````

Below a sample of code that check if the parent folder exists and create it if it doesn't

````powershell
$Path = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MyApp"
$TargetFile = "C:\Program Files (x86)\Path\to\MyApp.exe"
$ShortcutFile = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MyApp\MyApp.lnk"

If(-not (Test-Path $Path))
    {
    New-Item -ItemType Directory -Force -Path $path
    }
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
````

### Create a shortcut which is an .url shortcut

````powershell
$Shell = New-Object -ComObject ("WScript.Shell")
$Favorite = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\Shortcut.url")
$Favorite.TargetPath = "http://www.urlSample.com";
$Favorite.Save()
````

### create a small powershell function to create shortcut

````powershell
function Set-Shortcut {
param (
    [string]$ShortcutFile,
    [string]$TargetFile
    )

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
    }
````

i.e :

````powershell
Set-Shortcut -Shortcutfile "\\path\to\ShortCutFile.lnk" -TargetFile "\\Path\to\Targetfile"
````

### Discuss

One limitation of either the WshShell COM component or ````cmd /c mklink```` workarounds is a very limited character set for naming the .lnk file.
A name containing a → will fail, for example. One way around this, if you need better character support, is to ````[Web.HttpUtility]::UrlEncode()```` (after ````Add-Type -AN System.Web````) the filename while creating the .lnk file, then renaming it to the UrlDecoded name using ````Rename-Item```` (see comments in <https://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell)>

I've also found an alternative syntax, using ````invoke```` method of the ````COM```` Object

````powershell
$Create_Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut
$Create_Shortcut | gm
   TypeName : System.Management.Automation.PSMethod

Name                MemberType Definition
----                ---------- ----------
Copy                Method     System.Management.Automation.PSMemberInfo Copy()
Equals              Method     bool Equals(System.Object obj)
GetHashCode         Method     int GetHashCode()
GetType             Method     type GetType()
<span style="color:red">Invoke              Method     System.Object Invoke(Params System.Object[] arguments)</span>
ToString            Method     string ToString()
IsInstance          Property   bool IsInstance {get;}
MemberType          Property   System.Management.Automation.PSMemberTypes MemberType {get;}
Name                Property   string Name {get;}
OverloadDefinitions Property   System.Collections.ObjectModel.Collection[string] OverloadDefinitions {get;}
TypeNameOfValue     Property   string TypeNameOfValue {get;}
Value               Property   System.Object Value {get;set;}
````

Then we can also use, like the following

````powershell
$Create_Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut
$Shortcut = $Create_Shortcut.invoke("c:\test.lnk") # Must end in .lnk
````

### Tricks

- Use Automatic variable (````$Env:SystemRoot, $PSScriptRoot, ...````) to define paths as much as you can to avoid future problems (see **About_Automatic_Variable** in powershell to get more info).

- To create a shortcut on All Users Desktop use : ````$Env:Public\desktop````

- To create a shortcut in Start Menu use for the currrent user : ````$env:USERPROFILE + "Start Menu\Programs\Startup" + "\program.lnk"````

- To create a shortcut in Start Menu use for the all users : ````$env:ALLUSERSPROFILE + "Start Menu\Programs\Startup" + "\program.lnk"````

### Little extra more

Below, a sample code to list in console all .lnk files and their Target Path.

````powershell
Clear-Host
$Path = "$Env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$StartMenu = Get-ChildItem $Path -Recurse -Include *.lnk
ForEach ($Item in $StartMenu)
{
   $Shell = New-Object -ComObject WScript.Shell
   $Properties = @{
                  ShortcutName = $Item.Name
                  Target = $Shell.CreateShortcut($Item).TargetPath
                  }
New-Object PSObject -Property $Properties
}
[Runtime.InteropServices.Marshal]::ReleaseComObject($Shell) | Out-Null
````
