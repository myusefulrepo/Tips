# The Pb : A PSCustom Object contains a multivalues property
$info = [pscustomobject]@{
    First = "jason"
    Last = "Bourne"
    Location = @('US','FR')
}
$info

# If i want to export the object in a .csv file
$info |Export-Csv -Path C:\Temp\test.csv
# and use it later
Import-Csv -Path C:\temp\test.csv
# Biiip, Location is shown as a [System.object]

################################################
# The question is : How to solve this ?        #
################################################


# Solution 1 - Modify the PSCustomObject with Out-String cmdlet and Trim() method : 
$info1 = [pscustomobject]@{
    First = "Jason"
    Last = "Bourne"
    Location = (@('US','FR')|Out-String).Trim()
}
$info1

# Let's see that is the content for the different part of the property
@('US','FR').trim()
(@('US','FR')| Out-String) 
@('US','FR') | Get-Member               # [System.String]
(@('US','FR')| Out-String) | Get-Member # [System.String]
# It seems to be no change, but on the second we have the method Trim()

(@('US','FR')| Out-String).Trim() # this is exactly that we're looking for.

# Solution 2 : Modify the PSCustomObject with -Join and the separate caracter.
$info2 = [pscustomobject]@{
    First = "Jason"
    Last = "Bourne"
    Location = (@('US','FR') -join ',')
}
$info2

(@('US','FR') -join ',')
(@('US','FR') -join ',') | Get-Member # always [System.String]

$info1
$info2
# note that the output is slightly different ... but I don't know why. 


