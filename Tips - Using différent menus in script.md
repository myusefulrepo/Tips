# Using different Menus in a script

## Building a function
The first step is to build a function, remember always thinking code reuse :-).

The role of this function is to display the Menu, based of some imputs. 

````powershell
function Invoke-Menu
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        # Menu Item
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true, 
            Position = 0)]
        $MenuItem,

        # Foreground Color
        [Parameter(Position = 1)]
        [String]
        $ForegroundColor = 'White',

        # Background Color
        [Parameter(Position = 2)]
        [String]
        $BackgroundColor = 'blue'
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess('Computer'))
        {
            # Menu items are displayed consistently using a foreach loop
            foreach ($Item in $MenuItem)
            {
                Write-Host -Object "Enter $($Item.Key) for : $($Item.Text)" -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
            }
        }
    }
    End
    {
        # Read input from user
        $Result = Read-Host -Prompt 'Please select your choice'
        Write-Host 'the value selected var is : ' -ForegroundColor Green -NoNewline
        Write-Host "$Result" -ForegroundColor Yellow
        Return $Result
    }
}# end function
````

As you can see, Menu items are defined as array of hash tables in order to not needing long Write-Host sequences and to provide consistent formatting.
Arrays are defined using @() Hashtables are defined using @{}

Here a sample of this array of HashTable. I called it ````$MainMenu````

````powershell
$MainMenu = @(
    @{Text = 'Menu item 1'; Key = 'a' }
    @{Text = 'Menu item 2'; Key = 'b' }
    @{Text = 'Menu item 3'; Key = 'c' }
    @{Text = 'Quit'; Key = 'q' }
)
````

## Using the function

At this step, we can use the previous function in a script

````powershell
do
{
    $Out = $false # Init
    $Result = Invoke-Menu -MenuItem $MainMenu -ForegroundColor yellow -BackgroundColor darkblue
    # Process the user input. In a real script, replace Write-Host with custom actions
    switch ($Result)
    {
        'a'
        {
            Write-Host 'Do a' 
        }
        'b'
        {
            Write-Host 'Do b' 
        }
        'c'
        {
            Write-Host 'Do c' 
        }
        # If user presses q, exit the Do ... While loop
        'q'
        {
            $Out = $true
        }
        # The default branch is executed, if the user input is something
        # other.
        Default
        {
            Write-Host 'Wrong input' -BackgroundColor 'red' -ForegroundColor 'white'
        }
    }
    # Display the menu as an endless loop (until q is pressed).
} While ($Out -ne $true)
````

Later in a script, we could use another menu using the previous function.

i.e. : 




````powershell
$SubMenu1 = @(
    @{Text = 'SubMenu item 1'; Key = 'a' }
    @{Text = 'SubMenu item 2'; Key = 'b' }
    @{Text = 'SubMenu item 3'; Key = 'c' }
    @{Text = 'Quit'; Key = 'q' }
)

do
{
    $Out = $False # Init
    $Result = Invoke-Menu -MenuItem $SubMenu1
    # Process the user input. In a real script, replace Write-Host with custom actions
    switch ($Result)
    {
        'a'
        {
            Write-Host 'Do a' 
        }
        'b'
        {
            Write-Host 'Do b' 
        }
        'c'
        {
            Write-Host 'Do c' 
        }
        # If user presses q, exit the Do ... While loop
        'q'
        {
            $Out = $true
        }
        # The default branch is executed, if the user input is something
        # other.
        Default
        {
            Write-Host 'Wrong input' -BackgroundColor 'red' -ForegroundColor 'white'
        }
    }
    # Display the menu as an endless loop (until q is pressed).
} while ($Out -ne $true)
````

> As you could see, in this second sample, I'm using the function with the default value for ````Background```` and ````Foreground```` Parameters.  
