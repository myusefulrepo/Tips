# How to find and eliminate performance bottlenecks with PowerShell ?

- [x] **Do not append ( += ) arrays and strings** to avoid copy/duplicate/delete of arrays 

Array addition is inefficient because arrays have a **fixed size**. Each addition to the array creates a new array big enough to hold all elements of both the left and right operands. The elements of both operands are copied into the new array. For small collections, this overhead may not matter. Performance can suffer for large collections.

Demo : 
```powershell
$tests = @{
    'PowerShell Explicit Assignment' = {
        param($count)

        $result = foreach($i in 1..$count) {
            $i
        }
    }

    '.Add(..) to List<T>' = {
        param($count)

        $result = [Collections.Generic.List[int]]::new()
        foreach($i in 1..$count) {
            $result.Add($i)
        }
    }

    '+= Operator to Array' = {
        param($count)

        $result = @()
        foreach($i in 1..$count) {
            $result += $i
        }
    }
}

5kb, 10kb, 100kb | ForEach-Object {
    $groupResult = foreach($test in $tests.GetEnumerator()) {
        $ms = (Measure-Command { & $test.Value -Count $_ }).TotalMilliseconds

        [pscustomobject]@{
            CollectionSize    = $_
            Test              = $test.Key
            TotalMilliseconds = [math]::Round($ms, 2)
        }

        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }

    $groupResult = $groupResult | Sort-Object TotalMilliseconds
    $groupResult | Select-Object *, @{
        Name       = 'RelativeSpeed'
        Expression = {
            $relativeSpeed = $_.TotalMilliseconds / $groupResult[0].TotalMilliseconds
            [math]::Round($relativeSpeed, 2).ToString() + 'x'
        }
    }
}
```

```Output
# With Windows Powershell 5.1
CollectionSize Test                           TotalMilliseconds RelativeSpeed
-------------- ----                           ----------------- -------------
          5120 PowerShell Explicit Assignment              8,22 1x           
          5120 .Add(..) to List<T>                         21,2 2,58x        
          5120 += Operator to Array                      291,32 35,44x       
         10240 .Add(..) to List<T>                         0,52 1x           
         10240 PowerShell Explicit Assignment              0,53 1,02x        
         10240 += Operator to Array                     1600,65 3078,17x     
        102400 .Add(..) to List<T>                          4,1 1x           
        102400 PowerShell Explicit Assignment               4,5 1,1x         
        102400 += Operator to Array                   133456,39 32550,34x
# With Powershell 7.3.6
CollectionSize Test                           TotalMilliseconds RelativeSpeed
-------------- ----                           ----------------- -------------
          5120 PowerShell Explicit Assignment              8,32 1x
          5120 .Add(..) to List<T>                        12,48 1,5x
          5120 += Operator to Array                      318,34 38,26x
         10240 PowerShell Explicit Assignment              0,35 1x
         10240 .Add(..) to List<T>                         1,71 4,89x
         10240 += Operator to Array                     1309,00 3740x
        102400 PowerShell Explicit Assignment              3,09 1x
        102400 .Add(..) to List<T>                        19,04 6,16x
        102400 += Operator to Array                   104948,63 33963,96x
```

