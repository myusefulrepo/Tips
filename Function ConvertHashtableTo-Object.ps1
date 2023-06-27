# source : https://gordon.byers.me/powershell/convert-a-powershell-hashtable-to-object/
function ConvertHashtableTo-Object
{
    [CmdletBinding()]
    Param([Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [hashtable]$ht
    )
    PROCESS
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