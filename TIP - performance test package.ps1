Measure-MyScript -Name "100-Foreach Loop" -Unit ms -Repeat 100 -ScriptBlock {
$data = @(0..100)
foreach ( $node in $data )
{
    "Item: [$node]"
}
}
Measure-MyScript -Name "100-Foreach Method" -Unit ms -Repeat 100 -ScriptBlock {
$data.foreach({"Item [$PSItem]"})
}
Measure-MyScript -Name "100-For loop" -Unit ms -Repeat 100 -ScriptBlock {
for ( $index = 0; $index -lt $data.count; $index++)
{
    "Item: [{0}]" -f $data[$index]
}
}



Measure-MyScript -Name "1000-Foreach Loop" -Unit ms -Repeat 100 -ScriptBlock {
$data = @(0..1000)
foreach ( $node in $data )
{
    "Item: [$node]"
}
}
Measure-MyScript -Name "1000-Foreach Method" -Unit ms -Repeat 100 -ScriptBlock {
$data.foreach({"Item [$PSItem]"})
}
Measure-MyScript -Name "1000-For loop" -Unit ms -Repeat 100 -ScriptBlock {
for ( $index = 0; $index -lt $data.count; $index++)
{
    "Item: [{0}]" -f $data[$index]
}
}


Measure-MyScript -Name "10000-Foreach Loop" -Unit ms -Repeat 100 -ScriptBlock {
$data = @(0..10000)
foreach ( $node in $data )
{
    "Item: [$node]"
}
}
Measure-MyScript -Name "10000-Foreach Method" -Unit ms -Repeat 100 -ScriptBlock {
$data.foreach({"Item [$PSItem]"})
}
Measure-MyScript -Name "10000-For loop" -Unit ms -Repeat 100 -ScriptBlock {
for ( $index = 0; $index -lt $data.count; $index++)
{
    "Item: [{0}]" -f $data[$index]
}
}


Measure-MyScript -Name "100000-Foreach Loop" -Unit ms -Repeat 100 -ScriptBlock {
$data = @(0..100000)
foreach ( $node in $data )
{
    "Item: [$node]"
}
}
Measure-MyScript -Name "100000-Foreach Method" -Unit ms -Repeat 100 -ScriptBlock {
$data.foreach({"Item [$PSItem]"})
}
Measure-MyScript -Name "100000-For loop" -Unit ms -Repeat 100 -ScriptBlock {
for ( $index = 0; $index -lt $data.count; $index++)
{
    "Item: [{0}]" -f $data[$index]
}
}

<#
name                Avg                 Min                 Max                
----                ---                 ---                 ---                
100-Foreach Loop    0,098 Milliseconds  0,065 Milliseconds  1,3322 Milliseconds
100-Foreach Method  0,3009 Milliseconds 0,2145 Milliseconds 2,6612 Milliseconds
100-For loop        0,1865 Milliseconds 0,1417 Milliseconds 1,1957 Milliseconds
1000-Foreach Loop   0,3886 Milliseconds 0,3074 Milliseconds 1,6801 Milliseconds
1000-Foreach Method 2,2272 Milliseconds 1,8317 Milliseconds 5,0192 Milliseconds
1000-For loop       1,2864 Milliseconds 1,1381 Milliseconds 3,1989 Milliseconds
10000-Foreach Loop  3,1702 Milliseconds 2,7649 Milliseconds 5,1822 Milliseconds
10000-Foreach Me... 25,7769 Millisec... 21,418 Milliseconds 100,2741 Millise...
10000-For loop      12,5524 Millisec... 11,5678 Millisec... 15,3383 Millisec...
100000-Foreach Loop 50,7571 Millisec... 36,7766 Millisec... 117,3653 Millise...
100000-Foreach M... 257,729 Millisec... 222,3242 Millise... 322,9247 Millise...
100000-For loop     142,1927 Millise... 131,229 Millisec... 207,6459 Millise...
#>


$ProcessList = Get-Process
Measure-MyScript -Name "Pipeline to Foreach-Object" -Unit ms -Repeat 100 -ScriptBlock {
$ProcessList| ForEach-Object {$_.ProcessName}
}
Measure-MyScript -Name "Pipeline to Select-Object" -Unit ms -Repeat 100 -ScriptBlock {
$ProcessList | Select-Object -ExpandProperty ProcessName
}
Measure-MyScript -Name "Property" -Unit ms -Repeat 100 -ScriptBlock {
$ProcessList.ProcessName
}
<#
name                       Avg                 Min                 Max                  
----                       ---                 ---                 ---                  
Pipeline to Foreach-Object 4,9187 Milliseconds 2,5547 Milliseconds 178,5846 Milliseconds
Pipeline to Select-Object  3,9765 Milliseconds 3,5232 Milliseconds 11,9467 Milliseconds 
Property                   0,1388 Milliseconds 0,0714 Milliseconds 5,837 Milliseconds  
#>


$data = @(
    [pscustomobject]@{FirstName='Kevin';LastName='Marquette'}
    [pscustomobject]@{FirstName='John'; LastName='Doe'}
)
Measure-MyScript -Name "Pipeline to Where-Object filtering" -Unit ms -Repeat 100 -ScriptBlock {
$data | Where-Object {$_.FirstName -eq 'Kevin'}
}
Measure-MyScript -Name "Where Method" -Unit ms -Repeat 100 -ScriptBlock {
$data.Where({$_.FirstName -eq 'Kevin'})
}
<#
name                               Avg                 Min                 Max                
----                               ---                 ---                 ---                
Pipeline to Where-Object filtering 0,3818 Milliseconds 0,2474 Milliseconds 3,8617 Milliseconds
Where Method                       0,073 Milliseconds  0,0395 Milliseconds 1,7385 Milliseconds

