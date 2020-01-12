$registryParams = @{
    Path  = "HKCU:\Software\ScriptingGuys\Scripts"
    Name  = "Version"
    Value = "1"
    PropertyType = "DWORD"
    Force = $true
}

# METHOD 1
# If/else
IF (-not (Test-Path $registryParams.Path)) {
    "create path and property"
    [void](New-Item $registryParams.Path -Force)
    [void](New-ItemProperty @registryParams)
}
ELSE {
    "create version property"
    [void](New-ItemProperty @registryParams)
}

# METHOD 2

# Test Statement
# (Get-ItemProperty -Path HKCU:\Software\ScriptingGuys\Scripts -Name version).version
# find error specific type
# $Error[0].Exception.GetType().FullName
# try/catch with specific catches
try {
    (Get-ItemProperty -Path $registryParams.Path -Name $registryParams.Name -ErrorAction Stop).version
}
catch [System.Management.Automation.ItemNotFoundException] {
    "create path and property"
    [void](New-Item $registryParams.Path -Force)
    [void](New-ItemProperty @registryParams)
}
catch [System.Management.Automation.PSArgumentException] {
    "create version property"
    [void](New-ItemProperty @registryParams)
}
catch {
    $_
}

# METHOD 3 : with a simple function
$Path  = "HKCU:\Software\ScriptingGuys\Scripts"
$Name  = "Version"
$Value = "1"
$PropertyType = "DWORD"


function New-RecursiveItemProperty($Path,$Name,$Value,$PropertyType)
{
    foreach($key in $Path.split("{\}")) {
        $CurrentPath += $key + "\"
        if (-not (Test-Path $currentPath))
        {
           New-Item -Path $currentPath
        }
    }#end foreach
	New-ItemProperty -Path $CurrentPath -Name $Name -value $value -PropertyType $PropertyType
}

# method 4 : script
# source: https://gallery.technet.microsoft.com/scriptcenter/Create-or-Modify-registry-c752668c
<#
	.SYNOPSIS
		Set-RemoteRegistry allows user to set any given registry key/value pair.

	.DESCRIPTION
		Set-RemoteRegistry allows user to change registry on remote computer using remote registry access.

	.PARAMETER  ComputerName
		Computer name where registry change is desired. If not specified, defaults to computer where script is run.

	.PARAMETER  Hive
		Registry hive where the desired key exists. If no value is specified, LocalMachine is used as default value. Valid values are: ClassesRoot,CurrentConfig,CurrentUser,DynData,LocalMachine,PerformanceData and Users.

	.PARAMETER  Key
		Key where item value needs to be created/changed. Specify Key in the following format: System\CurrentControlSet\Services.

	.PARAMETER  Name
		Name of the item that needs to be created/changed.

	.PARAMETER  Value
		Value of item that needs to be created/changed. Value must be of correct type (as specified by -Type).

	.PARAMETER  Type
		Type of item being created/changed. Valid values for type are: String,ExpandString,Binary,DWord,MultiString and QWord.

	.PARAMETER  Force
		Allows user to bypass confirmation prompts.

	.EXAMPLE
		PS C:\> .\Set-RemoteRegistry.ps1 -Key SYSTEM\CurrentControlSet\services\AudioSrv\Parameters -Name ServiceDllUnloadOnStop -Value 1 -Type DWord

	.EXAMPLE
		PS C:\> .\Set-RemoteRegistry.ps1 -ComputerName ServerA -Key SYSTEM\CurrentControlSet\services\AudioSrv\Parameters -Name ServiceDllUnloadOnStop -Value 0 -Type DWord -Force

	.INPUTS
		System.String

	.OUTPUTS
		System.String

	.NOTES
		Created and maintainted by Bhargav Shukla (MSFT). Please report errors through contact form at http://blogs.technet.com/b/bshukla/contact.aspx. Do not remove original author credits or reference.

	.LINK
		http://blogs.technet.com/bshukla
