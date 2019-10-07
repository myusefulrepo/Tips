# Get a list of the package names of all installed apps for current user
Get-AppxPackage | Where-Object { if (-not($_.IsFramework -or $_.PublisherId -eq "cw5n1h2txyewy")) 
                                    {$_}
                               } | 
                  Select-Object Name, version, PackageFullName

# and now you can remove them by the following
Remove-AppXPackage <PackageFullName>

# One-liner version
Get-AppxPackage | Where-Object { if (-not($_.IsFramework -or $_.PublisherId -eq "cw5n1h2txyewy")) 
                                    {$_}
                               } | 
                  Select-Object Name, version, PackageFullName | 
                  Out-GridView -PassThru |
                  Remove-AppXPackage