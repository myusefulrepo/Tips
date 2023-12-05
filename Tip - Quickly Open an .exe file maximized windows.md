# Quickly Open an .exe file in maximized windows

Sometimes in a script we need to open a .exe file in a maximized windows. 

````powershell
Start-Process -FilePath <AppPath> -WindowStyle ([System.Diagnostics.ProcessWindowStyle]::Maximized)
# or a shorter version
Start-Process -FilePath  <AppPath> -WindowStyle Maximized

# and open a browser with a predefined page.
Start-Process -FilePath msedge -ArgumentList '--new-window www.google.com --start-maximized'
````

This could be useful to keep in mind.