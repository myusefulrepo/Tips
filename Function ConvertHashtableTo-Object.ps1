# source : https://gordon.byers.me/powershell/convert-a-powershell-hashtable-to-object/
function Convert-HashtableToObject
{
    [CmdletBinding()]
    param([Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [hashtable]$ht
    )
    process
    {
        $results = @()

        $ht | ForEach-Object {
            $result = New-Object psobject
            foreach ($key in $_.keys)
            {
                $result | Add-Member -MemberType NoteProperty -Name $key -Value $_[$key]
            }
            $results += $result
        }
        return $results
    }
}