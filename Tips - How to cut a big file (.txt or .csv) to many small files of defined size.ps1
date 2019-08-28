<#
Sometimes wewould like to split a large file (.txt or .csv) into several small files.

The goal of the following function without pretention is to do this boring cutting work for you.
#>

function Split-File
{
    [CmdletBinding()]
    #region params
    Param(
        # FilePath Help Description
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Location of the input file",
            Position = 0
        )]
        [System.String]$FilePath,

        # $BlockSize Help Description
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Number of lines desired in each new files",
            Position = 1
        )]
        [System.String]$BlockSize
    )
    #endregion

    <#
.SYNOPSIS
   Split a large file (.txt or .csv) into several small files.

.DESCRIPTION
    Split a large file (.txt or .csv) into several small files.

.PARAMETER FilePath
    Path of the input file

.PARAMETER BlockSize
   Number of lines in each generated split files

.INPUTS
   None

.OUTPUTS
 [System.Object]s

.EXAMPLE
    PS> Split-File  -FilePath c:\temp\Ipaddresses.csv -BlockSize 10 -Verbose
    COMMENTAIRES : The input file C:\temp\IPAddresses.csv has 254 lines
    COMMENTAIRES : It will be cut in 25 new files
    COMMENTAIRES : Creating The file IPAddresses-000.csv starting at 0 and ending at 9 of the original file C:\temp\IPAddresses.csv
    COMMENTAIRES : the file was created here : C:\Temp\Blocks\IPAddresses-000.csv
    COMMENTAIRES : Creating The file IPAddresses-001.csv starting at 10 and ending at 19 of the original file C:\temp\IPAddresses.csv
    COMMENTAIRES : the file was created here : C:\Temp\Blocks\IPAddresses-001.csv
    COMMENTAIRES : Creating The file IPAddresses-002.csv starting at 20 and ending at 29 of the original file C:\temp\IPAddresses.csv
    ...
    All files has been created here :  C:\Temp\Blocks

    Split the input file in many file with 10 lines in verbose mode

.EXAMPLE
    PS> Split-File -FilePath c:\temp\Ipaddresses.csv -BlockSize 10
    All files has been created here :  C:\Temp\Blocks

    Split the input file in many file with 10 lines in normal mode (quiet)


.NOTES
    Version         : 1.0
    Author          : O. FERRIERE
    Creation Date   : 28/08/2019
    Purpose/Change  : Initial script development

   TO DO
  Add Header in each generated file
#>
    #region Check
    # ExportPath is still existing
    $ExportPath = Join-Path -Path (Get-Location) -ChildPath "Blocks"
    if (-not (Test-Path $ExportPath))
    {
        New-Item -Path $ExportPath -ItemType Directory
        Write-Verbose "A directory for the new export Files has been created here : $ExportPath"
    }
    # Extension is .csv or .txt
    if (  (((Get-Item -Path $FilePath).Extension) -ne ".csv") -and (((Get-Item -Path $FilePath).Extension) -ne ".txt") )
    {
        Write-Verbose "The Input file must be a .csv or .txt file. Exit Script"
        throw
    }
    #endregion

    #region Execution
    $File = Get-Content -Path $FilePath
    $FileSizeMeaningZero = $File.count - 1
    Write-Verbose "The input file $FilePath has $FileSizeMeaningZero lines"

    # Calculation of the number of blocks (files)  to do
    $NrOfBlockMeaningZero = [math]::Floor(($FileSizeMeaningZero + 1) / $BlockSize)
    Write-Verbose "It will be cut in $NrOfBlockMeaningZero new files"

    # File (blocks) creation with automatic namming
    $PrefixName = (Get-Item -Path $FilePath).baseName
    $ExtensionName = (Get-Item -Path $FilePath).Extension
    foreach ($Block in (0..$NrOfBlockMeaningZero))
    {
        $BlockFileName = "$prefixName-{0:000}$ExtensionName" -f $Block
        $StartLine = $Block * $BlockSize
        $EndLine = $StartLine + $BlockSize - 1
        if ($EndLine -gt $FileSizeMeaningZero)
        {
            $EndLine = $FileSizeMeaningZero
        }
        Write-Verbose "Creating The file $BlockFileName starting at $StartLine and ending at $EndLine of the original file $FilePath"
        $ExportFilePath = Join-Path -Path $ExportPath -ChildPath $BlockFileName
        $File[$StartLine..$EndLine] | Out-File -FilePath $ExportFilePath -Encoding utf8
        Write-Verbose "the file was created here : $ExportFilePath"
    }
    Write-Output "All files has been created here :  $ExportPath"
    #endregion
}