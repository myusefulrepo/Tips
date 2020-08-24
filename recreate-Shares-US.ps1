# var
$TargetComputer = "RemoteComputer"

# Get All shares except admin share (special) on the current computer
$script:Shares = Get-SmbShare -Special $false -ErrorAction SilentlyContinue
# Get all ShareAccess Properties
$script:SharesAccess  = foreach ($Share in $Shares)
    {
    Get-SmbShareAccess -Name $($Share.Name)
    }

# At this step, jump to the Target Computer
Enter-PSSession -ComputerName $TargetComputer
foreach ($Share in $script:Shares)
    {
    # Check if the target directory is still existing : create if necessary
    if (-not (Test-Path -Path $($script:Share.Path)) )
        {
        # Path doesn't exist : create
        try {
            New-Item -Path $($Share.Path) -ErrorAction Stop
            Write-Host "Path $($Share.Path) has been created" -ForegroundColor Green
            }
        catch{
            Write-Host "an error is occured : $_" -ForegroundColor Red
            }
        }
    # Check if the target share is still existing and set access
    else{
        Try{
            New-SmbShare -Name $($share.Name) -Description $($share.Description) -Path $($share.Path) -ErrorAction stop
            Write-Host "Share " -ForegroundColor Green -NoNewline
            Write-Host "$($Share.Name) " -ForegroundColor Yellow -NoNewline
            Write-Host "has been recreated" -ForegroundColor Green
            Grant-SmbShareAccess -Name $($Share.Name) `
                                 -AccountName $($SharesAccess | Where-Object  {$($_.name) -eq $($share.Name) } | Select-Object -ExpandProperty AccountName) `
                                 -AccessRight $($SharesAccess | Where-Object  {$($_.name) -eq $($share.Name) } | Select-Object -ExpandProperty AccessRight) `
                                 -ScopeName * `
                                 -Force
            Write-Host "Acess rights on share " -ForegroundColor Green -NoNewline
            Write-Host "$($Share.Name) " -ForegroundColor Yellow -NoNewline
            Write-Host "has been replaced" -ForegroundColor Green
            }
        catch{
            Write-Host "an error is occured : $_" -ForegroundColor Red
            }
        }
    }
# Exit the PS Session
Exit-PSSession