==> Use collections, hashsets, stringbuilder, streams, etc., assign the loop ('s output) to variable.

    ```Powershell
    # To store [String]. You could also use [Int]
    $Output = [System.Collections.Generic.List[Int]]::new()
    #  Recommanded way with different types of objects. You could also use [PSObject]
    $Output = [System.Collections.Generic.List[Object]]::new()
    $Output.Add(1)
    $Output.Add('2')
    $Output.Add(3.0)
    $Output.GetEnumerator().ForEach({ "$_ is $($_.GetType())" })
    <#
    1 is int
    2 is string
    3 is double
    >#
    ```

```Powershell
    $results = @(Do-This
                Do-That
                )
    $results.GetType()

    IsPublic IsSerial Name                                     BaseType 
    -------- -------- ----                                     --------
    True     True     Object[]                                 System.Array

    <# PowerShell creates an ArrayList to hold the results written to the pipeline inside the array expression. Just before assigning to $results, PowerShell converts the ArrayList to an object[].
    #>

    $Output.GetType()

    IsPublic IsSerial Name                                     BaseType
    -------- -------- ----                                     --------
    True     True     List`1                                   System.Object
```

- [x] **Strings are immutable**. Each addition to the string actually creates a new string big enough to hold the contents of both the left and right operands, then copies the elements of both operands into the new string. For small strings, this overhead may not matter. For large strings, this can affect performance and memory consumption.

Demo : 
```Powershell
    $tests = @{
        'StringBuilder' = {
            $sb = [System.Text.StringBuilder]::new()
            foreach ($i in 0..$args[0]) {
                $sb = $sb.AppendLine("Iteration $i")
            }
            $sb.ToString()
        }
        'Join operator' = {
            $string = @(
                foreach ($i in 0..$args[0]) {
                    "Iteration $i"
                }
            ) -join "`n"
            $string
        }
        'Addition Assignment +=' = {
            $string = ''
            foreach ($i in 0..$args[0]) {
                $string += "Iteration $i`n"
            }
            $string
        }
    }

    10kb, 50kb, 100kb | ForEach-Object {
        $groupResult = foreach ($test in $tests.GetEnumerator()) {
            $ms = (Measure-Command { & $test.Value $_ }).TotalMilliseconds

            [pscustomobject]@{
                Iterations        = $_
                Test              = $test.Key
                TotalMilliseconds = [math]::Round($ms, 2)
            }

            [GC]::Collect()
            [GC]::WaitForPendingFinalizers()
        }

        $groupResult = $groupResult | Sort-Object TotalMilliseconds
        $groupResult | Select-Object *, @{
            Name       = 'RelativeSpeed'
            Expression = {
                $relativeSpeed = $_.TotalMilliseconds / $groupResult[0].TotalMilliseconds
                [math]::Round($relativeSpeed, 2).ToString() + 'x'
            }
        }
    }
```

```output
# With Windows Powershell 5.1
    Iterations Test                   TotalMilliseconds RelativeSpeed
    ---------- ----                   ----------------- -------------
        10240 StringBuilder                      14,41 1x           
        10240 Join operator                      26,11 1,81x        
        10240 Addition Assignment +=            222,37 15,43x       
        51200 StringBuilder                      20,83 1x           
        51200 Join operator                      67,25 3,23x        
        51200 Addition Assignment +=           11474,1 550,84x      
        102400 StringBuilder                       36,2 1x           
        102400 Join operator                     133,05 3,68x        
        102400 Addition Assignment +=          47362,19 1308,35x
# With Powershell 7.3.6
Iterations Test                   TotalMilliseconds RelativeSpeed
---------- ----                   ----------------- -------------
     10240 StringBuilder                       8,14 1x
     10240 Join operator                       9,93 1,22x
     10240 Addition Assignment +=            384,85 47,28x
     51200 StringBuilder                      15,80 1x
     51200 Join operator                      31,81 2,01x
     51200 Addition Assignment +=          10006,27 633,31x
    102400 StringBuilder                      28,13 1x
    102400 Join operator                      72,45 2,58x
    102400 Addition Assignment +=          39407,84 1400,92x
```
 ```[System.Text.StringBuilder]``` is Better than ```-Join``` Operator is Better than ```+=``` Assignment.


- [x] **Do not request the same data twice** : cache everything in **variables**.

- [x] Don't create the same object every time you need it. **Create once, use many**. 

- [x] Use **```begin```, ```process```, ```end```**.

- [x] **Think about how commands work in the background** and how you use them. If you ```Out-File``` 1 million times in a loop, it's 2M unnecessary open/close operations.

- [x] When processing large amounts of text, **consider NOT using regex**, it's too complex and slow. In many cases you can achieve the same result with ```IndexOf```, ```Substring```, etc. The code is uglier but orders of magnitude faster.

- [x] When processing large amounts of text, **Use the appropriate parameter** or another way of better.

Demo : 
```Powershell
    $Path = "C:\temp\testExport.csv" #96693 Kb file

    
    
    Measure-MyScript -Name "No Parameter" -Unit s -Repeat 10 -ScriptBlock{
    Get-Content $Path | Where-Object { $_.Length -gt 10 }
    }

    Measure-MyScript -Name "using Raw" -Unit s -Repeat 10 -ScriptBlock{
    Get-Content $Path -Raw | Where-Object { $_.Length -gt 10 }
    }

    Measure-MyScript -Name "Using ReadCount" -Unit s -Repeat 10 -ScriptBlock{
    Get-Content $Path -ReadCount 1000 | Where-Object { $_.Length -gt 10 }
    }

    Measure-MyScript -Name "Using StreamReader" -Unit s -Repeat 10 -ScriptBlock{
        try
        {
            $Stream = [System.IO.StreamReader]::new($Path)
            while ($Line = $Stream.ReadLine())
            {
                if ($Line.Length -gt 10)
                {
                    $Line
                }
            }
        }
        finally
        {
            $Stream.Dispose()
        }
        $Stream
    }
```
```Output
# With Windows Powershell 5.1
name                Avg               Min               Max              
----                ---               ---               ---              
No Parameter        9,3634985 Seconds 8,5479047 Seconds 9,9916297 Seconds
using Raw           0,9042806 Seconds 0,8779908 Seconds 0,9317357 Seconds
Using ReadCount     0,5036334 Seconds 0,459431 Seconds  0,5336208 Seconds
Using StreamReader  0,5795852 Seconds 0,5074654 Seconds 0,6573107 Seconds
# With Powershell 7.3.6
name                Avg              Min              Max
----                ---              ---              ---
No Parameter        1,838677 Seconds 1,762572 Seconds 1,9751122 Seconds
using Raw           0,2226865 Seconds 0,1970976 Seconds 0,2665302 Seconds
Using ReadCount     0,347263 Seconds 0,3282792 Seconds 0,3805914 Seconds
Using StreamReader  0,3566357 Seconds 0,3280474 Seconds 0,3992105 Seconds
```


- [x] **standalone ```ForEach ($a in $b)``` loop is better** than a piped ```| ForEach-Object { $_ }``` loop because it allows you to ```break/continue``` properly. Break loops as soon as the right conditions exist.

- [x] Looking up entries by property in large collections : Use ```HashTable```. It's common to need to use a shared property to identify the same record in different collections, like using a name to retrieve an ID from one list and an email from another. Iterating over the first list to find the matching record in the second collection is slow. In particular, the repeated filtering of the second collection has a large overhead.

Demo : 
```Powershell
    #Given two collections, one with an ID and Name, the other with Name and Email
    $Employees = 1..10000 | ForEach-Object {
        [PSCustomObject]@{
            Id   = $_
            Name = "Name$_"
        }
    }

    $Accounts = 2500..7500 | ForEach-Object {
        [PSCustomObject]@{
            Name = "Name$_"
            Email = "Name$_@fabrikam.com"
        }
    }
    <#
    The usual way to reconcile these collections to return a list of objects with the ID, Name, and Email properties might look like this:
    #>
    Measure-MyScript -Name "Using Legacy Way" -Unit s -Repeat 5 -ScriptBlock {
    $Results = $Employees | ForEach-Object -Process {
        $Employee = $_

        $Account = $Accounts | Where-Object -FilterScript {
            $_.Name -eq $Employee.Name
        }

        [pscustomobject]@{
            Id    = $Employee.Id
            Name  = $Employee.Name
            Email = $Account.Email
        }
    }
    }
    <#
    However, that implementation has to filter all 5000 items in the $Accounts collection once for every item in the $Employee collection. That can take minutes, even for this single-value lookup.
    #>

    <#
    Instead, you can make a hash table that uses the shared Name property as a key and the matching account as the value.
    #>
    Measure-MyScript -Name "Using HashTable" -Unit s -Repeat 5 -ScriptBlock {
    $LookupHash = @{}
    foreach ($Account in $Accounts) {
        $LookupHash[$Account.Name] = $Account
    }
    $Results = $Employees | ForEach-Object -Process {
        $Email = $LookupHash[$_.Name].Email
        [pscustomobject]@{
            Id    = $_.Id
            Name  = $_.Name
            Email = $Email
        }
    }
    }
```

```Output
# With windows Powershell 5.1
name             Avg                  Min                  Max                
----             ---                  ---                  ---                
Using Legacy Way 1050,1107712 Seconds 1023,9872385 Seconds 1121,929599 Seconds
Using HashTable  0,3905034 Seconds    0,3154502 Seconds    0,6081025 Seconds  
# 1h49 to realiza this test ! 
```
- [x] Avoid ```Write-Host``` : It's generally considered poor practice to write output directly to the console, but when it makes sense, many scripts use ```Write-Host```. If you must write many messages to the console, ```Write-Host``` can be an order of magnitude slower than ```[Console]::WriteLine()``` for specific hosts like pwsh.exe, powershell.exe, or powershell_ise.exe. However, ```[Console]::WriteLine()``` isn't guaranteed to work in all hosts. Also, output written using ```[Console]::WriteLine()``` doesn't get written to transcripts started by ```Start-Transcript```.

Instead of using ```Write-Host```, consider **using ```Write-Output```** or direct output.

Demo : 
```Powershell
Measure-MyScript -Name "Using Write-Host" -Unit ms -Repeat 10 -ScriptBlock {
for ($i = 1; $i -lt 100; $i++)
{ 
    Write-Host "Ceci est le texte $i"
}
}

Measure-MyScript -Name "Direct Ouput" -Unit ms -Repeat 10 -ScriptBlock {
for ($i = 1; $i -lt 100; $i++)
{ 
    "Ceci est le texte $i"
}
}

Measure-MyScript -Name "Using Write-Output" -Unit ms -Repeat 10 -ScriptBlock {
for ($i = 1; $i -lt 100; $i++)
{ 
    Write-Output "Ceci est le texte $i"
}
}

Measure-MyScript -Name "Using [Console]::WriteLine()" -Unit ms -Repeat 10 -ScriptBlock {
for ($i = 1; $i -lt 100; $i++)
{ 
    [Console]::WriteLine("Ceci est le texte $i")
}
}
```
```output
name                         Avg                  Min                  Max                 
----                         ---                  ---                  ---                 
Using Write-Host             94,7049 Milliseconds 71,6068 Milliseconds 252,062 Milliseconds
Direct Ouput                 0,1798 Milliseconds  0,0595 Milliseconds  0,9042 Milliseconds 
Using Write-Output           18,9798 Milliseconds 16,8433 Milliseconds 26,1302 Milliseconds
Using [Console]::WriteLine() 17,4883 Milliseconds 13,4097 Milliseconds 32,5102 Milliseconds
```

- [x] If you're looping around a collection of objects, try to have them sorted in a way and break out when you're out of the expected range.

- [x] If you have multiple nested loops, don't do everything in the last loop, move some code into the outer layers.

- [x] Always think "Filter Left, format right". 

- [x] Consider using Theadjobs ... and use ```-Parallel``` in PS 7.x

- [x] If you read something from disk, or from a website, or database, or calculated something, you paid a cost. Don't throw it away then ask for it again, instead keep it in memory to use later.

- [x] ```Get-Content``` does a lot more than reading lines from a text file, and that overhead costs. If you need to read files very quickly, look for ```Get-Content -Raw``` or something else.

- [x] Avoid to use the $user in $users (i.e.) in a foreach loop which is super super easy to confuse, double so in larder scripts

- [x] capture the output of the loop to the variable $Output

- [x] reconfiguring the [PSCustomObject] and loop to get the properties before using it in your object (makes testing and changing easier)

- [x] removed the unneeded ```Select-Object```

- [x] added SamAccountName as name might not be unique (and has a space in it)

Here a sample AD query

``` powershell 
    $Users = Get-ADGroupMember "delegat signature ztesting" -Recursive

    $Output = ForEach($SingleUser in $Users)
        {
        $SingleADResult = Get-ADUser $SingleUser -Properties lastLogon,LastLogonDate,lastLogonTimestamp
        [PSCustomObject]@{
            Name               = $SingleADResult.Name
            SamAccountName     = $SingleADResult.SamAccountName
            LastLogonTimeStamp = [DateTime]::FromFileTime($SingleADResult.LastLogonTimeStamp)
            }
        }
    $Output | Export-Csv -Path $PSScriptRoot\Files\TimeStamp.csv -NoTypeInformation
```

- [x] Suppressing Output. There are many ways to avoid writing objects to the pipeline : 
- Assigning to ```$Null``` : ```$Null = <cmdlet>```
- Casting to ```[void]``` : ```[Void]<cmdlet>```
- File redirection to ```$Null``` : ```<Cmdlet> > $Null```
- Pipe to ```Out-Null``` : ```<Cmdlet> | Out-Null```

The speeds of assigning to ```$Null``` ≃ casting to ```[void]``` ≃ file redirection to ```$Null``` are almost identical. However, calling ```Out-Null``` in a large loop can be significantly slower, especially in PowerShell 5.1.

- [x] **Avoid repeated calls to a function**. Calling a function can be an expensive operation. If you calling a function in a long running tight loop, consider moving the loop inside the function.

Demo : 

```Powershell
$ranGen = New-Object System.Random
$RepeatCount = 10000

Measure-MyScript -Name "Basic for-loop" -Unit ms -Repeat 10 -ScriptBlock {
    for ($i = 0; $i -lt $RepeatCount; $i++) {
        $Null = $ranGen.Next()
    }
}

# wraps the random number generator in a function that's called in a tight loop
Measure-MyScript -Name "Wrapped in a function" -Unit ms -Repeat 10 -ScriptBlock {
    function Get-RandNum_Core {
        param ($ranGen)
        $ranGen.Next()
    }

    for ($i = 0; $i -lt $RepeatCount; $i++) {
        $Null = Get-RandNum_Core $ranGen
    }
}
# The function is only called once but the code still generates 10000 random numbers. 
Measure-MyScript -Name "For-loop in a function" -Unit ms -Repeat 10 -ScriptBlock {
    function Get-RandNum_All {
        param ($ranGen)
        for ($i = 0; $i -lt $RepeatCount; $i++) {
            $Null = $ranGen.Next()
        }
    }

    Get-RandNum_All $ranGen
}
```


```output
name                    Avg                   Min                   Max
----                    ---                   ---                   ---
Basic for-loop          8,1763 Milliseconds   7,1114 Milliseconds   9,1556 Milliseconds
Wrapped in a function   157,3784 Milliseconds 148,9869 Milliseconds 165,9685 Milliseconds
For-loop in a function  5,4158 Milliseconds   4,7084 Milliseconds   7,1147 Milliseconds
```



