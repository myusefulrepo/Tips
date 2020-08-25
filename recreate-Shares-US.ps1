<#
.SYNOPSIS
   Get the shares (except administrative shares) and the access permissions and build the same shares on another computer

.DESCRIPTION
   Get the shares (except administrative shares) and the access permissions and build the same shares on another computer
   Could be useful in a Data migration between 2 servers as a preliminary step (before copy data from source server to target server)

.EXAMPLE
   .\recreate-shares-US.ps1 -TargetComputer RemoteComputer
   Run the script locally on the source computer and create same shares on the target computer as a parameter

.EXAMPLE
   .\recreate-shares-US.ps1
   Run the script locally on the source computer and create same shares on the target computer with the default value for the Remote Computer

.INPUTS
   none

.OUTPUTS
   none

.NOTES
   Author   : Olivier FERRIERE
   Date     : 25/08/2020
   Version  : 1.0 - final version after somme comments on reddit.
#>

Param
(
    # Remote Computer
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
    $TargetComputer = "RemoteComputer"
)

# Get All shares except admin share (special) on the current computer
$Shares = Get-SmbShare -Special $false -ErrorAction SilentlyContinue
# Get all ShareAccess Properties
$SharesAccess = foreach ($Share in $Shares)
{
    Get-SmbShareAccess -Name $($Share.Name)
}

# At this step, jump to the Target Computer
Try
{
    Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
        foreach ($Share in $Using:Shares)
        {
            # Check if the target directory is still existing : create if necessary
            if (-not (Test-Path -Path $Share.Path) )
            {
                # Path doesn't exist : create
                try
                {
                    New-Item -Path $Share.Path -ErrorAction Stop
                    Write-Output "Path $($Share.Path) has been created"
                }
                catch
                {
                    Write-Output "an error is occured : $_"
                }
            }
            # Check if the target share is still existing and set access
            else
            {
                Try
                {
                    New-SmbShare -Name $Share.Name -Description $Share.Description -Path $Share.Path -ErrorAction stop
                    Write-Output "Share $($Share.Name) has been recreated"
                    # revoke default grand access when you create a new share
                    Revoke-SmbShareAccess -Name $Share.Name  -AccountName "tout le monde" -Force
                    # add the ref share access
                    $ShareAccessParams = @{ Name = $Share.Name
                        AccountName              = ($using:SharesAccess | Where-Object { $_.name -eq $share.Name } | Select-Object -ExpandProperty AccountName)
                        AccessRight              = ($using:SharesAccess | Where-Object { $_.name -eq $share.Name } | Select-Object -ExpandProperty AccessRight)
                        ScopeName                = "*"
                        Force                    = $true
                    }
                    Grant-SmbShareAccess @ShareAccessParams
                    Write-Output "Access rights on share $($Share.Name) has been replaced"
                }
                catch
                {
                    Write-Output "an error is occured : $_"
                }
            }
        }
    }
}
catch
{
    Write-Output "An error is occured : $_"
}
