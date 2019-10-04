# THE PROBLEM
Recently, i was confronted to a the following question : How can i split a path and get the Parent and the children without "\\\\" or "\\\"
- The path is a UNC path, like this ````\\server\share````
- Just ````\\server\share````, not ````\\server\share\...\file````

Grr, the Split-Path cmdlet seems doesn't work with root UNC Path

Finally, i've found on the Internet 2 different ways to resolve this problem :

# FIRST WAY : SPLIT METHOD
````powershell
$FullPath = "\\server\folder"
$FullPath | get-Member
````
return
````
   TypeName : System.String

Name             MemberType            Definition
----             ----------            ----------
Clone            Method                System.Object Clone(), System.Object ICloneable.Clone()
CompareTo        Method                int CompareTo(System.Object value), int CompareTo(string strB), int IComparable.CompareTo(System.Object obj...
Contains         Method                bool Contains(string value)
...
Split            Method                string[] Split(Params char[] separator), string[] Split(char[] separator, int count), string[] Split(char[]...
...
````
OK, it's a ````[system.string]````. Let's try the split method
````powershell
$FullPath = "\\server\folder"
$FullPath.Split("\")
````
This return
````


server
folder
````
4 lines. 2 blank lines, and 2 lines with useful info
Now it should be easy to get differential values by adding the line number.
[0] is used for the first line,
[1] for the second, etc.
Nota : it seems that then number [-1] represents the last line (could be useful some times)
````powershell
$ParentPath = $FullPath.Split("\")[2])
$ParentPath
````
return
````
server
````
and
````powershell
$ChildrenPath = $FullPath.Split("\")[3])
$ChildrenPath
````
return
````
folder
````
Yes !

## comments
Transform a ````[System.String]```` with the split method is very easy to use and probably the easiest way.

Ref : https://devblogs.microsoft.com/scripting/using-the-split-method-in-powershell/

# SECOND WAY : Use [System.Uri]

````powershell
$FullPath = "\\server\folder"
$URI = New-Object System.Uri($FullPath) # or $URI = [URI]$FullPath
$URI
````
This return
````
AbsolutePath   : /folder
AbsoluteUri    : file://server/folder
LocalPath      : \\server\folder
Authority      : server
HostNameType   : Dns
IsDefaultPort  : True
IsFile         : True
IsLoopback     : False
PathAndQuery   : /folder
Segments       : {/, folder}
IsUnc          : True
Host           : server
Port           : -1
Query          :
Fragment       :
Scheme         : file
OriginalString : \\server\folder
DnsSafeHost    : server
IdnHost        : server
IsAbsoluteUri  : True
UserEscaped    : False
UserInfo       :
````
Now, we can use the following property to have the result
````powershell
$ParentPath = $URI.Host
$ParentPath
````
return
````
server
````
and
````powershell
$ChildrenPath = $URI.AbsolutePath
$ChildrenPath
````
return
````
/folder
````
Not exactly that i would like. Adding Split method

````powershell
$ChildrenPath = $URI.AbsolutePath.Split("/")
$ChildrenPath
````
return
````

folder
````
Not yet, one line more.
Let's play with the split method again.
Adding a second parameter : number of elements to return. As we can see 2 Lines/elements, choose 2.
Adding a third parameter : option. Option will be a ````[System.StringSplitOptions]::RemovingEmptyEntries````
````powershell
$option = [System.StringSplitOptions]::RemoveEmptyEntries
$ChildrenPath = $URI.AbsolutePath.Split("/",2,$option)
$ChildrenPath
````
return
````
folder
````
Yes !

## comments
Transform the ````[System.String]```` to ````[System.Uri]```` like this ```` [URI]$FullPath ```` return 2 important properties ````Host```` and ````AbsolutePath````
And it was easy to get the parent, but for the children it's not so : using split method with option.
If you don't know which option to use, well, it's not easy

Ref : https://stackoverflow.com/questions/18364710/split-path-with-root-unc-directory
