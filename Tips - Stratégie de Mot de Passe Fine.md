# 1. SOMMAIRE
- [1. SOMMAIRE](#1-sommaire)
- [2. INFORMATIONS SUR LES STRATEGIES DE MOT DE PASSE FINES](#2-informations-sur-les-strategies-de-mot-de-passe-fines)
  - [2.1. Les Best-Practices](#21-les-best-practices)
  - [2.2. Exemple de Stratégie pour le Groupe "utilisateurs du domaine"](#22-exemple-de-stratégie-pour-le-groupe-utilisateurs-du-domaine)
  - [2.3. Tableau des paramètres](#23-tableau-des-paramètres)
  - [2.4. | PasswordHistoryCount        | 12                               | Historique du mot de passe : 12 | Optionnel |](#24--passwordhistorycount---------12--------------------------------historique-du-mot-de-passe--12--optionnel-)
  - [2.5. Exemple de Stratégie pour le groupe "Admins du domaine"](#25-exemple-de-stratégie-pour-le-groupe-admins-du-domaine)
  - [2.6. Création du PSO et application à un groupe en Mode GUI](#26-création-du-pso-et-application-à-un-groupe-en-mode-gui)
    - [2.6.1. PSO (Personal Security Objet) valeur par défaut](#261-pso-personal-security-objet-valeur-par-défaut)
    - [2.6.2. Exemple de PSO Personnalisée](#262-exemple-de-pso-personnalisée)
    - [2.6.3. Visualisation dans ADAC](#263-visualisation-dans-adac)
    - [2.6.4. Visualisation dans ADUC](#264-visualisation-dans-aduc)
  - [2.7. Création du PSO et application à un groupe en Mode Powershell](#27-création-du-pso-et-application-à-un-groupe-en-mode-powershell)
    - [2.7.1. Création et Application](#271-création-et-application)
    - [2.7.2. propriétés dans un PSO par défaut](#272-propriétés-dans-un-pso-par-défaut)
    - [2.7.3. Propriétés dans un PSO dont les propriétés DisplayName et displayNamePrintable ont été modifiées](#273-propriétés-dans-un-pso-dont-les-propriétés-displayname-et-displaynameprintable-ont-été-modifiées)
    - [2.7.4. Récupérer toutes les stratégies](#274-récupérer-toutes-les-stratégies)
    - [2.7.5. Récupérer Les liens "AppliedTo" pour chaque PSO (avec une sortie par défaut)](#275-récupérer-les-liens-appliedto-pour-chaque-pso-avec-une-sortie-par-défaut)
    - [2.7.6. Récupérer Les liens "AppliedTo" pour chaque PSO (avec une sortie personnalisée)](#276-récupérer-les-liens-appliedto-pour-chaque-pso-avec-une-sortie-personnalisée)
    - [2.7.7. Obtenir la Stratégie de mot de passe résultante pour un utilisateur](#277-obtenir-la-stratégie-de-mot-de-passe-résultante-pour-un-utilisateur)
    - [2.7.8. Identification des membres d'une stratégie de mot de passe fine](#278-identification-des-membres-dune-stratégie-de-mot-de-passe-fine)
- [3. LE MOT FINAL](#3-le-mot-final)
# 2. INFORMATIONS SUR LES STRATEGIES DE MOT DE PASSE FINES
<!-- title: INFORMATIONS SUR LES STRATEGIES DE MOT DE PASSE FINES -->

## 2.1. Les Best-Practices

Lors de l'implémentation de Stratégies de Mots de passe fines, vous devez penser à plusieurs choses avant de les créer et les appliquer. Ci-après, 8 points à garder en mémoire.

1. Chaque PSO doit avoir un numéro d’index de préséance. Les PSOs avec un index de **priorité plus élevé (1)** ont priorité sur ceux avec un index de priorité plus faible (ex. 10s).

2. Les PSOs peuvent être **appliquées à des utilisateurs et à des groupes de sécurité**
Il est fortement préconisé d'***appliquer les PSOs à des groupes***.

3. Bien que les PSOs puissent être appliqués à plusieurs utilisateurs et groupes, **un seul PSO s’applique à un compte utilisateur**.
Le PSO dont l’indice de priorité est le plus élevé (le plus proche de 1) s’appliquera.
L’attribut *msDS-ResultantPSO* dans AD présente le PSO résultant pour un objet utilisateur si vous voulez le vérifier.

4. Les **PSOs liés aux comptes utilisateurs ont toujours la priorité sur ceux liés aux groupes**.

5. Assurez-vous que tous les PSOs ont un **numéro d’index de priorité unique**.
Si deux PSO ont le même numéro d’indice de priorité, le PSO avec le GUID le plus bas est appliqué.

6. Si vous voulez appliquer un PSO à tous les utilisateurs d’une unité organisationnelle (OU), vous devrez **créer un groupe de sécurité** qui contient tous les membres de l’OU et appliquer le PSO au groupe. Si les utilisateurs de l’OU changent, vous devez mettre à jour le groupe.

7. [](#7.) Utilisez les paramètres de la politique de verrouillage des mots de passe et des comptes dans la GPO ***"Default Domain Policy"*** pour la plupart des utilisateurs, et ne créez des PSOs que pour des groupes d’utilisateurs spécifiques plus petits.
>[Nota : ] Plus précisément, créer une Stratégie de Domaine personnalisée qui sera prioritaire sur la "Default Domain Policy". En effet, les Best Practices recommandent de **ne pas modifier la Default Domain Policy**.

8. Donnez aux PSOs des **noms significatifs**.

## 2.2. Exemple de Stratégie pour le Groupe "utilisateurs du domaine"

Ci-après les valeurs pour le Groupe "Utilisateurs du domaine", qui est le groupe par défaut pour tous les comptes utilisateurs.

2.3. Tableau des paramètres
----
| Nom de l'élément | Valeur | Description | Optionnel/Obligatoire |
| :-------------------------- | :------------------------------- | :------------------------------------------- | :---: |
| Name                        | "DomainUsersPSO"                 | Nom | Obligatoire |
| DisplayName                 | "PSO for Domain Users"           | Nom d'affichage | Optionnel |
| Description                 | "Stratégie de mots de passe pour les membres du groupe Utilisateurs de Domaine" | Optionnel |
| Precedence                  | 500                              | Poids | Obligatoire |
| ComplexityEnabled           | $true                            | complexité activée | Optionnel |
| ReversibleEncryptionEnabled | $false                           | Pas de Chiffrement réversible | Optionnel |
| MinPasswordLength           | 10                               | Longueur mini mot de passe : 10 caractères | Optionnel |
| LockoutThreshold            | 10                               | Seuil de verrouillage du compte : 10 mauvais mots de passe | Optionnel |
| LockoutDuration             | [TimeSpan]::Parse("0.00:30:00")  | Durée de verrouillage du compte 30 min | Optionnel |
| LockoutObservationWindow    | [TimeSpan]::Parse("0.00:15:00")  | Réinitialisation du compteur de verrouillage du compte après 15 min | Optionnel |
| MinPasswordAge              | [TimeSpan]::Parse("0.00:10:00")  | L'utilisateur ne peut pas rechanger de mot de passe avant 10 Min | Optionnel |
| MaxPasswordAge              | [TimeSpan]::Parse("60.00:00:00") | 42 Jours | Optionnel |
2.4. | PasswordHistoryCount        | 12                               | Historique du mot de passe : 12 | Optionnel |
---

Conformément à ce qu'énoncé au [Point 7](#7.) ci-avant, ces éléments de paramétrages pour le groupe "Utilisateurs du domaine" sont à appliquer via une Stratégie de groupe (GPO) prenant la priorité par rapport à la "Default Domain Policy".


## 2.5. Exemple de Stratégie pour le groupe "Admins du domaine"

Il est élégant d'utiliser un ***Splat*** pour définir l'ensemble des paramètres plutôt que d'avoir une cmdlet suivie d'un grand nombre de paramètres.

````Powershell
$FineGrainedParamsDomainAdmins = @{
    Name                        = "DomainAdminsPSO"                # Nom
    DisplayName                 = "PSO for Domain Users"           # Nom d'affichage
    Description                 = "Stratégie de mots de passe pour les membres du groupe Admins du Domaine"
    Precedence                  = 100                              # Poids
    ComplexityEnabled           = $true                            # complexité activée
    ReversibleEncryptionEnabled = $false                           # Pas de Chiffrement réversible
    MinPasswordLength           = 12                               # Longueur mini mot de passe : 10 caractères
    LockoutThreshold            = 10                               # Seuil de verrouillage du compte : 10 mauvais mots de passe
    LockoutDuration             = [TimeSpan]::Parse("0.00:30:00")  # Durée de verrouillage du compte 30 min
    LockoutObservationWindow    = [TimeSpan]::Parse("0.00:15:00")  # Réinitialisation du compteur de verrouillage du compte après 15 min
    MinPasswordAge              = [TimeSpan]::Parse("0.00:10:00")  # L'utilisateur ne peut pas rechanger de mot de passe avant 10 Min
    MaxPasswordAge              = [TimeSpan]::Parse("60.00:00:00") # 30 Jours
    PasswordHistoryCount        = 24                               # Historique du mot de passe : 12
                                }
````

Voir plus loin pour l'utilisation de ce ***splat*** avec les cmldet Powershell

## 2.6. Création du PSO et application à un groupe en Mode GUI

La création et l'application se fait avec ADAC (Active Directory Admin Center)

### 2.6.1. PSO (Personal Security Objet) valeur par défaut
![PSO-Vue par défaut](./Images/PSO-Default.jpg)
Ici sur un AD Niveau fonctionnel 2016

### 2.6.2. Exemple de PSO Personnalisée
![PSO-Vue personnalisée](./Images/PSO-SettingsExample.jpg)

### 2.6.3. Visualisation dans ADAC
![ADUC-Vue PSO](./Images/ADAC-VuePSO.jpg)

### 2.6.4. Visualisation dans ADUC
![ADUC-Vue PSO](./Images/ADUC-VuePSO.jpg)
En passant par l’éditeur d’attributs, ses paramètres peuvent être modifiés


## 2.7. Création du PSO et application à un groupe en Mode Powershell

### 2.7.1. Création et Application

````Powershell
<# Création du PSO avec les paramètres du Splat $FineGrainedParamsDomainAdmins#>
New-ADFineGrainedPasswordPolicy @FineGrainedParamsDomainAdmins
<# Application du PSO à un groupe de sécurité#>
Add-ADFineGrainedPasswordPolicySubject -Identity "DomainAdminsPSO" -Subjects "Admins du Domaine"
````
### 2.7.2. propriétés dans un PSO par défaut

````Powershell
Get-ADFineGrainedPasswordPolicy -Identity test -Properties *
<#
AppliesTo                                : {CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL}
CanonicalName                            : LAB.LOCAL/System/Password Settings Container/test
CN                                       : test
ComplexityEnabled                        : True
Created                                  : 01/02/2021 08:47:27
createTimeStamp                          : 01/02/2021 08:47:27
Deleted                                  :
Description                              :
DisplayName                              :
DistinguishedName                        : CN=test,CN=Password Settings Container,CN=System,DC=LAB,DC=LOCAL
dSCorePropagationData                    : {01/02/2021 08:47:27, 01/01/1601 01:00:00}
instanceType                             : 4
isDeleted                                :
LastKnownParent                          :
LockoutDuration                          : 00:30:00
LockoutObservationWindow                 : 00:30:00
LockoutThreshold                         : 0
MaxPasswordAge                           : 42.00:00:00
MinPasswordAge                           : 1.00:00:00
MinPasswordLength                        : 7
Modified                                 : 01/02/2021 08:47:27
modifyTimeStamp                          : 01/02/2021 08:47:27
msDS-LockoutDuration                     : -18000000000
msDS-LockoutObservationWindow            : -18000000000
msDS-LockoutThreshold                    : 0
msDS-MaximumPasswordAge                  : -36288000000000
msDS-MinimumPasswordAge                  : -864000000000
msDS-MinimumPasswordLength               : 7
msDS-PasswordComplexityEnabled           : True
msDS-PasswordHistoryLength               : 24
msDS-PasswordReversibleEncryptionEnabled : False
msDS-PasswordSettingsPrecedence          : 1000
msDS-PSOAppliesTo                        : {CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL}
Name                                     : test
nTSecurityDescriptor                     : System.DirectoryServices.ActiveDirectorySecurity
ObjectCategory                           : CN=ms-DS-Password-Settings,CN=Schema,CN=Configuration,DC=LAB,DC=LOCAL
ObjectClass                              : msDS-PasswordSettings
ObjectGUID                               : 7c95c67e-f678-4f90-9a37-5af1b97b9a8a
PasswordHistoryCount                     : 24
Precedence                               : 1000
ProtectedFromAccidentalDeletion          : True
ReversibleEncryptionEnabled              : False
sDRightsEffective                        : 15
uSNChanged                               : 434455
uSNCreated                               : 434452
whenChanged                              : 01/02/2021 08:47:27
whenCreated                              : 01/02/2021 08:47:27
#>
````

### 2.7.3. Propriétés dans un PSO dont les propriétés DisplayName et displayNamePrintable ont été modifiées

````Powershell
Get-ADFineGrainedPasswordPolicy -Identity PSO-DomainAdmins -Properties *
<#
AppliesTo                                : {CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL}
CanonicalName                            : LAB.LOCAL/System/Password Settings Container/PSO-DomainAdmins
CN                                       : PSO-DomainAdmins
ComplexityEnabled                        : True
Created                                  : 01/02/2021 08:33:18
createTimeStamp                          : 01/02/2021 08:33:18
Deleted                                  :
Description                              : Stratégie de mot de passe pour le Groupe (Builtin) : Admins du domaine
DisplayName                              : PSO-DomainAdmins
displayNamePrintable                     : PSO-DomainAdmins
DistinguishedName                        : CN=PSO-DomainAdmins,CN=Password Settings Container,CN=System,DC=LAB,DC=LOCAL
dSCorePropagationData                    : {01/02/2021 08:33:19, 01/02/2021 08:33:19, 01/01/1601 01:00:00}
instanceType                             : 4
isDeleted                                :
LastKnownParent                          :
LockoutDuration                          : 00:30:00
LockoutObservationWindow                 : 00:30:00
LockoutThreshold                         : 5
MaxPasswordAge                           : 30.00:00:00
MinPasswordAge                           : 1.00:00:00
MinPasswordLength                        : 14
Modified                                 : 01/02/2021 08:45:36
modifyTimeStamp                          : 01/02/2021 08:45:36
msDS-LockoutDuration                     : -18000000000
msDS-LockoutObservationWindow            : -18000000000
msDS-LockoutThreshold                    : 5
msDS-MaximumPasswordAge                  : -25920000000000
msDS-MinimumPasswordAge                  : -864000000000
msDS-MinimumPasswordLength               : 14
msDS-PasswordComplexityEnabled           : True
msDS-PasswordHistoryLength               : 24
msDS-PasswordReversibleEncryptionEnabled : False
msDS-PasswordSettingsPrecedence          : 100
msDS-PSOAppliesTo                        : {CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL}
Name                                     : PSO-DomainAdmins
nTSecurityDescriptor                     : System.DirectoryServices.ActiveDirectorySecurity
ObjectCategory                           : CN=ms-DS-Password-Settings,CN=Schema,CN=Configuration,DC=LAB,DC=LOCAL
ObjectClass                              : msDS-PasswordSettings
ObjectGUID                               : 6528e4f5-d1ba-4cfb-b45e-17465ff014f0
PasswordHistoryCount                     : 24
Precedence                               : 100
ProtectedFromAccidentalDeletion          : True
ReversibleEncryptionEnabled              : False
sDRightsEffective                        : 15
uSNChanged                               : 434445
uSNCreated                               : 434434
whenChanged                              : 01/02/2021 08:45:36
whenCreated                              : 01/02/2021 08:33:18
#>
````

### 2.7.4. Récupérer toutes les stratégies

````Powershell
$AllPSOs = Get-ADFineGrainedPasswordPolicy -Filter *
$AllPSOs
<#
AppliesTo                   : {CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL}
ComplexityEnabled           : True
DistinguishedName           : CN=PSO-DomainAdmins,CN=Password Settings Container,CN=System,DC=LAB,DC=LOCAL
LockoutDuration             : 00:30:00
LockoutObservationWindow    : 00:30:00
LockoutThreshold            : 5
MaxPasswordAge              : 30.00:00:00
MinPasswordAge              : 1.00:00:00
MinPasswordLength           : 14
Name                        : PSO-DomainAdmins
ObjectClass                 : msDS-PasswordSettings
ObjectGUID                  : 6528e4f5-d1ba-4cfb-b45e-17465ff014f0
PasswordHistoryCount        : 24
Precedence                  : 100
ReversibleEncryptionEnabled : False

AppliesTo                   : {CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL}
ComplexityEnabled           : True
DistinguishedName           : CN=test,CN=Password Settings Container,CN=System,DC=LAB,DC=LOCAL
LockoutDuration             : 00:30:00
LockoutObservationWindow    : 00:30:00
LockoutThreshold            : 0
MaxPasswordAge              : 42.00:00:00
MinPasswordAge              : 1.00:00:00
MinPasswordLength           : 7
Name                        : test
ObjectClass                 : msDS-PasswordSettings
ObjectGUID                  : 7c95c67e-f678-4f90-9a37-5af1b97b9a8a
PasswordHistoryCount        : 24
Precedence                  : 1000
ReversibleEncryptionEnabled : False
#>
````

### 2.7.5. Récupérer Les liens "AppliedTo" pour chaque PSO (avec une sortie par défaut)

````Powershell
$AllPSOs = Get-ADFineGrainedPasswordPolicy -Filter *
$AllAppliedTo = foreach ($PSO in $AllPSOs)
    {
    Get-ADFineGrainedPasswordPolicySubject -Identity $PSO.Name
$AllAppliedTo
````

Et la sortie

````Powershell
<#
DistinguishedName : CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL
Name              : Admins du domaine
ObjectClass       : group
ObjectGUID        : 081b94f4-7beb-41c8-b771-4257b10129a1
SamAccountName    : Admins du domaine
SID               : S-1-5-21-310437918-1906062273-1680514792-512

DistinguishedName : CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL
Name              : Admins du domaine
ObjectClass       : group
ObjectGUID        : 081b94f4-7beb-41c8-b771-4257b10129a1
SamAccountName    : Admins du domaine
SID               : S-1-5-21-310437918-1906062273-1680514792-512
#>
````

### 2.7.6. Récupérer Les liens "AppliedTo" pour chaque PSO (avec une sortie personnalisée)

````Powershell
$AllAppliedTo = foreach ($PSO in $AllPSOs)
    {
    Get-ADFineGrainedPasswordPolicySubject -Identity $PSO.Name |
        Select-Object -Property @{Label = "PSOName"     ; Expression = {$PSO.Name}},
                                @{Label = "AppliesTo"   ; Expression = {$PSO.AppliesTo}},
                                @{Label = "ObjectClass" ; Expression = {$_.ObjectClass}},
                                @{Label = "SID"         ; Expression = {$_.SID}}
    }
$AllAppliedTo
````
Et la sortie

````Powershell
<#
PSOName          AppliesTo                                     ObjectClass SID
-------          ---------                                     ----------- ---
PSO-DomainAdmins CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL group       S-1-5-21-310437918-1906062273-1680514792-512
test             CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL group       S-1-5-21-310437918-1906062273-1680514792-512
#>
````

### 2.7.7. Obtenir la Stratégie de mot de passe résultante pour un utilisateur

````Powershell
Get-ADUserResultantPasswordPolicy -Identity Administrateur
Get-ADUserResultantPasswordPolicy -Identity FakeAdminAccount
````

Et la sortie

````Powershell
<#
AppliesTo                   : {CN=Admins du domaine,CN=Users,DC=LAB,DC=LOCAL}
ComplexityEnabled           : True
DistinguishedName           : CN=PSO-DomainAdmins,CN=Password Settings Container,CN=System,DC=LAB,DC=LOCAL
LockoutDuration             : 00:30:00
LockoutObservationWindow    : 00:30:00
LockoutThreshold            : 5
MaxPasswordAge              : 30.00:00:00
MinPasswordAge              : 1.00:00:00
MinPasswordLength           : 14
Name                        : PSO-DomainAdmins
ObjectClass                 : msDS-PasswordSettings
ObjectGUID                  : 6528e4f5-d1ba-4cfb-b45e-17465ff014f0
PasswordHistoryCount        : 24
Precedence                  : 100
ReversibleEncryptionEnabled : False
#>
````

### 2.7.8. Identification des membres d'une stratégie de mot de passe fine

````Powershell
Get-ADFineGrainedPasswordPolicy -Identity PSO-DomainAdmins |
    Select-Object -ExpandProperty AppliesTo |
    Get-ADGroupMember

    ````
Et la sortie

````Powershell
<#
distinguishedName : CN=Administrateur,CN=Users,DC=LAB,DC=LOCAL
name              : Administrateur
objectClass       : user
objectGUID        : 3d23a39d-f92b-4011-a688-d241f5bd2196
SamAccountName    : Administrateur
SID               : S-1-5-21-310437918-1906062273-1680514792-500

distinguishedName : CN=FakeAdminAccount,OU=Visiteurs,DC=LAB,DC=LOCAL
name              : FakeAdminAccount
objectClass       : user
objectGUID        : fc040a9d-5fa0-412e-8a4e-5ab3dc54fee7
SamAccountName    : FakeAdminAccount
SID               : S-1-5-21-310437918-1906062273-1680514792-1226
#>
````

# 3. LE MOT FINAL
J'espère que ce tour rapide concernant les Stratégies de Mot de passe fine aura été informatif et utile.
