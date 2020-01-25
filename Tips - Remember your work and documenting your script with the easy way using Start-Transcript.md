# Remember your work and documenting your script with the easy way using Start-Transcript

The ````Start-Transcript```` cmdlet is a native cmdlet to create a record of powershell sessions This is very interesting and useful for your currents tasks with Powershell and logging tasks in PS Scripts (Interactive or not).

Moreover, you can use Start-Transcript in a local session and in a remote session.

## How to use it

````powershell
Start-Transcript
Transcription démarrée, le fichier de sortie est C:\Users\Olivier\Documents\PowerShell_transcript.ASUS10.PltJnuuq.20200125074423.txt
# and to stop it
Stop-Transcript
Transcription arrêtée, le fichier de sortie est C:\Users\Olivier\Documents\PowerShell_transcript.ASUS10.PltJnuuq.20200125074423.txt
````

OK, it's fine but the path is not necessary on a good place for you, and the name is not good too. Let's affine this

````powershell
Start-Transcript -Path c:\temp\TodayJob-$(Get-Date -format "dd-MM-yyyy").log
Transcription démarrée, le fichier de sortie est c:\temp\TodayJob-25-01-2020.log
````

It's better, but it's a semi-static path. We'll see later how to have an automatic naming when we'll use ````Start-Transcript```` with a script.

By default, ````Start-Transcript```` *overwrite an existing transcript file* without warning, use the ````-NoClobber```` parameter the avoid this

````powershell
Start-Transcript -Path c:\temp\TodayJob-$(Get-Date -format "dd-MM-YYYY").log -NoClobber
Start-Transcript : Le fichier C:\temp\TodayJob-25-01-YYYY.log existe déjà et NoClobber a été spécifié.
Au caractère Ligne:1 : 1
+ Start-Transcript -Path c:\temp\TodayJob-$(Get-Date -format "dd-MM-YYY ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceExists: (C:\temp\TodayJob-25-01-YYYY.log:String) [Start-Transcript], UnauthorizedAccessException
    + FullyQualifiedErrorId : NoClobber,Microsoft.PowerShell.Commands.StartTranscriptCommand
````

You can also use the ````-Append```` parameter to add new content at the end of an existing file

````Powershell
Start-Transcript -Path c:\temp\TodayJob-$(Get-Date -format "dd-MM-yyyy").log
Transcription démarrée, le fichier de sortie est c:\temp\TodayJob-25-01-2020.log
[08:01:20] C:/Temp> get-date
samedi 25 janvier 2020 08:01:24
[08:01:24] C:/Temp> Stop-Transcript
Transcription arrêtée, le fichier de sortie est C:\temp\TodayJob-25-01-2020.log
[08:01:28] C:/Temp> Start-Transcript -Path c:\temp\TodayJob-$(Get-Date -format "dd-MM-yyyy").log -Append
Transcription démarrée, le fichier de sortie est c:\temp\TodayJob-25-01-2020.log
[08:01:35] C:/Temp> write-host "the current date is $(Get-Date)"
the current date is 01/25/2020 08:01:41
````

As you have seen, to stop the transcript file, I've used ````Stop-Transcript```` cmdlet.

## and about Transcript against Remote Hosts

The Start-Transcript cmdlet haven't ````-ComputerName```` parameter. Then we must use ````Enter-PSSession```` cmdlet like this.

````powershell
Enter-PSSession -ComputerName RemoteComputer
Start-Transcript -Path Path\to\transcriptFile.log
````

You are free to use ````Invoke-Command```` cmdlet, this runs fine too.

## For Automatic recording

You can use 2 ways to do this

1 -  Add some command on your profile
2 - Use a Policy to do the job

### Add in Profile File

i.e. : Open your Profile file with the following command
 with Powershell ````invoke-item $profile````
 With Powershell ISE : ````PSEdit $Profile````

>[Nota ] Verify if a profile file exists with $Profile.

````powershell
$profile
C:\Users\UserName\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1
````

A profile file exists. Here for Powershell ISE. For Powershell the default path will be : "C:\Users\UserName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

If your profile file doesn't exist, you can can create it with :

````powershell
New-Item -Path $Profile -Force
````

Then add the following command :

````powershell
Start-Transcript -Path "ThePath\youwouldlike\to\transcriptfile.log"
````

I prefer use something like this to have Automatic Naming using TimeStamp.

````powershell
Start-Transcript -Path "C:\PSTranscripts\$(get-date -Format "yyyy-MM-dd-hh-mm-ss").log"
````

### Use Group Policy

But, the ultimate way is to use Group Policy. Open **GPEdit** : *\Computer Configuration\ Administrative Templates\Windows Components\Windows PowerShell*
Go to *Enabled Powershell Transcript*
Pass the value to : *Enabled*
Define Transcript output directory
You are free to check the box *"include invocation Headers"* if you want to have a time stamp for each command.

You can also do the same thing with User Configuration, but the ***Computer Policy have precedence over User Policy***.

>[Nota1 ]
> by Policy you define a path to OutputDirectory, but you *can't define the name* of the transcript file. It's the default naming convention (see first sample using Start-Transcript earlier in this post)
>[Nota 2]
> I'm thinking that the folder path must be existing. Take care about this. Ensure that the path is always existing on the computers you would like to apply this by GPO or create/check this path with Login script.

## Finally using Start-Transcript and with a script

In a script you certainly want to have

- Automatic Naming Including ScriptName running, TimeStamp
- break free from script execution path

The solution is to use a combinaison of Automatic Variable and pre-define variables

````powershell
$ScriptPath = $MyInvocation.MyCommand.Path # automatic Variable
$LogDirPath = "$ScriptPath\ScriptLogs\" # must be existing or create first
$TranscriptFilePath = $LogDirPath\$(($MyInvocation.MyCommand.Name).split(".")[0])-$(Get-Date -format "yyyy-MM-dd").log"
````

The ````($MyInvocation.MyCommand.Name)```` returns the script name with its extension. Then, I use the ````split```` method to cut on ````"."```` and keep only the first part.
````($MyInvocation.MyCommand.Name).split(".")[0])```` returns only script Name without the extension.

>[Nota] The previous code is for Powershell < version 3. This still works fine, in Powershell 3 and above and but you can also use ````$PSScriptRoot```` automatic variable.


I Hope this can help.
