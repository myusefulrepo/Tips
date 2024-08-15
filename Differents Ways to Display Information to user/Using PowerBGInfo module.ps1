# Using PowerBGInfo module
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Country = $IPInfo.Country

New-BGInfo -MonitorIndex 0 -BGInfoContent {
    # Lets add computer name, but lets use builtin values for that
    New-BGInfoValue -BuiltinValue HostName -Color Red -FontFamilyName 'Calibri' -FontSize 48
    # Lets add user name, but lets use builtin values for that
    New-BGInfoValue -BuiltinValue FullUserName -Name 'FullUserName' -Color White -FontSize 48
    # New-BGInfoValue -BuiltinValue CpuName -Color white
    # New-BGInfoValue -BuiltinValue CpuLogicalCores -Color white
    #New-BGInfoValue -BuiltinValue RAMSize -Color white
    # New-BGInfoValue -BuiltinValue RAMSpeed -Color white

    # Lets add Labels
    New-BGInfoValue -Name 'WAN IP' -Value $IP -Color white -FontSize 48
    New-BGInfoValue -Name 'Country' -Value $Country -Color white -FontSize 48
} -FilePath C:\temp2\wp2058636-3840x1080-wallpapers.jpg -ConfigurationDirectory c:\temp2\Output -PositionX 2500 -PositionY 500 -WallpaperFit Stretch