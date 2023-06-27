$OUs = Get-ADOrganizationalUnit -Filter * # Add the -SearchBase parameter to begin at a specific point
$Result = [System.Collections.Generic.List[PSObject]]::new()
ForEach ($OU In $OUs)
{
    # Gathering OU 's Acls
    $Path = 'AD:\' + $OU.DistinguishedName
    $ACLs = (Get-Acl -Path $Path).Access
    ForEach ($ACL in $ACLs)
    {
        # Retrieve only inherited Acls
        If ($ACL.IsInherited -eq $False)
        {
            # Building a PSObject
            $Properties = [PSCustomObject][Ordered]@{
                OU                    = $OU.DistinguishedName
                IdentityReference     = $ACL.IdentityReference
                ActiveDirectoryRights = $ACL.ActiveDirectoryRights
                InheritanceType       = $ACL.InheritanceType 
                IsInherited           = $ACL.IsInherited
                AccessControlType     = $ACL.AccessControlType
                InheritanceFlags      = $ACL.InheritanceFlags
                PropagationFlags      = $ALC.PropagationFlags
            }
            # Add the Psobject to $Result
            $Result.Add($Properties)
        }
    }
}

$Result | Out-GridView
$Result | Export-Csv -Path ...