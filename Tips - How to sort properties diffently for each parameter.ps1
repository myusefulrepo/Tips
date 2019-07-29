
# When you want to sort object
Get-Command | Sort-Object -Property Source, Name, Version # default ascending
Get-Command | Sort-Object -Property Source, Name, Version -Descending

# if you want to perform ascending sort for some properties and descending for some others, you must proceed like the following : 
Get-Command | Sort-Object -Property @{Expression = ‘Source’; Ascending = $true}, 
                                    @{Expression = ‘Name’; Ascending = $true}, 
                                    @{Expression = ‘Version’; Descending = $true}

# Once again a hash table is the answer (thanks Richard : https://richardspowershellblog.wordpress.com/2019/07/26/sort-direction/)
