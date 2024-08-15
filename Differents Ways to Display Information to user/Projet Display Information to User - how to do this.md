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
  - [What type of display will I choose ? Advantages vs disavantages](#what-type-of-display-will-i-choose--advantages-vs-disavantages)
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

[<img src=".\Images\WindowsNotification.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/WindowsNotification.png)


### Using the Windows notification system using the BurntToast powershell module

I have commented the code below to make it easier to understand.

````Powershell 
# Import Module BurntToast
Import-Module -Name BurntToast
# gathering WAN IP and Country info.
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content

# Info message for BurntToast Notification
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

[<img src=".\Images\BurntToast-Notification.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/BurntToast-Notification.png)

The reminder scheduling can be configured with different values :


[<img src=".\Images\BurntToast-Notification-Schedule.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/BurntToast-Notification-Schedule.png)

There are also many possible display settings such as adding icons to the notification window, repetitive messages with variable content, etc. We will refer to the [BurntToast module](https://github.com/Windos/BurntToast) documentation and more precisely to the examples that are provided.

### Using a WPF (Windows Presentation Framework) Windows

I have commented the code below to make it easier to understand.


````powershell
# gathering WAN IP and Country info.
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
# Info message for the Windows
$Text = @"
WAN IP Address : $IP
Country : $($IPInfo.country)
"@

Add-Type -AssemblyName PresentationFramework

# Creating the window
$Window = [System.Windows.Window]::new()
$Window.AllowsTransparency    #borderless window
$Window.WindowStyle = 'none' # non-movable window. Here I'm choosing a non-movable window
$Window.SizeToContent = 'WidthAndHeight'
$Window.WindowStartupLocation = 'manual' # or 0 for 'manual', 1 for 'CenterScreen' or 2 for 'centerowner', If Manual is selected, $Window.Left, and $Window.Right or $Window.Top could be defined
$Window.left = 3450 # adjust to your resolution. Here I'm choosing the top right corner. The value is high, but I have a big screen with high resolution (3840 x 1080)
$Window.Top = 0
$Window.Background = [System.Windows.Media.Brushes]::Azure

# Creating a StackPanel to hold the elements
$StackPanel = [System.Windows.Controls.StackPanel]::new()
$StackPanel.Margin = '10'

# Creating label
$Label = [System.Windows.Controls.Label]::new()
$Label.Content = "$Text"
$Label.FontSize = 20
$Label.FontWeight = 'bold'
# there is a property called $Label.FontFamily.Source but it's a read-only property. Otherwise, I'll set to = "seguiemj" to have emoji available
$Label.Foreground = [System.Windows.Media.Brushes]::DarkBlue
$StackPanel.AddChild($Label) | Out-Null

# Creating button
$Button = [System.Windows.Controls.Button]::new()
$Button.Content = 'OK'
$Button.Padding = '10,5'
$Button.Background = [System.Windows.Media.Brushes]::AliceBlue
$Button.Foreground = [System.Windows.Media.Brushes]::DarkBlue
$Button.FontWeight = 'Bold'
$StackPanel.AddChild($Button) | Out-Null

# Adding StackPanel to window
$Window.Content = $StackPanel

# Event for the button
$Button.Add_Click({
        $Window.Close()
    })

# Display Window
$Window.ShowDialog() | Out-Null
````

and the result is like the following :

[<img src=".\Images\WTF-Window.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/WTF-Window.png)


>[**Nota**] : it is also possible to use a `[Windows.Forms]` .Net class to show a windows, but this way is deprecated.

### Using the PowerBGInfo powershell module

I have commented the code below to make it easier to understand.


````powershell
# Import PowerBGInfo module
Import-Module -Name PowerBGInfo

# gathering WAN IP and Country info
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Country = $IPInfo.Country

New-BGInfo -MonitorIndex 0 -BGInfoContent {
    # Lets add computer name, but lets use builtin values for that
    New-BGInfoValue -BuiltinValue HostName -Color Red -FontFamilyName 'Calibri' -FontSize 48
    # Lets add user name, but lets use builtin values for that
    New-BGInfoValue -BuiltinValue FullUserName -Name 'FullUserName' -Color White -FontSize 48
    # Lets add Labels
    New-BGInfoValue -Name 'WAN IP' -Value $IP -Color white -FontSize 48
    New-BGInfoValue -Name 'Country' -Value $Country -Color white -FontSize 48
} -FilePath C:\temp2\wp2058636-3840x1080-wallpapers.jpg -ConfigurationDirectory c:\temp2\Output -PositionX 2500 -PositionY 500 -WallpaperFit Stretch
````
Here, I'm using a wallpaper located in my "C:\temp2 folder" as a ref wallpaper and the output will be created in "C:\temp\output".

and the result is like the following :

[<img src=".\Images\PowerBGInfo.png">](https://github.com/myusefulrepo/Tips/blob/master/Differents%20Ways%20to%20Display%20Information%20to%20user/Images/PowerBGInfo.png)

## What type of display will I choose ? Advantages vs disavantages

The information sought may change over time, to refresh it I would have to restart the script.

| Method                                | advantage | disavantage                                                                                                                                                                                                                              |
|:--------------------------------------|:----------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Using the Windows notification system |           | you need to know all the subtleties of the .NET class `[System.Windows.Forms.NotifyIcon]` to take full advantage of it. Non-persistent notification : If the notification appears when the user is not behind his screen, he may miss it |
|Using the Windows notification system using the BurntToast powershell module|Simplicity vs ***Windows Notification***. No need to know the subtleties of the .NET class `[System.Windows.Forms.NotifyIcon]` to take full advantage of it.| Non-persistent notification : If the notification appears when the user is not behind his screen, he may miss it, but it's easier to have a Notification with a reminder| |
|Using a WPF (Windows Presentation Framework) Windows |Elegant way - Possibility to place the window in a non-obtrusive location on the screen - Persistent window (the user cannot miss it)||
|Using the PowerBGInfo powershell module |Elegant Way - Ability to place information in a non-obtrusive location on the background image - Persistent information (user cannot miss it)||

## final word

I hope this little overview has given you an overview of different possibilities, although it is certainly not exhaustive.

I like the use of the **BurntToast** module for the ease of mastering the different possibilities of the module, much easier than having to master the subtleties of the .NET `[System.Windows.Forms.NotifyIcon]` class.

I also like the elegance of windows in **WPF**, despite the relative complexity to obtain a result that is pleasing to the eye.

The **PowerGBInfo** module advantageously replaces the **BGInfo.exe** executable and has interesting possibilities.

Afterwards, depending on the use cases, such a solution may be more suitable than another, or each person may prefer one method over another by personal choice.

Everyone will have their own opinion but I hope this will be useful to you.