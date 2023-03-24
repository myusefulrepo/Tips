# Find Duplicate files and delete

Identify duplicate file using their names, is not a solution, because the content of the files could be the same (independant of the file type). 

The way is to use Powershell, calculate the file Hash of each files, and then choose the file to keep, and the files (duplicate) to remove. 

When 2 hashes are identical, the contents of the files are identical. This is independent of the file type. Thus, 2 image files may appear to have identical content, but if only 1 pixel is different, their hash will be different. The hash is therefore an infallible means of file comparison

## Take a look on the cmdlet ````Get-FileHash````

````powershell 
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt           

Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
SHA256          E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855       C:\temp\ABCD_CPD_koufsdiofu.txt
````
> [ Nota ] : The cmdlet Get-FileHash has a parameter called Algorithm. The Default value for this parameter is ````SHA256````, but you can choose other algorithm (MD5, SHA1, SHA256, SHA384, Sha512, MACTripleDES, RIPEMD160)


````powershell
# MMACTripleDES
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt -Algorithm MACTripleDES
# MD5
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt -Algorithm MD5
# RIPEMD160
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt -Algorithm RIPEMD160
# SHA1
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt -Algorithm SHA1
# SHA256
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt -Algorithm SHA256
# SHA 384
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt -Algorithm SHA384
# SHA512
Get-FileHash -Path C:\temp\ABCD_CPD_koufsdiofu.txt -Algorithm SHA512
<#
Algorithm       Hash                                                                    Path
---------       ----                                                                    ----
MACTRIPLEDES    0000000000000000                                                        C:\temp\ABCD_CPD_koufsdiofu.txt
MD5             D41D8CD98F00B204E9800998ECF8427E                                        C:\temp\ABCD_CPD_koufsdiofu.txt
RIPEMD160       9C1185A5C5E9FC54612808977EE8F548B2258D31                                C:\temp\ABCD_CPD_koufsdiofu.txt
SHA1            DA39A3EE5E6B4B0D3255BFEF95601890AFD80709                                C:\temp\ABCD_CPD_koufsdiofu.txt
SHA256          E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855        C:\temp\ABCD_CPD_koufsdiofu.txt
SHA384          38B060A751AC96384CD9327EB1B1E36A21FDB71114BE07434C0CC7BF63F6E1DA274...  C:\temp\ABCD_CPD_koufsdiofu.txt
SHA512          CF83E1357EEFB8BDF1542850D66D8007D620E4050B5715DC83F4A921D36CE9CE47D...  C:\temp\ABCD_CPD_koufsdiofu.txt
#>
````
As you can see, using - in this case - an another algorithm create a hash more or less long, then the execution time is more or less long. Using the default algorithm is enought. 

# First Step : find duplicate files in a tree

In a first step, I have cut the approach in small steps to allow time to examine the result at each step.

````powershell
$FilePath = 'C:\temp\'
$Tree = Get-ChildItem –Path $FilePath -Recurse
$Hashs = $Tree | Get-FileHash
$GroupByHash = $Hashs | Group-Object -Property hash
$GroupByUniqueFiles = $groupByHash | Where-Object -FilterScript { $_.count -gt 1 }
$DuplicateFilesDetails = $GroupByUniqueFiles | ForEach-Object { $_.group | Select-Object -Property Path, Hash }
````
Take a look on each variable at each step (of course, using your own FilePath)
Now that each step is understood, let's put all this together in a one-liner command

````powershell 
$GroupByUniqueFiles = Get-ChildItem –Path $FilePath -Recurse | 
    Get-FileHash |
    Group-Object -Property Hash |
    Where-Object -FilterScript { $_.count -gt 1 }
````

The result looks like the following :

````powershell
$GroupByUniqueFiles = Get-ChildItem –Path $FilePath -Recurse | 
    Get-FileHash |
    Group-Object -Property Hash |
    Where-Object -FilterScript { $_.count -gt 1 }
