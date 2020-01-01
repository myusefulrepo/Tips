# Comparizon :  4 different ways to format numeric output with 2 decimals

I was writing different ways of formatting an output when I noticed some gaps that I can not explain.
If anyone could explain to me why we get different outings, my culture would be grateful to him.

# 1 - Use Label ; Expression ; format

````powershell
$f = Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB"      ; Expression = {$_.FreeSpace / 1GB}     ; format = '0.00'},
               @{Label = "Total_Size_GB"     ; Expression = {$_.Size / 1GB}          ; format = '0.00'},
               VolumeName,
               @{Label = "Percent_Free_Space"; Expression = {$_.FreeSpace / $_.Size} ; format = '0.00%'}
````

We can use `f` instead `format`
>[Nota] : Blank space are insignifiant, i use them only to clarify the code

# 2 - Use [Math]::round(Number,round)

````powershell
$round = Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB"      ; Expression = {[Math]::round($_.FreeSpace / 1GB, 2)} },
               @{Label = "Total_Size_GB"     ; Expression = {[Math]::round($_.Size / 1GB, 2 )} },
               VolumeName,
               @{Label = "Percent_Free_Space"; Expression = {[Math]::round(($_.FreeSpace / $_.Size)*100,2)} }
````

# 3 - Create and use a dedicated function to format output

````powershell
function Set-Precision([Float]$Number, [int]$Precision )
{
 $prec="{0:N$precision}"
 $val=$($prec -f $number)

 return $val
}

$function = Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB"      ; Expression = { Set-Precision -Number ($_.FreeSpace / 1GB) -Precision 2 } },
               @{Label = "Total_Size_GB"     ; Expression = { Set-Precision -Number ($_.Size / 1GB) -Precision 2 } },
               VolumeName,
               @{Label = "Percent_Free_Space"; Expression = { Set-Precision -Number ($_.FreeSpace / $_.Size * 100) -Precision 2 } }
````

As you can see, the function use the operator `-f` like the following sample

# 4 - use the -f format operator

The syntax for -F format operator is {<index>[,<alignment>][:<formatString>]}
| Format Strings |             Description
|:--------------:|:------------------------------------------:
| :C             | Currency format (for the current culture)
| :X             | Display Number in Hexa Decimal
| :p             | Display Number as Percentage
| :n             | Display with width n to left side (:np p for precision=number of decimal places), includes culture separator for thousands 1,000.00
| :-n            | Display with width -n to right side
| :d             | Display Numbers Padded by 0 by n times. (:dp p for precision=number of digits); if needed, leading zeros are added to the beginning of the (whole) number.
| :#             | Digit placeholder,
| :,             | Thousand separator
| :\             | Escape Character
| :ddd           | Day of Week
| :dd            | Day of Month
| :dddd          | Full name of Day of Week
| :hh            | Hour
| :HH            | Hour in 24 Hour format
| :mm            | Minutes
| :SS            | Seconds
| :MM            | Month in Number
| :MMMM          | Name of the Month
| :yy            | Year in short
| :yyyy          | Full year
>[Nota] In `-F` format operator we provide the **strings and numbers in the right hand side** and **syntax in left hand side**

Some examples

````powershell
# Display a number to 3 decimal places :
"{0:n3}" -f 123.45678
123.457

# Right align the first number only :
"{0,10}" -f 4,5,6
         4

# Left and right align text :
"|{0,-10}| |{1,10}|" -f "hello", "world"
|hello     ||     world|

# Display an integer with 3 digits :
"{0:n3}" -f [int32]12
012

# Separate a number with dashes (# digit place holder):
"{0:###-##-##}" -f 1234567
123-45-67

#Display a number as a percentage:
"{0:p0}" -f 0.5
50%

# Display a whole number padded to 5 digits:
"{0:d5}" -f 123
00123
````

and now with our query

````powershell
$foperator = Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB"      ; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) } },
               @{Label = "Total_Size_GB"     ; Expression = { "{0:N2}" -f ($_.Size / 1GB) } },
               VolumeName,
               @{Label = "Percent_Free_Space"; Expression = { "{0:P2}" -f ($_.FreeSpace / $_.Size ) } }
````

and now let's display all

````powershell
$f
$round
$function
$foperator

DeviceID FreeSpace_GB Total_Size_GB VolumeName Percent_Free_Space
-------- ------------ ------------- ---------- ------------------
C:             273,49        464,38 SYSTEM                 58,89%
D:            7732,24       8383,43 DATA                   92,23%

DeviceID FreeSpace_GB Total_Size_GB VolumeName Percent_Free_Space
-------- ------------ ------------- ---------- ------------------
C:             273,49        464,38 SYSTEM                  58,89
D:            7732,24       8383,43 DATA                    92,23

DeviceID FreeSpace_GB Total_Size_GB VolumeName Percent_Free_Space
-------- ------------ ------------- ---------- ------------------
C:       273,49       464,38        SYSTEM     58,89
D:       7 732,24     8 383,43      DATA       92,23

DeviceID FreeSpace_GB Total_Size_GB VolumeName Percent_Free_Space
-------- ------------ ------------- ---------- ------------------
C:       273,49       464,38        SYSTEM     58,89 %
D:       7 732,24     8 383,43      DATA       92,23 %
````

The output are different. Why is this behavior different ?

# And now the explanation i've received in Reddit powershell section

**Strings are left-aligned and numbers are right-aligned** by default.
Your output is a mix and match between strings and numbers.

So, the 3 & 4 samples use the `-f` string format operator ... so they will `always return a string`

