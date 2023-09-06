# Tip - A small fonction to create a Calendar DialogBox in script

## The Use Case

Imagine that you have a script intended solely for interactive use. In this script, you ask the user to enter a Date.

Naturally, different ways could be used to avoid errors in the date entered by the user. But we must also take Culture into account (a Date in English does not appear in the same order as a date in French. yyyy MM dd vs dd MM yyyy).

I offer you below a small advanced function (With no parameter, but it's advanced nonetheless because I added a verbose mode using [Cmdletbinding()]).

This uses a calendar-style dialog box.

I didn't invent anything, I just took the code provided on the [Microsoft site](https://learn.microsoft.com/en-us/powershell/scripting/samples/creating-a-graphical-date-picker? view=powershell-5.1) and created a function with all this stuff.

This can be interesting in your scripts (interactive only)

## The Code

Before the code perhaps a small point of attention. 

I've chosen to use `ShowTodayCircle   = $True` in the code below. Feel free to use `$False` for your uses.


```Powershell
function Get-aDate
{
    [CmdletBinding()]
    param ()

    begin
    {
        Write-Verbose -Message 'loading .NET classes'
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
    
        Write-Verbose -Message 'Loading a new instance of [Windows.Forms.form]'
        $Form = New-Object Windows.Forms.Form -Property @{
            StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
            Size          = New-Object Drawing.Size 243, 230
            Text          = 'Select a Date'
            Topmost       = $true
        }

        Write-Verbose -Message 'adding a MonthCalendar control to the DialogBox'
        $Calendar = New-Object Windows.Forms.MonthCalendar -Property @{
            ShowTodayCircle   = $True
            MaxSelectionCount = 1
        }
        $Form.Controls.Add($Calendar)

        Write-Verbose -Message 'Adding a OK button to the DialogBox'
        $OkButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 38, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'OK'
            DialogResult = [Windows.Forms.DialogResult]::OK
        }
        $form.AcceptButton = $OkButton
        $form.Controls.Add($OkButton)

        Write-Verbose -Message 'Adding a Cancel button to the DialogBox'
        $CancelButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 113, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'Cancel'
            DialogResult = [Windows.Forms.DialogResult]::Cancel
        }
        $form.CancelButton = $CancelButton
        $form.Controls.Add($CancelButton)
    }
    process
    {
        Write-Verbose -Message 'Display the DialogBox'
        $Result = $Form.ShowDialog()

        
        if ($Result -eq [Windows.Forms.DialogResult]::OK)
        {
            $Date = $Calendar.SelectionStart
            <# Optional
            Write-Output "Date selected: $($Date.ToShortDateString())"
            #>
        }
        
    }
    end
    {
        $Date
    }
}
```

Use : 


```powershell
# normal Mode
Get-aDate
Date selected: 06/09/2023

# verbose Mode
Get-aDate -Verbose
COMMENTAIRES : loading .NET classes
COMMENTAIRES : Loading a new instance of [Windows.Forms.form]
COMMENTAIRES : adding a MonthCalendar control to the DialogBox
COMMENTAIRES : Adding a OK button to the DialogBox
COMMENTAIRES : Adding a Cancel button to the DialogBox
COMMENTAIRES : Display the DialogBox
Date selected: 06/09/2023
```

>[Nota] : The function return the $Date variable in console if a the OK button has been chosen, else nothing is return. This is why I've chosen `ShowTodayCircle   = $True`. If the OK button is pressed, but no date chosen, we'll have today's date.

