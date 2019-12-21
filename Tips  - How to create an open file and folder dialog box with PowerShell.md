# How to create an open file and folder dialog box with PowerShell

## How to create an open file dialog box with PowerShell

### 1 - load the .NET System.Windows.Forms assembly

````powershell
Add-Type -AssemblyName System.Windows.Forms
````

### 2 - Instantiate an OpenFileDialog object using New-Object

````powershell
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
````

You can see above that the OpenFileDialog class constructor has an InitialDirectory argument.
This tells the OpenFileDialog class which folder to display when the dialog box comes up.
In this case, I have the dialog box to display the desktop.
At this point, the dialog box will not display. We're just instantiating the object.
To show the dialog box, we'll have to use the ShowDialog() method.

### 3 - Show the dialog box

````powershell
$Null = $FileBrowser.ShowDialog()
````

### 4 -  limit the input by file type too using the Filter property

````powershell
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter           = 'Documents (*.docx)|*.docx|SpreadSheet (*.xlsx)|*.xlsx'
}
$Null = $FileBrowser.ShowDialog()
````

### 5 - OpenFile Dialog bow in a function : Allow filter on one file extension

````powershell
function Get-FileName($InitialDirectory)
{
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}
````

### 6 - OpenFile Dialog bow in a function : Allow multiple filters

````powershell
function Get-FileName($InitialDirectory)
{
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $OpenFileDialog.filter = "Documents (*.docx)|*.docx |SpreadSheet (*.xlsx)|*.xlsx"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}
````

>[Nota] : As we can see, the filter applies for one or the other of the selected extensions, not both at the same time

### FINALLY : OpenFile Dialog bow in a function : Allow multiple filters and multiple selections and manage errors

````powershell
function Get-FileName
{
<#
.SYNOPSIS
   Show an Open File Dialog and return the file selected by the user

.DESCRIPTION
   Show an Open File Dialog and return the file selected by the user

.PARAMETER WindowTitle
   Message Box title
   Mandatory - [String]

.PARAMETER InitialDirectory
   Initial Directory for browsing
   Mandatory - [string]

.PARAMETER Filter
   Filter to apply
   Optional - [string]

.PARAMETER AllowMultiSelect
   Allow multi file selection
   Optional - switch

 .EXAMPLE
   Get-FileName
    cmdlet Get-FileName at position 1 of the command pipeline
    Provide values for the following parameters:
    WindowTitle: My Dialog Box
    InitialDirectory: c:\temp
    C:\Temp\42258.txt

    No passthru paramater then function requires the mandatory parameters (WindowsTitle and InitialDirectory)

.EXAMPLE
   Get-FileName -WindowTitle MyDialogBox -InitialDirectory c:\temp
   C:\Temp\41553.txt

   Choose only one file. All files extensions are allowed

.EXAMPLE
   Get-FileName -WindowTitle MyDialogBox -InitialDirectory c:\temp -AllowMultiSelect
   C:\Temp\8544.txt
   C:\Temp\42258.txt

   Choose multiple files. All files are allowed

.EXAMPLE
   Get-FileName -WindowTitle MyDialogBox -InitialDirectory c:\temp -AllowMultiSelect -Filter "text file (*.txt) | *.txt"
   C:\Temp\AES_PASSWORD_FILE.txt

   Choose multiple files but only one specific extension (here : .txt) is allowed

.EXAMPLE
   Get-FileName -WindowTitle MyDialogBox -InitialDirectory c:\temp -AllowMultiSelect -Filter "Text files (*.txt)|*.txt| csv files (*.csv)|*.csv | log files (*.log) | *.log"
   C:\Temp\logrobo.log
   C:\Temp\mylogfile.log

   Choose multiple file with the same extension

.EXAMPLE
   Get-FileName -WindowTitle MyDialogBox -InitialDirectory c:\temp -AllowMultiSelect -Filter "selected extensions (*.txt, *.log) | *.txt;*.log"
   C:\Temp\IPAddresses.txt
   C:\Temp\log.log

   Choose multiple file with different extensions
   Nota :It's important to have no white space in the extension name if you want to show them

.EXAMPLE
 Get-Help Get-FileName -Full

.INPUTS
   System.String
   System.Management.Automation.SwitchParameter

.OUTPUTS
   System.String

.NOTESs
  Version         : 1.0
  Author          : O. FERRIERE
  Creation Date   : 11/09/2019
  Purpose/Change  : Initial development

  Based on different pages :
   mainly based on https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
   https://code.adonline.id.au/folder-file-browser-dialogues-powershell/
   https://thomasrayner.ca/open-file-dialog-box-in-powershell/
#>
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # WindowsTitle help description
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Message Box Title",
            Position = 0)]
        [String]$WindowTitle,

        # InitialDirectory help description
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Initial Directory for browsing",
            Position = 1)]
        [String]$InitialDirectory,

        # Filter help description
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Filter to apply",
            Position = 2)]
        [String]$Filter = "All files (*.*)|*.*",

        # AllowMultiSelect help description
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Allow multi files selection",
            Position = 3)]
        [Switch]$AllowMultiSelect
    )

    # Load Assembly
    Add-Type -AssemblyName System.Windows.Forms

    # Open Class
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    # Define Title
    $OpenFileDialog.Title = $WindowTitle

    # Define Initial Directory
    if (-Not [String]::IsNullOrWhiteSpace($InitialDirectory))
    {
        $OpenFileDialog.InitialDirectory = $InitialDirectory
    }

    # Define Filter
    $OpenFileDialog.Filter = $Filter

    # Check If Multi-select if used
    if ($AllowMultiSelect)
    {
        $OpenFileDialog.MultiSelect = $true
    }
    $OpenFileDialog.ShowHelp = $true    # Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE.
    $OpenFileDialog.ShowDialog() | Out-Null
    if ($AllowMultiSelect)
    {
        return $OpenFileDialog.Filenames
    }
    else
    {
        return $OpenFileDialog.Filename
    }
}
````

