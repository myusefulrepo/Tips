# differents ways to get the AD groups a user is member of

## the easy way

````Powershell
$User = 'Administrateur'

Get-ADUser -Identity $User -Properties MemberOf

DistinguishedName : CN=Administrateur, CN=Users, DC=LAB, DC=LAN
Enabled : True
GivenName : 
MemberOf : {CN=Propriétaires créateurs de la stratégie de groupe, CN=Users, DC=LAB, DC=LAN, CN=Admins du domaine, CN=Users, DC=LAB, DC=LAN, CN=Administrateurs de 
                    l’entreprise,CN=Users,DC=LAB,DC=LAN, CN=Administrateurs,CN=Builtin,DC=LAB,DC=LAN}
Name              : Administrateur
ObjectClass       : user
ObjectGUID        : 39cf92a3-2af7-45c2-93ac-893e6d8e84d9
SamAccountName    : Administrateur
SID               : S-1-5-21-3143150007-2341727377-2275284598-500
Surname           : 
UserPrincipalName : 
````
Of course, the result return more properties that need

````powershell
Get-ADUser -Identity $User -Properties MemberOf | Select-Object -Property MemberOf

MemberOf
--------
{CN=Propriétaires créateurs de la stratégie de groupe,CN=Users,DC=LAB,DC=LAN, CN=Admins du domaine,CN=Users,DC=LAB,DC=LAN, CN=Administrateurs de l’entreprise,CN=Users,DC=LA...
````

It's not a clean way but, if i do the following : 

````powershell
Get-ADUser -Identity $User -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf

CN=Propriétaires créateurs de la stratégie de groupe,CN=Users,DC=LAB,DC=LAN
CN=Admins du domaine,CN=Users,DC=LAB,DC=LAN
CN=Administrateurs de l’entreprise,CN=Users,DC=LAB,DC=LAN
CN=Administrateurs,CN=Builtin,DC=LAB,DC=LAN
````

## An alternative

As an alternative of the first way, there is the following :

````powershell
(Get-ADUser -Identity $User -properties MemberOf).MemberOf

CN=Propriétaires créateurs de la stratégie de groupe,CN=Users,DC=LAB,DC=LAN
CN=Admins du domaine,CN=Users,DC=LAB,DC=LAN
CN=Administrateurs de l’entreprise,CN=Users,DC=LAB,DC=LAN
CN=Administrateurs,CN=Builtin,DC=LAB,DC=LAN
````
This second way is shorter. 

## a third way

There is another way : using the Get-ADPrincipalMemberShip cmdlet
````Powershell
(Get-ADPrincipalGroupMembership $User).Name
Utilisateurs du domaine
Administrateurs
Administrateurs de l’entreprise
Admins du domaine
Propriétaires créateurs de la stratégie de groupe
````

## and finally a more complex way

There is another way, more complex. 

````powershell
Get-ADUser $User |
    Get-ADUser -Properties TokenGroups | 
    Select-Object -ExpandProperty TokenGroups | 
    ForEach-Object { $_.Translate([System.Security.Principal.NTAccount]).Value }

BUILTIN\Administrateurs
BUILTIN\Utilisateurs
LAB\Groupe de réplication dont le mot de passe RODC est refusé
LAB\Administrateurs de l’entreprise
LAB\Utilisateurs du domaine
LAB\Propriétaires créateurs de la stratégie de groupe
LAB\Admins du domaine
LAB\Protected Users
````

There's actually a tokenGroups attribute on the user : [Token-Groups attribute](https://learn.microsoft.com/en-us/windows/win32/adschema/a-tokengroups)

This ends up being a lot faster than LDAP_MATCHING_RULE_IN_CHAIN or Recursively solving this, but it's still tricky just because of cmdlet support. 

TokenGroups contains the list of SIDs, complete with nesting. The above is the easiest way - but will throw an error for BUILTIN groups. This is my preferred way if I just need group names.


## But what about performance ?

For my tests, I'm using [this function](https://gist.github.com/Rapidhands/e80c921baa08c5506d832e6fed73391b) with powershell 5.1.

````powershell
$User = "Administrateur"

Measure-MyScript -Name "ExpandProperty" -Unit ms -Repeat 100 -ScriptBlock {
Get-ADUser -Identity $User -Properties MemberOf | Select -ExpandProperty MemberOf 
}

Measure-MyScript -Name ".MemberOf" -Unit ms -Repeat 100 -ScriptBlock {
(Get-ADUser -Identity $User -properties MemberOf).MemberOf
}

Measure-MyScript -Name "TokenGroups" -Unit ms -Repeat 100 -ScriptBlock {
Get-ADUser $User |
    Get-ADUser -Properties TokenGroups | 
    Select-Object -ExpandProperty tokenGroups | 
    ForEach-Object { $_.Translate([System.Security.Principal.NTAccount]).Value }
}
Measure-MyScript -Name "Get-ADGroupMemberShip" -Unit ms -Repeat 100 -ScriptBlock {
(Get-ADPrincipalGroupMembership $User).Name
}
````
and the result was : 
````ouptut
name                  Avg                    Min                    Max                   
----                  ---                    ---                    ---                   
ExpandProperty        3,0385 Milliseconds    2,1478 Milliseconds    4,995 Milliseconds    
.MemberOf             3,2487 Milliseconds    2,3004 Milliseconds    6,0045 Milliseconds   
TokenGroups           7,2574 Milliseconds    5,5111 Milliseconds    10,602 Milliseconds   
Get-ADGroupMemberShip 3307,7151 Milliseconds 2355,9896 Milliseconds 6955,3997 Milliseconds
````

Using `-ExpandProperty` or `.MemberOf` way give similar and fastest results.
Using the `TokenGroups` way takes more time but `Get-ADGroupMembership` is definitely the slowest way.


<span style="color:green;font-weight:700;font-size:20px">[Nota]</span>  : TokenGroups retrieves all transitive groups a user is a member of. MemberOf retrieves groups a user is a direct member of.
Thanks to [u/raip](https://new.reddit.com/user/raip/) for this precision. Here's an example: https://imgur.com/aXxhvlO - for user account in its organization, `Get-ADUser memberOf` is missing 34 groups that `tokenGroups` collects (we have a fair amount of group nesting).

Nested groups should indeed be taken into account. In the tests I had conducted, I did not have nested groups.
In real organization, it's indeed very common for a user to be a member of a group, itself a member of a larger group.

I have a function in my toolbox
````powershell
Function Get-ADUserNestedGroups
{
    Param
    (
        [string]$DistinguishedName,
        [array]$Groups = @()
    )

    #Get the AD object, and get group membership.
    $ADObject = Get-ADObject -Filter "DistinguishedName -eq '$DistinguishedName'" -Properties memberOf, DistinguishedName
    
    #If object exists.
    If($ADObject)
    {
        #Enumerate through each of the groups.
        Foreach($GroupDistinguishedName in $ADObject.memberOf)
        {
            #Get member of groups from the enummerated group.
            $CurrentGroup = Get-ADObject -Filter "DistinguishedName -eq '$GroupDistinguishedName'" -Properties memberOf, DistinguishedName
       
            #Check if the group is already in the array.
            If (($Groups | Where-Object {$_.DistinguishedName -eq $GroupDistinguishedName}).Count -eq 0)
            {
                #Add group to array.
                $Groups +=  $CurrentGroup

                #Get recursive groups.      
                $Groups = Get-ADUserNestedGroups -DistinguishedName $GroupDistinguishedName -Groups $Groups
            }
        }
    }

    #Return groups.
    Return $Groups
}
````
this return something like the following : 
````powershell
Get-ADUserNestedGroups -DistinguishedName (Get-ADUser -Identity $User).DistinguishedName

DistinguishedName                                       Name             ObjectClass ObjectGUID                          
-----------------                                       ----             ----------- ----------                          
CN=NotnestedGroup,OU=Groups,OU=LABUsers,DC=LAB,DC=LAN   NotnestedGroup   group       9a725f59-bcc1-4f08-96a3-5bb8599ad60a
CN=Interdisciplines,OU=Groups,OU=LABUsers,DC=LAB,DC=LAN Interdisciplines group       6a6d1196-663d-43fd-add5-bda08d863467
CN=Physique,OU=Groups,OU=LABUsers,DC=LAB,DC=LAN         Physique         group       0b695ea4-92b0-41a2-84e2-b55563b8e1ba
CN=Professeurs,OU=Groups,OU=LABUsers,DC=LAB,DC=LAN      Professeurs      group       1e21a337-0848-4c9b-9921-a87819e84d6c
CN=Math,OU=Groups,OU=LABUsers,DC=LAB,DC=LAN             Math             group       8f0facd0-d838-4f22-b78a-54165a6f621
````

But about the performance ? 

````Powershell
Measure-MyScript -Name "function" -Unit ms -Repeat 10 -ScriptBlock {
Get-ADUserNestedGroups -DistinguishedName (Get-ADUser -Identity $User).DistinguishedName
}

Measure-MyScript -Name "TokenGroups" -Unit ms -Repeat 100 -ScriptBlock {
Get-ADUser $User |
    Get-ADUser -Properties TokenGroups | 
    Select-Object -ExpandProperty tokenGroups | 
    ForEach-Object { $_.Translate([System.Security.Principal.NTAccount]).Value }
}

name        Avg                 Min                 Max                 
----        ---                 ---                 ---                 
TokenGroups 6,9536  Milliseconds  5,2513 Milliseconds 12,4522 Milliseconds
function    25,6329 Milliseconds 21,045  Milliseconds 31,2382 Milliseconds
````

There is no doubt that using `TokenGroups` is faster than the function.

<span style="color:green;font-weight:700;font-size:20px">[Nota]</span>  : I've noticed a difference point between the function and the "complex way". This one returns an additional group `BUILTIN\Users` not returned by the function or the other ways.

## Final Word

Keep in mind that if the "complex way" seems to be complex at the first look, it's the more efficient way to find all groups a user is member of including nested groups. This will be even more obvious as the number of nested groups increases.

````Powershell
Get-ADUser $User |
    Get-ADUser -Properties TokenGroups | 
    Select-Object -ExpandProperty tokenGroups | 
    ForEach-Object { $_.Translate([System.Security.Principal.NTAccount]).Value }
    ````
