# Speed up your powershell scripts

1 - Avoid using ````+=```` to add to an array that creates a new one every time you add anything to it.
for small collections, the copy is fast. However, if your collection is large [lots of items OR ram-intensive items], you will see a steadily slower process.
==> the recommended solution is to use a collection that has a real ````.Add()```` method **OR** to assign the whole loop to your ````$Collection```` var.

````powershell
# avoid
$Array = @()
foreach ($User  in $UserList){
    $array += [PSCustomObject]@{
        UserName = $User.Name
        Email    = $User.SamAccountName
    }
}

# prefer
$Array  = foreach ($User in $UserList){
    [PScustomObject]@{
        UserName = $User.Name
        Email    = $User.SamAccountName
    }
}

# Another solution : less memory consumption
$Array = [System.Collections.Generic.List[PSObject]]::New()
$Array  = foreach ($User in $UserList){
    $Array.Add([PSCustomObject]@{
        UserName = $User.Name
        Email    = $User.SamAccountName
    })
}
````


2 - the ````New-Object```` cmdlet is known for slowness.
If you are only doing this a few times, it is not meaningful. However, it mounts up. Use the ````[PSCustomObject]```` accelerator instead.

````powershell
# Avoid this
$Object = "" | Select-Object -Property Int,Ext, AddText, RemText, FileName, FilePath, Error
$Object = New-Object PSObject @{
    Int = ''
    Ext = ''
    AddText = ''
    RemText = ''
    FileName = ''
    FilePath = ''
    Error = ''
}

$CustomObject =[PSCustomObject]@{}
foreach ($Param in $PSBoundParameters.GetEnumerator())
    {
    Add-Member -InputObject $CustomObject -MemberType NoteProperty -Name $Param.key -Value $Param.value
    }

# prefer
[PSCustomObject]@{
    Int = ''
    Ext = ''
    AddText = ''
    RemText = ''
    FileName = ''
    FilePath = ''
    Error = ''
}

# Or for Powershell V2
New-Object PSObject@{
    Int = ''
    Ext = ''
    AddText = ''
    RemText = ''
    FileName = ''
    FilePath = ''
    Error = ''
}
$CustomObject = [PSCustomObject]@{
    Param = $Param
}
````

3 - Assigning values to props after defining the object.
It's a very minor thing, but you can make the assignment when you define the property.

4 - Avoid to use use pipeline to filter if you can filter in the first cmdlet

````powershell
# avoid this
Get-ChildItem c:\backups\*.bak | Copy-Item -Destination d:\backups
# prefer this
Get-ChildItem -Path c:\backups -filter *.bak | Copy-Item -Destination d:\backups
````
