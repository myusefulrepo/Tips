function Get-PublicHoliday
{
<#
.SYNOPSIS
   Get the Public Holiday dates for a country

.DESCRIPTION
   Get the Public Holiday dates for a country

.PARAMETER Date
    [DateTime]
    To avoid any trouble with an incorrect format of the Date if your current culture is not EN, use the Get-Date cmdlet, like this :
    $(Get-Date) or $(Get-Date -Year 2025)

.PARAMETER CountryCode
    [String]
    Define your Country Code on 2 characters.
    ex. NZ, FR, ...

.EXAMPLE
   Get-PublicHoliday -Date $(Get-Date) -CountryCode 'FR'
   return Holiday dates for this country

.EXAMPLE
   Get-Help Get-PublicHoliday -ShowWindow
   Complete help about this fonction

.NOTES
    Author : O. FERRIERE (inspired by Luke Murray Code : https://github.com/lukemurraynz/PowerOfTheShell/blob/master/Other/Get-PublicHoliday.ps1)
    Version 1.0
    Date 30/10/2023
    Change : v1.0 - 30/10/2023 - Initial Version
#>
[CmdletBinding()]
[OutputType([PSObject])]
    Param
    (
        # Define a Date
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [DateTime]
        $Date,

        # define your country Code with 2 char
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]
        $CountryCode
    )

    Begin
    {
    Write-Verbose "Determining The Year of the date variable"
    $Year = $Date.Year
    }
    Process
    {
    Write-Verbose "Read the content from nager.date"
    $url = "https://date.nager.at/api/v2/publicholidays/$Year/$CountryCode"
    Write-Verbose "Fix TLS Protocol to avoid any problem"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Verbose "Querying for Holiday dates"
    $Holidays = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $url
    }
    End
    {
    $Holidays
    }
}
$Holidays | Format-Table