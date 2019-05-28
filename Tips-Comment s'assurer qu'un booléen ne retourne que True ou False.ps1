# Source de référence Original: https://powershell-du-zero.fr/2019/01/29/comment-passer-une-variable-null-a-un-parametre-du-type-booleen.html


# Le contexte : on a un paramètre facultatif dans une fonction ou un script de type Booléen.
# On veut s'assurer que les seules options valides sont $true ou $false.
Function Test-ParamBoolean
{
    param(
        [CmdletBinding()]
        [System.boolean]$TestCase
    )
    Write-Output "The test case is $TestCase"
}

<#
[09:01:00] C:/Temp> Test-ParamBoolean -TestCase $true
The test case is True
[09:01:05] C:/Temp> Test-ParamBoolean -TestCase $false
The test case is False
[09:01:09] C:/Temp> Test-ParamBoolean
The test case is False
#>
# On constate que si on passe $true ou $false, cela donne le résultat escompté, mais si on ne passe rien, ca retourne $false
# Il existe une classe .NET Nullable (T) Struct -https://docs.microsoft.com/en-us/dotnet/api/system.nullable-1?view=netframework-4.7.2).
# Cette classe permet de placer a lintérieur de [System.Nullable] le type [System.Boolean], ce qui permet enfin de pouvoir gérer $true, $false et $null.


Function Test-ParamBoolean
{
    param(
        [System.Nullable[System.boolean]] $TestCase = $false
    )
    if ( -not [string]::IsNullOrEmpty($TestCase) )
    {
        Write-Output "The test case is $TestCase"
    }
    else
    {
        Write-Output "Hey buddy, I don't read minds!"
    }
}
<#
[09:37:53] C:/Temp> Test-ParamBoolean -TestCase $true
The test case is True
[09:37:59] C:/Temp> Test-ParamBoolean -TestCase $false
The test case is False
[09:38:07] C:/Temp> Test-ParamBoolean -TestCase $null
Hey buddy, I don't read minds!
[09:38:11] C:/Temp> Test-ParamBoolean
The test case is False
#>

# Il semble que l'on obtienne un effet équivalent cependant avec un [ValidateSet]
Function Test-ParamBoolean
{
    param(
        [CmdletBinding()]
        [ValidateSet($true, $false, $null)]
        [System.String]$TestCase = $false
    )
    If (-not [string]::IsNullOrEmpty($TestCase))
    {
        Write-Output "The test case is $TestCase"
    }
    else
    {
        Write-Output "Hey buddy, I don't read minds!"
    }
}
<#[09:39:52] C:/Temp> Test-ParamBoolean -TestCase $true
The test case is True
[09:39:55] C:/Temp> Test-ParamBoolean -TestCase $false
The test case is False
[09:39:59] C:/Temp> Test-ParamBoolean -TestCase $null
Hey buddy, I don't read minds!
[09:40:02] C:/Temp> Test-ParamBoolean
The test case is False
#>
