# Some different ways to display script execution time with a beautiful display
## First way : Using ````Get-Date````

```` Powershell
# Begining the script
$StartTime = Get-Date
# your code here

# end script
$EndTime = Get-Date
$CheckTime = New-TimeSpan -Start $StartTime -End $EndTime
# Display Script execution Time
$CheckTime
````
## Second way : Using the ````[System.Diagnostics.Stopwatch]```` .Net class

```` Powershell
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()
# or simply, defining the Type [System.Diagnostics.Stopwatch], like the following
[System.Diagnostics.Stopwatch]$StopWatch.Start()
# your code here

# At the end of the script
$StopWatch.Stop()
$StopWatch.Elapsed
````

## Improving the output

```` Powershell
if ($CheckTime.Days -gt ‘0’)
{
    Write-Host "$(“Script Completed in {0} days, {1} hours, {2} minutes {3} seconds `n" -f $CheckTime.Days, $CheckTime.Hours, $CheckTime.Minutes, $CheckTime.Milliseconds )" -ForegroundColor Green
}
elseif ($CheckTime.Hours -gt ‘0’)
{
    Write-Host "$(“Script Completed in {0} hours, {1} minutes`n” -f $CheckTime.Hours, $CheckTime.tMinutes )" -ForegroundColor Green
}
elseif ($CheckTime.Minutes -gt ‘0’)
{
    Write-Host "$(“Script Completed in {0} minutes, {1} seconds`n” -f $CheckTime.Minutes, $CheckTime.Seconds )" -ForegroundColor Green
}
else
{
    Write-Host "$(“Script Completed in {0} seconds, {1} milliseconds `n” -f $CheckTime.Seconds, $CheckTime.Milliseconds )" -ForegroundColor Green
}

<#
Script Completed in 34 minutes, 21 seconds
#>
````


## Even better coding : Using a ````Switch```` statement 

```` Powershell
switch ($CheckTime)
{
    { $($CheckTime.Days) -gt '0' }
    {
        Write-Host "$(“Script Completed in {0} days, {1} hours, {2} minutes {3} seconds `n” -f $CheckTime.Days, $CheckTime.Hours, $CheckTime.totalMinutes, $CheckTime.seconds)" -ForegroundColor Green 
    }
    { $($CheckTime.Hours) -gt '0' }
    {
        Write-Host "$(“Script Completed in {0} hours, {1} minutes `n” -f $CheckTime.Hours, $CheckTime.tMinutes)" -ForegroundColor Green 
    }
    { $($CheckTime.Minutes) -gt '0' }
    {
        Write-Host "$(“Script Completed in {0} minutes, {1} seconds `n” -f $CheckTime.Minutes, $CheckTime.Seconds)" -ForegroundColor Green 
    }
    Default
    {
        Write-Host "$(“Script Completed in {0} seconds, {1} milliseconds `n” -f $CheckTime.Seconds, $CheckTime.Milliseconds )" -ForegroundColor Green
    }
}
````

## Or in the same vein,  with a better look

```` Powershell 
switch ($CheckTime)
{
    { $($CheckTime.Days) -gt '0' }
    {
        Write-Host "Script Completed in " -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Days) " -ForegroundColor Yellow -NoNewline
        Write-Host "Days " -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Hours) " -ForegroundColor Yellow -NoNewline
        Write-Host "hours, " -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Minutes) " -ForegroundColor Yellow -NoNewline
        Write-Host "minutes, " -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.seconds) " -ForegroundColor Yellow -NoNewline
        Write-Host "seconds `n" -ForegroundColor Green 
    }
    { $($CheckTime.Hours) -gt '0' }
    {
        Write-Host "Script Completed in " -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Hours) " -ForegroundColor Yellow -NoNewline
        Write-Host "hours, " -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Minutes) " -ForegroundColor Yellow -NoNewline
        Write-Host "minutes `n" -ForegroundColor Green 
    }
    { $($CheckTime.Minutes) -gt '0' }
    {
        Write-Host "Script Completed in "  -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Minutes) " -ForegroundColor Yellow -NoNewline
        Write-Host "minutes, "  -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Seconds) " -ForegroundColor Yellow -NoNewline
        Write-Host "seconds `n"  -ForegroundColor Green 
    }
    Default
    {
        Write-Host "Script Completed in "  -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Seconds) " -ForegroundColor Yellow -NoNewline
        Write-Host "seconds, "  -ForegroundColor Green -NoNewline
        Write-Host "$($CheckTime.Milliseconds) " -ForegroundColor Yellow -NoNewline
        Write-Host "milliseconds `n" -ForegroundColor Green
    }
}
````

