<#
.SYNOPSIS
    Generate a report about Computer Certificates

.DESCRIPTION
    Generate a report about Computer Certificates
    The expired certificates are highlighted

.PARAMETER MaxDays
    Maximum days before a certificate is highlighted
    Default value : 100

.PARAMETER HtmlReportPath
    Full path of the the .Html report file
    Default value : "$PSScriptRoot\CertReport.html"

.INPUTS
    No input

.OUTPUTS
    Report file in Html format

.EXAMPLE
    .\.\HtmlCertReport.ps1
    Exec the script with the default value for parameters

.EXAMPLE
    .\.\HtmlCertReport.ps1 -Verbose
    Exec the script with the default value for parameters in a verbose mode


.EXAMPLE
    .\HtmlCertReport.ps1 -HtmlReportPath "C:\temp2\MyCertReport.html"
    Exec the script with the default value for parameters except for the -HtmlReportPath that runs with passed value.

.EXAMPLE
    Get-Help .\HtmlCertReport.ps1 -ShowWindow
    Full help about this script in a separate window

.NOTES
    File Name       : HtmlCertReport.ps1
    Version         : V.1.0
    Date            : 29/10/2024
    Author          : O. FERRIERE
    Change          : V.1.0 - 29/10/2024 - Initial Version

#>

[CmdletBinding()]
param (
    [Parameter(HelpMessage = 'Maximum days before a certificate is highlighted')]
    [int]
    $MaxDays = 100,

    [Parameter(HelpMessage = 'Full path of the the .Html report file')]
    [String]
    $HtmlReportPath = "$PSScriptRoot\CertReport.html"
)


#region Récupération dynamique des noms de magasins de certificats dans LocalMachine
Write-Verbose -Message 'Dynamic retrieval of certificate store names in LocalMachine'
$StoreNames = (Get-ChildItem -Path Cert:\LocalMachine | Where-Object { $_.PSIsContainer }).Name
#endregion Récupération dynamique des noms de magasins de certificats dans LocalMachine

#region Collection pour stocker les noms de variables dynamiques
Write-Verbose -Message 'Initializing a collection to Store Dynamic Variable Names'
$Collection = [System.Collections.ArrayList]::new()
#endregion Collection pour stocker les noms de variables dynamiques


#region Création d'une variable dynamique pour chaque magasin de certificats
Write-Verbose -Message 'Creating a dynamic variable for each certificate store'
foreach ($Item in $StoreNames)
{
    # Nom dynamique de la variable (ex. CertsInStore_My)
    # Dynamic name of the variable (eg. CertsInStore_My)
    $varName = "CertsInStore_$Item"
    # Initialiser une liste vide pour chaque magasin
    # Initialize an empty list for each store
    New-Variable -Name $varName -Value ([System.Collections.Generic.List[PSObject]]::new()) -Force
    # Ajouter le nom de la variable dans la collection pour un traitement ultérieur
    # Add the variable name to the collection for further processing
    $Collection.Add($varName) | Out-Null
}
#endregion Création d'une variable dynamique pour chaque magasin de certificats

#region Paramétrage du comportement par défaut de certaines cmdlets
Write-Verbose -Message 'Setting the default behavior of some cmdlets'
$PSDefaultParameterValues = @{
    'New-HTMLSection:HeaderBackGroundColor'      = 'seagreen'
    'New-HTMLSection:HeaderTextSize'             = 16
    'New-HTMLSection:CanCollapse'                = $true
    'New-HTMLSection:HeaderTextColor'            = 'Yellow'
    'New-HtmlTable:HideFooter'                   = $true
    'New-HTMLText:Alignment'                     = 'center'
    'New-HTMLText:FontSize'                      = 25
    'New-HTMLText:FontWeight'                    = 'bold'
    'New-HTMLPanel:BackgroundColor'              = 'lightpink'
    'New-HTMLPanel:AlignContentText'             = 'right'
    'New-HTMLPanel:BorderRadius'                 = '10px'
    'New-HTMLSectionStyle:BorderRadius'          = '0px'
    'New-HTMLSectionStyle:HeaderBackGroundColor' = 'Grey'
    'New-HTMLSectionStyle:RemoveShadow'          = $true
    'New-TableCondition:BackgroundColor'         = 'lightpink'
    'New-TableCondition:Color'                   = 'Black'
}
if ($PSBoundParameters.ContainsKey('verbose'))
{
    $PSDefaultParameterValues
}
#endregion Paramétrage du comportement par défaut de certaines cmdlets

