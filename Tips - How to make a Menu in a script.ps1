###### The simple way ######

# Building a simple function like the following
function Show-Menu {
    param (
        [string]$Title = 'My Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for this option."
    Write-Host "2: Press '2' for this option."
    Write-Host "3: Press '3' for this option."
    Write-Host "Q: Press 'Q' to quit."
}
# then, use it in a script like this : 
Show-Menu –Title 'My Menu'
$selection = Read-Host "Please make a selection"
switch ($selection) {
    '1' {
        'You chose option #1' # Insert your code : simple cmdlet, or calling a function 
    } '2' {
        'You chose option #2' # Insert your code : simple cmdlet, or calling a function 
    } '3' {
        'You chose option #3' # Insert your code : simple cmdlet, or calling a function 
    } 'q' {
        return
    }
}

<# The result is like this : 
 ================ My Menu ================
1: Press '1' for this option.
2: Press '2' for this option.
3: Press '3' for this option.
Q: Press 'Q' to quit.
Please make a selection : q
 
 #>

<#
Only one Advice : If you have many entries, it could be better to build differents Show-Menu Functions (Show-MenuMain, Show-MenuAD, ...) 
 #> 

##### A Color Menu ######

# Building a function
<#
Color Menu
Source Ref : https://gallery.technet.microsoft.com/scriptcenter/Create-colorful-PowerShell-8689c5b2
#>

function CreateMenu ($Title, $MenuItems, $TitleColor, $LineColor, $MenuItemColor) { 
    Clear-Host 
    [string]$Title = "$Title" 
    $TitleCount = $Title.Length 
    $LongestMenuItem = ($MenuItems | Measure-Object -Maximum -Property Length).Maximum 
    if ($TitleCount -lt $LongestMenuItem) { 
        $reference = $LongestMenuItem 
    } 
    else 
    { $reference = $TitleCount } 
    $reference = $reference + 10 
    $Line = "═" * $reference 
    $TotalLineCount = $Line.Length 
    $RemaniningCountForTitleLine = $reference - $TitleCount 
    $RemaniningCountForTitleLineForEach = $RemaniningCountForTitleLine / 2 
    $RemaniningCountForTitleLineForEach = [math]::Round($RemaniningCountForTitleLineForEach) 
    $LineForTitleLine = "`0" * $RemaniningCountForTitleLineForEach 
    $Tab = "`t" 
    Write-Host "╔" -NoNewline -f $LineColor; Write-Host $Line -NoNewline -f $LineColor; Write-Host "╗" -f $LineColor 
    if ($RemaniningCountForTitleLine % 2 -eq 1) { 
        $RemaniningCountForTitleLineForEach = $RemaniningCountForTitleLineForEach - 1 
        $LineForTitleLine2 = "`0" * $RemaniningCountForTitleLineForEach 
        Write-Host "║" -f $LineColor -nonewline; Write-Host $LineForTitleLine -nonewline -f $LineColor; Write-Host $Title -f $TitleColor -nonewline; Write-Host $LineForTitleLine2 -f $LineColor -nonewline; Write-Host "║" -f $LineColor 
    } 
    else { 
        Write-Host "║" -nonewline -f $LineColor; Write-Host $LineForTitleLine -nonewline -f $LineColor; Write-Host $Title -f $TitleColor -nonewline; Write-Host $LineForTitleLine -nonewline -f $LineColor; Write-Host "║" -f $LineColor 
    } 
    Write-Host "╠" -NoNewline -f $LineColor; Write-Host $Line -NoNewline -f $LineColor; Write-Host "╣" -f $LineColor 
    $i = 1 
    foreach ($menuItem in $MenuItems) { 
        $number = $i++ 
        $RemainingCountForItemLine = $TotalLineCount - $menuItem.Length - 9 
        $LineForItems = "`0" * $RemainingCountForItemLine 
        Write-Host "║" -nonewline -f $LineColor ; Write-Host $Tab -nonewline; Write-Host $number"." -nonewline -f $MenuItemColor; Write-Host $menuItem -nonewline -f $MenuItemColor; Write-Host $LineForItems -nonewline -f $LineColor; Write-Host "║" -f $LineColor 
    } 
    Write-Host "╚" -NoNewline -f $LineColor; Write-Host $Line -NoNewline -f $LineColor; Write-Host "╝" -f $LineColor 
} 

# Use splating to pass the most items of the CreateMenu Function

$MenuParams = @{
    Title         = "Service Desk Task - Reports AD" 
    TitleColor    = "Red" 
    LineColor     = "Cyan"
    MenuItemColor = "Yellow"
}

# I didn't success to pass all parameters in a splat
CreateMenu @MenuParams -MenuItems  "User Memberhip groups", `
    "Group Members", `
    "Users Groups members from a file", `
    "User accounts in a specific OU", `
    "Disabled Users Accounts", `
    "User Accounts with expired password", `
    "User Accounts with password expiring in x days",
"All User Accounts",
"Quit"
<#
The result is like this ... in color
╔════════════════════════════════════════════════════════╗
║             Service Desk Task - Reports AD             ║
╠════════════════════════════════════════════════════════╣
║       1.User Memberhip groups                          ║
║       2.Group Members                                  ║
║       3.Users Groups members from a file               ║
║       4.User accounts in a specific OU                 ║
║       5.Disabled Users Accounts                        ║
║       6.User Accounts with expired password            ║
║       7.User Accounts with password expiring in x days ║
║       8.All User Accounts                              ║
║       9.Quit                                           ║
╚════════════════════════════════════════════════════════╝
#>


# then, use it in a script like this : 
CreateMenu @MenuParams -MenuItems  "User Memberhip groups", `
    "Group Members", `
    "Groups members from a file", `
    "User accounts in a specific OU", `
    "Disabled Users Accounts", `
    "User Accounts with expired password", `
    "User Accounts with password expiring in x days", `
    "All User Accounts", `
    "Quit"
$selection = Read-Host "Please make a selection"
switch ($selection) {
    '1' {
        'You chose option #1' # Insert your code : simple cmdlet, or calling a function 
    } '2' {
        'You chose option #2' # Insert your code : simple cmdlet, or calling a function 
    } '3' {
        'You chose option #3' # Insert your code : simple cmdlet, or calling a function 
    } 'q' {
        return
    }
}


