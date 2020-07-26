# How to resolve PS Error Message Warning - unable to resolve package source

Recently, after I've just done a fresh install of a new Windows 2016 server, I wanted to install some useful Powershell module.

A message appears in console "WARNING: Unable to resolve package source 'https://www.powershellgallery.com/api/v2'.

````powershell
Install-Module pswritehtml
AVERTISSEMENT : Unable to resolve package source 'https://www.powershellgallery.com/api/v2'.
PackageManagement\Install-Package : Aucune correspondance trouvée pour les critères de recherche spécifiés et le nom de module pswritehtml. Utilisez Get-PSRepository pour afficher
pour toutes les repositories de module enregistrées disponibles.
````

This is linked to the insecure security protocols being used by powershell and it will need to be set to a supported protocol, this could be either if you were behind a proxy configured a certain way or the site you are connecting to only supports certain protocols.

I've already correct this in the past, but how ? After a look on the Internet, I've found this post : <https://infra.engineer/windows/63-powershell-error-message-warning-unable-to-resolve-package-source>

and I tested this successfully. I've decided to post this in my Gibhub in the Tips section, to have a permanent reminder for me and for all people.

First check current security Protocols you are running

````powershell
[Net.ServicePointManager]::SecurityProtocol
Ssl3, Tls
````

Then, i've changed this to use TLS1.2 bu running the following command

````powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# And now let's install a module
Install-Module -Name pswritehtml -Verbose -Force
COMMENTAIRES : Utilisation du fournisseur PowerShellGet pour la recherche de packages.
COMMENTAIRES : Le paramètre -Repository n'a pas été spécifié. PowerShellGet utilisera tous les référentiels enregistrés.
COMMENTAIRES : Obtention de l'objet fournisseur pour le fournisseur PackageManagement NuGet.
COMMENTAIRES : Emplacement spécifié : https://www.powershellgallery.com/api/v2. Fournisseur PackageManagement : NuGet.
...
COMMENTAIRES : Le module PSWriteHTML a été installé dans le chemin d’accès C:\Program Files\WindowsPowerShell\Modules\PSWriteHTML\0.0.88.
````

It's fine, but when I've closed my PS session, settings returned to the previous version.

This post : <https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/> explain why.

A solution to have TLS 1.2  permanently enabled is the following : set up the Powershell Profile File

````powershell
# Setting to use TLS1.2 for updating PS modules on PowershellGallery à partir from 1st April 2020
# ref : https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
Write-Host "Settings to use TLS1.2 for updating PS Modules on PowershellGallery from 1st April 2020" -ForegroundColor  'DarkGray'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
````

Another solution is to use registry entries forcing all .NET processes targetting .NET 4.5 to use strong crypto.

````powershell

$Newkeyparam1 =     @{
              Path  = "HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319"
              Name  = "SchUseStrongCrypto"
              Value = "1"
              Type  = "DWord"
              Force = $true
}
Set-ItemProperty @Newkeyparam1

$Newkeyparam2 = @{
    Path      = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319"
    Name      = "SchUseStrongCrypto"
    Value     = "1"
    Type      = "DWord"
    Force     = $true
}
Set-ItemProperty @Newkeyparam2
````

Other Ref :
<https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/security/enable-tls-1-2-server>
<https://support.microsoft.com/en-us/help/3140245/update-to-enable-tls-1-1-and-tls-1-2-as-default-secure-protocols-in-wi>
<https://docs.microsoft.com/en-us/windows-server/security/tls/tls-registry-settings>
<https://docs.microsoft.com/en-us/officeonlineserver/enable-tls-1-1-and-tls-1-2-support-in-office-online-server>
<https://support.microsoft.com/en-us/help/245030/how-to-restrict-the-use-of-certain-cryptographic-algorithms-and-protoc>
<https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/>
<https://docs.microsoft.com/en-us/dotnet/framework/network-programming/tls>
