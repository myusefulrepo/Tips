# Using BurntToast Module
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Text = @"
WAN IP Address : $IP
Country : $($IPInfo.country)
"@
$Title = 'WAN Info'

New-BurntToastNotification -Text $Title, $Text -Silent -SnoozeAndDismiss