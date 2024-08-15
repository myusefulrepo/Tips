# Display Information to User : how to do this ? 

## Table of contents

- [Display Information to User : how to do this ?](#display-information-to-user--how-to-do-this-)
  - [Table of contents](#table-of-contents)
  - [Preface](#preface)
    - [The use case](#the-use-case)
    - [The Challenges](#the-challenges)
  - [How do I retrieve my WAN IP address ?](#how-do-i-retrieve-my-wan-ip-address-)
  - [How do I retrieve the country of this WAN IP ?](#how-do-i-retrieve-the-country-of-this-wan-ip-)
  - [What are the different types of display possible ?](#what-are-the-different-types-of-display-possible-)
    - [Using the Windows notification system](#using-the-windows-notification-system)
    - [Using the Windows notification system using the BurntToast powershell module](#using-the-windows-notification-system-using-the-burnttoast-powershell-module)
    - [Using a WPF (Windows Presentation Framework) Windows](#using-a-wpf-windows-presentation-framework-windows)
    - [Using the PowerBGInfo powershell module](#using-the-powerbginfo-powershell-module)
  - [What type of display will I choose ?](#what-type-of-display-will-i-choose-)
  - [advantages vs disavantages](#advantages-vs-disavantages)
  - [final word](#final-word)

## Preface

There are different ways to present information to a user. Through an example, I will present some of them to you.

### The use case

I have a VPN client on my computer. When the VPN is established to a VPN server, my Internet IP address and its location (country) changes. This is the information I need to retrieve and display.

### The Challenges

Several challenges are to be met
- How do I retrieve my WAN IP address ?
- How do I retrieve the country of this WAN IP ?
- What are the different types of display possible ?
- What type of display will I choose ?

## How do I retrieve my WAN IP address ?

This step is the easier step. There are several Web services to do this

eg. : "http://ifconfig.me/ip",  "https://api.ipify.org/", "https://www.theictguy.co.uk/ip/" and so on.

***Details of the approach :***

````powershell
$URL = "http://ifconfig.me/ip"
Invoke-WebRequest -Uri $URL
$URL
StatusCode        : 200
StatusDescription : OK
Content           : 85.171.xx.xx
RawContent        : HTTP/1.1 200 OK
                    access-control-allow-origin: *
                    Content-Length: 14
                    Content-Type: text/plain
                    Date: Thu, 15 Aug 2024 01:16:18 GMT
                    Via: 1.1 google

                    85.171.189.xxx
Forms             : {}
Headers           : {[access-control-allow-origin, *], [Content-Length, 14], [Content-Type, text/plain], [Date, Thu, 15 Aug 2024 01:16:18 GMT]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 14
````

the information (IP) sought is in the `Content` Property.

***Synthesis :***

````Powershell
$URL = "http://ifconfig.me/ip"
$IP = (Invoke-WebRequest -Uri $URL).Content
$IP
85.171.189.xxx
````

## How do I retrieve the country of this WAN IP ?

I got my WAN IP but I don't have the country of this IP. I will use another Internet Service, based on the `Invoke-RestMethod` cmdlet.

***Details of the approach :***

````powershell
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$IPInfo
status      : success
country     : France
countryCode : FR
region      : IDF
regionName  : Île-de-France
city        : xxxxxxxx
zip         : xxxxx
lat         : xxxxx
lon         : xxxxx
timezone    : Europe/Paris
isp         : xxxxxxxxxxxxx
org         :
as          : xxxxxxxxxxxxxx
query       : 85.171.189.xxx
````


The needed info in the `Country` property

***Synthesis :***
````Powershell
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Country = $IPInfo.Country
````

## What are the different types of display possible ?
I have identified 4 ways to display the collected information to the user:
- Using the Windows notification system
- Using the Windows notification system using the BurntToast powershell module
- Using a WPF (Windows Presentation Framework) Windows
- Using the PowerBGInfo powershell module

I will review them.

### Using the Windows notification system

I have commented the code below to make it easier to understand.

````Powershell
# using NotifyIcon .NET class
Add-Type -AssemblyName System.Windows.Forms
# gathering WAN IP and Country info.
$URL = 'http://ifconfig.me/ip' 
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Text = @"
WAN IP Address : $IP
Country : $($IPInfo.country)
"@
$Title = 'WAN Info'

# Create a NotifyIcon (Tray Icon) - https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.notifyicon?view=windowsdesktop-8.0
$TrayIcon = [System.Windows.Forms.NotifyIcon]::new()
$TrayIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Windows.Forms.Application]::ExecutablePath)
$TrayIcon.Visible = $true
$TrayIcon.BalloonTipTitle = $Title
$TrayIcon.BalloonTipText = $Text
$TrayIcon.BalloonTipIcon = 1 # 0 : none - 1:info - 2:warning - 3:error - source : https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.tooltipicon?view=windowsdesktop-7.0
$TrayIcon.ShowBalloonTip(1) # ShowBalloonTip(int timeout) : Displays a balloon tip in the taskbar for the specified time period.
$TrayIcon.Dispose() # Releases all resources used
````
and the result is like the following :

[<img src=".\Images\Windows Notification.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/Windows%20Notification.png)


### Using the Windows notification system using the BurntToast powershell module

I have commented the code below to make it easier to understand.

````Powershell 
# Import Module BurntToast
Import-Module -Name BurntToast
# gathering WAN IP and Country info.
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content

# Info message for BurtnToast Notification
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Text = @"
WAN IP Address : $IP
Country : $($IPInfo.country)
"@
$Title = 'WAN Info'
# BurtToast notification and parameters
New-BurntToastNotification -Text $Title, $Text -Silent -SnoozeAndDismiss
````
and the result is like the following :

[<img src=".\Images\BurntToast Notification.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/BurntToast Notification.png)

The reminder scheduling can be configured with different values

[<img src=".\Images\BurntToast Notification-Schedule.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/BurntToast Notification-Schedule.png)





### Using a WPF (Windows Presentation Framework) Windows

### Using the PowerBGInfo powershell module


## What type of display will I choose ?
## advantages vs disavantages
## final word

