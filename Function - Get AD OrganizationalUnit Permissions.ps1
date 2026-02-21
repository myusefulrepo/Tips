# Based on : https://github.com/HarmVeenstra/Powershellisfun/blob/main/Retrieve%20Active%20Directory%20OU%20permissions/Get-ActiveDirectoryOUpermissions.ps1
function Get-ActiveDirectoryOUpermissions
{
    param (
        [Parameter(
            HelpMessage = 'File type must be .csv or .xlsx')]
        [ValidateSet('CSV', 'XLSX')]
        [String]
        $OutputType,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the path to where the CSV file should be stored, e.g c:\temp\OU_ACL.csv')]
        [ValidateScript(
            {
                if (Test-Path -Path $_ -PathType Leaf -IsValid)
                {
                    $true
                }
                else
                {
                    throw
                    "Invalid path given: $_ The Path must be a path to a file"
                }
            }
        )]
        [string]
        $Output,

        [Parameter(Mandatory = $false,
            HelpMessage = "Start OU to scan including child OU's, format it like 'OU=Servers,DC=domain,DC=Local'")]
        [string]
        $StartOU
    )

    #Validate output by creating the file, stop if location is inaccessible
    try
    {
        New-Item -Path $Output -ItemType File -Force:$true -ErrorAction Stop | Out-Null
        Write-Host ('Output to {0} is valid' -f $Output) -ForegroundColor Green
    }
    catch
    {
        Write-Warning ("The output can't be saved as {0}, is specified path accessible?" -f $Output)
        break
    }

    #Try to detect the Active Directory Domain name before continuing and stop script if it fails
    try
    {
        $domain = (Get-ADDomain -ErrorAction Stop).DNSroot
        Write-Host ('Domain {0} detected' -f $domain) -ForegroundColor Green
    }
    catch
    {
        Write-Warning 'Could not retrieve Domain Name, is the ActiveDirectory module installed or are you running this from a non-domain-joined device?'
        break
    }

    #Continu if Active Directory Domain was detected and retrieve list of OU's from the whole domain
    #or from the Ou specified in the StartOU parameter
    if ($domain)
    {
        if ($StartOU)
        {
            try
            {
                Write-Host ("Retrieving OU's for Domain {0} starting from {1}" -f $domain, $StartOU) -ForegroundColor Green
                $oulist = Get-ADOrganizationalUnit -SearchBase $StartOU -Filter * -ResultSetSize 10000 -SearchScope Subtree -ErrorAction Stop |
                    Sort-Object DistinguishedName
            }
            catch
            {
                Write-Warning ("Could not use {0}, check spelling and format it like 'OU=Servers,DC=domain,DC=Local')" -f $startou)
                break
            }
        }
        else
        {
            Write-Host ("Retrieving all OU's for Domain {0}" -f $domain, $StartOU) -ForegroundColor Green
            $oulist = Get-ADOrganizationalUnit -Filter * -ResultSetSize 10000 -SearchScope Subtree -ErrorAction Stop |
                Sort-Object DistinguishedName
        }
    }

    #Function for translating ObjectTypes to name
    #Thanks go out for the blog here https://blog.wobl.it/2016/04/active-directory-guid-to-friendly-name-using-just-powershell/
    function Get-NameForGUID
    {
        [CmdletBinding()]
        param(
            [guid]
            $guid
        )
        begin
        {
            $DomainDC = ([ADSI]'').distinguishedName
            $ExtendedRightGUIDs = "LDAP://cn=Extended-Rights,cn=configuration,$DomainDC"
            $PropertyGUIDs = "LDAP://cn=schema,cn=configuration,$DomainDC"
        }
        process
        {
            if ($guid -eq '00000000-0000-0000-0000-000000000000')
            {
                return 'All'
            }
            else
            {
                $rightsGuid = $guid
                $property = 'cn'
                $SearchAdsi = ([ADSISEARCHER]"(rightsGuid=$rightsGuid)")
                $SearchAdsi.SearchRoot = $ExtendedRightGUIDs
                $SearchAdsi.SearchScope = 'OneLevel'
                $SearchAdsiRes = $SearchAdsi.FindOne()
                if ($SearchAdsiRes)
                {
                    return $SearchAdsiRes.Properties[$property]
                }
                else
                {
                    $SchemaGuid = $guid
                    $SchemaByteString = '\' + ((([guid]$SchemaGuid).ToByteArray() | ForEach-Object { $_.ToString('x2') }) -join '\')
                    $property = 'ldapDisplayName'
                    $SearchAdsi = ([ADSISEARCHER]"(schemaIDGUID=$SchemaByteString)")
                    $SearchAdsi.SearchRoot = $PropertyGUIDs
                    $SearchAdsi.SearchScope = 'OneLevel'
                    $SearchAdsiRes = $SearchAdsi.FindOne()
                    if ($SearchAdsiRes)
                    {
                        return $SearchAdsiRes.Properties[$property]
                    }
                    else
                    {
                        return $guid.ToString()
                    }
                }
            }
        }
    }

    #Custom object for certain Security Identifiers which don't report a friendly name
    #List is from https://docs.microsoft.com/en-us/windows/security/identity-protection/access-control/security-identifiers
    $CustomIdentifiers = @{
        'S-1-5-32-544' = 'Administrators'
        'S-1-5-32-545' = 'Users'
        'S-1-5-32-546' = 'Guests'
        'S-1-5-32-547' = 'Power Users'
        'S-1-5-32-548' = 'Account Operators'
        'S-1-5-32-549' = 'Server Operators'
        'S-1-5-32-550' = 'Print Operators'
        'S-1-5-32-551' = 'Backup Operators'
        'S-1-5-32-552' = 'Replicators'
        'S-1-5-32-554' = 'Builtin\Pre-Windows 2000 Compatible Access'
        'S-1-5-32-555' = 'Builtin\Remote Desktop Users'
        'S-1-5-32-556' = 'Builtin\Network Configuration Operators'
        'S-1-5-32-557' = 'Builtin\Incoming Forest Trust Builders'
        'S-1-5-32-558' = 'Builtin\Performance Monitor Users'
        'S-1-5-32-559' = 'Builtin\Performance Log Users'
        'S-1-5-32-560' = 'Builtin\Windows Authorization Access Group'
        'S-1-5-32-561' = 'Builtin\Terminal Server License Servers'
        'S-1-5-32-562' = 'Builtin\Distributed COM Users'
        'S-1-5-32-568' = 'Builtin\IIS_IUSRS'
        'S-1-5-32-569' = 'Builtin\Cryptographic Operators'
        'S-1-5-32-573' = 'Builtin\Event Log Readers'
        'S-1-5-32-574' = 'Builtin\Certificate Service DCOM Access'
        'S-1-5-32-575' = 'Builtin\RDS Remote Access Servers'
        'S-1-5-32-576' = 'Builtin\RDS Endpoint Servers'
        'S-1-5-32-577' = 'Builtin\RDS Management Servers'
        'S-1-5-32-578' = 'Builtin\Hyper-V Administrators'
        'S-1-5-32-579' = 'Builtin\Access Control Assistance Operators'
        'S-1-5-32-580' = 'Builtin\Remote Management Users'
    }

    #Create empty variable acltotal, loop through all OU's and save the ACL's to $acltotal
    # Using a system.collections.Generic.list is more efficient than using a array, cause the array is recreated at each turn
    $AclTotal = New-Object -TypeName 'System.Collections.Generic.List[PSCustomObject]'
    foreach ($ou in $oulist)
    {
        Write-Host ('Processing {0}' -f $ou.DistinguishedName) -ForegroundColor Green
        $acls = (Get-Acl -Path "AD:$($ou.DistinguishedName)").Access
        foreach ($acl in $acls)
        {
            #If IdentityReference matches item in $customidentifiers, change it to the friendly name
            #Otherwise just use the IdentityReference found by Get-Acl
            if ($CustomIdentifiers | Select-String "$($acl.IdentityReference.Value)" -SimpleMatch )
            {
                $IdentityReference = ($customidentifiers |
                        Select-Object -Property $acl.IdentityReference.Value).$($acl.IdentityReference.Value)
            }
            else
            {
                $IdentityReference = "$($acl.IdentityReference)"
            }

            Write-Host ('- Retrieving {0} details for {1}' -f $acl.ActiveDirectoryRights, $IdentityReference) -ForegroundColor Gray

            $FoundAcls = [PSCustomObject]@{
                OrganizationalUnit = $ou.DistinguishedName
                Principal          = $IdentityReference
                Rights             = $acl.ActiveDirectoryRights
                AppliesTo          = Get-NameForGUID $acl.InheritedObjectType
                Item               = Get-NameForGUID $acl.ObjectType
                Access             = $acl.AccessControlType
                Inheritance        = $acl.InheritanceType
                InheritanceFrom    = $acl.InheritanceFlags
            }
            $AclTotal.add($FoundAcls)
        }
    }

    #Export results to CSV file
    if ($OutputType -eq 'CSV')
    {
        if ($AclTotal.count -gt 0)
        {
            Write-Host ('Exporting {0} results to {1}' -f $AclTotal.count, $Output) -ForegroundColor Green
            $AclTotal | Sort-Object OrganizationalUnit, Principal, Rights, AppliesTo, Item, Access, Inheritance, InheritanceFrom |
                Export-Csv -Path $Output -Encoding UTF8 -Delimiter ';' -NoTypeInformation
        }
    }
    else # The OutputType is .xslx
    {
        if (-not (Get-Module -ListAvailable ImportExcel))
        {
            Write-Host 'Module ImportExcel Not installed, Download and Install for current User from PSGallery' -ForegroundColor Green
            # Settings to use TLS1.2 to download or update module from PowershellGallery since 01 April 2020
            # ref : https://devblogs.microsoft.com/powershell/powershell-gallery-tls-support/
            Write-Host 'Settings to use TLS1.2 to download or update module from PowershellGallery since 01 April 2020' -ForegroundColor 'DarkGray'
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Install-Module -Name ImportExcel -Scope CurrentUser
        }
        else # module already installed
        {
            {
                Write-Host 'Module ImportExcel available, loading' -ForegroundColor Green
                Import-Module -Name ImportExcel
            }

            #Export results to .xlsx file
            if ($AclTotal.count -gt 0)
            {
                # using a splat for more human-readable
                $ExcelParams = @{
                    Path          = $Output 
                    WorksheetName = 'OUAcls'
                    AutoSize      = $true
                    FreezeTopRow  = $true
                    TableStyle    = 'Medium6'
                    FreezePane    = $true
                    Show          = $true
                }
                $AclTotal | Sort-Object OrganizationalUnit, Principal, Rights, AppliesTo, Item, Access, Inheritance, InheritanceFrom |
                    Export-Excel @ExcelParams
            }
        }
    }
} # end Get-ActiveDirectoryOUpermissions