<#
Count Name                      Group
----- ----                      -----
    2 E3B0C44298FC1C149AFBF4... {@{Algorithm=SHA256; Hash=E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855; Path=C:\temp\ABCD_CPD_koufsdiofu...
    2 F1945CD6C19E56B3C1C789... {@{Algorithm=SHA256; Hash=F1945CD6C19E56B3C1C78943EF5EC18116907A4CA1EFC40A57D48AB1DB7ADFC5; Path=C:\temp\rep_wsus.csv}, @{Al...
    2 56BF363F780F12CC092BA8... {@{Algorithm=SHA256; Hash=56BF363F780F12CC092BA8FA75384258C2FC8360B53D01077FD48C639AFF1CE0; Path=C:\temp\Ouptut\TapN-Evotec-...
    2 A577FBE5DDD554A68F5709... {@{Algorithm=SHA256; Hash=A577FBE5DDD554A68F5709F187D99C8A21A8BB94CA50D3AFD1466015FB9EDB45; Path=C:\temp\windows_hardening-m...
    5 E43E04ADA5ADC5D030719E... {@{Algorithm=SHA256; Hash=E43E04ADA5ADC5D030719E2AA6E0268A0ACFFE4D14E69A1CD7EAEB0F015D75CB; Path=C:\temp\windows_hardening-m...
    2 665140416FE0807B194D2A... {@{Algorithm=SHA256; Hash=665140416FE0807B194D2AB10128BF92C5FA4450BEAD217F2AFE19C3E060E629; Path=C:\temp\windows_hardening-m...
    2 10C4B95C56F91B9DA98CBA... {@{Algorithm=SHA256; Hash=10C4B95C56F91B9DA98CBA8A3B2522E39B0ABB4D2DA2EA8010DB76D39CFF32B2; Path=C:\temp\windows_hardening-m...
    2 BE86DC9F374B5C8FF51B64... {@{Algorithm=SHA256; Hash=BE86DC9F374B5C8FF51B640C3A6AC6194E2B42438C744A9F823A555394C36240; Path=C:\temp\windows_hardening-m...
    2 A7C1203AB0023A097DF092... {@{Algorithm=SHA256; Hash=A7C1203AB0023A097DF092D380203B7BB1221A08BAFA24BABADBA87B312C4689; Path=C:\temp\windows_hardening-m...
    2 E792D41AE4F274156E99C5... {@{Algorithm=SHA256; Hash=E792D41AE4F274156E99C5781C6C4B07B200EBCCE39E665C8305486517B8CABF; Path=C:\temp\windows_hardening-m...
#>
````
And the last step

````powershell
$DuplicateFileDetails = $GroupByUniqueFiles | ForEach-Object  { $_.Group | Select-Object -Property Path, Hash }
<#
Path                                                                                                            Hash
----                                                                                                            ----
C:\temp\ABCD_CPD_koufsdiofu.txt                                                                                 E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B
C:\temp\files.csv                                                                                               E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B
C:\temp\rep_wsus.csv                                                                                            F1945CD6C19E56B3C1C78943EF5EC18116907A4CA1EF
C:\temp\Utilisateurs du bureau à distance.csv                                                                   F1945CD6C19E56B3C1C78943EF5EC18116907A4CA1EF
C:\temp\Ouptut\TapN-Evotec-2048x1536.jpg                                                                        56BF363F780F12CC092BA8FA75384258C2FC8360B53D
C:\temp\PowerBGInfo-master\Examples\Samples\TapN-Evotec-2048x1536.jpg                                           56BF363F780F12CC092BA8FA75384258C2FC8360B53D
C:\temp\windows_hardening-master\lists\finding_list_bsi_sisyphus_windows_10_nd_user.csv                         A577FBE5DDD554A68F5709F187D99C8A21A8BB94CA50
C:\temp\windows_hardening-master\lists\finding_list_bsi_sisyphus_windows_10_ne_user.csv                         A577FBE5DDD554A68F5709F187D99C8A21A8BB94CA50
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_10_enterprise_1809_user.csv           E43E04ADA5ADC5D030719E2AA6E0268A0ACFFE4D14E6
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_10_enterprise_1903_user.csv           E43E04ADA5ADC5D030719E2AA6E0268A0ACFFE4D14E6
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_10_enterprise_1909_user.csv           E43E04ADA5ADC5D030719E2AA6E0268A0ACFFE4D14E6
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_server_2016_1607_1.2.0_user.csv       E43E04ADA5ADC5D030719E2AA6E0268A0ACFFE4D14E6
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_server_2019_1809_1.1.0_user.csv       E43E04ADA5ADC5D030719E2AA6E0268A0ACFFE4D14E6
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_10_enterprise_1903_machine.csv        665140416FE0807B194D2AB10128BF92C5FA4450BEAD
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_10_enterprise_1909_machine.csv        665140416FE0807B194D2AB10128BF92C5FA4450BEAD
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_10_enterprise_20h2_user.csv           10C4B95C56F91B9DA98CBA8A3B2522E39B0ABB4D2DA2
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_10_enterprise_21h1_user.csv           10C4B95C56F91B9DA98CBA8A3B2522E39B0ABB4D2DA2
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_11_enterprise_21h2_user.csv           BE86DC9F374B5C8FF51B640C3A6AC6194E2B42438C74
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_server_2022_21h2_1.0.0_user.csv       BE86DC9F374B5C8FF51B640C3A6AC6194E2B42438C74
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_server_2016_1607_1.3.0_user.csv       A7C1203AB0023A097DF092D380203B7BB1221A08BAFA
C:\temp\windows_hardening-master\lists\finding_list_cis_microsoft_windows_server_2019_1809_1.2.1_user.csv       A7C1203AB0023A097DF092D380203B7BB1221A08BAFA
C:\temp\windows_hardening-master\lists\finding_list_dod_microsoft_windows_server_2019_dc_stig_v2r1_user.csv     E792D41AE4F274156E99C5781C6C4B07B200EBCCE39E
C:\temp\windows_hardening-master\lists\finding_list_dod_microsoft_windows_server_2019_member_stig_v2r1_user.csv E792D41AE4F274156E99C5781C6C4B07B200EBCCE39E
#>
````
Of course, you could display the output in a ````Out-Gridiew ````for a more readable output.

````powershell
$DuplicateFileDetails | Out-GridView
````

## Last Step : Delete the duplicate files

To help choose the files to delete among the duplicates of the same file, the ````Out-GridView```` cmdlet is a good solution using its ````-OutputMode```` with the value ````Multiple```` parameter. This setting allow to **choose multiple files** in the ````Out-gridView````, by selecting them and click OK. The selected files are in the output of the cmdlet.

````powershell
$FilesToDelete = $DuplicateFileDetails | Out-GridView -OutputMode Multiple
$FilesToDelete
<#
$FilesToDelete
Path                                          Hash
----                                          ----
C:\temp\files.csv                             E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855
C:\temp\Utilisateurs du bureau à distance.csv F1945CD6C19E56B3C1C78943EF5EC18116907A4CA1EFC40A57D48AB1DB7ADFC5
#>
````

Here, I'm selected 2 duplicate files. I'm keeping the other "replicate" (with a diffrent name) of these file

now let's proceed to delete these files.

````powershell 
$FileToDelete | Remove-Item -WhatIf
WhatIf : Opération « Supprimer le fichier » en cours sur la cible « C:\temp\files.csv ».
WhatIf : Opération « Supprimer le fichier » en cours sur la cible « C:\temp\Utilisateurs du bureau à distance.csv ».
````
Of course, to really proceed with the deletion, you must remove the ````-Whatif```` parameter.

> [ Nota ] : the cmdlet Remove-Item return nothing when it's executed.

## Final words

This whole process was done step by step in order to fully understand what each step does.
It is also important to note that the most important operation **(deletion) is not trivial**, and requires a lot of attention before being executed. 

Playing it with the ````-WhatIf```` parameter in order to check what it would give is not an option, I would even say that **it's mandatory to do** so.

Finally, this entire process is designed to be done in **interactive mode only** (don't forget that the selection is done by the ````Out-GridView````).

Hope this help