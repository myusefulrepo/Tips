<#
 .Synopsis
    Script de report détaillé sur les serveurs DHCP

 .DESCRIPTION
    Script de report détaillé sur les serveurs DHCP
    Toutes les informations recueillies sont dynamiques : Aucune information n'est demandée à l'utilisateur

    - Collecte dynamique des serveurs DHCP dans le domaine Active Directory
    - Collecte dynamique des Scopes
    - Collecte dynamique des Stats pour les Scopes
    - Collecte dynamique des informations concernant la DB DHCP
    - Collecte dynamique des informations sur les journaux d'audit
    - Collecte dynamique des informations sur Options Serveur
    - Collecte Dynamique des informations sur le paramétrage des paramètres DNS
    - Collecte Dynamique des informations sur le paramétrage du DHCP failover
    - Collecte Dynamique des informations sur les paramètres des serveurs DHCP
    - Collecte Dynamique des informations sur Options Etendues
    - Collecte Dynamique des informations sur IP réservées
    - Collecte Dynamique des informations sur les exclusions
    - Génération du Rapport au format Html avec l'ensemble de ces informations
        Utilise le module Powershell PSWriteHtml pour les sorties

    Les informations importantes et conformes apparaissent sur fond vert
    Les informations importantes et conforme, mais non "standards" apparaissent sur fond orange
    Les informations importantes non conformes apparaissent sur fond rouge

 .INPUTS
    Aucune

 .OUTPUTS
    Fichier Rapport au format Html
    Localisation par défaut : $PSScriptRoot (répertoire courant du script)

 .NOTES
    Auteur             : O. FERRIERE
    Date               : 27/07/2020
    Version            : 1.1
    Changement/version : 1.0 22/07/2020 - Version Initiale - basée sur les infos et l'exemple suivant : https://evotec.xyz/active-directory-dhcp-report-to-html-or-email-with-zero-html-knowledge/
                         1.1 27/07/2020 - Amélioration sortie après Tests approfondis et corrections sur DHCP Failover

 .EXAMPLE
    .\DHCP_Report.ps1
    Exécute le script et génère le rapport

 .EXAMPLE
    Get-Help .\DHCP_Report.ps1 -Full
    Aide complète sur ce script
 #>

#region Collecte dynamique des serveurs DHCP dans le domaine Active Directory
Write-Host "Collecte des serveurs DHCP du domaine... " -ForegroundColor Green -NoNewline
$DHCPServers = Get-DhcpServerInDC |
    Select-Object -Property @{Label = "IpAddress"          ; Expression = { $_.IpAddress } },
    @{Label = "DnsName"          ; Expression = { $_.DnsName } }
Write-Host "Terminé" -ForegroundColor Yellow
# obtention du nom de domaine courant
Write-Host "Collecte du nom de domaine : " -ForegroundColor Green -NoNewline
$Domain = (Get-ADDomain).DnsRoot
Write-Host "$Domain" -ForegroundColor Yellow
#endregion Collecte dynamique des serveurs DHCP dans le domaine Active Directory

#region Vérification si le module est installé, si non téléchargement
Write-Host "Vérification que le module PSWriteHtml est installé" -ForegroundColor Green
If (-not (Get-Module -ListAvailable -Name PSWriteHtml))
{
    # On fait l'installation pour l'utilisateur courant, on pourrait le faire pour tous les utilisateurs de la machine tout aussi bien, mais il faudrait pour ce faire exécuter le script en "Run As Administrator"
    Try
    {
        Write-Host "Le module PSWriteHtml n'est pas installé" -ForegroundColor yellow
        Write-Host "Téléchargement et installation ... : " -ForegroundColor Green -NoNewline
        Install-Module PSWriteHTML -Force -Scope CurrentUser
        Write-Host "Terminé" -ForegroundColor Yellow
    }
    Catch
    {
        Write-Host "Le module n'a pu être installé. Fin du script." -ForegroundColor Red
        Write-Host "Une erreur est survenue. Message d'erreur : $_." -ForegroundColor Red
        Break
    }
}
#endregion Vérification si le module est installé, si non téléchargement

