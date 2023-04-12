# Play With PSReadLineOption

````Powershell 
Get-PSReadLineOption

EditMode                               : Windows
AddToHistoryHandler                    : System.Func`2[System.String,System.Object]
HistoryNoDuplicates                    : True
HistorySavePath                        : C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
HistorySaveStyle                       : SaveIncrementally
HistorySearchCaseSensitive             : False
HistorySearchCursorMovesToEnd          : False
MaximumHistoryCount                    : 4096
ContinuationPrompt                     : >> 
ExtraPromptLineCount                   : 0
PromptText                             : 
BellStyle                              : Audible
DingDuration                           : 50
DingTone                               : 1221
CommandsToValidateScriptBlockArguments : {ForEach-Object, %, Invoke-Command, icm…}
CommandValidationHandler               : 
CompletionQueryItems                   : 100
MaximumKillRingCount                   : 10
ShowToolTips                           : True
ViModeIndicator                        : None
WordDelimiters                         : ;:,.[]{}()/\|^&*-=+'"–—―
AnsiEscapeTimeout                      : 100
PredictionSource                       : HistoryAndPlugin
PredictionViewStyle                    : InlineView
CommandColor                           : "`e[93m"
CommentColor                           : "`e[32m"
ContinuationPromptColor                : "`e[37m"
DefaultTokenColor                      : "`e[37m"
EmphasisColor                          : "`e[96m"
ErrorColor                             : "`e[91m"
InlinePredictionColor                  : "`e[38;5;238m"
KeywordColor                           : "`e[92m"
ListPredictionColor                    : "`e[33m"
ListPredictionSelectedColor            : "`e[48;5;238m"
MemberColor                            : "`e[97m"
NumberColor                            : "`e[97m"
OperatorColor                          : "`e[90m"
ParameterColor                         : "`e[90m"
SelectionColor                         : "`e[30;47m"
StringColor                            : "`e[36m"
TypeColor                              : "`e[37m"
VariableColor                          : "`e[92m"
````

Take a look on the parameter ````PredictionViewStyle```` (default)

````powershell 
(Get-PSReadLineOption).PredictionViewStyle
InlineView
````
In this mode, when I'm tiping the beginning of a cmdlet, the auto-completion shows the last cmdlet from the History

 ````Powershell 
 Get-PSReadLineOption
 ````


Now changing the value
```` Powershell
Set-PSReadLineOption -PredictionViewStyle ListView
````
In this mode, when I'm tiping the beginning of a cmdlet, the auto-completion shows all last cmdlets from the History

````Powershell
Get
> Get-PSReadLineOption                                                                     [History]
> Get-AppPackage Microsoft.Windows.PowerShell                                              [History]
> Get-AppPackage Microsoft.PowerShell                                                      [History]
> get-ntfsaccess $item.fullName                                                            [History]
> Get-NTFSInheritance -Path $item.FullName                                                 [History]
> Get-LocalUser |select *                                                                  [History]
> Get-LocalUser |gm                                                                        [History]
> Get-LocalUser                                                                            [History]
> Get-LocalUser | Format-Table -Property Name,FullName,LastLogon                           [History]
> Get-WindowsDriver -Online -All | Where-Object -FilterScript { $_.Driver -like 'oem*in... [History]
````

Have you notice the value for the parameter called HistorySavePath ? In this file, there is all Console Host History.

````Powershell 
HistoryNoDuplicates                    : True
HistorySavePath                        : C:\Users\Olivier\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
HistorySaveStyle                       : SaveIncrementally
HistorySearchCaseSensitive             : False
HistorySearchCursorMovesToEnd          : False
MaximumHistoryCount                    : 4096
````
Of course, theses values could be modified. All concerning History. 

https://learn.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-5.1


# Take a look on PSReadLineKeyHandler

Here all parameters and default values

````Powershell
Get-PSReadLineKeyHandler

Basic editing functions
=======================

Key              Function            Description
---              --------            -----------
Enter            AcceptLine          Accept the input or move to the next line if input is missing a closing token.
Shift+Enter      AddLine             Move the cursor to the next line without attempting to execute the input
F12,c            AddLine             Move the cursor to the next line without attempting to execute the input
Backspace        BackwardDeleteChar  Delete the character before the cursor
Ctrl+h           BackwardDeleteChar  Delete the character before the cursor
Ctrl+Home        BackwardDeleteInput Delete text from the cursor to the start of the input
Ctrl+Backspace   BackwardKillWord    Move the text from the start of the current or previous word to the cursor to the kill ring
Ctrl+w           BackwardKillWord    Move the text from the start of the current or previous word to the cursor to the kill ring
Ctrl+C           Copy                Copy selected region to the system clipboard.  If no region is selected, copy the whole line
Ctrl+c           CopyOrCancelLine    Either copy selected text to the clipboard, or if no text is selected, cancel editing the line with CancelLine.
Ctrl+x           Cut                 Delete selected region placing deleted text in the system clipboard
Delete           DeleteChar          Delete the character under the cursor
Ctrl+End         ForwardDeleteInput  Delete text from the cursor to the end of the input
Ctrl+Enter       InsertLineAbove     Inserts a new empty line above the current line without attempting to execute the input
Shift+Ctrl+Enter InsertLineBelow     Inserts a new empty line below the current line without attempting to execute the input
Alt+d            KillWord            Move the text from the cursor to the end of the current or next word to the kill ring
Ctrl+Delete      KillWord            Move the text from the cursor to the end of the current or next word to the kill ring
Ctrl+v           Paste               Paste text from the system clipboard
Shift+Insert     Paste               Paste text from the system clipboard
Ctrl+y           Redo                Redo an undo
Escape           RevertLine          Equivalent to undo all edits (clears the line except lines imported from history)
Ctrl+z           Undo                Undo a previous edit
Alt+.            YankLastArg         Copy the text of the last argument to the input

Cursor movement functions
=========================

Key             Function        Description
---             --------        -----------
LeftArrow       BackwardChar    Move the cursor back one character
Ctrl+LeftArrow  BackwardWord    Move the cursor to the beginning of the current or previous word
Home            BeginningOfLine Move the cursor to the beginning of the line
End             EndOfLine       Move the cursor to the end of the line
RightArrow      ForwardChar     Move the cursor forward one character
Ctrl+]          GotoBrace       Go to matching brace
Ctrl+RightArrow NextWord        Move the cursor forward to the start of the next word

History functions
=================

Key       Function              Description
---       --------              -----------
Alt+F7    ClearHistory          Remove all items from the command line history (not PowerShell history)
Ctrl+s    ForwardSearchHistory  Search history forward interactively
F8        HistorySearchBackward Search for the previous item in the history that starts with the current input - like PreviousHistory if the input is empty
Shift+F8  HistorySearchForward  Search for the next item in the history that starts with the current input - like NextHistory if the input is empty
DownArrow NextHistory           Replace the input with the next item in the history
UpArrow   PreviousHistory       Replace the input with the previous item in the history
Ctrl+r    ReverseSearchHistory  Search history backwards interactively

Completion functions
====================

Key           Function            Description
---           --------            -----------
Ctrl+@        MenuComplete        Complete the input if there is a single completion, otherwise complete the input by selecting from a menu of possible completions.
Ctrl+Spacebar MenuComplete        Complete the input if there is a single completion, otherwise complete the input by selecting from a menu of possible completions.
F12,a         MenuComplete        Complete the input if there is a single completion, otherwise complete the input by selecting from a menu of possible completions.
Tab           TabCompleteNext     Complete the input using the next completion
Shift+Tab     TabCompletePrevious Complete the input using the previous completion

Prediction functions
====================

Key Function             Description
--- --------             -----------
F2  SwitchPredictionView Switch between the inline and list prediction views.

Miscellaneous functions
=======================

Key           Function              Description
---           --------              -----------
Ctrl+l        ClearScreen           Clear the screen and redraw the current line at the top of the screen
Alt+0         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+1         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+2         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+3         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+4         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+5         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+6         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+7         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+8         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+9         DigitArgument         Start or accumulate a numeric argument to other functions
Alt+-         DigitArgument         Start or accumulate a numeric argument to other functions
PageDown      ScrollDisplayDown     Scroll the display down one screen
Ctrl+PageDown ScrollDisplayDownLine Scroll the display down one line
PageUp        ScrollDisplayUp       Scroll the display up one screen
Ctrl+PageUp   ScrollDisplayUpLine   Scroll the display up one line
F1            ShowCommandHelp       Shows help for the command at the cursor in an alternate screen buffer.
Ctrl+Alt+?    ShowKeyBindings       Show all key bindings
Alt+h         ShowParameterHelp     Shows help for the parameter at the cursor.
Alt+?         WhatIsKey             Show the key binding for the next chord entered

Selection functions
===================

Key                   Function              Description
---                   --------              -----------
Ctrl+a                SelectAll             Select the entire line. Moves the cursor to the end of the line
Shift+LeftArrow       SelectBackwardChar    Adjust the current selection to include the previous character
Shift+Home            SelectBackwardsLine   Adjust the current selection to include from the cursor to the start of the line
Shift+Ctrl+LeftArrow  SelectBackwardWord    Adjust the current selection to include the previous word
Alt+a                 SelectCommandArgument Make visual selection of the command arguments.
Shift+RightArrow      SelectForwardChar     Adjust the current selection to include the next character
Shift+End             SelectLine            Adjust the current selection to include from the cursor to the end of the line
F12,d                 SelectLine            Adjust the current selection to include from the cursor to the end of the line
Shift+Ctrl+RightArrow SelectNextWord        Adjust the current selection to include the next word

Search functions
================

Key      Function                Description
---      --------                -----------
F3       CharacterSearch         Read a character and move the cursor to the next occurence of that character
Shift+F3 CharacterSearchBackward Read a character and move the cursor to the previous occurence of that character
````




One of the best features of this module is its ability to search automatically through your history of commands. However, that functionality isn't enabled by default. Enabling it is a simple process, and you can change a few options to tailor it to your preference.

````Powershell
F8        HistorySearchBackward Search for the previous item in the history that starts with the current input - like PreviousHistory if the input is empty
Shift+F8  HistorySearchForward  Search for the next item in the history that starts with the current
DownArrow NextHistory           Replace the input with the next item in the history
UpArrow   PreviousHistory       Replace the input with the previous item in the history
````

The Up and Down arrows are the first thing you should set to browse history from the command prompt.

````Powershell 
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
````


````Powershell
Get-PSReadLineKeyHandler -Unbound
...
Completion functions
====================

Key     Function              Description
---     --------              -----------
Unbound Complete              Complete the input if there is a single completion, otherwise complete the input with common prefix for all completions.  Show possible completions if pressed a second time.
````

Customizing this
````Powershell
Set-PSReadLineKeyHandler -Key Tab -Function Complete
````

Now the result is : 
Completion functions
====================

````Powershell 
Key           Function            Description
---           --------            -----------
Tab           Complete            Complete the input if there is a single completion, otherwise complete the input with common prefix for all completions.  Show possible completions if pressed a second time.
````

## sample configuration files

[Sample script from MS Github](https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1)

[Another sample]https://megamorf.gitlab.io/cheat-sheets/powershell-psreadline/