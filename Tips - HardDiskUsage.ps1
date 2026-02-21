# Initialise machine name
$server = $env:COMPUTERNAME

# Get fixed drive info
$disks = Get-CimInstance -ComputerName $server -ClassName Win32_LogicalDisk -Filter 'DriveType = 3'

$ResultDisks = [System.Collections.Generic.List[PSObject]]::new()
foreach ($disk in $disks)
{
	$deviceID = $disk.DeviceID
	[float]$size = $disk.Size
	[float]$freespace = $disk.FreeSpace

	$percentFree = [Math]::Round(($freespace / $size) * 100, 2)
	$sizeGB = [Math]::Round($size / 1GB, 2)
	$freeSpaceGB = [Math]::Round($freespace / 1GB, 2)

	$Obj = [PSCustomObject][Ordered]@{
		Server      = $server
		DeviceID    = $deviceID
		SizeGB      = $sizeGB
		FreeSpaceGB = $freeSpaceGB
		PercentFree = $PercentFree
	}
	$ResultDisks.Add($Obj)
}
$ResultDisks
