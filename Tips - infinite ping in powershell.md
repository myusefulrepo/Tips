# The pb : you would do like the old DOS command : infinite ping with -t parameter
````powershell
ping google.com -t
````
... but in powershell. how do you do that ?

The answer is : "With `Test-connection`" of course, with parameter `-Count` but what integer ?

# Let's see this quickly together
>[Nota] : Remember in the Quick Tips : https://github.com/myusefulrepo/Tips/blob/master/Tips%20-%20Get%20a%20list%20of%20the%20available%20special%20folders%20with%20the%20%5BEnum%5D%20Accelerator.md
> We had seen that we had these accelerators [Int], [Int16], [Int32], [Int64]
> These accelerators have some properties (to be honest, only 2) MinValue and MaxValue

Let's test theses accelerators with MaxValue property
````powershell
[int]::MaxValue
2147483647
[int16]::MaxValue
32767
[int32]::MaxValue
2147483647
[int64]::MaxValue
223372036854775807
````
As we can see, [int] is an [Int32]. We can use it for the -Count parameter in the Test-Connection cmdlet.
The only precaution is to ***surround by a parenthesis***
````
Test-Connection google.com -Count ([int]::MaxValue)
Source        Destination     IPV4Address      IPV6Address                              Bytes    Time(ms)
------        -----------     -----------      -----------                              -----    --------
xxxxxx        google.com      216.58.201.238                                            32       7
xxxxxx        google.com      216.58.201.238                                            32       13
xxxxxx        google.com      216.58.201.238                                            32       8
xxxxxx        google.com      216.58.201.238                                            32       7
xxxxxx        google.com      216.58.201.238                                            32       9
xxxxxx        google.com      216.58.201.238                                            32       9
xxxxxx        google.com      216.58.201.238                                            32       7
xxxxxx        google.com      216.58.201.238                                            32       9
`````

Simple, isn't it ?

Hope this helpful