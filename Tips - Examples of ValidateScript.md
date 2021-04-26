# Examples of ValidateScripts

in Scripts, or functions we can use the Powershell Parameter Validation (formally ValidateScript) to validate the entries. Here, some samples of use just for memory.

## Syntax

````powershell
Param(
    [ValidateScript({ScriptBlock})]
    $Var
)
````

## Validating Active Directory computer names

````powershell
param(
    [ValidateScript({Get-ADComputer -Identity $PSItem})]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating NetBIOS compatible computer names

This can be useful when:

- You want to work with standalone computers.
-You want to create a new virtual machine.

````powershell
param(
    [ValidateLength(1, 15)]
    [ValidateScript({$PSItem -replace '\\|/|:|\*|\?|"||\||\.' -eq $PSItem})]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating FQDN compatible computer names

This validates only the name and not the full FQDN.

````powershell
param(
    [ValidateLength(1, 63)]
    [ValidatePattern('^[a-z0-9-]+$')]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating full FQDNs

````powershell
param(
    [ValidateLength(6, 253)]
    [validatePattern('^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$')]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating DNS registered computers names

````powershell
param(
    [ValidateScript({Resolve-DnsName -Name $PSItem})]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating PowerShell Remoting capable computers

> Note
This is the same validation you would use for CIM remoting capable computers,
except if you force the connection to use DCOM instead.

````powershell
param(
    [ValidateScript({Test-WSMan -ComputerName $PSItem})]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating SSH Remoting capable computers

````powershell
param(
    [ValidateScript({(Test-NetConnection -ComputerName $PSItem -Port 22).TcpTestSucceeded})]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating SMB capable computers

This can be useful when you want to map a network drive.

````powershell
param(
    [ValidateScript({(Test-NetConnection -ComputerName $PSItem -CommonTCPPort 'SMB').TcpTestSucceeded})]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## Validating SQL capable computers

In addition to validating the port availability, it also tries a connection with your current credential.

````powershell
param(
    [ValidateScript({(Test-DbaConnection $PSItem).ConnectSuccess})]
    [ValidateScript({(Test-NetConnection -ComputerName $PSItem -Port 1433).TcpTestSucceeded})]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

## About Validating a whole list of computer names

See more informations in the following link : <https://itluke.online/2020/08/05/validating-computer-names-with-powershell/>

## Validating Module

Depending on the audience of your function or script, you may want to give a hint when a required module for a validation script attribute is missing.

However, and unfortunately, the ````#Requires```` statement is processed after all parameters are validated.
And inside a validation script block, the ````#Requires```` statement is ignored.

But, as a workaround, you can make a check on your own and throw a terminating error.
The second example from the beginning (validating Active Directory computers) could look like:

````powershell
param(
    [ValidateScript( {
        if (-not(Get-Module -Name 'ActiveDirectory' -ListAvailable)) {
            throw 'The ActiveDirectory module is missing on this computer!'
        }
        else {
            Get-ADComputer -Identity $PSItem
        }
    })]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)
````

> All the previous samples are from the following link : <https://itluke.online/2020/08/05/validating-computer-names-with-powershell/>

## validate a value

Here validate the value is equal to 20

````powershell
param (
    [ValidateScript({
        if ($_ -eq 20) {
            $true
        }
        else {
            throw "$_ is invalid. Valid value is 20 only."
        }
    })]
    )
````

## Validate Date

* startDate
            - date must not be older than 90 days.
            - date must not be in the future.
* endDate
            - date must not be older than 90 days.
            - date must not be in the future.

````powershell
param (
        [ValidateScript({
            ($_ -gt (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-90) -and $_ -le (Get-Date))
        })]
        [datetime]$startDate,

        [ValidateScript({
            ($_ -gt (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-90) -and $_ -le (Get-Date))
        })]
        [datetime]$endDate
    )
````

## Validate date is greater than the current date
````powershell
Param(
    [ValidateScript({$_ -ge (Get-Date)})]
)
````

## Validate Existing Process

````powershell
param (
    [ValidateScript(
            {
                if (Get-Process -Name $_) {
                    $true
                }
                else {
                    throw "A process with name $_ is not found."
                }
            }
        )]
)
````

## Validate if the var is contain on a Set of var

````powershell
$ValidateSet =   @('Banana','Apple','PineApple') # (Get-Content -Path 'E:\Temp\FruitValidationSet.txt')

function Test-LongValidateSet
{
    Param
    (
        [ValidateScript({
            if ($ValidateSet -contains $PSItem) {$true}
            else { throw $ValidateSet}})]
        [String]$Fruit
    )

    "The selected fruit was: $Fruit"
}
````
Source : <https://stackoverflow.com/questions/56115792/how-to-have-a-powershell-validatescript-parameter-pulling-from-an-array>

## Validate if a path is existing

````powershell
Param(
    [ValidateScript({Test-Path $_ })]
    $Path
)
````

## Using an "If" statement with the ValidateScript parameter validation attribute

````powershell
Function Check-Parameters
{
  [cmdletbinding()]
  Param
  (
    $ComputerName = $env:COMPUTERNAME,
    [Switch]$Param1,
    [ValidateScript({
        If ($Param1)
            {Throw
            "The Param1 parameter and the Param2 parameter cannot be used together!"
            }
        else{$true}})]
    [Int]$Param2
  )
  'Running function with parameters: {0}' -f ($PSBoundParameters.Keys -join ', ')
}
Check-Parameters -Param1 -Param2 "10"
Check-Parameters -Param2 "10"
Check-Parameters -Param1
````

> Ref : <https://powershell.org/forums/topic/using-an-if-statement-with-the-validatescript-parameter-validation-attribute/>



## Useful links and references

<https://adamtheautomator.com/powershell-validatescript/>
<https://jdhitsolutions.com/blog/powershell/2193/powershell-scripting-with-validatescript/>
<https://powershell.org/2013/05/why-doesnt-my-validatescript-work-correctly/>
