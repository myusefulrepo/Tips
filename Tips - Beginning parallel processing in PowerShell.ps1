# Ping a subnet : Beginning parallel processing in PowerShell
# ref : https://hkeylocalmachine.com/?p=612

# Gather network address (must end in .0)
$network = read-host "Enter network address";
$networkcheck = $network.substring($network.length-2);
 
if ($networkcheck -eq ".0") {
    # Drop the .0 from the network address
    $network = $network.substring(0,$network.length-1);
 
    # Create Runspace Pool with 500 threads
    $pool = [RunspaceFactory]::CreateRunspacePool(1, 500)
    $pool.ApartmentState = "MTA"
    $pool.open()
    $runspaces = @()
     
    # The script you want run against each host
    $scriptblock = {
 
        # Take the IP address as a parameter
        param ([string]$ip);
        
        # Ping IP address    
        $online = test-connection $ip -count 1 -ea 0;
 
        # Print IP address if online
    	if ($online) {
    		$ip;
    	}
    }
     
    # Loop through numbers 1 to 254 
    foreach ($hostnumber in 1..254) {
 
    	# Set full IP address
    	$ip = $network + $hostnumber;
 
        $runspace = [powershell]::create()
 
        # Add script block to runspace (use $null to avoid noise)
        $null = $runspace.addscript($scriptblock)
 
        # Add IP address as an argument to the scriptblock (use $null to avoid noise)
        $null = $runspace.addargument($ip)
 
        # Add/create new runspace
        $runspace.runspacepool = $pool
        $runspaces += [pscustomobject]@{pipe=$runspace; Status=$runspace.begininvoke() }
    }
     
    # Prepare the progress bar
    $currentcount = 0;
    $totalcount = ($runspaces | measure-object).count;
 
    # Pause until all runspaces have completed
    while ($runspaces.status -ne $null)
    {
        $completed = $runspaces | where { $_.status.iscompleted -eq $true };
        
        # Update progress bar
        $currentcount = $currentcount + ($completed | measure-object).count;
        write-progress -activity "Pinging IP Addresses..." -percentcomplete (([int]$currentcount/[int]$totalcount)*100);
        
        # Clear completed runspaces
        foreach ($runspace in $completed)
        {
            $runspace.pipe.endinvoke($runspace.status)
            $runspace.status = $null            
        }
    }
 
    # Clean-up Runspace Pool
    $pool.close();
    $pool.dispose();
 
} else {
    write-host "NOT A VALID NETWORK ADDRESS" -foregroundcolor "red" -backgroundcolor "black";
}