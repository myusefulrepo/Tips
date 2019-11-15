# Searching for All Files in ReadOnly Mode and uncheck IsReadOnly Property
Get-ChildItem c:\temp -Recurse | Set-ItemProperty -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue

# Searching for All specific extension Files in ReadOnly Mode and uncheck IsReadOnly Property
Get-ChildItem c:\temp -Filter *.docx | Set-ItemProperty -Name IsReadOnly -Value $false


# We could use the same way to perform other changes on the files properties




