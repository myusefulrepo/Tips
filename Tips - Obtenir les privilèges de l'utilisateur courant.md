# Obtenir les privilèges de l'utilisateur courant

## Objectif recherché
avoir une vue synthétique des privilèges de l'utilisateur

## Voie N°1 : Whoami
On peut utiliser ma commande DOS ````WHOAMI```` et lui passer les arguments suivants ;
- ````/priv```` :  Affiche les privilèges de sécurité de l'utilisateur actuel.
- ````/fo```` : Spécifie le format de sortie Affichées. Les valeurs valides sont ````TABLE````, ````LIST````, ````CSV````. et lui préciser ````CSV````.

````powershell
whoami /priv /fo csv
"Nom de privilŠge","Description","tat"
"SeShutdownPrivilege","Arrˆter le systŠme","D‚sactiv‚"
"SeChangeNotifyPrivilege","Contourner la v‚rification de parcours","Activ‚"
"SeUndockPrivilege","Retirer l'ordinateur de la station d'accueil","D‚sactiv‚"
"SeIncreaseWorkingSetPrivilege","Augmenter une plage de travail de processus","D‚sactiv‚"
"SeTimeZonePrivilege","Changer le fuseau horaire","D‚sactiv‚"
````
Le résultat est tout sale avec des caractères qui ne correspondent pas à mon language courant.
De plus, si cela reste compréhensible, ce n'est qu'une seule [String]

Ajoutons donc la cmdlet ````ConvertFrom-Csv````

````powershell
whoami /priv /fo csv | ConvertFrom-Csv

Nom de privilŠge              Description                                  tat
----------------              -----------                                  ----
SeShutdownPrivilege           Arrˆter le systŠme                           D‚sactiv‚
SeChangeNotifyPrivilege       Contourner la v‚rification de parcours       Activ‚
SeUndockPrivilege             Retirer l'ordinateur de la station d'accueil D‚sactiv‚
SeIncreaseWorkingSetPrivilege Augmenter une plage de travail de processus  D‚sactiv‚
SeTimeZonePrivilege           Changer le fuseau horaire                    D‚sactiv‚
````

J'obtiens bien un objet (Powershell power :-) ), mais toujours ce pb de code-page.

J'ai essayé en vain d'utiliser le paramètre ````-UseCulture```` avec ````ConvertFrom-Csv````, mais j'obtiens toujours un pb de code-page.

Essayons une autre voie

## voie N°2 : La classe .net [System.Security.Principal]

````powershell
$Principal = ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent())
$Principal

Identity     : System.Security.Principal.WindowsIdentity
UserClaims   : {http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name: ASUS10\Olivier,
               http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid: S-1-5-21-3845454979-1943553122-731453197-1001,
               http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid:
               S-1-5-21-3845454979-1943553122-731453197-513, http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid:
               S-1-5-21-3845454979-1943553122-731453197-513...}
DeviceClaims : {}
Claims       : {http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name: ASUS10\Olivier,
               http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid: S-1-5-21-3845454979-1943553122-731453197-1001,
               http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid:
               S-1-5-21-3845454979-1943553122-731453197-513, http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid:
               S-1-5-21-3845454979-1943553122-731453197-513...}
Identities   : {ASUS10\Olivier}

````
pas grand chose à en tirer directement, voyons les détails

````powershell
$Principal |Get-Member
   TypeName : System.Security.Principal.WindowsPrincipal

