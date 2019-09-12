# Here-String : use it to send automatic and personalized mails


# But what is a Here-String ? 
$Message=@"
Hello, this is your admin
Welcome to the Corp
Today we're showing you a Here-String.
"@

$Message | gm
<#
$Message | gm
   TypeName : System.String

Name             MemberType            Definition                                                                            
----             ----------            ----------                                                                            
Clone            Method                System.Object Clone(), System.Object ICloneable.Clone()                               
CompareTo        Method                int CompareTo
....
#>
$Message.GetType()
<#
$Message.GetType()

IsPublic IsSerial Name                                     BaseType                                                          
-------- -------- ----                                     --------                                                          
True     True     String                                   System.Object
#>

# as we can see, a Here-String is a [String]

<# 
We can notice that we can use the syntax @ "" @ or @ '' @ 
In the second case, as in any chain surrounded by simple quote,the variables are not interpreted.
#>

# So for what use (s)?
<#
Imagine that we want to send a personalized email to x people. It's boring to manually generate a body for the mail every time!
We could consider something like this
#>
$FirstName = "Michel"
$SupportCallNumber = " XX-XX-XX-XX-XX"
$Report = Get-Item -Path "C:\Temp\report.html"

$Message =@"
Bonjour $FirstName ! 

Vous trouverez ci-joint le rapport sur le parc machine en date du $($Report.CreationTime.ToShortDateString()) 

Si vous avez des questions sur ce dernier, vous pouvez appeler le support au $SupportCallNumber

Cordialement
L'équipe Admin Système
"@

<# 
It's clean, in text format, but it's clean.
We can then consider having a body in Html to allow more important enrichments
#>

### Determination of the Body for the mails
$HtmlBody = @"
<head>
<style type='text/css'>
body {
    font-family: Calibri
    p{color:blue;}
    }
</style>
</head>
<body>
<center><P>Bonjour $FirstName,</P></center>
<br>
<br><P>Vous trouverez ci-joint le rapport sur le parc machine en date du $($Report.CreationTime.ToShortDateString())</P>
<br>
<P> Si vous avez des questions sur ce dernier, vous pouvez appeler le support au $SupportCallNumber</P>
<br>
<center><P>Cordialement
<br>
<B>L'équipe Admin Système</B></center>
</body>  
"@
# Note the internal css in the HEAD (minima in this case)
# At the beginning of the script we will also define the variables.
$From       = "sender@domain.com"
$To         = "Dest1@domain.com", "Dest2@domain.com"
$Cc         = "AdminGroup@domain.com"
$HtmlBody   = $HtmlBody
$SmtpServer = "smtp.domain.com"
$priority   = "normal"
$Encoding   = "UTF8"
$Subjet = "Computers Asset Report in date of $Date"
# Preparing a Hash table for mail parameters
$SendMailMessageParams = @{
    From         = $From 
    To           = $To 
    Cc           = $Cc 
    Body         = $HtmlBody 
    SmtpServer   = $SmtpServer 
    Priority     = $priority 
    Encoding     = $Encoding 
    Subject      = $Subjet 
    BodyAsHtml   = $true
}
Send-MailMessage @SendMailMessageParams

<# 
Another example of use
Here we will have a here-string with different values separated by a comma
we'll convert the Here-String to hash table with convert-FromCsv, and paste it into a variable
We will specify the Headers to use
then we will use a mail body template incorporating variables
#>
$InfoUsers =  @' 
DomainScripto,UserID,ContosoJSmith,Fabrikam
toto,UserID,Contosototo,Fabrikam
'@ | ConvertFrom-Csv -Delimiter "," -Header "username", "userid", "password", "office"
$template = @"
Hello and welcome to Contoso {0} ! 
Your user id on the system will be {1} with a Temporary Password of {2} and your home Office is in {3}. 
You can be reached at $PhoneNumber. If you have any issues with your setup you can call 425-555-1111 in order to reach the Help desk. 

Thanks!
Your Friendly Neighborhood It Department
"@
# finally we make our loop foreach to send to each his personalized mail
foreach ($item in $InfoUsers)
    { 
    $SendMailMessageParams = @{
    From         = $From 
    To           = $To 
    Cc           = $Cc 
    Body         = $letter 
    SmtpServer   = $SmtpServer 
    Priority     = $priority 
    Encoding     = $Encoding 
    Subject      = $Subjet 
    BodyAsHtml   = $false
}
    $letter = $template -f $item.username, $item.useriduserid, $item.passwordpassword, $item.office
    Send-MailMessage @SendMailMessageParams -Body
    }

<# 
largely inspired by:
Source : https://devblogs.microsoft.com/scripting/maximizing-the-power-of-here-string-in-powershell-for-configuration-data/
#>
