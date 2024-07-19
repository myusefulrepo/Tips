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

# Gathering files. We limit to 100 000 (Nota $cgi contains 379938 files)
$FileCount = 100000
if (!$gci) { $gci = Get-ChildItem / -Recurse -ea SilentlyContinue }
if (!$all -or $all.count -ne $FileCount) { $all = $gci | Select-Object -first $FileCount }
$date = [datetime]::now.AddDays(-30)

Measure-MyScript -Name 'Test1 - | ForEach-Object' -Unit ms -Repeat 10 -ScriptBlock {
$all | ForEach-Object { If ($_.CreationTime -gt $date) {$_} }
}
Measure-MyScript -Name 'Test2 - ForEach(){}' -Unit ms -Repeat 10 -ScriptBlock {
foreach ($f in $all) { If ($f.CreationTime -gt $date) {$f} }
}
Measure-MyScript -Name 'Test3 - .ForEach({})' -Unit ms -Repeat 10 -ScriptBlock {
$all.ForEach({ If ($_.CreationTime -gt $date) {$_} })
}
Measure-MyScript -Name  'Test4 - |Where-Object {}'  -Unit ms -Repeat 10 -ScriptBlock {
$all | Where-Object { $_.CreationTime -gt $date }
}
Measure-MyScript -Name 'Test5 - |where-Object -prop -gt a' -Unit ms -Repeat 10 -ScriptBlock {
$all | Where-Object CreationTime -gt $date
}
Measure-MyScript -Name 'Test6 - .where({})' -Unit ms -Repeat 10 -ScriptBlock {
$all.where({ $_.CreationTime -gt $date })
}
Measure-MyScript -Name 'Test7 - .where{}' -Unit ms -Repeat 10 -ScriptBlock {
$all.where{ $_.CreationTime -gt $date }
}
Measure-MyScript -Name  'Test8 - for(){}'  -Unit ms -Repeat 10 -ScriptBlock {
for($int=0;$int -lt ($all.count - 1 );$int++ ) { If ($_.CreationTime -gt $date) {$_} }
}
Measure-MyScript -Name  'Test9 - while(){}' -Unit ms -Repeat 10 -ScriptBlock {
$int=0 ; while( $int -lt ($FileCount -1) ) { If ($all[$int].CreationTime -gt $date) { $all[$int] } ; $int++ }
}
Measure-MyScript -Name 'Test10 - Do{}While()' -Unit ms -Repeat 10 -ScriptBlock {
$int=0 ; Do{ If ($all[$int].CreationTime -gt $date) { $all[$int] } ; $int++ }while ( $int -lt ($FileCount -1) )
}
Measure-MyScript -Name  'Test11 - Do{}Until()'  -Unit ms -Repeat 10 -ScriptBlock {
$int=0 ; Do{ If ($all[$int].CreationTime -gt $date) { $all[$int] } ; $int++ }Until ( $int -ge ($FileCount -1) ) 
}

<#
$PSVersionTable

Name                           Value                                                                                                                                                           
----                           -----                                                                                                                                                           
PSVersion                      5.1.22621.3880                                                                                                                                                  
PSEdition                      Desktop                                                                                                                                                         
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}                                                                                                                                         
BuildVersion                   10.0.22621.3880                                                                                                                                                 
CLRVersion                     4.0.30319.42000                                                                                                                                                 
WSManStackVersion              3.0                                                                                                                                                             
PSRemotingProtocolVersion      2.3                                                                                                                                                             
SerializationVersion           1.1.0.1   


name             Avg                    Min                    Max                   
----             ---                    ---                    ---                   
Test1 - | ForEach-Object 2066,7904 Milliseconds 1919,5881 Milliseconds 2499,9918 Milliseconds
Test2 - ForEach(){}      122,7311 Milliseconds  113,6152 Milliseconds  133,2163 Milliseconds 
Test3 - .ForEach({})     650,4967 Milliseconds  639,7764 Milliseconds  664,7341 Milliseconds 
Test4 - |Where-Object {} 2677,6827 Milliseconds 2470,2638 Milliseconds 3208,6559 Milliseconds
Test5 - |where-Object... 2220,4467 Milliseconds 2021,5834 Milliseconds 2651,897 Milliseconds 
Test6 - .where({})       682,7328 Milliseconds  668,7208 Milliseconds  708,1836 Milliseconds 
Test7 - .where{}         688,5304 Milliseconds  663,6053 Milliseconds  727,2786 Milliseconds 
Test8 - for(){}          156,6285 Milliseconds  147,1067 Milliseconds  174,3825 Milliseconds 
Test9 - while(){}        248,3217 Milliseconds  241,8252 Milliseconds  259,6716 Milliseconds 
Test10 - Do{}While()     256,8603 Milliseconds  244,1728 Milliseconds  303,5863 Milliseconds 
Test11 - Do{}Until()     246,3595 Milliseconds  240,2746 Milliseconds  257,4495 Milliseconds 
 