Name          MemberType   Definition
----          ---------- ----------
AddIdentities Method     void AddIdentities(System.Collections.Generic.IEnumerable[System.Security.Claims.ClaimsIdentity] identities)
AddIdentity   Method     void AddIdentity(System.Security.Claims.ClaimsIdentity identity)
Clone         Method     System.Security.Claims.ClaimsPrincipal Clone()
Equals        Method     bool Equals(System.Object obj)
FindAll       Method     System.Collections.Generic.IEnumerable[System.Security.Claims.Claim] FindAll(System.Predicate[System.Secu...
FindFirst     Method     System.Security.Claims.Claim FindFirst(System.Predicate[System.Security.Claims.Claim] match), System.Secu...
GetHashCode   Method     int GetHashCode()
GetType       Method     type GetType()
HasClaim      Method     bool HasClaim(System.Predicate[System.Security.Claims.Claim] match), bool HasClaim(string type, string va...
IsInRole      Method     bool IsInRole(string role), bool IsInRole(System.Security.Principal.WindowsBuiltInRole role), bool IsInRo...
ToString      Method     string ToString()
WriteTo       Method     void WriteTo(System.IO.BinaryWriter writer)
Claims        Property   System.Collections.Generic.IEnumerable[System.Security.Claims.Claim] Claims {get;}
DeviceClaims  Property   System.Collections.Generic.IEnumerable[System.Security.Claims.Claim] DeviceClaims {get;}
Identities    Property   System.Collections.Generic.IEnumerable[System.Security.Claims.ClaimsIdentity] Identities {get;}
Identity      Property   System.Security.Principal.IIdentity Identity {get;}
UserClaims    Property   System.Collections.Generic.IEnumerable[System.Security.Claims.Claim] UserClaims {get;}
````

Beaucoup, d'info. Focus sur la propriété "Identities" ou "Identity"
````powershell
$Principal.Identities

AuthenticationType : NTLM
ImpersonationLevel : None
IsAuthenticated    : True
IsGuest            : False
IsSystem           : False
IsAnonymous        : False
Name               : ASUS10\Olivier
Owner              : S-1-5-21-3845454979-1943553122-731453197-1001
User               : S-1-5-21-3845454979-1943553122-731453197-1001
Groups             : {S-1-5-21-3845454979-1943553122-731453197-513, S-1-1-0, S-1-5-21-3845454979-1943553122-731453197-1008,
                     S-1-5-21-3845454979-1943553122-731453197-1006...}
Token              : 1924
AccessToken        : Microsoft.Win32.SafeHandles.SafeAccessTokenHandle
UserClaims         : {http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name: ASUS10\Olivier,
                     http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid:
                     S-1-5-21-3845454979-1943553122-731453197-1001,
                     http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid:
                     S-1-5-21-3845454979-1943553122-731453197-513, http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid:
                     S-1-5-21-3845454979-1943553122-731453197-513...}
DeviceClaims       : {}
Claims             : {http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name: ASUS10\Olivier,
                     http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid:
                     S-1-5-21-3845454979-1943553122-731453197-1001,
                     http://schemas.microsoft.com/ws/2008/06/identity/claims/primarygroupsid:
                     S-1-5-21-3845454979-1943553122-731453197-513, http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid:
                     S-1-5-21-3845454979-1943553122-731453197-513...}
Actor              :
BootstrapContext   :
Label              :
NameClaimType      : http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name
RoleClaimType      : http://schemas.microsoft.com/ws/2008/06/identity/claims/groupsid
````

Pas mal d'info, mais il reste encore à traduire les SID des groupes par leur nom. Bref, encore du boulot à faire

essayons une autre voie

## Voie N°3 : Cmdlet Get Privilège
Cette cdmlet provient du module ````PoshPrivilege````

````powershell
Import PS Module poshPrivilege
Get-Privilege
Computername         Privilege                        Accounts
------------         ---------                        --------
ASUS10               SeAssignPrimaryTokenPrivilege    {}
ASUS10               SeAuditPrivilege                 {}
ASUS10               SeBackupPrivilege                {}
ASUS10               SeBatchLogonRight                {}
ASUS10               SeChangeNotifyPrivilege          {}
ASUS10               SeCreateGlobalPrivilege          {}
ASUS10               SeCreatePagefilePrivilege        {}
ASUS10               SeCreatePermanentPrivilege       {}
ASUS10               SeCreateSymbolicLinkPrivilege    {}
ASUS10               SeCreateTokenPrivilege           {}
ASUS10               SeDebugPrivilege                 {}
ASUS10               SeImpersonatePrivilege           {}
ASUS10               SeIncreaseBasePriorityPrivilege  {}
ASUS10               SeIncreaseQuotaPrivilege         {}
ASUS10               SeInteractiveLogonRight          {}
ASUS10               SeLoadDriverPrivilege            {}
ASUS10               SeLockMemoryPrivilege            {}
ASUS10               SeMachineAccountPrivilege        {}
ASUS10               SeManageVolumePrivilege          {}
ASUS10               SeNetworkLogonRight              {}
ASUS10               SeProfileSingleProcessPrivilege  {}
ASUS10               SeRemoteInteractiveLogonRight    {}
ASUS10               SeRemoteShutdownPrivilege        {}
ASUS10               SeRestorePrivilege               {}
ASUS10               SeSecurityPrivilege              {}
ASUS10               SeServiceLogonRight              {}
ASUS10               SeShutdownPrivilege              {}
ASUS10               SeSystemEnvironmentPrivilege     {}
ASUS10               SeSystemProfilePrivilege         {}
ASUS10               SeSystemtimePrivilege            {}
ASUS10               SeTakeOwnershipPrivilege         {}
ASUS10               SeTcbPrivilege                   {}
ASUS10               SeTimeZonePrivilege              {}
ASUS10               SeUndockPrivilege                {}
ASUS10               SeDenyNetworkLogonRight          {}
ASUS10               SeDenyBatchLogonRight            {}
ASUS10               SeDenyServiceLogonRight          {}
ASUS10               SeDenyInteractiveLogonRight      {}
ASUS10               SeSyncAgentPrivilege             {}
ASUS10               SeEnableDelegationPrivilege      {}
ASUS10               SeDenyRemoteInteractiveLogonR... {}
ASUS10               SeTrustedCredManAccessPrivilege  {}
ASUS10               SeIncreaseWorkingSetPrivilege    {}
````
verbeux et trop de détails, pais très intéressant.

Utilisons le paramètre ````-CurrentUser````

````powershell
Get-Privilege -CurrentUser

Privilege                        Description                              Enabled
---------                        -----------                              -------
SeShutdownPrivilege              Arrêter le système                       False
SeChangeNotifyPrivilege          Contourner la vérification de parcours   True
SeUndockPrivilege                Retirer l’ordinateur de la station d’... False
SeIncreaseWorkingSetPrivilege    Augmenter une plage de travail de pro... False
SeTimeZonePrivilege              Changer le fuseau horaire                False
````

Impeccable ! Exactement ce que je voulais, et l'affichage se fait bien, il ne reste plus qu'à exporter dans le format que je souhaite et l'affaire est faite.

## Le mot final
Si comme moi, vous n'avez pas de cmdlet native powershell qui répond à votre besoin, et que vous devez vous rabattre sur une vieille commande DOS "legacy".
Une petite recherche sur Internet, vous permettra très certainement d'obtenir un module ou un script qui vous permettra d'atteindre l'objectif recherché en évitant les problèmes de code-page avec les commandes DOS.