#region Importation du module pour avoir les cmdlets disponibles
Write-Host "Import du module PSWriteHtml ... " -ForegroundColor Green -NoNewline
Import-Module PSWriteHTML
Write-Host "Terminé" -ForegroundColor Yellow
Write-Host "Import du module DHCPServer... " -ForegroundColor Green -NoNewline
Import-Module DhcpServer
Write-Host "Terminé" -ForegroundColor Yellow
#endregion Importation du module pour avoir les cmdlets disponibles

#region Paramétrage du comportement par défaut de certaines cmdlets
Write-Host "Paramétrage du comportement par défaut de certaines cmdlets : " -ForegroundColor Green -NoNewline
$PSDefaultParameterValues = @{
    "New-HTMLSection:HeaderBackGroundColor" = "Green"
    "New-HTMLSection:CanCollapse"           = $true
}
Write-Host "Terminé" -ForegroundColor Yellow
#endregion Paramétrage du comportement par défaut de certaines cmdlets

#region Sortie HTML d'informations multiples dans différents onglets d'une même page html
$ReportPath = "$PSScriptRoot\DHCPReport-du-$(Get-Date -f "dd-MM-yyyy").html"
Write-Host "Collecte des Info et génération du rapport ..." -ForegroundColor Green -NoNewline
New-HTML -FilePath $ReportPath -Online -ShowHTML {
    # 1er Onglet Sommaire
    New-HTMLTab -Name 'Sommaire' {
        New-HTMLSection -HeaderText "TOUS LES SERVEURS DHCP du domaine $Domain" {
            # Ici on va mettre les informations qu'on a préalablement mis dans la variable $DHCPServers
            New-HTMLTable -DataTable $DHCPServers {
                New-TableContent -ColumnName "IpAddress" -Alignment center
                New-TableContent -ColumnName "DnsName"   -Alignment center -Color white -BackGroundColor Green
            }#end-newhtmltable
        }
        # Ici on va mettre les informations concernant la DB DHCP, les info d'audit, les paramètres d'enregistrement DNS, le failover, les autres paramètres du DHCP et ce pour chaque serveur DHCP
        foreach ($Server in $DHCPServers)
        {
            #region Collecte dynamique des informations concernant la DB DHCP
            try
            {
                $Database = Get-DhcpServerDatabase -ComputerName $Server.DnsName |
                    Select-Object -Property @{Label = "BackupInterval"     ; Expression = { $_.BackupInterval } },
                    @{Label = "BackupPath"         ; Expression = { $_.BackupPath } },
                    @{Label = "CleanupInterval"    ; Expression = { $_.CleanupInterval } },
                    @{Label = "FileName"           ; Expression = { $_.FileName } },
                    @{Label = "LoggingEnabled"     ; Expression = { $_.LoggingEnabled } },
                    @{Label = "RestoreFromBackup"  ; Expression = { $_.RestoreFromBackup } }
            }
            catch
            {
                continue
            }
            #endregion Collecte dynamique des informations concernant la DB DHCP
            #region Collecte dynamique des informations sur les journaux d'audit
            try
            {
                $AuditLog = Get-DhcpServerAuditLog -ComputerName $Server.DnsName |
                    Select-Object -Property @{Label = "DiskCheckInterval" ; Expression = { $_.DiskCheckInterval } },
                    @{Label = "Enable"            ; Expression = { $_.Enable } },
                    @{Label = "MaxMBFileSize"     ; Expression = { $_.MaxMBFileSize } },
                    @{Label = "MinMBDiskSpace"    ; Expression = { $_.MinMBDiskSpace } },
                    @{Label = "Path"              ; Expression = { $_.Path } }
            }
            catch
            {
                continue
            }
            #endregion Collecte dynamique des informations sur les journaux d'audit
            #region collecte Dynamique des informations sur le paramétrage des paramètres DNS
            try
            {
                $DNSSettings = Get-DhcpServerv4DnsSetting -ComputerName $Server.DnsName |
                    Select-Object -Property @{Label = "DeleteDnsRROnLeaseExpiry"   ; Expression = { $_.DeleteDnsRROnLeaseExpiry } },
                    @{Label = "DisableDnsPtrRRUpdate"      ; Expression = { $_.DisableDnsPtrRRUpdate } },
                    @{Label = "DnsSuffix"                  ; Expression = { $_.DnsSuffix } },
                    @{Label = "DynamicUpdates"             ; Expression = { $_.DynamicUpdates } },
                    @{Label = "NameProtection"             ; Expression = { $_.NameProtection } },
                    @{Label = "UpdateDnsRRForOlderClients" ; Expression = { $_.UpdateDnsRRForOlderClients } }
            }
            catch
            {
                continue
            }
            #endregion collecte Dynamique des informations sur le paramétrage des paramètres DNS
            #region collecte Dynamique des informations sur le paramétrage du DHCP failover
            try
            {
                $DHCPFailover = Get-DhcpServerv4Failover  -ComputerName $Server.DnsName |
                    Select-Object -Property @{Label = "Name"                ; Expression = { $_.Name } },
                    @{Label = "PrimaryServerName"   ; Expression = { $_.PrimaryServerName } },
                    @{Label = "SecondaryServerName" ; Expression = { $_.SecondaryServerName } },
                    @{Label = "Mode"                ; Expression = { $_.Mode } },
                    @{Label = "LoadBalancePercent"  ; Expression = { $_.LoadBalancePercent } },
                    @{Label = "State"               ; Expression = { $_.State } },
                    @{Label = "ScopeId"             ; Expression = { $_.ScopeId } },
                    @{Label = "AutoStateTransition" ; Expression = { $_.AutoStateTransition } },
                    @{Label = "EnableAuth"          ; Expression = { $_.EnableAuth } }

            }
            catch
            {
                continue
            }
            #endregion collecte Dynamique des informations sur le paramétrage du DHCP failover
            #region collecte Dynamique des informations sur les paramètres des serveurs DHCP
            try
            {
                $DHCPSetting = Get-DhcpServerSetting -ComputerName $Server.DnsName |
                    Select-Object -Property @{Label = "ActivatePolicies"          ; Expression = { $_.ActivatePolicies } },
                    @{Label = "ConflictDetectionAttempts" ; Expression = { $_.ConflictDetectionAttempts } },
                    @{Label = "DynamicBootp"              ; Expression = { $_.DynamicBootp } },
                    @{Label = "IsAuthorized"              ; Expression = { $_.IsAuthorized } },
                    @{Label = "IsDomainJoined"            ; Expression = { $_.IsDomainJoined } },
                    @{Label = "NapEnabled"                ; Expression = { $_.NapEnabled } },
                    @{Label = "NpsUnreachableAction"      ; Expression = { $_.NpsUnreachableAction } },
                    @{Label = "RestoreStatus"             ; Expression = { $_.RestoreStatus } }
            }
            catch
            {
                continue
            }
            #endregion collecte Dynamique des informations sur les paramètres des serveurs DHCP
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "DATABASE INFORMATION pour le Serveur $($Server.DnsName)" {
                    New-HTMLTable -DataTable $Database {
                        New-TableContent -ColumnName "BackupInterval", "BackupPath", "CleanupInterval", "FileName", "LoggingEnabled", "RestoreFromBackup" -Alignment center
                        New-TableCondition -Name 'LoggingEnabled' -Operator eq -Value true -BackgroundColor Green -Color White -Inline -ComparisonType string -Alignment center
                        New-TableCondition -Name 'LoggingEnabled' -Operator ne -Value true -BackgroundColor red   -Color White -Inline -ComparisonType string -Alignment center
                    }#end New-htmltable
                }#end New-htmlsection
            }#end new-htmlsection

            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "AUDIT LOG pour le Serveur $($Server.DnsName)" {
                    New-HTMLTable -DataTable $AuditLog {
                        New-TableContent -ColumnName "DiskCheckInterval", "Enable", "MaxMBFileSize", "MinMBDiskSpace", "Path" -Alignment center
                        New-TableCondition -Name 'Enable' -Operator eq -Value true -BackgroundColor Green -Color White -Inline -ComparisonType string -Alignment center
                        New-TableCondition -Name 'Enable' -Operator ne -Value true -BackgroundColor red   -Color White -Inline -ComparisonType string -Alignment center
                    }# end new-htmltable
                }#end New-htmlsection
            }#end New-htmlsection

            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "PARAMETRES d'ENREGISTREMENT AUPRES DES DNS pour le Serveur $($server.DnsName)" {
                    New-HTMLTable -DataTable $DNSSettings {
                        New-TableContent -ColumnName "DeleteDnsRROnLeaseExpiry", "DisableDnsPtrRRUpdate", "DnsSuffix", "DynamicUpdates", "NameProtection", "UpdateDnsRRForOlderClients" -Alignment center
                        New-TableCondition -Name 'DynamicUpdates' -Operator eq -Value Always -BackgroundColor Green -Color White -Inline -ComparisonType string -Alignment center
                        New-TableCondition -Name 'DynamicUpdates' -Operator ne -Value Always -BackgroundColor red   -Color White -Inline -ComparisonType string -Alignment center
                    }#end New-htmltable
                }#end New-htmlsection
            }#end New-htmlsection

            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "PARAMETRES DHCP FAILOVER pour le Serveur $($server.DnsName)" {
                    New-HTMLTable -DataTable $DHCPFailover {
                        New-TableCondition -Name "State" -Operator eq -Value "Normal" -ComparisonType string -Alignment center -BackgroundColor Green -Color White
                        New-TableCondition -Name "State" -Operator ne -Value "Normal" -ComparisonType string -Alignment center -BackgroundColor Red    -Color White
                        New-TableContent -ColumnName "Name", "PrimaryServerName", "SecondaryServerName", "Mode", "LoadBalancePercent", "MaxClientLeadTime", "StateSwitchInterval", "State", "ScopeId", "AutoStateTransition", "EnableAuth" -Alignment center
                    }#end New-htmltable
                }#end New-htmlsection
            }#end New-htmlsection

            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "PARAMETRES SERVEUR DHCP du Serveur $($server.DnsName)" {
                    New-HTMLTable -DataTable $DHCPSetting {
                        New-TableContent "ActivatePolicies", "ConflictDetectionAttempts", "DynamicBootp", "IsAuthorized" , "IsDomainJoined", "NapEnabled", "NpsUnreachableAction" , "RestoreStatus" -Alignment center
                        New-TableCondition -Name 'ConflictDetectionAttempts' -Operator eq -Value 0     -BackgroundColor Red   -Color White -Inline -ComparisonType number -Alignment center
                        New-TableCondition -Name 'ConflictDetectionAttempts' -Operator ge -Value 1     -BackgroundColor Green -Color White -Inline -ComparisonType number -Alignment center
                        New-TableCondition -Name "IsAuthorized"              -Operator eq -Value true  -BackgroundColor Green -Color White -Inline -ComparisonType String -Alignment center
                        New-TableCondition -Name "IsAuthorized"              -Operator eq -Value false -BackgroundColor Red   -Color White -Inline -ComparisonType String -Alignment center
                        New-TableCondition -Name "IsDomainJoined"            -Operator eq -Value true  -BackgroundColor Green -Color White -Inline -ComparisonType String -Alignment center
                        New-TableCondition -Name "IsDomainJoined"            -Operator eq -Value false -BackgroundColor Red   -Color White -Inline -ComparisonType String -Alignment center
                    }#end New-htmltable
                }#end New-htmlsection
            }#end New-htmlsection
        }#end foreach
    }#end new-htmltab

    # 2ème Onglet on va mettre toutes les informations récupérées sur les étendues DHCP
    New-HTMLTab -Name 'Etendues DHCP' {
        foreach ($Server in $DHCPServers)
        {
            #region Collecte dynamique des Scopes
            try
            {
                $DHCP_Scopes = Get-DhcpServerv4Scope -ComputerName $Server.DNSName -ErrorAction Stop |
                    Select-Object -Property @{Label = "Name"          ; Expression = { $_.Name } },
                    @{Label = "ScopeID"       ; Expression = { $_.ScopeID } },
                    @{Label = "State"         ; Expression = { $_.State } },
                    @{Label = "SubnetMask"    ; Expression = { $_.SubnetMask } },
                    @{Label = "StartRange"    ; Expression = { $_.StartRange } },
                    @{Label = "EndRange"      ; Expression = { $_.EndRange } },
                    @{Label = "LeaseDuration" ; Expression = { $_.LeaseDuration } }
            }
            catch
            {
                Write-Warning "Le serveur $($Server.DNSName) ne peut être atteint"
                $DHCP_Scopes = $Null
            }
            #endregion Collecte dynamique des Scopes
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "ETENDUES DHCP du serveur $($Server.DnsName)" {
                    New-HTMLTable -DataTable $DHCP_Scopes {
                        New-TableContent -Alignment center -ColumnName "Name", "ScopeID", "State", "SubnetMask", "StartRange", "EndRange", "LeaseDuration"
                        New-TableCondition -Name 'State' -Operator eq -Value 'Active' -BackgroundColor Green -Color White -Inline -ComparisonType string -Alignment center
                    }#end new-htmltable
                }#end new-htmlsection
            }#end new-htmlsection
        }#end foreach
    }# end new-htmltab

    # 3ème Onglet on va mettre toutes les informations récupérées sur Options Serveur
    New-HTMLTab -Name 'Options Serveur' {
        foreach ($Server in $DHCPServers)
        {
            #region Collecte dynamique des informations sur Options Serveur
            try
            {
                $OptionsServeur = Get-DhcpServerv4OptionValue -ComputerName $Server.DnsName |
                    Select-Object -Property @{Label = "Server" ; Expression = { $server.DnsName } },
                    @{Label = "Name" ; Expression = { $_.Name } },
                    @{Label = "OptionID" ; Expression = { $_.OptionID } },
                    @{Label = "Type" ; Expression = { $_.Type } },
                    @{Label = "Value" ; Expression = { $_.Value } }
            }
            catch
            {
                continue
            }

            #endregion Collecte dynamique des informations sur Options Serveur
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "OPTIONS SERVEUR de : $($server.DnsName)" {
                    New-HTMLTable -DataTable $OptionsServeur {
                        New-TableCondition -Name 'OptionID' -Operator eq -Value 6  -BackgroundColor Green -Color White -Inline -ComparisonType number -Alignment center
                        New-TableCondition -Name 'OptionID' -Operator eq -Value 15 -BackgroundColor Green -Color White -Inline -ComparisonType number -Alignment center
                        New-TableContent   -Alignment center -ColumnName "Server", "Name", "OptionID", "Type", "Value"
                    }
                }
            }
        }
    }#end new-htmltab

    # 4ème Onglet on va mettre toutes les informations récupérées sur Options des Etendues
    New-HTMLTab -Name 'Options des Etendues' {
        foreach ($Server in $DHCPServers)
        {
            #region Collecte dynamique des Scopes
            try
            {
                $DHCP_Scopes = Get-DhcpServerv4Scope -ComputerName $Server.DNSName -ErrorAction Stop |
                    Select-Object -Property  @{Label = "Serveur" ; Expression = { $server.DnsName } },
                    @{Label = "Name" ; Expression = { $_.Name } },
                    @{Label = "ScopeID" ; Expression = { $_.ScopeID } },
                    @{Label = "State" ; Expression = { $_.State } },
                    @{Label = "SubnetMask" ; Expression = { $_.SubnetMask } },
                    @{Label = "StartRange" ; Expression = { $_.StartRange } },
                    @{Label = "EndRange" ; Expression = { $_.EndRange } },
                    @{Label = "LeaseDuration" ; Expression = { $_.LeaseDuration } }
            }
            catch
            {
                Write-Warning "Le serveur $($Server.DNSName) ne peut être atteint"
                $DHCP_Scopes = $Null
            }
            #endregion Collecte dynamique des Scopes
            #region collecte Dynamique des informations sur Options Etendues
            if (-not($null -eq $DHCP_Scopes))
            {
                $OptionEtendues = foreach ($Scope in $DHCP_Scopes)
                {
                    Get-DhcpServerv4OptionValue -ComputerName $Server.DnsName -ScopeId $Scope.ScopeId |
                        Select-Object -Property @{Label = "Server" ; Expression = { $server.DnsName } },
                        @{Label = "ScopeID" ; Expression = { $scope.ScopeID } },
                        @{Label = "Name" ; Expression = { $_.Name } },
                        @{Label = "OptionID" ; Expression = { $_.OptionID } },
                        @{Label = "Value" ; Expression = { ($_.Value) } }
                }
            }
            #endregion collecte Dynamique des informations sur Options Etendues

            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "OPTIONS DES ETENDUES DU Serveur $($server.DnsName)" {
                    New-HTMLTable -DataTable $OptionEtendues {
                        New-TableCondition -Name 'OptionID' -Operator eq -Value 3 -BackgroundColor Green -Color White -Inline -ComparisonType number -Alignment center
                        New-TableContent -Alignment center -ColumnName "Server", "ScopeID", "Name", "OptionID", "Value"
                    }
                }
            }
        }
    }#end new-htmltab

    # 5ème Onglet on va mettre toutes les informations récupérées sur les réservations d'IP
    New-HTMLTab -Name "Réservations d'IP" {
        foreach ($Server in $DHCPServers)
        {
            #region Collecte dynamique des Scopes
            try
            {
                $DHCP_Scopes = Get-DhcpServerv4Scope -ComputerName $Server.DNSName -ErrorAction Stop |
                    Select-Object -Property  @{Label = "Serveur" ; Expression = { $server.DnsName } },
                    @{Label = "Name" ; Expression = { $_.Name } },
                    @{Label = "ScopeID" ; Expression = { $_.ScopeID } },
                    @{Label = "State" ; Expression = { $_.State } },
                    @{Label = "SubnetMask" ; Expression = { $_.SubnetMask } },
                    @{Label = "StartRange" ; Expression = { $_.StartRange } },
                    @{Label = "EndRange" ; Expression = { $_.EndRange } },
                    @{Label = "LeaseDuration" ; Expression = { $_.LeaseDuration } }
            }
            catch
            {
                Write-Warning "Le serveur $($Server.DNSName) ne peut être atteint"
                $DHCP_Scopes = $Null
            }
            #endregion Collecte dynamique des Scopes
            #region collecte Dynamique des informations sur IP réservées
            if (-not($null -eq $DHCP_Scopes))
            {
                $ReservedIP = foreach ($Scope in $DHCP_Scopes)
                {
                    Get-DhcpServerv4Reservation -ComputerName $Server.DnsName -ScopeId $Scope.ScopeId |
                        Select-Object -Property @{Label = "Server" ; Expression = { $server.DnsName } },
                        @{Label = "Name" ; Expression = { $_.Name } },
                        @{Label = "Description" ; Expression = { $_.Description } },
                        @{Label = "IPAddress" ; Expression = { $_.IPAddress } },
                        @{Label = "ClientID" ; Expression = { $_.ClientID } },
                        @{Label = "Type" ; Expression = { $_.Type } },
                        @{Label = "ScopeID" ; Expression = { $Scope.ScopeID } }
                }# end foreach
            }#end if
            #endregion collecte Dynamique des informations sur IP réservées
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "IP RESERVEES du Serveur $($server.DnsName)" {
                    New-HTMLTable -DataTable $ReservedIP {
                        New-TableContent -Alignment center -ColumnName "Server", "Name", "Description", "IPAddress", "ClientID", "Type", "ScopeID"
                    }#end new-htmltable
                }#end new-htmlsection
            }#end new-htmlsection
        }#end foreach
    }#end new-htmltab

    # 6ème Onglet on va mettre toutes les informations récupérées sur les plages d'exclusion
    New-HTMLTab -Name "Plages d'exclusion" {
        foreach ($Server in $DHCPServers)
        {
            #region Collecte dynamique des Scopes
            try
            {
                $DHCP_Scopes = Get-DhcpServerv4Scope -ComputerName $Server.DNSName -ErrorAction Stop |
                    Select-Object -Property  @{Label = "Server" ; Expression = { $server.DnsName } },
                    @{Label = "Name" ; Expression = { $_.Name } },
                    @{Label = "ScopeID" ; Expression = { $_.ScopeID } },
                    @{Label = "State" ; Expression = { $_.State } },
                    @{Label = "SubnetMask" ; Expression = { $_.SubnetMask } },
                    @{Label = "StartRange" ; Expression = { $_.StartRange } },
                    @{Label = "EndRange" ; Expression = { $_.EndRange } },
                    @{Label = "LeaseDuration" ; Expression = { $_.LeaseDuration } }
            }
            catch
            {
                Write-Warning "Le serveur $($Server.DNSName) ne peut être atteint"
                $DHCP_Scopes = $Null
            }
            #endregion Collecte dynamique des Scopes
            #region collecte Dynamique des informations sur les exclusions
            if (-not($null -eq $DHCP_Scopes))
            {
                $ExclusionRanges = foreach ($Scope in $DHCP_Scopes)
                {
                    Get-DhcpServerv4ExclusionRange -ComputerName $Server.DnsName -ScopeId $Scope.ScopeId |
                        Select-Object -Property @{Label = "Server" ; Expression = { $server.DnsName } },
                        @{Label = "StartRange" ; Expression = { $_.StartRange } },
                        @{Label = "EndRange" ; Expression = { $_.EndRange } },
                        @{Label = "ScopeID" ; Expression = { $_.ScopeId } }
                }
            }
            #endregion collecte Dynamique des informations sur les exclusions
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "PLAGES d'EXCLUSION du Serveur $($server.DnsName)" {
                    New-HTMLTable -DataTable $ExclusionRanges {
                        New-HTMLTableContent -Alignment center -ColumnName "Server", "StartRange", "EndRange", "ScopeID"
                    }#End new-htmltable
                }#end new-htmlsection
            }
        }
    }#end new-htmltab

    # 7ème Onglet on va mettre toutes les informations récupérées sur les statistiques des étendues DHCP
    New-HTMLTab -Name 'Statistiques des étendues DHCP' {
        foreach ($Server in $DHCPServers)
        {
            #region Collecte dynamique des Scopes
            try
            {
                $DHCP_Scopes = Get-DhcpServerv4Scope -ComputerName $Server.DNSName -ErrorAction Stop |
                    Select-Object -Property  @{Label = "Serveur" ; Expression = { $server.DnsName } },
                    @{Label = "Name" ; Expression = { $_.Name } },
                    @{Label = "ScopeID" ; Expression = { $_.ScopeID } },
                    @{Label = "State" ; Expression = { $_.State } },
                    @{Label = "SubnetMask" ; Expression = { $_.SubnetMask } },
                    @{Label = "StartRange" ; Expression = { $_.StartRange } },
                    @{Label = "EndRange" ; Expression = { $_.EndRange } },
                    @{Label = "LeaseDuration" ; Expression = { $_.LeaseDuration } }
            }
            catch
            {
                Write-Warning "Le serveur $($Server.DNSName) ne peut être atteint"
                $DHCP_Scopes = $Null
            }
            #endregion Collecte dynamique des Scopes
            #region Collecte dynamique des Stats pour les Scopes
            if (-not($null -eq $DHCP_Scopes))
            {
                $DHCP_Scope_Stats = Foreach ($Scope in $DHCP_Scopes)
                {
                    Get-DhcpServerv4ScopeStatistics -ComputerName $Server.DnsName -ScopeId $Scope.ScopeId |
                        Select-Object -Property @{Label = "Server" ; Expression = { $server.DnsName } },
                        @{Label = "ScopeId" ; Expression = { $_.ScopeId } },
                        @{Label = "Free" ; Expression = { $_.Free } },
                        @{Label = "InUse" ; Expression = { $_.InUse } },
                        @{Label = "Reserved" ; Expression = { $_.Reserved } },
                        @{Label = "Pending" ; Expression = { $_.Pending } },
                        @{Label = "AddressesFree" ; Expression = { $_.AddressesFree } },
                        @{Label = "AddressesInUse" ; Expression = { $_.AddressesInUse } },
                        @{Label = "PendingOffers" ; Expression = { $_.PendingOffers } },
                        @{Label = "PercentageInUse" ; Expression = { $_.PercentageInUse } },
                        @{Label = "ReservedAddress" ; Expression = { $_.ReservedAddress } }
                }#end foreach
            } # end if DHCP_Scope
            #endregion Collecte dynamique des Stats pour les Scopes
            New-HTMLSection -Invisible {
                New-HTMLSection -HeaderText "STATISTIQUES DES ETENDUES DHCP du serveur $($server.DnsName) au $(Get-Date)" {
                    New-HTMLTable -DataTable $DHCP_Scope_Stats {
                        New-TableCondition -Name 'PercentageInUse' -Operator ge -Value 95 -BackgroundColor Red    -Color White -Inline -ComparisonType number -Alignment center
                        New-TableCondition -Name 'PercentageInUse' -Operator ge -Value 80 -BackgroundColor Yellow -Color Black -Inline -ComparisonType number -Alignment center
                        New-TableCondition -Name 'PercentageInUse' -Operator lt -Value 80 -BackgroundColor Green  -Color White -Inline -ComparisonType number -Alignment center
                        New-TableCondition -Name 'Reserved'        -Operator ne -Value 0  -BackgroundColor Orange -Color White -Inline -ComparisonType number -Alignment center
                        New-TableContent -Alignment center -ColumnName "Server", "ScopeID", "Free", "InUse", "Reserved", "Pending", "AddressesFree", "AddressesInUse", "PendingOffers", "PercentageInUse", "ReservedAddress"
                    }#end new-htmltable
                }#end new-htmlsection
            }#endnew-htmlsection
        }#end foreach
    }# end new-htmltab

}#end new-html
#endregion Sortie HTML d'informations multiples dans différents onglets d'une même page html
Write-Host "Terminé" -ForegroundColor Yellow
Write-Host "Le rapport est disponible ici : " -ForegroundColor Green -NoNewline
Write-Host $ReportPath -ForegroundColor Yellow
# Le résultat donne au final un affichage tout à fait séduisant, informatif et utile. Il peut être naturellement amélioré.
# basé sur les infos et l'exemple de la page suivante : https://evotec.xyz/active-directory-dhcp-report-to-html-or-email-with-zero-html-knowledge/
