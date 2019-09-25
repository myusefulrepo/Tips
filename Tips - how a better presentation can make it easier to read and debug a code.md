# How a better presentation can make easier to read, understand and debug a code

Let's show this sample found in the Internet

````powershell
$items = Import-CSV "C:\OSMOR Pipeline\u_dbview_fsc.csv" | Sort-Object 'cr_start_date' | Where-Object { ($_.cr_u_port_driver -in @('CCT-Retail Operations Technology', 'CCT-Retail Operations & Intria', 'CCT-Enterprise Operations Technology (EOT)')) -and ($_.ct_assignment_group -in @('to-io.got-app', 'to-io.got-proc', 'to-io.got'))} | Select-Object -Property `
    @{ Name       = 'Change request'; Expression = 'ct_change_request' },
    @{ Name       = 'Change Title'; Expression = 'cr_short_description' },
    @{ Name       = 'Technology Portfolio Driver'; Expression = 'cr_u_port_driver' },
    @{ Name       = 'Planned Start Date'; Expression = 'cr_start_date' },
    @{ Name       = 'Planned End Date'; Expression = 'cr_end_date' },
    @{ Name       = 'Phase'; Expression = 'cr_phase' },
    @{ Name       = 'Change Type'; Expression = 'cr_type' },
    @{ Name       = 'Opened By'; Expression = 'cr_opened_by' },
    @{ Name       = 'Task Description'; Expression = 'ct_description' },
    @{ Name       = 'Task Number'; Expression = 'ct_number' },
    @{ Name       = 'Assigned To'; Expression = 'ct_assigned_to' },
    @{ Name       = 'Assignment Group'; Expression = 'ct_assignment_group' },
    @{ Name       = 'Technology Portfolio Impacted'; Expression = 'tpi_u_technology_portfolio' } | Export-Excel -Path 'C:\Temp\Test1.xls' -Title "Changes Driven by CCT-GOT" -TitleBold
````
## Comments about the code
it's hard to reason through the code. Let's see in details

It's a oneline command.

Let's cut it in parts and talk about.

````powershell
$items = Import-CSV "C:\OSMOR Pipeline\u_dbview_fsc.csv" | Sort-Object 'cr_start_date' | Where-Object { ($_.cr_u_port_driver -in @('CCT-Retail Operations Technology', 'CCT-Retail Operations & Intria', 'CCT-Enterprise Operations Technology (EOT)')) -and ($_.ct_assignment_group -in @('to-io.got-app', 'to-io.got-proc', 'to-io.got'))}
````
Too long line, trunk depending of the larger of your screen.

Difficult to read and understand (I haven't any idea about the parameters, but it's not the question, I'm talking about code)

````powershell
$items = Import-CSV "C:\OSMOR Pipeline\u_dbview_fsc.csv" |
        Sort-Object 'cr_start_date' |
        Where-Object { ($_.cr_u_port_driver -in @('CCT-Retail Operations Technology', 'CCT-Retail Operations & Intria', 'CCT-Enterprise Operations Technology (EOT)')) -and
                       ($_.ct_assignment_group -in @('to-io.got-app', 'to-io.got-proc', 'to-io.got'))
                     }
````
By this way, this is a more readable, but not yet enough. We'll see later how to do something better (I hope)

for the remaining code, it's just a change header and export in a .csv file.

# 1st Try to show a more readable code
I suggest to separate the different sections of the code.
- Define some parameters in variables (Arrays)
- Import and filter
- Process (change header)
- Export

Let's tidy it up a bit

```` powershell
$DriverArray = @(
    'CCT-Retail Operations Technology'
    'CCT-Retail Operations & Intria'
    'CCT-Enterprise Operations Technology (EOT)'
)

$GroupArray = @(
    'to-io.got-app'
    'to-io.got-proc'
    'to-io.got'
)

$items = Import-CSV "C:\OSMOR Pipeline\u_dbview_fsc.csv" |
    Sort-Object -Property 'cr_start_date' |
    Where-Object {
        $_.cr_u_port_driver -in $DriverArray -and
        $_.ct_assignment_group -in $GroupArray
    } | ForEach-Object {
        [PSCustomObject]@{
            'Change request'                = $_.'ct_change_request'
            'Change Title'                  = $_.'cr_short_description'
            'Technology Portfolio Driver'   = $_.'cr_u_port_driver'
            'Planned Start Date'            = $_.'cr_start_date'
            'Planned End Date'              = $_.'cr_end_date'
            'Phase'                         = $_.'cr_phase'
            'Change Type'                   = $_.'cr_type'
            'Opened By'                     = $_.'cr_opened_by'
            'Task Description'              = $_.'ct_description'
            'Task Number'                   = $_.'ct_number'
            'Assigned To'                   = $_.'ct_assigned_to'
            'Assignment Group'              = $_.'ct_assignment_group'
            'Technology Portfolio Impacted' = $_.'tpi_u_technology_portfolio'
        }
    }

$items |
    Export-Excel -Path 'C:\Temp\Test1.xls' -Title "Changes Driven by CCT-GOT" -TitleBold
````
## comments about this code
It's easier to read, and easier to understand
Each section is separate form the others by a blank line. We can distinguish
- Define Parameters in variables (String, Arrays)
- Import, filter and modify header
- Export

It seems that we could do better.

# 2nd Try to show a more readable code

```` powershell
#region Parameters
$ImportCsvfile = 'C:\OSMOR Pipeline\u_dbview_fsc.csv'
$SortProperty  = 'cr_start_date'
$ExportFile    = 'C:\Temp\Test1.xls'
$ExportTitle   = "Changes Driven by CCT-GOT"

$DriverArray = @(
    'CCT-Retail Operations Technology'
    'CCT-Retail Operations & Intria'
    'CCT-Enterprise Operations Technology (EOT)'
)

$GroupArray = @(
    'to-io.got-app'
    'to-io.got-proc'
    'to-io.got'
)
#Endregion

#region Import and filtering
$Items = Import-CSV $ImportCsvFile |
    Sort-Object -Property $SortProperty |
    Where-Object {
        $_.cr_u_port_driver -in $DriverArray -and
        $_.ct_assignment_group -in $GroupArray
    }
#endregion

#region Custom Headers
$Result = ForEach-Object ($Item in $Items)
    {
        [PSCustomObject]@{
            'Change request'                = $Item.'ct_change_request'
            'Change Title'                  = $Item.'cr_short_description'
            'Technology Portfolio Driver'   = $Item.'cr_u_port_driver'
            'Planned Start Date'            = $Item.'cr_start_date'
            'Planned End Date'              = $Item.'cr_end_date'
            'Phase'                         = $Item.'cr_phase'
            'Change Type'                   = $Item.'cr_type'
            'Opened By'                     = $Item.'cr_opened_by'
            'Task Description'              = $Item.'ct_description'
            'Task Number'                   = $Item.'ct_number'
            'Assigned To'                   = $Item.'ct_assigned_to'
            'Assignment Group'              = $Item.'ct_assignment_group'
            'Technology Portfolio Impacted' = $Item.'tpi_u_technology_portfolio'
        }
    }
#endregion

#region Export to a .csv file
$Result |
    Export-Excel -Path $ExportFile -Title $ExportTitle -TitleBold
#endregion
````
## comments about the code
It's easier to read, and easier to understand
Each section is separate form the others by a blank line. We can distinguish
- Define some parameters in variables (String, Arrays)
- Import and filter
- Process (modify header)
- Export

### using regions

and I Introduce ````#region  [...] #endregion````

In this .md file, it seems to produce no change, but if you open the code with ISE or VS Code and then you could collapse the code of a specific region or all regions.

It could be useful when the code is very long.


### comments the code

Explanations are the text after ````region````, no additional comments are necessary


### cut the code in regions : One process/task/action/subjet - one region

I separate in 2 regions : import and filter and process (modify headers)


***Why ?***
if in the script you would like to use ````$Items```` variable in another process. If you concatenate import/filter and process, you will not be able to do this with the existing variable. it will be necessary to recalculate another.
Then, I separate.

For the same reason, I separate process and export in a file. So I can export in many different ways (console, .csv, .txt, .xml, .html, embedded in the body of a mail, ...)


### Avoid Hard-coding in the code

Perhaps, have you noticed that the export path is defined in the beginning of the code in a variable and some other parameters too.

It's not useful to dive into the code to modify a fileName, a parameter and so on, used many times in the script.


# and finally

I hope this sample could be helpful for some people.