#region fonction  Get-CertificateInfo
function Get-CertificateInfo
{
    param(
        [string]$certStoreName
    )
    $certStore = "Cert:\LocalMachine\$certStoreName"
    try
    {
        # Récupération de tous les certificats dans le magasin spécifié
        $allCerts = Get-ChildItem -Path $certStore
        # Création d'une liste générique pour stocker les informations des certificats
        $certsData = [System.Collections.Generic.List[PSCustomObject]]::new()
        foreach ($cert in $allCerts)
        {
            $certData = [PSCustomObject]@{
                Store         = $certStoreName
                Name          = $cert.FriendlyName
                Subject       = $cert.Subject
                Issuer        = $cert.Issuer
                NotBefore     = $cert.NotBefore
                NotAfter      = $cert.NotAfter
                RemainingDays = ($cert.NotAfter - (Get-Date)).Days
            }
            $certsData.Add($certData)
        }
        return $certsData
    }
    catch
    {
        Write-Warning "Erreur lors de l'accès au magasin de certificats : $($_.Exception.Message)"
        return $null
    }
}
#endregion fonction  Get-CertificateInfo

#region Fonction Get-CertificatesData
function Get-CertificatesData
{
    # Récupération de tous les magasins de certificats
    $allStores = Get-ChildItem Cert:\LocalMachine
    $allCertsData = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($store in $allStores)
    {
        $certsData = Get-CertificateInfo -certStoreName $store.Name
        if ($certsData)
        {
            $allCertsData += $certsData
        }
    }
    return $allCertsData
}
#endregion Get-CertificatesData

#region Collecte de tous les certificats de la machine
Write-Verbose -Message 'Collecting all machine certificates'
$AllCertificates = Get-CertificatesData | Sort-Object -Property RemainingDays
#endregion Collecte de tous les certificats de la machine

#region Génération de rapport HTML
Write-Verbose -Message 'HTML Report Generation'
New-HTML -FilePath $HtmlReportPath -TitleText 'Certificates Report' -Online -ShowHTML {
    New-HTMLHeader {
        New-HTMLText -Text "Date of this report : $(Get-Date -Format 'yyyy-MM-dd')" -Color Blue -Alignment right -FontSize 12
    }
    New-HTMLMain -BackgroundColor Azure {
        # Tableau pour tous les certificats de la machine - Tab for all machine certificates
        # Mise en évidence des certificats expirés ou expirant dans $MaxDate
        # Highlighting expired or expiring certificates in $MaxDate
        New-HTMLTab -Name 'All Certificates' {
            New-HTMLSection -HeaderText 'Total Number Of certificates' {
                New-HTMLSectionStyle
                New-HTMLPanel {
                    New-HTMLText -TextBlock {
                        New-HTMLText -Text "$($AllCertificates.count)"
                    } #end New-htmlText
                } #end New-HtmlPanel
            } #end New-htmlSection
                        
            New-HTMLSection -HeaderText "Certificates expiring before $Maxdays days are highlighted" {
                New-HTMLTable -Title 'All Certificates' -DataTable $AllCertificates {
                    New-TableCondition -Name 'RemainingDays' -ComparisonType number -Operator le -Value $MaxDays
                    New-HTMLTableContent -ColumnName RemainingDays -Alignment center
                } # end New-htmlTable
            } #end New-HtmlSection
        } #end New-htmlTab

        Write-Verbose -Message 'Processing certificates for each store'
        # Tableau pour chaque magasin de certificats
        # Tab for each certificate store
        foreach ($Store in $StoreNames)
        {
            Write-Verbose -Message "=== Processing Store Certificates : [$Store] ==="
            $CurrentStoreCerts = Get-CertificateInfo -certStoreName $Store | Sort-Object -Property RemainingDays
            if ($CurrentStoreCerts)
            {
                New-HTMLTab -Name "$Store" {
                    New-HTMLSection -HeaderText "Number Of certificates in $store" {
                        New-HTMLSectionStyle
                        New-HTMLPanel {
                            New-HTMLText -TextBlock {
                                # If a collection contains only 1 object, $collection.count return nothing
                                New-HTMLText -Text "$(if ( $CurrentStoreCerts -and $CurrentStoreCerts.count -lt 1){'1'}else{$($CurrentStoreCerts.count)} )"
                            } #end New-htmlText
                        } #end New-HtmlPanel
                    } #end New-htmlSection
                    
                    New-HTMLSection -HeaderText "$Store - Certificates" {
                        New-HTMLTable -Title "$Store Certificates" -DataTable $CurrentStoreCerts {
                            New-TableCondition -Name 'RemainingDays' -ComparisonType number -Operator le -Value $MaxDays
                            New-HTMLTableContent -ColumnName RemainingDays -Alignment center
                        }  #end New-htmlTable
                    } #end New-HtmlSection
                } #end New-htmlTab
            }
            else
            {
                Write-Verbose -Message "No certificate found in the store : [$Store]"
            }
        }
    } # end New-htmlMain
    New-HTMLFooter {
        New-HTMLText -Text "Report generated by $env:USERNAME on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Color blue -Alignment right -FontSize 12
    }
}
#endregion Génération de rapport HTML