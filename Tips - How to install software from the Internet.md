# How to install software from the Internet silently
In this sample, i'm choosing VScode

1 - Define the URL and the install Arguments

````powershell
$Url = "https://aka.ms/win32-x64-user-stable"
$Install_Args = '/verysilent /suppressmsgboxes /mergetasks=!runcode'
````

2 -  Define the install location UNC or Local

````powershell
$CurrentDir = (Get-Location).Path
````

3 - Get latest download url for Visual Studio Code

````powershell
# Set the Net.SecurityProtocolType to TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$webRequest = [Net.WebRequest]::Create("$Url")
$Asset = $Webrequest.GetResponse()
$Uri = $Asset.ResponseUri.AbsoluteUri
$InstallerPath = "$CurrentDir\$($Uri.Split('/')[-1])"
````

4 -  download to the $InstallerPath

````powershell
if (-not (Test-Path $InstallerPath))
    {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $Uri -OutFile $InstallerPath
    }````

5 -  Run installer, silently

````Powershell
Start-Process -FilePath $InstallerPath -ArgumentList $Install_args -Wait
````

6 - Post-Installation, Customizations : Install Extensions ms-vscode-powershell and vscode-Icons-team

````Powershell
Set-Location -Path $Env:LOCALAPPDATA\Program\Microsoft VS Code\"
code --install-extension ms-vscode.powershell --force
code --install-extension vscode-icons-team.vscode-icons --force
````

7 - Post-Installation, Defining some Settings for VScode

````Powershell
$SettingJSONfile = "$($env:APPDATA)\Code\User\settings.json"
# Define VSCode settings as a Here-String
$SettingJSON = @"
{
    //"powershell.powerShellDefaultVersion": "Windows PowerShell (x64)",
    "editor.renderWhitespace": "all",
    "terminal.integrated.profiles.windows": {
    "PowerShell": {"path": "C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"}
},
    "terminal.integrated.automationShell.linux": ""
}
"@
Set-Content -Path $SettingJSONfile -Value $SettingJSON
````

[Nota] : Based on the following article
https://azurecloudai.blog/2021/04/26/how-i-install-microsoft-code/
