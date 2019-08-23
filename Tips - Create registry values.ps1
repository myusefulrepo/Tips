# RUN AS ADMINISTRATOR if you modify HKLM due to security restrictions

# New key : complete Path
New-Item -Path 'HKCU:\SOFTWARE\Test'

# New Key: Path + Name
New-Item -Path 'HKCU:\SOFTWARE\Test' -Name 'App'
Get-ChildItem -Path 'HKCU:\SOFTWARE\Test' 

# Replace Existing Key
New-Item -Path 'HKCU:\SOFTWARE\Test' -Force
Get-ChildItem -Path 'HKCU:\SOFTWARE\Test' 
<# With the parameter -Force, it replace the existing key
Note that All Items in this key disapear
#>

# Create and assign a Value
New-Item -Path 'HKCU:\SOFTWARE\Test\Website' -Value 'Https://www.mywebsite.com' 
# Note that the default key name is "Default"
Get-Item -Path 'HKCU:\SOFTWARE\Test\Website'
Get-ItemProperty -Path 'HKCU:\SOFTWARE\Test\Website'

# Rename a value
Rename-ItemProperty -Path 'HKCU:\SOFTWARE\Test\Website' -Name "(default)" -NewName "WebSite"
Get-ItemProperty -Path 'HKCU:\SOFTWARE\Test\Website' 
# Note that the "(default)" key still exists but the value is set to $null

# Add another key/value
New-ItemProperty -Path 'HKCU:\SOFTWARE\Test\Website' -Name "website2" -Value 'Https://www.mywebsite2.com' 

# Define the PropertyType of a value
$Name = "Version"
$Value = "1.0"
$PropertyType = "DWORD"
New-ItemProperty -Path 'HKCU:\SOFTWARE\Test\Website' -Name $Name -Value $Value -PropertyType $PropertyType

# Testing the existence of the registry Key and the value
$RegistryPath = 'HKCU:\SOFTWARE\Test\Website' 
$Name = "Version"
$Value = "2"
if (Test-Path $RegistryPath)
    {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force 
    Write-host "The Key is existing... and the value updated" -ForegroundColor Green
    }
else { # registry Key doesn't exist
    New-Item -Path $registryPath -Force  | Out-Null # to avoid console output
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force  | Out-Null
}
Get-ItemProperty -Path $RegistryPath -Name $Name

# Tips to save time
Set-Location -Path 'HKCU:\SOFTWARE\Test\'
# and now use the cmdlet Pop-Location to return to the starting working location.
Pop-Location
New-Item -Path .\Website\ -Name 'AnotherKey'