## As an alternative, you could use a Advanced function calle Get-TimeSpanPretty

````Powershell 
Function Get-TimeSpanPretty
{
    <#
.SYNOPSIS
   Displays the time span between two dates in a single line, in an easy-to-read format
.DESCRIPTION
   Only non-zero weeks, days, hours, minutes and seconds are displayed.
   If the time span is less than a second, the function display "Less than a second."
.PARAMETER TimeSpan
   Uses the TimeSpan object as input that will be converted into a human-friendly format
.EXAMPLE
   Get-TimeSpanPretty -TimeSpan $TimeSpan
   Displays the value of $TimeSpan on a single line as number of weeks, days, hours, minutes, and seconds.
.EXAMPLE
   $LongTimeSpan | Get-TimeSpanPretty
   A timeline object is accepted as input from the pipeline. 
   The result is the same as in the previous example.
.OUTPUTS
   String(s)
.NOTES
   Last changed on 28 July 2022
   Source : https://4sysops.com/archives/format-time-and-date-output-of-powershell-new-timespan/#comment-1140293
#>
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()][timespan]$TimeSpan
    )
    Begin
    {
    }
    Process
    {
        # Initialize $TimeSpanPretty, in case there is more than one timespan in the input via pipeline
        [string]$TimeSpanPretty = ''
    
        $Ts = [ordered]@{
            Weeks   = [math]::Floor($TimeSpan.Days / 7)
            Days    = [int]$TimeSpan.Days % 7
            Hours   = [int]$TimeSpan.Hours
            Minutes = [int]$TimeSpan.Minutes
            Seconds = [int]$TimeSpan.Seconds
        } 
        # Process each item in $Ts (week, day, etc.)
        foreach ($i in $Ts.Keys)
        {
            # Skip if zero
            if ($Ts.$i -ne 0)
            {
                
                # Append the value and key to the string
                $TimeSpanPretty += '{0} {1}, ' -f $Ts.$i, $i
                
            } #Close if
    
        } #Close for
    
        # If the $TimeSpanPretty is not 0 (which could happen if start and end time are identical.)
        if ($TimeSpanPretty.Length -ne 0)
        {
            # delete the last coma and space
            $TimeSpanPretty = $TimeSpanPretty.Substring(0, $TimeSpanPretty.Length - 2)
        }
        else
        {
        
            # Display "Less than a second" instead of an empty string.
            $TimeSpanPretty = 'Less than a second'
        }
        $TimeSpanPretty
    } # Close Process
    End
    {
    }
} # Close function Get-TimeSpanPretty
````
and using like this
````powershell 
$CheckTime | Get-TimeSpanPretty
````
> [Nota] : This function is useful in case of many output are displayed in console, because it facilitates writing and reading.
> 
> In the case of a single console output, it is not necessarily useful to extend your script with an internal function.

## Another alternative : Using the Powershell module ````PSWriteColor````
````Powershell 
Function Check-Module
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ModuleName
    )
    If ( -not (Get-Module -ListAvailable $ModuleName))
    {
        Install-Module PSWriteColor
    }
    else
    {
        # Module Already installed : loading
        Import-Module $ModuleName
    }
}
Check-Module -ModuleName PSWriteColor
Write-Color -Text 'Script Completed in ' , "$($CheckTime.Days) ", 'days, ', "$($CheckTime.Hours) ", 'hours, ', "$($CheckTime.Minutes) ", 'minutes ', "$($CheckTime.seconds) ", 'seconds' -Color Green, Yellow, Green, Yellow, Green, Yellow, Green, Yellow, Green
````

As you can see,the cmdlet ````Write-Color```` is easy to understand : a bunch of String separates by comma for the ````-Text```` parameter and a bunch of color separate by comma in the same order for the color to applied for the ````-Color```` parameter.



## Final Word
I hope this overview has enabled you to make your choice.