## How to create an open folder dialog box with PowerShell

### 1 - load the .NET System.Windows.Forms assembly

````powershell
Add-Type -AssemblyName System.Windows.Forms
````

### 2 - Instantiate an FolderBrowserDialog object using New-Object

````powershell
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
````

### 3 - Show the dialog box

````powershell
$Null = $FolderBrowser.ShowDialog()
````

### 4 -  limit the input by file type too using the Filter property

````powershell
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
    RootFolder            = "MyComputer"
    Description           = "$Env:ComputerName - Select a folder"
}
$Null = $FolderBrowser.ShowDialog()
````

### FINALLY - Open Folder Browser as a function

````powershell
Function Get-FolderName
{
<#
.SYNOPSIS
   Show a Folder Browser Dialog and return the directory selected by the user

.DESCRIPTION
  Show a Folder Browser Dialog and return the directory selected by the user

.PARAMETER SelectedPath
   Initial Directory for browsing
   Mandatory - [string]

.PARAMETER Description
   Message Box Title
   Optional - [string] - Default : "Select a Folder"

.PARAMETER  ShowNewFolderButton
   Show New Folder Button when unused (default) or doesn't show New Folder when used with $false value
   Optional - [Switch]

 .EXAMPLE
   Get-FolderName
    cmdlet Get-FileFolder at position 1 of the command pipeline
    Provide values for the following parameters:
    SelectedPath: C:\temp
    C:\Temp\

   Choose only one Directory. It's possible to create a new folder (default)

.EXAMPLE
   Get-FolderName -SelectedPath c:\temp -Description "Select a folder" -ShowNewFolderButton
   C:\Temp\Test

   Choose only one Directory. It's possible to create a new folder

.EXAMPLE
   Get-FolderName -SelectedPath c:\temp -Description "Select a folder"
   C:\Temp\Test
   Choose only one Directory. It's not possible to create a new folder

.EXAMPLE
   Get-FolderName  -SelectedPath c:\temp
   C:\Temp\Test

   Choose only one Directory. It's possible to create a new folder (default)


.EXAMPLE
 Get-Help Get-FolderName -Full

.INPUTS
   System.String
   System.Management.Automation.SwitchParameter

.OUTPUTS
   System.String


.NOTES
  Version         : 1.0
  Author          : O. FERRIERE
  Creation Date   : 12/10/2019
  Purpose/Change  : Initial development

  Based on different pages :
   mainly based on https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
   https://code.adonline.id.au/folder-file-browser-dialogues-powershell/
   https://thomasrayner.ca/open-file-dialog-box-in-powershell/
   https://code.adonline.id.au/folder-file-browser-dialogues-powershell/
#>

[CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # InitialDirectory help description
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Initial Directory for browsing",
            Position = 0)]
        [String]$SelectedPath,

        # Description help description
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Message Box Title")]
        [String]$Description="Select a Folder",

        # ShowNewFolderButton help description
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show New Folder Button when used")]
        [Switch]$ShowNewFolderButton
    )

    # Load Assembly
    Add-Type -AssemblyName System.Windows.Forms

    # Open Class
    $FolderBrowser= New-Object System.Windows.Forms.FolderBrowserDialog

   # Define Title
    $FolderBrowser.Description = $Description

    # Define Initial Directory
    if (-Not [String]::IsNullOrWhiteSpace($SelectedPath))
    {
        $FolderBrowser.SelectedPath=$SelectedPath
    }

    if($folderBrowser.ShowDialog() -eq "OK")
    {
        $Folder += $FolderBrowser.SelectedPath
    }
    return $Folder
}
````
