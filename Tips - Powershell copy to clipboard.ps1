Get-content -Path C:\temp\test1.txt # content is serv1, srv2, srv3
Get-Clipboard -Format FileDropList
# I've srv2,srv2 and Srv3 in the clipboard, and now
Get-Clipboard -Format Text
# same result

Get-ChildItem -Path C:\temp -File # copy the console result in the clipboard
Get-Clipboard -Format Text
# as you can see, everything I have in the clipboard is copy to the console

# I'm editing a image file (i.e. with Paint) select it and copy to the clipboard
Get-Clipboard -Format Image 
# The result is the properties of the selected image

# more info with 
Get-Help Set-Clipboard -Detailed
# interesting parameters : -Append -Path
Get-Help Get-Clipboard -Detailed


# more help in https://adamtheautomator.com/powershell-copy-to-clipboard/

