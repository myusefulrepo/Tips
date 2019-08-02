# Track changes to Active Directory group membership
# ref : https://hkeylocalmachine.com/?p=792
 
# Location to save log files to. DO NOT put a trailing back slash in here
$FolderPath = "d:\temp\kamal";
 
# Define the group name prefix (we will find all groups with this prefix - make sure to include at least one asterisk, or this will fail)
$GroupNamePrefix = "aAdmin_*";
 
# Get all groups matching a specific prefix
$Groups = Get-ADGroup -Filter {name -like $GroupNamePrefix};
 
# Format todays date to be appended to the output file name
$Today = (Get-Date).tostring("yyyyMMdd");
 
# Loop through each group found
foreach ($Group in $Groups) {
	
    # Get the most recent export of group members (may or may not be yesterday - just most recent)
    $PreviousFileIbject = Get-ChildItem $FolderPath | 
        Where-Object {$_.name -like ("*" + $group.name + "*")} | 
        Sort-Object lastwritetime -Descending | 
        Select-Object -first 1

    $PreviousGroupMembers = Import-Csv -Path $PreviousFileIbject.fullname
 
    # Get current group members from Active Directory
    $CurrentGroupMembers = $Group |
        Get-ADGroupMember |
        Select-Object samaccountname
 
    # Compare both lists to find new members and removed members
    $NewMembers = Compare-Object -ReferenceObject $CurrentGroupMembers -DifferenceObject $PreviousGroupMembers -Property samaccountname |
        Where-Object {$_.sideindicator -eq "<="} |
        Select-Object samaccountname

    $RemovedMembers = Compare-Object -ReferenceObject $CurrentGroupMembers -DifferenceObject $previousgroupmembers -Property samaccountname |
    Where-Object {$_.sideindicator -eq "=>"} |
    Select-Object samaccountname
 
 
    #----------------[ Do something with the the lists of new and removed users here ]----------------
 
 
    # Save current members to new file
    $NewFilePath = $FolderPath + "\" + $Today + "_" + $Group.name + ".txt";
    $CurrentGroupMembers | Export-Csv -Path $NewFilePath 
}