function Get-EOL
{
    <#
.SYNOPSIS
   Get End Of life information in https://endoflife.date

.DESCRIPTION
   Get End Of life information in https://endoflife.date

   Different cases of use : 
    - ProductName is known : Get-EOL -ProductName <ProductName> # Optional -Report in simple but pretty html file
    - ProductName and Cycle (version) are known : Get-EOL -ProductName <ProductName> - Cycle <Cycle> # Optional -Report in simple but pretty html file
    - ProductName is unknown : Get-EOL ==> An Out-Gridview displays All Product Names, Select one or more, then products ares processed. In this case, the report is automatic and use the PS Module PSWriteHTML

.EXAMPLE
   Get-EOL -Verbose -ProductName powershell
   Get EOL for Product Powershell, no specific release (Cycle) required, all cycles returned

.EXAMPLE
   Get-EOL -Verbose -ProductName powershell -Cycle 5.1
   Get EOL for Product Powershell, using a specific release (Cycle). Only this Cycle is returned

.EXAMPLE
    Get-EOL -ProductName windows-server -Cycle 2016 -Verbose
    Get EOL for Product Windows Server, using a specific release (Cycle = 2016). Only this Cycle is returned. 
    The verbose mode is enabled

.EXAMPLE
    Get-EOL -ProductName windows-server -Cycle 2016 -Verbose -Export
    Get EOL for Product Windows Server, using a specific release (Cycle = 2016). Only this Cycle is returned. 
    The verbose mode is enabled
    A simple html export is done (no additional Module required)

.EXAMPLE
    Get-EOL
    A OutGridview shows All Products. One ore more could be selected and processed to Get EOL for Products selected.
    This way uses the PS Module PSWriteHTML.

    Take care : If lot of Product Names are selected the execution Time will increase (31 sec for all Products). Nota : If All Products are selected, the report is not as pretty.

.EXAMPLE
    Get-EOL -Verbose
    A OutGridview shows All Products. One ore more could be selected and processed to Get EOL for Products selected.
    This way uses the PS Module PSWriteHTML
    The verbose mode is enabled

    Take care : If lot of Product Names are selected the execution Time will increase (31 sec for all Products). Nota : If All Products are selected, the report is not as pretty.

.EXAMPLE
    Get-Help Get-EOL -full
    Get-Help Get-EOL -ShowWindow
    Complete help about this function in the shell

.EXAMPLE
    Get-Help Get-EOL -ShowWindow
    Complete help about this function in a separate Windows

.PARAMETER ProductName
    [String]
    Product Name to looking for EOL

.PARAMETER Cycle
    [String]
    Cycle of Product Name to looking for EOL'

.PARAMETER Export
    [Switch]
    When Passed, Export EOL result in a html file

.INPUTS
   none

.OUTPUTS
    [System.Object]

.NOTES
   Author  : O. FERRIERE
   Version : 3.0
   Date    : November 07th 2024
   Change  : v1.0  - September 18th 2023 - Initial release.
             v2.0 - September 19th 2023 - If no ProductName parameter is selected, then a list of ProductName is displayed in Out-GridView. 
                                          You can select one or more ProductName, and then a Report (using PSWriteHTML Module) is générated 
             v3.0 - November 07th 2024 - replace OGV by a WFP window
   TODO    : Add DynamicParameter for ProductName and Cycle, change OGV by a WPF windows
#>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(
            #Mandatory = $true,
            HelpMessage = 'Product Name to looking for EOL'
        )]
        [string[]]
        $ProductName,

        [Parameter(
            HelpMessage = 'Cycle of Product Name to looking for EOL'
        )]
        [string]
        $Cycle,

        [Parameter(
            HelpMessage = 'When Passed, Export EOL result in a html file'
        )]
        [switch]
        $Export
    )

    begin
    {
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
        if ($PSBoundParameters.ContainsKey('Verbose') )
        {
            Write-Verbose -Message 'Parameters'
            $PSBoundParameters | Out-String
        }
    }
    Process
    {
        if (-not ($PSBoundParameters.ContainsKey('ProductName') ))
        {
            Write-Verbose -Message 'No ProductName has been Selected, The selection will be made via GUI'
            $URI = 'https://endoflife.date/api//All.json'
            $ResultQuery = (Invoke-RestMethod -Uri $URI | ConvertFrom-Csv -Delimiter ';' -Header 'ProductName').ProductName
            #| Out-GridView -Title 'Choose one or more ProductName to gather EOL information, using CTRL' -OutputMode Multiple
            
            function Show-SelectionDialog
            {
                param (
                    [Parameter(Mandatory = $true)]
                    [array]$Items
                )

                # Charger l'assembly nécessaire pour WPF
                Add-Type -AssemblyName PresentationFramework

                # Initialiser la variable pour stocker les éléments sélectionnés
                $script:SelectedValues = @()

                # Création de la fenêtre
                $Window = [System.Windows.Window]::new()
                $Window.Title = 'Select one or more Product Name'
                $Window.height = 500 # hauteur
                $Window.width = 300  # Largeur
                $Window.WindowStartupLocation = 'CenterScreen' # localisation de la fenêtre
                $Window.Background = [System.Windows.Media.Brushes]::Azure # Couleur de fond de la fenêtre
                $Window.AllowsTransparency    # fenêtre sans bordure
                #$Window.WindowStyle = 'none' # fenêtre non déplaçable
                #$Window.SizeToContent = 'WidthAndHeight'

                # Créer une grille pour la disposition des contrôles
                $Grid = [System.Windows.Controls.Grid]::new()
                $Grid.Margin = '10'

                # Définir les lignes du Grid
                $rowDefinition1 = [System.Windows.Controls.RowDefinition]::new()
                $rowDefinition2 = [System.Windows.Controls.RowDefinition]::new()
                $rowDefinition2.Height = [System.Windows.GridLength]::Auto  # Ajuster la hauteur pour la ligne des boutons
                $Grid.RowDefinitions.Add($rowDefinition1)
                $Grid.RowDefinitions.Add($rowDefinition2)

                # Créer une ListBox pour afficher les items
                $ListBox = [System.Windows.Controls.ListBox]::new()
                $ListBox.Margin = '0,0,0,10'
                $ListBox.Background = [System.Windows.Media.Brushes]::AliceBlue
                $ListBox.BorderBrush = [System.Windows.Media.Brushes]::DarkBlue
                $ListBox.BorderThickness = 2
                $ListBox.SelectionMode = 'Multiple'
                $ListBox.HorizontalAlignment = 'Stretch'
                $ListBox.VerticalAlignment = 'Stretch'
                [System.Windows.Controls.Grid]::SetRow($ListBox, 0)
                $Grid.Children.Add($ListBox) | Out-Null # Ajout de la listbox à la grille

                # Ajouter les items à la ListBox
                foreach ($Name in $Items)
                {
                    $listBoxItem = [System.Windows.Controls.ListBoxItem]::new()
                    $listBoxItem.Content = $Name
                    $ListBox.Items.Add($listBoxItem) | Out-Null
                }

                # Créer un StackPanel pour les boutons
                $ButtonStackPanel = [System.Windows.Controls.StackPanel]::new()
                $ButtonStackPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
                $ButtonStackPanel.HorizontalAlignment = 'Center'
                $ButtonStackPanel.Margin = '0,10,0,0'
                [System.Windows.Controls.Grid]::SetRow($ButtonStackPanel, 1)
                $Grid.Children.Add($ButtonStackPanel) | Out-Null

                # Créer le bouton "Validate"
                $Button = [System.Windows.Controls.Button]::new()
                $Button.Content = 'Validate'
                $Button.Padding = '10,5'
                $Button.Background = [System.Windows.Media.Brushes]::AliceBlue
                $Button.Foreground = [System.Windows.Media.Brushes]::DarkBlue
                $Button.FontWeight = 'Bold'
                $ButtonStackPanel.Children.Add($Button) | Out-Null

                # Créer le bouton "Cancel"
                $Button2 = [System.Windows.Controls.Button]::new()
                $Button2.Content = 'Cancel'
                $Button2.Padding = '10,5'
                $Button2.Background = [System.Windows.Media.Brushes]::AliceBlue
                $Button2.Foreground = [System.Windows.Media.Brushes]::DarkBlue
                $Button2.FontWeight = 'Bold'
                $ButtonStackPanel.Children.Add($Button2) | Out-Null

                # Définir le contenu de la fenêtre avec la grille créée
                $Window.Content = $Grid

                # Ajouter les événements de clic pour les boutons
                $Button.Add_Click({
                        $script:SelectedValues = $ListBox.SelectedItems.Content
                        Write-Verbose -Message "You have selected: $($script:SelectedValues -join ', ')"
                        $Window.Close()
                    })

                $Button2.Add_Click({
                        $script:SelectedValues = @()
                        Write-Verbose -Message 'No element selected'
                        $Window.Close()
                    })

                # Afficher la fenêtre en mode modal
                try
                {
                    $Window.ShowDialog() | Out-Null
                }
                finally
                {
                    if ($Window -and $Window.IsVisible)
                    {
                        $Window.Close()
                    }
                }

                # Retourner les valeurs sélectionnées
                return $script:SelectedValues
            }

            $Result = Show-SelectionDialog -Items $ResultQuery
            # I have a "false" in the first entry. Transform the var to an ArrayList ad use the method RemoveAt() to delete it
            [System.Collections.ArrayList]$Result = $result
            $Result.RemoveAt(0)
            $Result
            Write-Verbose -Message "Selected ProductName : $($Result -join ' - ') "
        }
        else
        {
            Write-Verbose -Message 'One or more ProductName has been Selected'
            $Result = $ProductName
            Write-Verbose -Message "Selected ProductName : $($Result -join ' - ')"
        } #end else
        
        foreach ($Product in $Result)
        {
            Write-Verbose 'Display on console'
            Write-Verbose -Message "Retrieve EOL for : $Product"
            $URI = "https://endoflife.date/api/$($Product).json"
            $Output = Invoke-RestMethod -Uri $URI
            Write-Verbose "EOL for : $($Product)"
            $Output
        }

        
        if ($PSBoundParameters.ContainsKey('Export') )
        {
            #region Check if module is installed, then download
            Write-Verbose -Message 'Check if PSWriteHtml and modules are installed'
            If (-not (Get-Module -ListAvailable -Name PSWriteHtml, PSParseHtml))
            {
                Try
                {
                    Write-Verbose -Message 'PSWriteHtml and/or PSParseHTML is not installed, Download and install ... : '
                    Install-Module PSWriteHTML, PSParseHTML -Force -Scope CurrentUser
                    Write-Verbose -Message 'Installation : Completed'
                }
                Catch
                {
                    Write-Verbose 'The module could not be installed. End of script.'
                    Write-Host "An errer occurs. Message : $_."
                    Break
                }
            }
            #endregion Check if module is installed, then download

            #region Module Import
            Write-Verbose -Message 'PSWriteHtml cmdlets import ... ' 
            Import-Module PSWriteHTML
            Write-Verbose -Message 'Loading : Completed'
            #endregion Module Import

            #region Setting the default behavior of certain cmdlets
            Write-Verbose 'Setting the default behavior of certain cmdlets'
            $PSDefaultParameterValues = @{
                'New-HTML:Online'                       = $true
                'New-HTML:ShowHtml'                     = $true
                'New-HTML:Minify'                       = $true
                'New-HTMLSection:HeaderBackGroundColor' = 'Green'
                'New-HTMLSection:HeaderTextColor'       = 'WhiteSmoke'
                'New-HTMLSection:BorderRadius'          = '15px'
                'New-HTMLSection:CanCollapse'           = $true
                'New-HTMLTable:Style'                   = 'cell-border'
                'New-TableContent:Alignment'            = 'Center'
                'New-TableCondition:Alignment'          = 'Center'
            }
            #endregion Setting the default behavior of certain cmdlets

            #region Html Report
            $ReportPath = ".\EOL-Report-at-$(Get-Date -f 'dd-MM-yyyy').html"
            Write-Verbose 'Gathering Info and generating report ...'
            New-HTML -FilePath $ReportPath -TitleText 'End Of Life Product Report' {
                foreach ($Product in $Result)
                {
                    # tabs
                    Write-Verbose -Message "Treatment of $($Product.toupper())"
                    New-HTMLTab -Name "$($Product.toupper())" {
                        New-HTMLSection -HeaderText "$($Product.toupper())" {
                            # Here we will put the information concerning the product
                            $URI = "https://endoflife.date/api/$($Product).json"
                            $Output = Invoke-RestMethod -Uri $URI
                            New-HTMLTable -DataTable $Output {
                                New-TableContent -ColumnName 'Cycle', 'Latest', 'LatestReleaseDate', 'Link', 'lts', 'releaseDate', 'support', 'ExtentedSupport', 'support'
                                New-TableContent -ColumnName 'eol' -Color white -BackgroundColor limegreen
                                New-TableCondition -Name 'lts' -ComparisonType bool -Operator eq -Value True -BackgroundColor limegreen -Color white
                                New-TableCondition -Name 'eol' -ComparisonType date -Operator lt -Value $( (Get-Date).AddMonths(6) ) -BackgroundColor orange -Color white
                                New-TableCondition -Name 'eol' -ComparisonType date -Operator lt -Value $(Get-Date) -BackgroundColor red -Color white
                            } #end New-htmltable
                        } # end New-htmlSection
                    } # end new-htmltab
                } # end foreach
                New-HTMLFooter {
                    New-HTMLText -Text "Date of this report $(Get-Date)" -Color Blue -Alignment right
                } # end New-htmlfooter
            } # end New-html
            Write-Output "Report generated in $ReportPath"

        }#  enf if Export
    } #end Process
    end
    {
        $StopWatch.Stop()
        $Min = $StopWatch.Elapsed.Minutes
        $Sec = $StopWatch.Elapsed.Seconds
        $Milli = $StopWatch.Elapsed.Milliseconds
        Write-Host 'Execution Time ' -ForegroundColor Green -NoNewline
        Write-Host "$min " -ForegroundColor Yellow -NoNewline
        Write-Host 'min, ' -ForegroundColor Green -NoNewline
        Write-Host "$Sec " -ForegroundColor Yellow -NoNewline
        Write-Host 'seconds, ' -ForegroundColor Green -NoNewline
        Write-Host "$Milli " -ForegroundColor Yellow -NoNewline
        Write-Host 'Milliseconds' -ForegroundColor Green
    }

} # end function