If we compare the first 3 tests, we see that foreach(){} wins by a wide margin. We also see that the 1st test, using the pipeline, is failing.
This point is confirmed by tests 4 and 5, where, once again, the use of the pipeline impacts the execution time.
We also see that the .foreach or .where Methods, although they have acceptable performance, have less efficient results than foreach(){}

Tests using for(){}, while(){}, Do{}While(), or Do{}Until() processing obtain good performance, and are of the same order of magnitude

#############
$PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.4.3
PSEdition                      Core
GitCommitId                    7.4.3
OS                             Microsoft Windows 10.0.22631
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0

name                     Avg                   Min                   Max
----                     ---                   ---                   ---
Test1 - | ForEach-Object 386,8502 Milliseconds 333,3133 Milliseconds 652,4685 Milliseconds
Test2 - ForEach(){} 72,021 Milliseconds 56,6391 Milliseconds 89,0043 Milliseconds
Test3 - .ForEach({}) 239,9704 Milliseconds 228,8701 Milliseconds 268,9787 Milliseconds
Test4 - |Where-Object {} 747,9589 Milliseconds 721,6816 Milliseconds 779,0011 Milliseconds
Test5 - |where-Object -prop -gt a 616,5551 Milliseconds 573,9203 Milliseconds 872,5747 Milliseconds
Test6 - .where({}) 233,9067 Milliseconds 220,823 Milliseconds 250,2483 Milliseconds
Test7 - .where{} 233,277 Milliseconds 227,3163 Milliseconds 248,2186 Milliseconds
Test8 - for(){} 68,0961 Milliseconds 55,2434 Milliseconds 105,9065 Milliseconds
Test9 - while(){} 124,3651 Milliseconds 114,2524 Milliseconds 158,2068 Milliseconds
Test10 - Do{}While() 120,9574 Milliseconds 117,5519 Milliseconds 125,6489 Milliseconds
Test11 - Do{}Until() 122,9229 Milliseconds 116,6034 Milliseconds 138,4929 Milliseconds

With Powershell 7.x (here 7.4.3) we can see that all performances have been improved, regardless of the tests.
We can note a very notable improvement in pipeline performance.

#>


####################################
Measure-MyScript -Name 'Test1 - Assign to $null' -Unit ms -Repeat 10 -ScriptBlock {
$arrayList = [System.Collections.ArrayList]::new()
foreach ($i in 0..1000) {$null = $arraylist.Add($i) }
}
Measure-MyScript -Name 'Test2 - Cast to [void]' -Unit ms -Repeat 10 -ScriptBlock {
$arrayList = [System.Collections.ArrayList]::new()
foreach ($i in 0..1000) {[void] $arraylist.Add($i) }
}
Measure-MyScript -Name 'Test3 - Redirect to $null' -Unit ms -Repeat 10 -ScriptBlock {
$arrayList = [System.Collections.ArrayList]::new()
foreach ($i in 0..1000) {$arraylist.Add($i) > $null }
}
Measure-MyScript -Name 'Test4 - Pipe to Out-Null' -Unit ms -Repeat 10 -ScriptBlock {
$arrayList = [System.Collections.ArrayList]::new()
foreach ($i in 0..1000) { $arraylist.Add($i) | Out-Null }
}
<#
With Windows powershell 5.1
name                      Avg                   Min                  Max                  
----                      ---                   ---                  ---                  
Test1 - Assign to $null   1,0579 Milliseconds   0,0726 Milliseconds  9,3875 Milliseconds  
Test2 - Cast to [void]    0,875 Milliseconds    0,0727 Milliseconds  7,3808 Milliseconds  
Test3 - Redirect to $null 2,5291 Milliseconds   0,157 Milliseconds   14,1272 Milliseconds 
Test4 - Pipe to Out-Null  246,0788 Milliseconds 238,187 Milliseconds 257,3145 Milliseconds

With powershell 7.4.3
name                      Avg                 Min                Max
----                      ---                 ---                ---
Test1 - Assign to $null   6,0783 Milliseconds 2,302 Milliseconds 34,4447 Milliseconds
Test2 - Cast to [void]    2,5902 Milliseconds 2,281 Milliseconds 4,1359 Milliseconds
Test3 - Redirect to $null 2,894 Milliseconds 2,3512 Milliseconds 6,3293 Milliseconds
Test4 - Pipe to Out-Null  8,769 Milliseconds 3,1511 Milliseconds 32,9489 Milliseconds

"Cast to [Void]" remains the most efficient method than this with Windows Powershell 5.1 or Powershell 7.4.3

#>




