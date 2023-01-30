# Create a bunch of Dummy files

## Create empty file with defined size 

````powershell
$File = New-Object -TypeName System.IO.FileStream c:\temp\test.txt, Create, ReadWrite
# Here, we define the size of the file
$File.SetLength(10Mb)
````

## closing and creating file

````powershell
$File.Close()
````


## Create a bunch of file with different sizes and in a diffrent quantity

````powershell
$PathForDummyFiles = "c:\temp"
$NumberOf100KB = 200
$NumberOf1MB = 100
$NumberOf10MB = 10
$NumberOf100MB = 5

# Creating 1 KB files
for ($i = 1; $i -lt $NumberOf100KB; $i++)
    { 
    $File = New-Object -TypeName System.IO.FileStream "$PathForDummyFiles\test100KB-$I.txt", Create, ReadWrite
    $File.SetLength(100KB)
    $File.Close() 
    }

# Creating 1 MB files
for ($i = 1; $i -lt $NumberOf1MB; $i++)
    { 
    $File = New-Object -TypeName System.IO.FileStream "$PathForDummyFiles\test1MB-$I.txt", Create, ReadWrite
    $File.SetLength(1MB)
    $File.Close() 
}

# Creating 10 MB files
for ($i = 1; $i -lt $NumberOf10MB; $i++)
    { 
    $File = New-Object -TypeName System.IO.FileStream "$PathForDummyFiles\test10MB-$I.txt", Create, ReadWrite
    $File.SetLength(10MB)
    $File.Close() 
}

# Creating 100 MB files
for ($i = 1; $i -lt $NumberOf100MB; $i++)
    { 
    $File = New-Object -TypeName System.IO.FileStream "$PathForDummyFiles\test100MB-$I.txt", Create, ReadWrite
    $File.SetLength(100MB)
    $File.Close() 
}
````

In this sample to create 311 files, this take 291 ms. To create 2146 files, this takes 2,2 sec. 

## We can also use another way to do the same thing

````powershell
$Path = "C:\temp2"
$File = "MyFile.txt"
$MyArray = New-Object -TypeName Byte[] -ArgumentList 10Kb
$OBJ = New-Object -TypeName System.Random
$OBJ.NextBytes($MyArray)
Set-Content -Path $Path\$File -Value $MyArray -Encoding Byte
````

there is no real difference in execution time. However, you will notice that the files are not empty but filled with weird characters

# we can also use the legacy DOS command fsutil


````DOS 
fsutil file createnew C:\Temp2\test1.txt 10000
````

>[Nota] : the size is in Bytes. It's not really obvious to play with this.



Hope this will be useful
