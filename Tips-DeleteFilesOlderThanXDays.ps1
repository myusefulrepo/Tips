#Shows what files would be deleted from c:\windows\temp (older than 10 days) if run. Remove 'whatif' to implement.

filter FileAge($days) { if ( ($_.LastWriteTime -le (Get-Date).AddDays($days * -1) )) { $_ } }

get-childitem c:\windows\temp -recurse | FileAge 10 | del -whatif