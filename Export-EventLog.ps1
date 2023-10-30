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
    Date    : 30/10/2023
    Version : 1.0
    Change  : V1.0 - 30/10/2023 - Initial Version
    #>

    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
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
                if (-Not ($_ | Test-Path) )
                {
                    throw "The path doesn't exist"
                }
                if (-Not ($_ | Test-Path -PathType Container ) )
                {
                    throw 'The Path argument must be a folder. File paths are not allowed.'
                }
                return $true
            })]
        [System.IO.FileInfo]
        $Path
    )

    Begin
    {
        Write-Verbose -Message 'Determining the Name of the Exported Log File'
        $ExportFileName = $logFileName + '_' + (Get-Date -f yyyyMMdd) + '.evt'
        Write-Verbose -Message "The Name of the log File Exported will be : [$ExportFileName]"
        Write-Verbose -Message 'Parameters and values will be used'
        $PSBoundParameters

    }
    Process
    {
        Write-Verbose -Message "We'll use Get-WMIObject cause Get-CIMInstance hasn't the BackupEventlog Method"
        $logFile = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object { $_.Logfilename -eq $logFileName }
        $FullNameExportPath = Join-Path -Path $Path -ChildPath $ExportFileName
        $logFile.BackupEventlog($FullNameExportPath)
    }
    End
    {
        Write-Output "The Export File is located here : [$FullNameExportPath]"
    }
}

# Usage example : Export-EventLog -LogFileName 'Application' -Path C:\temp -Verbose
