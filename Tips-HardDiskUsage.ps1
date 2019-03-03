# Initialise machine name
$server = "<>"
 
# Get fixed drive info
$disks = Get-WmiObject -ComputerName $server -Class Win32_LogicalDisk -Filter "DriveType = 3";
 
foreach($disk in $disks)
{
  $deviceID = $disk.DeviceID;
  [float]$size = $disk.Size;
	[float]$freespace = $disk.FreeSpace;
 
	$percentFree = [Math]::Round(($freespace / $size) * 100, 2);
	$sizeGB = [Math]::Round($size / 1073741824, 2);
	$freeSpaceGB = [Math]::Round($freespace / 1073741824, 2);
 
	Write-Host "$server,$deviceID,$sizeGB,$freeSpaceGB,$percentFree";
}