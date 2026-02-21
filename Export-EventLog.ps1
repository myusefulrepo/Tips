function Export-EventLog
{
    <#
.SYNOPSIS
   Export an Event Log file

.DESCRIPTION
   Export an Event Log file

.PARAMETER LogFileName
    Name of the  Log File to export
    eg. : Application, System, ...
    The Name must be already exists

.PARAMETER Path
    Path of the folder to Export the log File.
    The Path must be already existing and be is a folder path.

.EXAMPLE
   Export-EventLog -LogFileName 'Application' -Path "C:\temp"
   Export the Event Log FIle to the Path passed in parameter

.EXAMPLE
   Get-Help Export-EventLog  -ShowWindow
   Complet help about this function in a separate window

.NOTES
    Author  : O. FERRIERE (inspired by Jeffery Hick (https://4sysops.com/archives/managing-the-event-log-with-powershell-part-2-backup/) and Luke Murray (https://github.com/lukemurraynz/PowerOfTheShell/blob/master/Other/Export_EventLogs.ps1)
    Date    : 20/02/2026
    Version : 2.0
    Change  : 
            - V1.0 - 30/10/2023 - Initial Version
            - v2.0 - 020/02/2026
                - Utilisation de Get-CIMInstance au lieu de Get-WMIObject (déprécié)
                - [OutputTrype([String])] changé en [OutputType([System.IO.FileInfo])]
                - Ajout d'un try...catch
                - Ajout du test if (-not $logFile) avec Write-Error
                - Write-Output polluant le pipeline	Remplacé par Get-Item qui retourne l'objet fichier exporté (exploitable dans le pipeline)
                - Message verbose WMI obsolète	Supprimé (plus pertinent)


    #>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param
    (
        # Event Log Name
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateScript({
                if ([System.Diagnostics.EventLog]::SourceExists($_))
                {
                    $true
                }
                else
                {
                    throw "Le nom de l'EventLog '$_' n'existe pas."
                }
            })]
        [string]$LogFileName,

        # Folder Path to Export the Event Log File
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [ValidateScript({
                if (-not ($_ | Test-Path) )
                {
                    throw "Le chemin '$_' n'existe pas."
                }
                if (-not ($_ | Test-Path -PathType Container ) )
                {
                    throw "Le chemin '$_' doit être un répertoire. Les chemins de fichier ne sont pas autorisés."
                }
                return $true
            })]
        [System.IO.DirectoryInfo]
        $Path
    )

    begin
    {
        Write-Verbose -Message 'Determining the Name of the Exported Log File'
        $ExportFileName = $logFileName + '_' + (Get-Date -f yyyyMMdd) + '.evtx'
        Write-Verbose -Message "The Name of the log File Exported will be : [$ExportFileName]"
        Write-Verbose -Message 'Parameters and values will be used'
        Write-Verbose -Message ($PSBoundParameters | Out-String)

    }
    process
    {
        $logFile = Get-CimInstance -ClassName Win32_NTEventlogFile |
            Where-Object { $_.LogFileName -eq $logFileName }

        if (-not $logFile)
        {
            Write-Error "L'EventLog '$LogFileName' n'a pas été trouvé via CIM."
            return
        }

        $FullNameExportPath = Join-Path -Path $Path -ChildPath $ExportFileName
        Write-Verbose -Message "Export vers : [$FullNameExportPath]"

        try
        {
            Invoke-CimMethod -InputObject $logFile -MethodName BackupEventlog -Arguments @{ ArchiveFileName = $FullNameExportPath } -ErrorAction Stop | Out-Null
        }
        catch
        {
            Write-Error "Échec de l'export de l'EventLog '$LogFileName' : $_"
            return
        }

        Write-Verbose -Message "Export terminé : [$FullNameExportPath]"
        Get-Item -Path $FullNameExportPath
    }
    end
    {
        Write-Verbose 'Fin du script'
    }
}

# Usage example : Export-EventLog -LogFileName 'Application' -Path C:\temp -Verbose
