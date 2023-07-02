# TIP - Pass credentials as a parameter in a script

Sometimes we need to pass credentials in a script. Of course, we can do it with 2 variables (ex. $UserName and $Password) but why not do it with a single variable ?

## the code
````powershell
[CmdletBinding()]
param(
    [Parameter(
        Position = 0,
        HelpMessage = 'Credentials to authenticate agains a remote computer')]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.CredentialAttribute()]
    $Credential
)
````

and now a demo how to use it. I've a simple script with the following content : 

````powershell
[CmdletBinding()]
param(
    [Parameter(
        Position = 0,
        HelpMessage = 'Credentials to authenticate agains a remote computer')]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.CredentialAttribute()]
    $Credential
)
Write-Host "the credentials passed in parameter are : "
$Credential
````
and now running the script : 

````powershell
& '.\test-get-credentials.ps1' -Credential asus10\olivier

UserName                           Password
--------                           --------
asus10\olivier System.Security.SecureString
````

>[Nota] : The parameter ````-Credential```` is mandatory. The value passed is just the ***Domain\userName*** or ***Computer\UserName***.

This could be useful

Hope this help


