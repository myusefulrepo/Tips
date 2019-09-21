##### 1 ##### Using plaintext passwords (not recommended!)
<#
With this method this create a PSCredential Object
The PSCredential object is a combination of the user account and the password
#>
$Account = "MyDomain\MyAccount"
$AccountPassword = "123456" | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential($Account, $AccountPassword)
# and for later use, export it to a file
$Credentials | Out-File -FilePath c:\temp\credential.txt
# or
$Credentials | Export-Clixml -Path c:\temp\credential.xml

# USEFUL AND PRACTICAL : Naming with User and computerName
$credentials | Export-Clixml -Path "C:\Temp\Credential_${env:USERNAME}_${env:COMPUTERNAME}.xml"

<#$Credentials
UserName                               Password
--------                               --------
MyDomain\MyAccount System.Security.SecureString
#>
# Biggest advantages : The file contain password, AND Domain\account or machine\account
# Biggest drawback   : 100% INSECURE!!!
# Limitation         : Only use on the same account on the same computer


##### 2  ##### Enter the password interactively (Read-Host)
<#
With this method this create a PSCredential Object
The PSCredential object is a combination of the user account and the password
#>
$Account = "MyDomain\MyAccount"
$AccountPassword = Read-Host -AsSecureString
$Credentials = New-Object System.Management.Automation.PSCredential($Account, $AccountPassword)
<#$Credentials

UserName                               Password
--------                               --------
MyDomain\MyAccount System.Security.SecureString
#>
# and for later use, export it to a file
$Credentials | Out-File -FilePath c:\temp\credential.txt
# or
$Credentials | Export-Clixml -Path c:\temp\credential.xml

# Biggest advantages : easy to implement and 100% secure.
#                    : The file contain password, AND Domain\account or machine\account
# Biggest drawback   : can only be used when running the PowerShell script interactively.
# Limitation         : Only use on the same account on the same computer


##### 3 ##### Using a 256-bit AES key file and a password file
<#
With this method this create a PSCredential Object
The PSCredential object is a combination of the user account and the password
but to use it with another account on another computer it was salted
When you use this method you will generate two files:
> 256-bit AES key file
> a password file.
These files can than be used in your PowerShell scripts on local and remote computers.
Ref. : https://dennisspan.com/encrypting-passwords-in-a-powershell-script
#>

#==========================================================================
#
# CREATE SECURE PASSWORD FILES
#
# AUTHOR: Dennis Span (https://dennisspan.com)
# DATE  : 05.04.2017
#
# COMMENT:
# -This script generates a 256-bit AES key file and a password file
# -In order to use this PowerShell script, start it interactively (select this file
#  in Windows Explorer. With a right-mouse click select 'Run with PowerShell')
#
#==========================================================================
# Define variables
$Directory = "C:\temp"
$KeyFile = Join-Path $Directory -ChildPath "AES_KEY_FILE.key"
$PasswordFile = Join-Path -Path $Directory -ChildPath "AES_PASSWORD_FILE.txt"
# Text for the console
Write-Host "CREATE SECURE PASSWORD FILE" -ForegroundColor Green
Write-Host ""
Write-Host "Comments:"-ForegroundColor Green
Write-Host "This script creates a 256-bit AES key file and a password file" -ForegroundColor Green
Write-Host "containing the password you enter below."-ForegroundColor Green
Write-Host ""
Write-Host "Two files will be generated in the directory " -ForegroundColor Green -no
Write-Host "$($Directory) :" -ForegroundColor Yellow
Write-Host "-> $($KeyFile)" -ForegroundColor Yellow
Write-Host "-> $($PasswordFile)"-ForegroundColor Yellow
Write-Host ""
$Password = Read-Host -Prompt "Enter password and press ENTER :" -AsSecureString
Write-Host ""
# Create the AES key file
try
{
    $Key = New-Object Byte[] 32  # Generate a random AES encryption Key
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | Out-File -FilePath $KeyFile # store the key in a file ==> THis file should be protected by NTFS
    $KeyFileCreated = $True
    Write-Host "The key file $KeyFile was created successfully"
}
catch
{
    Write-Host "An error occurred trying to create the key file $KeyFile (error: $($Error[0])" -ForegroundColor Red
}
# Add the plaintext password to the password file (and encrypt it based on the AES key file)
If ( $KeyFileCreated -eq $True )
{
    try
    {
        $Key = Get-Content -Path $KeyFile
        $Password | ConvertFrom-SecureString -key $Key | Out-File -FilePath $PasswordFile
        Write-Host "The key file $PasswordFile was created successfully" -ForegroundColor Green
    }
    catch
    {
        Write-Host "An error occurred trying to create the password file $PasswordFile (error: $($Error[0])" -ForegroundColor Red
    }
}
Write-Host ""
Write-Host "End of script (press any key to quit)" -ForegroundColor Yellow


