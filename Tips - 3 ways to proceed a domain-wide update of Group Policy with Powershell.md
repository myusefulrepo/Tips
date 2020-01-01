# 3 ways to proceed a domain-wide update of Group Policy with Powershell


## 1 - THE OLD WAY (Powershell < v4)

At this period there is no specific Windows Powershell cmdlet to proceed. Then we must use the good old DOS cmd : gpupdate

We can process in 4 steps

- Collect the computers in the domain
- Create PS remote session on these computers
- run the command on all the remote computers
- Check if it's applied with success

#### Step 1 - Gather computers

```powershell
$Computers = Get-ADComputer -filter *
```

We can add a -SearchBase parameter or set up a more precise filter, like this one -Filter {OperatingSystem -like 'Windows Server 2012*'}

#### Step 2 - Create sessions

```powershell
$credential = Get-credential <Domain>\<AdminAccount>
$Sessions = New-PSSession -ComputerName $computers.Name -Credential $credential
```

We can have a lot of errors at this step, if PSRemoting isn't enable or if the remote computers are down.
The it could be useful to know exactly with which machines a session is established, then we can run the following

```powershell
foreach (session in $sessions)
    {
    Write-Host " the session " -ForegroundColor Green -NoNewLine
    Write-Host "$($session.Name)" -ForegroundColor Yellow -NoNewLine
    Write-Host "with " -ForegroundColor Green -NoNewLine
    Write-Host " $($session.ComputerName) " -ForegroundColor Yellow -NoNewLine
    Write-Host "is " -ForegroundColor Green -NoNewLine
    Write-Host "$($session.State) "  -ForegroundColor Yellow -NoNewLine
    Write-Host "and"  -ForegroundColor Green -NoNewLine
    Write-Host "$($session.availability)"  -ForegroundColor Yellow -NoNewLine
    }
```

#### Step 3 - GPUpdate process

```powershell
Invoke-Command -Session $Sessions -ScripBlock { gpupdate /force }
```

#### Step 4 - Check the EventLog

We can complete the job with a check in the Event Viewer. An ID 1502 appears in the system Event Log when the command is applied successfully

```powershell
Invoke-Command -Session $Sessions -ScriptBlock { Get-WinEvent - MaxEvents 1 -filterHashTable @{
                                                                                                LogName = 'System'
                                                                                                Level = '3'
                                                                                                ID = '1502'
                                                                                                }
                                                }
```

We can also use the following

```powershell
foreach ($Computer in $Computers
    {
    Get-WinEvent -ComputerName $computer.name -MaxEvents 1 -filterHashTable @{
                                                                                                    LogName = 'System'
                                                                                                    Level = '3'
                                                                                                    ID = '1502'
                                                                                                    }
                                                    }
    }
```

I prefer the second way, because i'm thinking is always faster to use the -ComputerName parameter of a cmdlet instead of Invoke-Command. But I concede it, it would be necessary to carry out measurement tests, and I don't do these.

I prefer to use Get-WinEvent vs Get-EventLog because it's fastest.
If you prefer to use Get-EventLog, use it like the following in the -ScriptBlock

```powershell
Get-Eventlog -LogName 'System' -InstanceID '1502' -Newest1
```

We can complete all these jobs by logging, or another tasks.

## 2 - THE NEW WAY (Powershell >= v4)

A  specific Windows Powershell cmdlet is appeared. Then we'll use it : Invoke-GPUpdate

#### Step 1 - Gather computers

```powershell
$Computers = Get-ADComputer -filter *
```

We can add a -SearchBase parameter or set up a more precise filter, like this one -Filter {OperatingSystem -like 'Windows Server 2012*'}

#### Step 2 - GPUpdate Process

```powershell
Foreach ($computer in $computers)
    {
    Invoke-GPUpdate -force -Computer $Computer.Name
    }
```

OK, I Know, we can use a one-liner command for these 2 steps, but I don't like this, because it's not always clear for people who start with Powershell. If you prefer use the following, use it.

```powershell
Get-ADComputer -filter * | Foreach-Object {Invoke-GPUpdate -force -Computer $_.Name}
```

#### Step 3 - Check the EventLog

We can complete the job with a check in the Event Viewer. An ID 1502 appears in the system Event Log when the command is applied successfully

```powershell
foreach ($Computer in $Computers
    {
    Get-WinEvent -ComputerName $computer.name -MaxEvents 1 -filterHashTable @{
                                                                                                    LogName = 'System'
                                                                                                    Level = '3'
                                                                                                    ID = '1502'
                                                                                                    }
                                                    }
    }
```

I prefer to use Get-WinEvent vs Get-EventLog because it's fastest.
If you prefer to use Get-EventLog, use it like the following in the -ScriptBlock

```powershell
Get-Eventlog -LogName 'System' -InstanceID '1502' -Newest1
```

We can complete all these jobs by logging, or another tasks.

## 3 - THE MIXED WAY

This way is just a mix of the the previous way based on the presumed Windows Powershell version (we'll use the OS version)

#### Step 1 - Gather computers

```powershell
$Computers = Get-ADComputer -filter * -Properties OperatingSystem
```

You can note that i have an additional parameter -Properties. Indeed, OperatingSystem property is not a part of the default output of the Get-ADComputer cmdlet.

#### Step 2 - differential treatment

```powershell
foreach ($Computer in $Computers)
    {
    If ($computer.OperatingSystem -like 'Windows Server 2012') # PS >4
        {
        Invoke-GPUpdate -force -Computer $Computer.Name
        }
    else  # PS <4
        {
        $credential = Get-credential <Domain>\<AdminAccount>
        $Sessions = New-PSSession -ComputerName $computers.Name -Credential $credential
        foreach (session in $sessions)
            {
            Write-Host " the session " -ForegroundColor Green -NoNewLine
            Write-Host "$($session.Name)" -ForegroundColor Yellow -NoNewLine
            Write-Host "with " -ForegroundColor Green -NoNewLine
            Write-Host " $($session.ComputerName) " -ForegroundColor Yellow -NoNewLine
            Write-Host "is " -ForegroundColor Green -NoNewLine
            Write-Host "$($session.State) "  -ForegroundColor Yellow -NoNewLine
            Write-Host "and"  -ForegroundColor Green -NoNewLine
            Write-Host "$($session.availability)"  -ForegroundColor Yellow -NoNewLine
            }
        Invoke-Command -Session $Sessions -ScripBlock { gpupdate /force }
        }
    # The check in the Event Log is the same for the 2 previous process
    Get-WinEvent -ComputerName $computer.name -MaxEvents 1 -filterHashTable @{
                                                                             LogName = 'System'
                                                                             Level = '3'
                                                                             ID = '1502'
                                                                             }
    }
```
