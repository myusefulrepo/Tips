# 2 ways to rename file in mass

<# I need to rename a set of 540 files as such:
Folder: C:\ABCD
Original names are varied, mostly "ABCD (#).raw", but others can be "ABCD _longtext (#)"
Destination names: ABCD-YYYY-MM-DD-HH-SS.RAW where the timestamp is the ModificationDate (not creation).
#>


(Get-ChildItem -File C:\abcd\abcd*.raw) |
  Rename-Item -NewName {
   "ABCD-{0:yyyy-MM-dd-HH-mm-ss}.raw" -f $_.LastWriteTime
  }

# With regex
$files = Get-ChildItem -Path 'c:\temp\test' '*.raw'
foreach ($file in $files){
  $my_date    = "{0:yyyy-MM-dd-HH-mm-ss}" -f $file.LastWriteTime
  $Begin_name = [regex]::Match($file.name,'^([A-Z]+)[\d\(_\s].+\.raw$').groups[1].value
  $New_name   = $Begin_name +'-'+ $my_date + '.RAW'
  Rename-Item -Path $file.fullname -NewName $New_name -WhatIf
}