# Read the secure password from a password file and decrypt it to a normal readable string
$SecurePassword = ( (Get-Content $PasswordFile) | ConvertTo-SecureString -Key (Get-Content $KeyFile) )        # Convert the standard encrypted password stored in the password file to a secure string using the AES key file
$SecurePasswordInMemory = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword); # Write the secure password to unmanaged memory (specifically to a binary or basic string)
$PasswordAsString = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($SecurePasswordInMemory); # Read the plain-text password from memory and store it in a variable
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($SecurePasswordInMemory);
<#
In the above code we use the Marshal class to write the secure password to unmanaged memory.
We than read this unmanaged memory and store the password in the variable $PasswordAsString.
You can test if this variable contains the correct password by adding a simple write-host command:
#>
Write-Host "Password is: $PasswordAsString"

# Biggest advantage  : can be used in multiple scripts on remote computers.
# Biggest drawback   : not 100% secure. The AES key file can be used to decrypt the password and therefore requires additional (NTFS) protection from unauthorized access.
#                    : The file contain only password, NOT Domain\account or machine\account
# Limitation         : can be used with another account on another computer
#                    : The file contain only password, not the Domain\account and machine\account


##### 4 ##### Use Export-Clixml
<#
For credentials that need to be saved to disk, serialize the credential object using Export-CliXml to protect the password value.
The password will be protected as a secure string and will only be accessible to the user who generated the file on the same computer where it was generated.
The file can than be used in your PowerShell scripts on local and remote computers but only with the same machine and account that encrypt the file
Ref. : http://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/
#>
# Define variables
$Directory = "C:\temp"
$PasswordFile = Join-Path -Path $Directory -ChildPath "AllCredentials.xml"# Define a HashTable that contains multiples credentials
$Hash = @{
    Srv1 = Get-Credential -Message "Please enter the credentials for Account on SRV1 - form : Domain\Account or IP\Account or Machine\Account"
    Srv2 = Get-Credential -Message "Please enter the credentials for Account on SRV2 - form : Domain\Account or IP\Account or Machine\Account"
    Srv3 = Get-Credential -Message "Please enter the credentials for Account on SRV3 - form : Domain\Account or IP\Account or Machine\Account"
}


# $hash contains all credentials
$Hash | Export-Clixml -Path $PasswordFile

# later you can add a new value in he hash table with the method add (key, value)
$hash.add("Srv4" , (Get-Credential -Message "Please enter the credentials for Account on SRV3 - form : Domain\Account or IP\Account or Machine\Account"))

# You can use later by importing the previously saved credential
$Credentials = Import-Clixml -Path $PasswordFile
Invoke-Command -ComputerName srv1 -Credential $Credentials.Srv1 -ScriptBlock { MyCommand }
Invoke-Command -ComputerName srv2 -Credential $Credentials.Srv2 -ScriptBlock { MyCommand }
Invoke-Command -ComputerName srv3 -Credential $Credentials.Srv3 -ScriptBlock { MyCommand }
Invoke-Command -ComputerName srv4 -Credential $Credentials.Srv4 -ScriptBlock { MyCommand }

# Biggest advantages : easy to implement and 100% secure.
#                    : The file contain multiples passwords, AND Domain\accounts or msachine\accounts
# Biggest drawback   : Only use on the same account on the same computer
# Limitation         : Only use on the same account on the same computer,
#                      but you can generate the hash with a runas "AccountthatRunTheScheduledTask"
#                      and one limitation disappears.


##### 5 ##### Combine Salting Method (3) and export-xml method (4)  Possible ?
