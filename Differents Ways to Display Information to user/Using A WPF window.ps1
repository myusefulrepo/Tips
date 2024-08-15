# Using A WPF window
$URL = 'http://ifconfig.me/ip'
$IP = (Invoke-WebRequest -Uri $URL).Content
$IPInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IP"
$Text = @"
WAN IP Address : $IP
Country : $($IPInfo.country)
"@

Add-Type -AssemblyName PresentationFramework

# Creating the window
$Window = [System.Windows.Window]::new()
$Window.AllowsTransparency    #borderless window
$Window.WindowStyle = 'none' # non-movable window. Here I'm choosing a non-movable window
$Window.SizeToContent = 'WidthAndHeight'
$Window.WindowStartupLocation = 'manual' # or 0 for 'manual', 1 for 'CenterScreen' or 2 for 'centerowner', If Manual is selected, $Window.Left, and $Window.Right or $Window.Top could be defined
$Window.left = 3450 # adjust to your resolution. Here I'm choosing the top right corner
$Window.Top = 0
$Window.Background = [System.Windows.Media.Brushes]::Azure

# Creating a StackPanel to hold the elements
$StackPanel = [System.Windows.Controls.StackPanel]::new()
$StackPanel.Margin = '10'

# Creating label
$Label = [System.Windows.Controls.Label]::new()
$Label.Content = "$Text"
$Label.FontSize = 20
$Label.FontWeight = 'bold'
# there is a property called $Label.FontFamily.Source but it's a read-only property. Otherwise, I'll set to = "seguiemj" to have emoji available
$Label.Foreground = [System.Windows.Media.Brushes]::DarkBlue
$StackPanel.AddChild($Label) | Out-Null

# Creating button
$Button = [System.Windows.Controls.Button]::new()
$Button.Content = 'OK'
$Button.Padding = '10,5'
$Button.Background = [System.Windows.Media.Brushes]::AliceBlue
$Button.Foreground = [System.Windows.Media.Brushes]::DarkBlue
$Button.FontWeight = 'Bold'
$StackPanel.AddChild($Button) | Out-Null

# Adding StackPanel to window
$Window.Content = $StackPanel

# Event for the button
$Button.Add_Click({
        $Window.Close()
    })

# Display Window
$Window.ShowDialog() | Out-Null