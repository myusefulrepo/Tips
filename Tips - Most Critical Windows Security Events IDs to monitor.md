# Most Critical Windows Security Events IDs to monitor

- [Most Critical Windows Security Events IDs to monitor](#most-critical-windows-security-events-ids-to-monitor)
  - [High Critically Events](#high-critically-events)
  - [Prerequisite to enable Event Logging](#prerequisite-to-enable-event-logging)
  - [Verify the auditing Policies](#verify-the-auditing-policies)
  - [Audit with Powershell scripts](#audit-with-powershell-scripts)
  - [References](#references)


## High Critically Events

| Category | EventID  | Description | Reasons To monitor (by no means exhaustive) |
|:---------:|:---------:|:---------:|:---------------------------------------------------------------------|
| Logon and logoff |**4624**| Successful logon | - To detect abnormal and possibly unauthorized insider activity, like a logon from an inactive or restricted account, users logging on outside of normal working hours, concurrent logons to many resources, etc. <br>- To get information on user behavior like user attendance, user working hours, etc |
||**4625**| Failed logon | - To detect possible brute-force, dictionary, and other password guess attacks, which are characterized by a sudden spike in failed logons. <br>- To arrive at a benchmark for the account lockout threshold policy setting |
| Account management | **4728** |Member added to security-enabled global group |- To ensure group membership for privileged users, who hold the "keys to the kingdom," is scrutinized regularly. This is especially true for security group membership additions. <br>- To detect privilege abuse by users who are responsible for unauthorized additions. <br>- To detect accidental additions. |
||**4732**|Member added to security-enabled localgroup ||
||**4756**|Member added to security-enabled universal group||
||**4765**| SIDHistory was Added to an account||
||**4766**| an attempt to add SIDHistory to an account failed||
||**4794**| An attempt was made to set the Directory Services Restore Mode.||
||**4897**| Role separation enabled.||
||**4964**| Special groups have been assigned to a new logon.||
||**5124**| A security setting was updated on the OCSP Responder Service.||
|Event Log | **1102** | (Log cleared) (Alternatively the event log service can also be disabled which results in the logs not getting recorded. This is done by the system audit policy, in which case event 4719 gets recorded.|To spot users with malicious intent, such as those responsible for tampering with event logs.|
||**4719**| System Audit Policy Was changed |
| Account Management | **4740** | User account locked out | - To detect possible brute-force, dictionary, and other password guess attacks, which are characterized by a sudden spike in failed logons. <br>- To mitigate the impact of legitimate users getting locked out and being unable to carry out their work.|
|Object Access | **4663** | Attempt made to access object | To detect unauthorized attempts to access files and folders.|


## Prerequisite to enable Event Logging

The best and easiest way is to set all theses Events by **Group Policy Objects**

*Computer Configuration ➔ Windows Settings ➔ Security Settings ➔ Advanced Audit Policy Configuration ➔ Audit Policies.*

|Type of Auditing|Path|
|:---------:|:---------:|
Domain Logon/Logoff Auditing |In ‘Logon/Logoff’ : enable <br>Audit Logon<br>Audit Logoff|
|File System Auditing|In ‘Object Access : enable <br>Audit Detailed File Share <br>Audit File Share<br>Audit File System|
|Registry Auditing | In ‘Object Access' : enable <br>Audit Registry|
|Auditing of Handle Manipulation |In ‘Object Access’ : enable <br>Audit Handle Manipulation|
|Global Object Access Auditing| In 'Global Object Access Auditing' : enable <br> Add Registry with the following Settings <br>Click ‘Add’ to add users or groups of which access you want to audit. It shows ‘Auditing Entry for Global Registry SACL’ window. <br> Suggested Groups and Users : Domain Admins, Entreprise Admins, Schema Admin, Administrator (builtin) <br> All permissions checked <br>Type : Success |

*Computer Configuration ➔ Policies ➔ Windows Settings ➔ Security Settings ➔ Security Options.*

|Type of Auditing|Path|
|:---------:|:---------:|
|Manage the Integrity of Advanced Auditing| In 'Audit : Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings' : enable.|

## Verify the auditing Policies

Run the following command on the Command prompt (Run as Admin)

````DOS
auditpol.exe /get /category:*
````

This command lists the status of all auditing policies (both basic and advanced) on the server. Check carefully both *Success* and *Failure* events for the policies, which you have enabled.

## Audit with Powershell scripts

The fastest way is to use ````Get-WinEvent ````with the ````FilterHashTable ````parameter

````powershell
$StartTime = Get-Date -Year 2021 -Month 07 -Day 22  -Hour 08 -Minute 00
$EndTime   = Get-Date -Year 2021 -Month 07 -Day 22  -Hour 17 -Minute 00
$Events = Get-WinEvent -FilterHashtable @{
                                LogName   = 'Security'
                                StartTime = $StartTime
                                EndTime   = $EndTime
                                ID        = "4624"
                                } -ErrorAction SilentlyContinue # in case no event meet the criteria, to avoid the error display
````

In the previous sample, I've looking for only One ID, but we should monitor many IDs by adding multiple ID (separated by a ",")

Of course, in the ````filterHashtable```` parameter, we could add other things like ````Level````, ````keywords````,... and we could use the pipeline to add another filters (i.e. filtering on ````AccountName````)
See *Sample 11* in the following link : [Tips - How to use Get-WinEvent efficiently](https://github.com/myusefulrepo/Tips/blob/master/Tips%20-%20How%20to%20use%20get-WinEvent%20efficiently.md)


> Nota : You should notice that, in the previous code, I'm using Get-Date with parameters to avoid language issues.

## References

> [events to monitor](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor)
> [enable active directory security auditing](https://www.lepide.com/how-to/enable-active-directory-security-auditing.html)
> [Tips-Useful Events to Monitor for Security Reasons](https://github.com/myusefulrepo/Tips/blob/master/Tips-%20Useful%20Events%20to%20Monitor%20for%20Security%20Reasons.ps1)
> [how to detect changes to organizational units and groups in active directory](https://www.netwrix.com/how_to_detect_changes_to_organizational_units_and_groups_in_active_directory.html?cID=70170000000kgFh)
>[how to detect who modified security permission](https://www.netwrix.com/how_to_detect_who_modified_security_permission.html?cID=70170000000kgFh)
>[how to monitor ad group membership changes](https://www.netwrix.com/how_to_monitor_ad_group_membership_changes.html?cID=70170000000kgFh)
> [active-directory change audit events](https://morgantechspace.com/2013/08/active-directory-change-audit-events.html)
> [event id 5136 ad object change audit event](https://morgantechspace.com/2013/11/event-id-5136-ad-object-change-audit-event.html)
> [event 4672 special logon](https://morgantechspace.com/2013/10/event-4672-special-logon.html)
> [how to enable active directory-change](https://morgantechspace.com/2013/08/how-to-enable-active-directory-change.html)
>
