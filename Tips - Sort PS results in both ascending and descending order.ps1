<# 
You want to sort something in powershell with one property sorte descending and another one sorting ascending.
Use the property parameter with a hash table to specify the property names and their order

Thanks Mike F Robbins : https://mikefrobbins.com/2019/05/09/sort-powershell-results-in-both-ascending-and-descending-order/
#>	
Get-Service -Name Win* |
    Sort-Object -Property `
    @{expression = 'Status'
      descending = $true}, 
    @{expression = 'DisplayName'
      descending = $false}


