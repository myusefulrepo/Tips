# using NotifyIcon .NET class
Add-Type -AssemblyName System.Windows.Forms

$URL = 'http://ifconfig.me/ip' 
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Text = @"
WAN IP Address : $IP
Country : $($IPInfo.country)
"@
$Title = 'WAN Info'

# Create a NotifyIcon (Tray Icon) - https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.notifyicon?view=windowsdesktop-8.0
$trayIcon = [System.Windows.Forms.NotifyIcon]::new()
$trayIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Windows.Forms.Application]::ExecutablePath)
$trayIcon.Visible = $true
$trayIcon.BalloonTipTitle = $Title
$trayIcon.BalloonTipText = $Text
$trayIcon.BalloonTipIcon = 1 # 0 : none - 1:info - 2:warning - 3:error - source : https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.tooltipicon?view=windowsdesktop-7.0
$trayIcon.ShowBalloonTip(1) # ShowBalloonTip(int timeout) : Displays a balloon tip in the taskbar for the specified time period.
$trayIcon.Dispose() # Releases all resources used