==> Pipeline increase duration time
#>


$data = @(
    [pscustomobject]@{FirstName='Kevin';LastName='Marquette'}
    [pscustomobject]@{FirstName='John'; LastName='Doe'}
)
Measure-MyScript -Name "-eq" -Unit ms -Repeat 100 -ScriptBlock {
$data.Where({$_.FirstName -eq 'Kevin'})
}
Measure-MyScript -Name "-Like" -Unit ms -Repeat 100 -ScriptBlock {
$data.Where({$_.FirstName -like 'Kevin'})
}
Measure-MyScript -Name "-Contains" -Unit ms -Repeat 100 -ScriptBlock {
$data.Where({$_.FirstName -contains 'Kevin'})
}
Measure-MyScript -Name "-Match" -Unit ms -Repeat 100 -ScriptBlock {
$data.Where({$_.FirstName -match 'Kevin'})
}
<#
name      Avg                 Min                 Max                
----      ---                 ---                 ---                
-eq       0,0683 Milliseconds 0,0398 Milliseconds 1,9602 Milliseconds
-Like     0,0652 Milliseconds 0,0396 Milliseconds 1,6981 Milliseconds
-Contains 0,0731 Milliseconds 0,0402 Milliseconds 1,7818 Milliseconds
-Match    0,1515 Milliseconds 0,0434 Milliseconds 7,7597 Milliseconds
#>

$array = @('one',$null,'three')
if ( $array -eq $null)
{
    'I think Array is $null, but I would be wrong'
}
if ( $null -eq $array )
{
    'Array actually is $null'
}
if ( $array.count -gt 0 )
{
    "Array isn't empty"
}


$object = [PSCustomObject]@{Name='TestObject'}
$object.count # $null
if ( @($array).count -gt 0 )
{
    "Array isn't empty"
}
if ( $null -ne $array -and @($array).count -gt 0 )
{
    "Array isn't empty"
}

Measure-MyScript -Name "Pipeline to Foreach-Object" -Unit ms -Repeat 100 -ScriptBlock {
$array = 1..5 | ForEach-Object {
    "ATX-SQL-$PSItem"
}
}

Measure-MyScript -Name "Foreach Loop" -Unit ms -Repeat 100 -ScriptBlock {
$array = foreach ( $node in (1..5))
{
    "ATX-SQL-$node"
}
}
<#
name                       Avg                 Min                 Max                
----                       ---                 ---                 ---                
Pipeline to Foreach-Object 0,3921 Milliseconds 0,2488 Milliseconds 7,8594 Milliseconds
Foreach Loop               0,0948 Milliseconds 0,0257 Milliseconds 6,2399 Milliseconds
#>

Measure-MyScript -Name "100-Pipeline to Foreach-Object" -Unit ms -Repeat 100 -ScriptBlock {
$array = 1..100 | ForEach-Object {
    "ATX-SQL-$PSItem"
}
}

Measure-MyScript -Name "100-Foreach Loop" -Unit ms -Repeat 100 -ScriptBlock {
$array = foreach ( $node in (1..100))
{
    "ATX-SQL-$node"
}
}
<#
name                           Avg                 Min                 Max                
----                           ---                 ---                 ---                
100-Pipeline to Foreach-Object 1,0525 Milliseconds 0,8116 Milliseconds 8,7156 Milliseconds
100-Foreach Loop               0,127 Milliseconds  0,0583 Milliseconds 6,1754 Milliseconds
#>

Measure-MyScript -Name "1000-Pipeline to Foreach-Object" -Unit ms -Repeat 100 -ScriptBlock {
$array = 1..1000 | ForEach-Object {
    "ATX-SQL-$PSItem"
}
}

Measure-MyScript -Name "1000-Foreach Loop" -Unit ms -Repeat 100 -ScriptBlock {
$array = foreach ( $node in (1..1000))
{
    "ATX-SQL-$node"
}
}
<#
name                            Avg                  Min                 Max                  
----                            ---                  ---                 ---                  
1000-Pipeline to Foreach-Object 10,5272 Milliseconds 6,9953 Milliseconds 245,1266 Milliseconds
1000-Foreach Loop               0,4551 Milliseconds  0,3072 Milliseconds 7,5033 Milliseconds  
==> Using Pipeline increase execution Time
#>


Measure-MyScript -Name "ArrayList" -Unit ms -Repeat 100 -ScriptBlock {
$MyArrayList = [System.Collections.ArrayList]::new()
}
Measure-MyScript -Name "GenericList String" -Unit ms -Repeat 100 -ScriptBlock {
$Mylist = [System.Collections.Generic.List[string]]::new()
}
Measure-MyScript -Name "GenericList PsObject" -Unit ms -Repeat 100 -ScriptBlock {
$Mylist = [System.Collections.Generic.List[string]]::new()
}
<#
name                 Avg                 Min                 Max                
----                 ---                 ---                 ---                
ArrayList            0,0363 Milliseconds 0,021 Milliseconds  1,1773 Milliseconds
GenericList String   0,036 Milliseconds  0,0213 Milliseconds 1,0683 Milliseconds
GenericList PsObject 0,0359 Milliseconds 0,0215 Milliseconds 0,9199 Milliseconds

==> Creating ArrayList or GenericList consumme same time
#>