`[math]` returns an `integer` or a `double` etc (actual numbers), whereas `-f` as stated above returns a string so even if it returns numbers, those numbers are still of the object type 'string'

In addition to Label, Expression, and Format, you can also use an ***Alignment key*** in the property ***hashtables***. It can be any of: "Left", "Center", or "Right". (Or `a='r'`` if you're abbreviating.)

Let's do this :

````powershell
$foperator  = Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB"      ; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) }; Alignment = "r" },
               @{Label = "Total_Size_GB"     ; Expression = { "{0:N2}" -f ($_.Size / 1GB) }; Alignment = "r" },
               VolumeName,
               @{Label = "Percent_Free_Space"; Expression = { "{0:P2}" -f ($_.FreeSpace / $_.Size ) }; Alignment = "r"  }
$foperator
DeviceID FreeSpace_GB Total_Size_GB VolumeName Percent_Free_Space
-------- ------------ ------------- ---------- ------------------
C:             273,44        464,38 SYSTEM                58,88 %
D:           7 732,24      8 383,43 DATA                  92,23 %
````

````powershell
Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB - format rights"      ; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) }; Alignment = "r" },
               @{Label = "FreeSpace_GB - format left"        ; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) }; Alignment = "l" },
               @{Label = "FreeSpace_GB - format center"      ; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) }; Alignment = "c" }

DeviceID FreeSpace_GB - format rights FreeSpace_GB - format left FreeSpace_GB - format center
-------- ---------------------------- -------------------------- ----------------------------
C:                             273,44 273,44                                273,44
D:                           7 732,24 7 732,24                             7 732,24
````
I didn't know this way to use "Label ... expression", I've learned something new this day.

Cherries on the cake, we can combine all these keys in the "Label ... Expression" hashtable

````powershell
Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB"      ; Expression = {$_.FreeSpace / 1GB}     ; format ='0.00'  ; Alignment = "c"},
               @{Label = "Total_Size_GB"     ; Expression = {$_.Size / 1GB}          ; format ='0.00'  ; Alignment = "c"},
               VolumeName,
               @{Label = "Percent_Free_Space"; Expression = {$_.FreeSpace / $_.Size} ; format ='0.00%' ; Alignment = "c"}

DeviceID FreeSpace_GB Total_Size_GB VolumeName Percent_Free_Space
-------- ------------ ------------- ---------- ------------------
C:          273,44       464,38     SYSTEM           58,88%
D:         7732,24       8383,43    DATA             92,23%
````

## Additional question : is it possible to add color at the output

It's possible to use `Write-Host` with colors (parameters `-ForegroundColor` and `-BackgroundColor`), but there's no "output" to send to `Format-Table`
The "output" from `Write-Host` is a side-effect that sends data directly to the console rather than returning it to the caller like a standard function.

But, there is a "but", I've found a small function called [Format-Color](https://www.bgreco.net/powershell/format-color/)
Here the function
````powershell
function Format-Color([hashtable] $Colors = @{}, [switch] $SimpleMatch) {
	$lines = ($input | Out-String) -replace "`r", "" -split "`n"
	foreach($line in $lines) {
		$color = ''
		foreach($pattern in $Colors.Keys){
			if(!$SimpleMatch -and $line -match $pattern) { $color = $Colors[$pattern] }
			elseif ($SimpleMatch -and $line -like $pattern) { $color = $Colors[$pattern] }
		}
		if($color) {
			Write-Host -ForegroundColor $color $line
		} else {
			Write-Host $line
		}
	}
}
````

and now let's try it

````powershell
$Query = Get-CimInstance -ClassName win32_logicaldisk |
  Format-Table DeviceID,
               @{Label = "FreeSpace_GB"      ; Expression = {$_.FreeSpace / 1GB}     ; format ='0.00'  ; Alignment = "c"},
               @{Label = "Total_Size_GB"     ; Expression = {$_.Size / 1GB}          ; format ='0.00'  ; Alignment = "c"},
               VolumeName,
               @{Label = "Percent_Free_Space"; Expression = {$_.FreeSpace / $_.Size} ; format ='0.00%' ; Alignment = "c"}

$Query | Format-Color @{"DATA" = "Green"; "VolumeName" = "red"; "System" = "yellow"}

DeviceID FreeSpace_GB Total_Size_GB VolumeName Percent_Free_Space
-------- ------------ ------------- ---------- ------------------
C:          273,41       464,38     SYSTEM           58,88%
D:         7732,24       8383,43    DATA             92,23%

````

It works fine, and more is simply to use `Format-Color @{<Value1> = <Color>; <Value2> = <Color2>; ...}`
>[Nota] : The colors are not rendered in the code above
>[Nota] : This function colors all the line when matching, not column or value

I also found another function called [Write-PSObject](https://gallery.technet.microsoft.com/scriptcenter/Format-Table-Colors-in-e0a4beac)
It's really complete and can colorize the values and the columns but it's not very easy to use.

I should also mention the [PSWrite](https://github.com/sctfic/PsWrite#octocat-write-logstep-in-pswritepsm1) powershell module that does a very good job

>[Nota] : At this point, one can simply ask the question : is it really useful to make a color output console, especially since this output will be only temporary (lifetime of the console) ?
>I'm thinking *no*, almost time.

# SYNTHESIS

We have seen this :

- If we use the `-f` operator,  the result type is ***always a string***, not a numeric.
- If we use the key `f` in addition to Label, Expression, the result is not modified, just the output

Moreover, we discovered that in the ***hashtable*** 'Label, Expression' we can add additional keys like `format` (`f`) or `Alignment` (`a`)

Hope this will be useful (if it's not for you, it's for me, sure)
