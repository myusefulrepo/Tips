In this short post, i would like to show you 4 different ways to to the same thing. Here, sending a mail with html body that report Volume informations

It's not my code, it's some code that I've found in Technet forums (answers to a question). Then, I made myself my analysis and ***my own opinion*** and i show it below


# The First way
```powershell
$Data = Get-Volume |
            Where-Object {
            $_.SizeRemaining -lt 10GB -and
            $_.DriveType -eq 'FIXED' -and
            $_.FileSystemLabel -notmatch 'System Reserved|Recovery'
            }|
            ConvertTo-Html
if($Data)
    {
    Send-MailMessage -To Recipient@something.com -From Sender@something.com -Body $Data -SmtpServer "SMTP SERVER" -Subject "Email Subject" -BodyAsHtml
    }
```
## let's look at the code
- Query Volume information, convert to html and put in a variable ($Data)
- If statement. If variable $Data is not équal to $null then send mail message with passing all needed parameters after the cmdlet.
> [!IMPORTANT]
> - The $Data variable can't be used for another use (cause html formated)
> - In If statement, the condition -ne $Null is implicit. It runs, but it's not obvious for all people (specially powershell beginners)
> - In Send-MailMessage statement, all needed parameters are passed directly. If a parameter must be modify, we must read code (and sometimes reading could be long) : It's not really a practical way

# The Second way
```powershell
$mailprops = @{
    To = 'Recipient@something.com'
    From = 'Sender@something.com'
    Subject = 'your email subject'
    SmtpServer = 'SMTP SERVER'
    BodyAsHtml = $true
}
if($data = Get-Volume |
            Where-Object {
            $_.SizeRemaining -lt 10GB -and
            $_.DriveType -eq 'FIXED' -and
            $_.FileSystemLabel -notmatch 'System Reserved|Recovery'
            })
    {
    $body = $data | ConvertTo-Html | Out-String
    Send-MailMessage @mailprops -Body $body
    }
```
## let's look at the code
- Prepare a hash table with all needed parameters to send a mail. Just common parameters
- If Statement. If variable $Data (processing Query Volume information) is not équal to $null then
    - prepare Message Body (convert to html)
    - send mail message with passing needed parameters with the previous splat
> [!IMPORTANT]
> - Preparing a splat for send mail message parameters, this makes the cmldet more readable
> - Processing the variable $Data directly in the If statement makes the cmdlet less readable
> - Separating the processing of the variable from its use (formatting) makes this first reusable
> - In If statement, the condition -ne $Null is implicit. It runs, but it's not obvious for all people (specially powershell beginners)

# The Third Way
```powershell
$mailprops = @{
    To = 'Recipient@something.com'
    From = 'Sender@something.com'
    Subject = 'your email subject'
    SmtpServer = 'SMTP SERVER'
    BodyAsHtml = $true
}
$data = Get-Volume |
    Where-Object {
        $_.SizeRemaining -lt 10GB -and
        $_.DriveType -eq 'FIXED' -and
        $_.FileSystemLabel -notmatch 'System Reserved|Recovery'
    }
if($data)
    {
    $body = $data | ConvertTo-Html | Out-String
    Send-MailMessage @mailprops -Body $body
    }
```
## let's look at the code
- Prepare a hash table with all needed parameters to send a mail. Just common parameters
- Processing the variable $Data (Query Volume information)
- If Statement. If variable $Data is not équal to $null then
    - prepare Message Body (convert to html)
    - send mail message with passing needed parameters with the previous splat
> [!IMPORTANT]
> - Preparing a splat for send mail message parameters, this makes the cmldet more readable
> - Processing the variable $Data, this make the variable $data reusable for different uses
> - In If statement, the condition -ne $Null is implicit. It runs, but it's not obvious for all people (specially powershell beginners)


# The fourth  Way
```powershell
$mailprops = @{
    To = 'Recipient@something.com'
    From = 'Sender@something.com'
    Subject = 'your email subject'
    SmtpServer = 'SMTP SERVER'
    BodyAsHtml = $true
}
$data = Get-Volume |
    Where-Object {
        $_.SizeRemaining -lt 10GB -and
        $_.DriveType -eq 'FIXED' -and
        $_.FileSystemLabel -notmatch 'System Reserved|Recovery'
    }
if($Null -ne $data)
    {
    $body = $data | ConvertTo-Html | Out-String
    Send-MailMessage @mailprops -Body $body
    }
```
## let's look at the code
- Prepare a hash table with all needed parameters to send a mail. Just common parameters
- Processing the variable $Data (Query Volume information)
- If Statement. If variable $Data is not équal to $null then
    - prepare Message Body (convert to html)
    - send mail message with passing needed parameters with the previous splat
> [!IMPORTANT]
> - Preparing a splat for send mail message parameters, this makes the cmldet more readable
> - Processing the variable $Data, this make the variable $data reusable for different uses
> - In If statement, the condition -ne $Null is explicit. It's really clear for everyone

> [!TIP]
> We can never repeat this enough :

> make reusable code :
>   - Use splating
>   - Separate processing from formatting

> what is implicit is not for everyone :
>    - Put all that is necessary to make the code obvious for everyone

and you, ***what is your own opinion ?***