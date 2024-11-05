- [1 - Preface](#1---preface)
  - [1.1 - Why create dummy files ?](#11---why-create-dummy-files-)
  - [1.2 - What is a dummy file ?](#12---what-is-a-dummy-file-)
- [2 - Using legacy DOS cmd line in powershell](#2---using-legacy-dos-cmd-line-in-powershell)
  - [2.1 - Create a single file](#21---create-a-single-file)
  - [2.2 - Create a bundle of dummy files](#22---create-a-bundle-of-dummy-files)
  - [2.3 - Pro/Cons](#23---procons)
- [3 - Using the powershell cmdlet : `New-Item`](#3---using-the-powershell-cmdlet--new-item)
  - [3.1 - Create a single file](#31---create-a-single-file)
  - [3.2 - Create a bundle of dummy files](#32---create-a-bundle-of-dummy-files)
  - [3.3 - Pro/Cons](#33---procons)
- [4 - Using the Powershell cmdlet `Set-Content` or `[System.IO.File]::WriteAllText()` or `[System.IO.File]::WriteAllbyte()`](#4---using-the-powershell-cmdlet-set-content-or-systemiofilewritealltext-or-systemiofilewriteallbyte)
  - [4.1 - Create a single file](#41---create-a-single-file)
  - [4.2 - Create a bundle of dummy files](#42---create-a-bundle-of-dummy-files)
  - [4.3 - Pro/Cons](#43---procons)
- [5 - Using the .NET `[System.IO.File]::OpenWrite()` class + `fsutil` to create a sparse file](#5---using-the-net-systemiofileopenwrite-class--fsutil-to-create-a-sparse-file)
  - [5.1 - Create a single file](#51---create-a-single-file)
  - [5.2 - Create a bundle of dummy files](#52---create-a-bundle-of-dummy-files)
  - [5.3 - Pro/Cons](#53---procons)
- [6  - Using the Powershell cmdlet `Add-Content` or `[System.IO.File]::OpenWrite()` .NET class (Stream)](#6----using-the-powershell-cmdlet-add-content-or-systemiofileopenwrite-net-class-stream)
  - [6.1 - Create a single file](#61---create-a-single-file)
  - [6.2 - Create a bundle of dummy files](#62---create-a-bundle-of-dummy-files)
  - [6.3 - Pro/Cons](#63---procons)
- [7  - Summarize different performance tests](#7----summarize-different-performance-tests)
  - [7.1 - File size 1KB](#71---file-size-1kb)
  - [7.2 - File size 10 KB](#72---file-size-10-kb)
  - [7.3 - File size 100 KB](#73---file-size-100-kb)
  - [7.4 - File size 1 MB](#74---file-size-1-mb)
  - [7.5 - File size 10 MB](#75---file-size-10-mb)
  - [7.4 - File size 100 MB](#74---file-size-100-mb)
- [8 - Last word](#8---last-word)

## 1 - Preface

Recently I was digging through my collection of scripts and functions of all sorts and came across various functions for creating dummy files.

### 1.1 - Why create dummy files ?

There are many opportunities to have dummy files. For example, to do tests without impacting real files, but also for example to simulate a tree structure

### 1.2 - What is a dummy file ?
As its name suggests, it is a file that is not a file with real content but is representative of a real file (extension, size, name, ...) for its use. At this level we can have dummy files empty of any content, but also dummy files containing equally lactic content (Lorem Ipsum).

This is what we are going to see in this post.

## 2 - Using legacy DOS cmd line in powershell

There is a DOS command named `fsutil` that can be used.

[Reference document](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/fsutil-file)

>[Nota] : Requires administrator rights

The syntax is the following :
````powershell
fsutil file CreateNew <FileName> <FileSize>

fsutil file CreateNew <Directory> <ShortName> <FileSize>
````

With : 
- **FileName** : Full Path of the file (eg. c:\path\to\Dummy\dummyFile.txt)
- **FileSize** : Size in Bytes (eg. 12288 equal 12 Kb)
- **Directory** : Full Path of the parent directory of the dummy file (eg. c:\path\to\Dummy\)
- **ShortName** : ShortName of the dummy file (eg : dummy.txt)

### 2.1 - Create a single file

Here we will create a 12 Kb file, named Dummy.txt

````powershell
fsutil file createnew C:\Temp\Dummy\DummyFile.txt 12288
Le fichier C:\Temp\Dummy\DummyFile.txt est créé
````
>[Nota] : if the path is omitted, the file is created in the directory where the prompt is located.

**About the performance** : I performed different processing with different file sizes (1KB, 10 KB, 100 KB, 1MB and 100 MB), here are the execution performance results : 

````output
file 1 KB  with fsutil : 20.1118 ms
file 10 KB  with fsutil : 12.2715 ms
file 100 KB  with fsutil : 12.8126 ms
file 1 MB  with fsutil : 12.1161 ms
file 100 MB  with fsutil : 11.903 ms
````


### 2.2 - Create a bundle of dummy files

We can use a simple `For` loop to do this.

eg. : Create 200 files of 12 Kb

````Powershell
for ($i = 1; $i -lt 100; $i++)
{ 
    fsutil file createnew Test-$i.txt 12288
}
````

And the output in shell is : 
````output
Le fichier C:\temp\dummy\Test-1.txt est créé
Le fichier C:\temp\dummy\Test-2.txt est créé
Le fichier C:\temp\dummy\Test-3.txt est créé
Le fichier C:\temp\dummy\Test-4.txt est créé
...
````
>[Nota] : in the present case the prompt was located in c:\temp\dummy. Be careful if the full path is not defined.
> We will see later that we can also manage the file extension

### 2.3 - Pro/Cons
| Pro | Cons |
|:---: |:---:| 
| Name managed | Content unmanaged
| Extension managed | Syntax  not really "Powershell Friendly" (DOS Command)
| Size managed |

## 3 - Using the powershell cmdlet : `New-Item`

### 3.1 - Create a single file

````powershell
New-Item -Path C:\temp\dummy\EmptyFile.txt -ItemType File
````

And the output in shell is : 
````output
    Répertoire : C:\temp\dummy

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        05/11/2024     08:24              0 EmptyFile.txt
````
>[Attention Point] : the file size cannot be determined and is equal to 0.

### 3.2 - Create a bundle of dummy files

````Powershell
for ($i=1;$i -le 100; $i++) 
    {  
    New-Item -Path C:\temp\Dummy\EmptyDummyFile$i.txt -ItemType File
    }
````

And the output in shell is : 

````output
Répertoire : C:\temp\Dummy

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        05/11/2024     08:37              0 EmptyDummyFile1.txt
-a----        05/11/2024     08:37              0 EmptyDummyFile2.txt
-a----        05/11/2024     08:37              0 EmptyDummyFile3.txt
-a----        05/11/2024     08:37              0 EmptyDummyFile4.txt
-a----        05/11/2024     08:37              0 EmptyDummyFile5.txt
-a----        05/11/2024     08:37              0 EmptyDummyFile6.txt
-a----        05/11/2024     08:37              0 EmptyDummyFile7.txt
...
````

### 3.3 - Pro/Cons
| Pro | Cons |
|:---: |:---:| 
| Name managed | Content unmanaged
| Extension managed | Size unmanaged
|Syntax "Powershell Friendly"|


## 4 - Using the Powershell cmdlet `Set-Content` or `[System.IO.File]::WriteAllText()` or `[System.IO.File]::WriteAllbyte()`

### 4.1 - Create a single file

````Powershell
$Path = Join-Path -Path "C:\temp\dummy" -ChildPath  "dummy.txt"
$SizeInKB = 100
$Content = "0" * (1KB * $SizeInKB)
Set-Content -Path $Path -Value $Content
<# equivalent in .NET form with : 
[System.IO.File]::WriteAllText($Path, $Content)
or
[System.IO.File]::WriteAllBytes($Path, $Content)
````
**About the performance** : I performed different processing with different file sizes (1KB, 10 KB, 100 KB, 1MB and 100 MB), here are the execution performance results : 

````output
file 1 KB  with Set-Content : 27.4024 ms
file 10 KB  with Set-Content : 9.8071 ms
file 100 KB  with Set-Content : 14.579 ms
file 1 MB  with Set-Content : 18.1971 ms
file 100 MB  with Set-Content : 972.7018 ms
file 1 KB  with [System.IO.File]::WriteAllText() : 9.495 ms
file 10 KB  with [System.IO.File]::WriteAllText() : 12.5454 ms
file 100 KB  with [System.IO.File]::WriteAllText() : 9.5493 ms
file 1 MB  with [System.IO.File]::WriteAllText() : 10.0611 ms
file 100 MB  with [System.IO.File]::WriteAllText() : 319.3047 ms
file 1 KB  with [System.IO.File]::WriteAllByte() : 7.4543 ms
file 10 KB  with [System.IO.File]::WriteAllByte() : 8.384 ms
file 100 KB  with [System.IO.File]::WriteAllByte() : 7.8705 ms
file 1 MB  with [System.IO.File]::WriteAllByte() : 10.1081 ms
file 100 MB  with [System.IO.File]::WriteAllByte() : 211.305 ms
````
**Comment** : As always, using the .NET method is a faster than the equivalent powershell cmdlet. It seems that `[System.IO.File]::WriteAllByte()` way is faster than `[System.IO.File]::WriteAllText()`

### 4.2 - Create a bundle of dummy files

````Powershell
$SizeInKB = 100
for ($i=1;$i -le 100; $i++) 
    {  
    $Path = Join-Path -Path "C:\temp\dummy" -ChildPath  "dummyFile-$i.txt"
    $content = "0" * (1KB * $SizeInKB)
    Set-Content -Path $Path -Value $Content
    # equivalent in .NET form with :  [System.IO.File]::WriteAllText($Path, $Content)
    }
````

### 4.3 - Pro/Cons
| Pro | Cons |
|:---: |:---:|
| Name managed | Content unmanaged ( a bunch of 0)
| Extension managed | Consumes a lot of memory
| Size managed | 
| Simple Syntax "Powershell Friendly"| Syntax not really "Powershell Friendly" using .NET class

## 5 - Using the .NET `[System.IO.File]::OpenWrite()` class + `fsutil` to create a sparse file

A sparse file is a special type of file that allows the file system to physically store only non-zero blocks of data. Blocks that contain all zeros are not actually written to disk, but are simply "marked" as blocks of zeros.

### 5.1 - Create a single file

>[Nota] : Requires administrator rights (cause fsutil)

````Powershell
[string]$Path = "C:\temp\dummy\dummyFile.txt"
[int64]$SizeInBytes = 100*1MB
$file = [System.IO.File]::Create($Path)
$file.Close()
# Mark file as sparse
$null = & fsutil sparse setflag "$Path"
# Set the size
$file = [System.IO.File]::OpenWrite($Path)
$file.SetLength($SizeInBytes)
$file.Close()
````
You can check in Windows Explorer by right-clicking on the file >Properties. 
- The "Size" represents the virtual size -100 MN in the present case)
- while the "Size on disk" represents the actual space used (0 MB in the present case)

**About the performance** : I performed different processing with different file sizes (1KB, 10 KB, 100 KB, 1MB and 100 MB), here are the execution performance results : 

````output
file 1 KB  with sparse : 12.864 ms
file 10 KB  with sparse : 19.6296 ms
file 100 KB  with sparse : 12.3886 ms
file 1 MB  with sparse : 12.3942 ms
file 100 MB  with sparse : 12.5758 ms
````



### 5.2 - Create a bundle of dummy files

````Powershell
[int64]$SizeInBytes = 100*1KB
for ($i=1;$i -le 100; $i++) 
    {  
    $Path = Join-Path -Path "C:\temp\dummy" -ChildPath  "dummyFile-$i.txt"
    $file = [System.IO.File]::Create($Path)
    $file.Close()
    # Mark file as sparse
    $null = & fsutil sparse setflag "$Path"
    # Set the size
    $file = [System.IO.File]::OpenWrite($Path)
    $file.SetLength($SizeInBytes)
    $file.Close()
    }
````
### 5.3 - Pro/Cons
| Pro | Cons |
|:---: |:---:|
| Name managed | Content unmanaged (empty file)
| Extension managed | Syntax not really "Powershell Friendly" using .NET class
| Size managed |
|very fast, uses no real disk space|

## 6  - Using the Powershell cmdlet `Add-Content` or `[System.IO.File]::OpenWrite()` .NET class (Stream)

### 6.1 - Create a single file

````Powershell
# Using the Add-Content cmdlet
[string]$Path = "C:\temp\dummy\AddContent.txt"
[int64]$SizeInMB = 100
$Buffer = New-Object byte[] (1MB)
for($i = 0; $i -lt $SizeInMB; $i++) {
        Add-Content -Path $Path -Value $Buffer -Encoding Byte -NoNewline
    }
}
````

````Powershell
# Using .NET way and a Stream
[string]$Path = "C:\temp\dummy\LargeDummyFile.txt"
[int64]$SizeInMB = 100
$Buffer = New-Object byte[] (1MB)
$Stream = [System.IO.File]::OpenWrite($Path)
for($i = 0; $i -lt $SizeInMB; $i++)
    {
    $Stream.Write($Buffer, 0, $Buffer.Length)
    }
    
$Stream.Close()
````

>[**Attention Point**] : If the Buffer size is different, the number of iterations needed to reach the same size must be adjusted

````powershell
[string]$Path = "C:\temp\dummy\LargeDummyFileBuffer4KB.txt"
[int64]$SizeInMB = 100
$Buffer = New-Object byte[] (4KB)
$Stream = [System.IO.File]::OpenWrite($Path)
# Calculate the number of iterations needed to reach the same size
$iterationsNeeded = ($SizeInMB * 1MB) / $Buffer.Length
for($i = 0; $i -lt $iterationsNeeded; $i++) 
    {
    $Stream.Write($Buffer, 0, $Buffer.Length)
    }
$Stream.Close()
````

**About the performances** : I performed different processing with different file sizes (1 MB, 10 MB, 100 MB), usingthe `Add-Content` cmdlet or a file stream.
````output
file 1 MB  with File Stream : 8.8154 ms
file 10 MB  with File Stream : 11.1839 ms
file 100 MB  with File Stream : 33.1382 ms
file 1 MB with Add-Content : 559.823 ms
file 10 MB with Add-Content : 5229.9907 ms
file 100 MB with Add-Content : 53159.7028 ms
````
**Comment** : The result is unequivocal: do not use `Add-Content`, prefer the use of a stream


**About the buffer size** : I performed different processing with different file sizes (1 MB and 100 MB) and different buffer sizes (1MB, 2MB, 4 KB), here are the execution performance results : 

````output
1 MB file with buffer size 1MB : 1.9988 ms
1 MB file with buffer size 2MB : 2.4019 ms
1 MB file with buffer size 4KB : 3.556 ms
100 MB file with buffer size 1MB : 23.3806 ms
100 MB file with buffer size 2MB : 23.0367 ms
100 MB file with buffer size 4KB : 235.9185 ms
````
**Comment** : It seems that in all cases, the most suitable is to use a 1MB buffer size.



### 6.2 - Create a bundle of dummy files

````Powershell
[int64]$SizeInMB = 100
$Buffer = New-Object byte[] (1MB)
for ($i=1;$i -le 100; $i++) 
    {  
    $Path = Join-Path -Path "C:\temp\dummy" -ChildPath  "LargedummyFile-$i.txt"
    $Stream = [System.IO.File]::OpenWrite($Path)
    for($j = 0; $j -lt $SizeInMB; $j++)
        {
        $Stream.Write($Buffer, 0, $Buffer.Length)
        }
    $Stream.Close()
    }
````

### 6.3 - Pro/Cons

| Pro | Cons |
|:---: |:---:|
| Name managed | Content unmanaged (Random content)
| Extension managed | Syntax not really "Powershell Friendly" using .NET class
| Size managed | Slower
| Useful for testing 

## 7  - Summarize different performance tests

### 7.1 - File size 1KB
| Test | Execution Time|
|:------------------------|-------------------|
| file 1 KB  with `[System.IO.File]::WriteAllByte()` | 7.4543 ms    |
| file 1 KB  with `[System.IO.File]::WriteAllText()` | 9.495 ms|
| file 1 KB  with `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file)` | 12.864 ms          |
| file 1 KB  with `fsutil` | 20.1118 ms         |
| file 1 KB  with `Set-Content` | 27.4024 ms    

**Comment** :
1 - `[System.IO.File]::WriteAllByte()`

2 - `[System.IO.File]::WriteAllText()`

3 - `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file)

4 - `fsutil`

5 - `Set-Content`


### 7.2 - File size 10 KB
| Test | Execution Time|
|:------------------------|-------------------|
| file 10 KB  with `[System.IO.File]::WriteAllByte()` | 8.384 ms    |
| file 10 KB  with `Set-Content` | 9.8071 ms    |
| file 10 KB  with `fsutil` | 12.2715 ms        |
| file 10 KB  with `[System.IO.File]::WriteAllText()` | 12.5454 ms   |
| file 10 KB  with `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file) | 19.6296 ms        |


**Comment** :

1 - `[System.IO.File]::WriteAllByte()`

2 - `Set-Content`

3 - `[System.IO.File]::WriteAllText()` - `fsutil`

3 - `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file)


### 7.3 - File size 100 KB
| Test | Execution Time|
|:------------------------|-------------------|
| file 100 KB  with `[System.IO.File]::WriteAllByte()` | 7.8705 ms  |
| file 100 KB  with `[System.IO.File]::WriteAllText()` | 9.5493 ms   |
| file 100 KB  with `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file) | 12.3886 ms       |
| file 100 KB  with `fsutil` | 12.8126 ms       |
| file 100 KB  with `Set-Content` | 14.579 ms   |

**Comment** :

1 -  `[System.IO.File]::WriteAllByte()` 

2 - `[System.IO.File]::WriteAllText()`

3 -  `fsutil` - `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file)

4 - `Set-Content`


### 7.4 - File size 1 MB
| Test | Execution Time|
|:------------------------|-------------------|
| file 1 MB  with `[System.IO.File]::OpenWrite()` (File Stream) | 8.8154 ms     |
| file 1 MB  with `[System.IO.File]::WriteAllText()` | 10.0611 ms    |
| file 1 MB  with `[System.IO.File]::WriteAllByte()` | 10.1081 ms   |
| file 1 MB  with `fsutil` | 12.1161 ms         |
| file 1 MB  with `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file) | 12.3942 ms         |
| file 1 MB  with `Set-Content` | 18.1971 ms    |
| file 1 MB with `Add-Content` | 559.823 ms     |

**Comment** :

1 - `[System.IO.File]::OpenWrite()` (File Stream)

2 - `[System.IO.File]::WriteAllText()` -  `[System.IO.File]::WriteAllByte()`

3 - `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file) - `fsutil`

4 - `Set-Content`

5 - `Add-Content`


### 7.5 - File size 10 MB
| Test | Execution Time|
|:------------------------|-------------------|
| file 10 MB  with  `[System.IO.File]::OpenWrite()` (File Stream) | 11.1839 ms   |
| file 10 MB with `Add-Content` | 5229.9907 ms  |

**Comment** :

1 - `[System.IO.File]::OpenWrite()` (File Stream) 

2 - `Add-Content`


### 7.4 - File size 100 MB
| Test | Execution Time|
|:------------------------|-------------------|
| file 100 MB  with `fsutil` | 11.903 ms        |
| file 100 MB  with `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file) | 12.5758 ms    |
| file 100 MB  with `[System.IO.File]::OpenWrite()` (File Stream)  | 33.1382 ms  |
| file 100 MB  with `[System.IO.File]::WriteAllByte()` | 211.305 ms |
| file 100 MB  with `[System.IO.File]::WriteAllText()` | 319.3047 ms |
| file 100 MB  with `Set-Content` | 972.7018 ms |
| file 100 MB with `Add-Content` | 53159.7028 ms|


**Comment** :

1 -  `fsutil` - `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file)

2 - `[System.IO.File]::OpenWrite()` (File Stream) 

3 - `[System.IO.File]::WriteAllByte()`

4 - `[System.IO.File]::WriteAllText()`

5 -  `Set-Content`

6 -  `Add-Content`


On small files use : `[System.IO.File]::WriteAllByte()` or  `[System.IO.File]::WriteAllText()`
On large files use : `[System.IO.File]::OpenWrite()` class + `fsutil` (sparse file)


## 8 - Last word

I've put an advanced function to create some dummy files [here](https://gist.github.com/Rapidhands/7855f8ddfee8c942fcdc95cc68bf7832). I hope this will be usefull.