#>
[CmdletBinding(SupportsShouldProcess=$true)]
	param
	(
		[Parameter(Position=0, Mandatory=$false)]
		[System.String]
		$ComputerName = $Env:COMPUTERNAME,
		[Parameter(Position=1, Mandatory=$false)]
		[ValidateSet("ClassesRoot","CurrentConfig","CurrentUser","DynData","LocalMachine","PerformanceData","Users")]
		[System.String]
		$Hive = "LocalMachine",
		[Parameter(Position=2, Mandatory=$true, HelpMessage="Enter Registry key in format System\CurrentControlSet\Services")]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Key,
		[Parameter(Position=3, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Name,
		[Parameter(Position=4, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Value,
		[Parameter(Position=5, Mandatory=$true)]
		[ValidateSet("String","ExpandString","Binary","DWord","MultiString","QWord")]
		[System.String]
		$Type,
		[Parameter(Position=6, Mandatory=$false)]
		[Switch]
		$Force
	)

	If ($pscmdlet.ShouldProcess($ComputerName, "Open registry $Hive"))
	{
	#Open remote registry
	try
	{
			$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)

	}
	catch
	{
		Write-Error "The computer $ComputerName is inaccessible. Please check computer name. Please ensure remote registry service is running and you have administrative access to $ComputerName."
		Return
	}
	}

	If ($pscmdlet.ShouldProcess($ComputerName, "Check existense of $Key"))
	{
	#Open the targeted remote registry key/subkey as read/write
	$regKey = $reg.OpenSubKey($Key,$true)

	#Since trying to open a regkey doesn't error for non-existent key, let's sanity check
	#Create subkey if parent exists. If not, exit.
	If ($regkey -eq $null)
	{
		Write-Warning "Specified key $Key does not exist in $Hive."
		$Key -match ".*\x5C" | Out-Null
		$parentKey = $matches[0]
		$Key -match ".*\x5C(.*)" | Out-Null
		$childKey = $matches[1]

		try
		{
			$regtemp = $reg.OpenSubKey($parentKey,$true)
		}
		catch
		{
			Write-Error "$parentKey doesn't exist in $Hive or you don't have access to it. Exiting."
			Return
		}
		If ($regtemp -ne $null)
		{
			Write-Output "$parentKey exists. Creating $childKey in $parentKey."
			try
			{
				$regtemp.CreateSubKey($childKey) | Out-Null
			}
			catch
			{
				Write-Error "Could not create $childKey in $parentKey. You  may not have permission. Exiting."
				Return
			}

			$regKey = $reg.OpenSubKey($Key,$true)
		}
		else
		{
			Write-Error "$parentKey doesn't exist. Exiting."
			Return
		}
	}

	#Cleanup temp operations
	try
	{
		$regtemp.close()
		Remove-Variable $regtemp,$parentKey,$childKey
	}
	catch
	{
		#Nothing to do here. Just suppressing the error if $regtemp was null
	}
	}

	#If we got this far, we have the key, create or update values
	If ($Force)
	{
		If ($pscmdlet.ShouldProcess($ComputerName, "Create or change $Name's value to $Value in $Key. Since -Force is in use, no confirmation needed from user"))
		{
			$regKey.Setvalue("$Name", "$Value", "$Type")
		}
	}
	else
	{
		If ($pscmdlet.ShouldProcess($ComputerName, "Create or change $Name's value to $Value in $Key. No -Force specified, user will be asked for confirmation"))
		{
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
		$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
		$caption = "Warning!"
		$message = "Value of $Name will be set to $Value. Current value `(If any`) will be replaced. Do you want to proceed?"
		Switch ($result = $Host.UI.PromptForChoice($caption,$message,$choices,0))
		{
			1
			{
				Return
			}
			0
			{
				$regKey.Setvalue("$Name", "$Value", "$Type")
			}
		}
		}
	}

	#Cleanup all variables
	try
	{
		$regKey.close()
		Remove-Variable $ComputerName,$Hive,$Key,$Name,$Value,$Force,$reg,$regKey,$yes,$no,$caption,$message,$result
	}
	catch
	{
		#Nothing to do here. Just suppressing the error if any variable is null
	}