 # find the total number of servers in each Organizational Unit
 # source : https://hkeylocalmachine.com/?p=809

$StartTime = Get-Date
 
# Get all servers from AD
$Servers = Get-ADComputer -Filter {OperatingSystem -like "*server*"}
 
# Loop through each server found
foreach ($Server in $Servers) {
 
	# Strip out OU from DN
	$dnSplit = $Server.DistinguishedName -split ",";
	$Server.ou = $dnsplit[1..$dnSplit.count] -join ",";
 }
 
# Save results into a table and sort from highest to lowest
$ResultTable = $Servers | Group-Object -NoElement -Property ou | Sort-Object count -Descending
 
# Record end of test 1
$EndTime = Get-Date
 
# Calculate total test time
$TestTime = New-TimeSpan -Start $StartTime -End $EndTime;

#---------- Output ----------#
# Show results of times taken to perform each test
Write-Host -ForegroundColor Cyan "Test :" $TestTime.totalseconds "seconds";$TestTime