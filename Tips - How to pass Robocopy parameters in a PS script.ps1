# requires RunAsAdministrator

$source = "C:\temp\test"
$Destination = "c:\temp3"
$what = @("/COPYALL", "/B",  "/SEC",  "/MIR") # copy type mirroring (as a lazy admin, i'm calling the same code to inital copy and final sync)
$options = @("/R:0", "/W:0", "/NP") # and all other options you want to use
$user = "Hodor"
$log = @("/Log+:c:\temp\logrobo-$User.log") # Useful if you want a different log file for each treatement (here user)
$RoboArgs = @($Source, $Destination, $what, $options, $log)

& robocopy @RoboArgs

<#
As you can see, the first Tips is to pass robocopy params in an array
The second one is to concatenate them with splating method
#>

$RoboArgs =@(
    "C:\temp\test",
    "C:\temp3\",
    "/COPYALL", "/B", "/SEC", "/MIR", "/R:0", "/W:0", "/NP", 
    "/Log+:c:\temp\logrobo.log"
)
# is working fine too