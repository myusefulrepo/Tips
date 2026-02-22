# TIP - 3 Ways to have the -WhatIf parameter for a script

## Firstly
Add ````[CmdletBinding(SupportsShouldProcess)]```` at the beginning of the script.

## Best approach - Using : ````$PSCmdlet.ShouldProcess(...)````
Enclose the destructive action with a call to ````$PSCmdlet.ShouldProcess(...)```` :

Example
````Powershell
# Syntax here : $PSCmdlet.ShouldProcess(Target, Operation)
if ($PSCmdlet.ShouldProcess($Rule.DisplayName, 'Restrict RemoteAddress'))
{
    Set-NetFirewallRule -Name $Rule.Name -RemoteAddress $AllowedIPs
}
````

## Second Way : Using ````$WhatIfPreference````

````$WhatIfPreference```` — an automatic PowerShell variable that is set to ````$true```` when ````-WhatIf```` is passed :

Example : 

````powershell
if ($WhatIfPreference) 
    {
    Write-Host "Simulation mode — no changes"
    }
else 
    {
    Set-NetFirewallRule -Name $Rule.Name -RemoteAddress $AllowedIPs
    }
````
## Third way : Using ````$PSBoundParameters.ContainsKey('WhatIf)````

Example : 
````powershell
if ($PSBoundParameters.ContainsKey('WhatIf')) 
{
     ...
}
````

# Why ````$PSCmdlet.ShouldProcess(...)```` is the best way ? 

However, the 2 last approaches are discouraged for controlling destructive actions. ````$PSCmdlet.ShouldProcess()```` remains the idiomatic method in PowerShell because it :

- Automatically handles both ````-WhatIf```` and ````-Confirm````
- Produces the standardized message ````What if: Performing the operation "..." on target "..."````
- Properly propagates the ````-WhatIf```` to cmdlets called downstream
- Respects the conventions expected by PowerShell users


<span style="color:green;font-weight:700;font-size:20px">[Point d'attention]</span> : Both alternatives are useful in specific cases (logging, conditional logic not tied to an action), but to protect a ````Set-NetFirewallRule```` (Our examples), ````ShouldProcess()```` is the right choice.

