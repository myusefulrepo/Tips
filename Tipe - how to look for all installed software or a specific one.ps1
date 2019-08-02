###### Gather all Installed programs ######
# They could be located at these 2 registry paths
$paths = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
         'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
# Here the properties that interessed me.
$props = @(
         @{label ='Architecture'; expression = { if($_.PsParentPath -match 'SysWow'){'32-bit'}else{'64-bit'}}},
         'Publisher',
         'Version',
         'DisplayName',
         'UninstallString'
)
# And now Gather thel all
Get-ItemProperty $paths | Select-Object $props

# a another way is the following : assign the output to a variable and call the interesting property
$Products = Get-ItemProperty $paths | Select-Object $props
$Products.DisplayName

# And now to look for a specific software
$SoftwareTitle = "Mozilla"
$Product = Get-ItemProperty $paths | where {$_.DisplayName -match $SoftwareTitle} | Select-Object $props
$Product.DisplayName



