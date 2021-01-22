# Explanations about different outputs


what is the difference between
````(Get-ComputerInfo).csprocessors````
and ````Get-ComputerInfo | Select-Object -Property csprocessors```` ?

Indeed, the 2 previous commands show a different outputs. Let's show the output for each command.

````powershell
(Get-ComputerInfo).csprocessors

Name                      : Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz
Manufacturer              : GenuineIntel
Description               : Intel64 Family 6 Model 94 Stepping 3
Architecture              : x64
AddressWidth              : 64
DataWidth                 : 64
MaxClockSpeed             : 4001
CurrentClockSpeed         : 4001
NumberOfCores             : 4
NumberOfLogicalProcessors : 8
ProcessorID               : BFEBFBFF000506E3
SocketDesignation         : LGA1151
ProcessorType             : CentralProcessor
Role                      : CPU
Status                    : OK
CpuStatus                 : Enabled
Availability              : RunningOrFullPower
````

and

````powershell
(Get-ComputerInfo).csprocessors


Name                      : Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz
Manufacturer              : GenuineIntel
Description               : Intel64 Family 6 Model 94 Stepping 3
Architecture              : x64
AddressWidth              : 64
DataWidth                 : 64
MaxClockSpeed             : 4001
CurrentClockSpeed         : 4001
NumberOfCores             : 4
NumberOfLogicalProcessors : 8
ProcessorID               : BFEBFBFF000506E3
SocketDesignation         : LGA1151
ProcessorType             : CentralProcessor
Role                      : CPU
Status                    : OK
CpuStatus                 : Enabled
Availability              : RunningOrFullPower
````

The first one expands the value and the second one does not. The curly braces on the second one means its an **array** and in this case it is an array of objects.

Nota : If you we use in the second command the parameter ````-ExpandProperty````, the output will be the same as the first command.

````powershell
Get-ComputerInfo | Select -ExpandProperty CsProcessors


Name                      : Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz
Manufacturer              : GenuineIntel
Description               : Intel64 Family 6 Model 94 Stepping 3
Architecture              : x64
AddressWidth              : 64
DataWidth                 : 64
MaxClockSpeed             : 4001
CurrentClockSpeed         : 1700
NumberOfCores             : 4
NumberOfLogicalProcessors : 8
ProcessorID               : BFEBFBFF000506E3
SocketDesignation         : LGA1151
ProcessorType             : CentralProcessor
Role                      : CPU
Status                    : OK
CpuStatus                 : Enabled
Availability              : RunningOrFullPower
````

Hope this help to understand how Powerwhell works.
