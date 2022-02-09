# How to display a pop-up message box with PowerShell in a script


## 1 - Load Assembly
Using WPF (Windows Presentation Framework) provides a better look awith rich-looking UIs. It's better that using the legacy Windows Forms.

````powershell
Add-Type -AssemblyName PresentationCore,PresentationFramework
````

This helps to access the classes in the Windows Presentation Framework.

## Decide the Button Type to use

```` powershell
$ButtonType = [System.Windows.MessageBoxButton]::YesNo
````

There are 4 types of button Types :
- OK
- OKCancel
- YesNo
- YesNoCancel

More Info about [MessageBoxButton Enum](https://docs.microsoft.com/en-us/dotnet/api/system.windows.messageboxbutton?redirectedfrom=MSDN&view=windowsdesktop-6.0)


## Decide the Message Icon to use

```` powershell
$MessageIcon = [System.Windows.MessageBoxImage]::Question
````

There are 8 types of Message Icons :
- Asterik
- Error
- Exclamation
- Hand
- None
- Question
- Stop
- Warning

More Info about [MessageBoxImage Enum](https://docs.microsoft.com/en-us/dotnet/api/system.windows.messageboximage?redirectedfrom=MSDN&view=windowsdesktop-6.0)


## Define the Message Body to display

```` powershell
$MessageBody = "Are you sure you want to delete the log file ?"
````

No specific info about this, ti's just a string to display. Note that the [String] may contain variables.

## Define the message Title

```` powershell
$MessageTitle = "Confirm Deletion"
````
No specific info about this, ti's just a string to display. Note that the [String] may contain variables.

## and finally display the result

````powershell
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
````

As you can show, the ````Show```` Method has 4 parameters :
- MessageBody
- MessageTitle
- ButtonType
- MessageIcon

Note that you must **respect this order**.

More Info about the [MessageBox Class](https://docs.microsoft.com/en-us/dotnet/api/system.windows.messagebox?redirectedfrom=MSDN&view=windowsdesktop-6.0)

## Assemble all code

````powershell
$var = "John"
Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::YesNoCancel
$MessageIcon = [System.Windows.MessageBoxImage]::Error
$MessageBody = "Are you sure you want to delete the log file, $var"
$MessageTitle = "Confirm Deletion, $Var"
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
Write-Host "Your choice is $Result"
````

## Additional explanations

- If you would like to display a Message Info Box, in a scheduled Task script, assure the *"Run Only when user is logged on"* radio button is selected. Choosing the alternative (i.e. *"Run whether user is logged on or not"*) will hide the script, including any message boxes you have programmed in.
