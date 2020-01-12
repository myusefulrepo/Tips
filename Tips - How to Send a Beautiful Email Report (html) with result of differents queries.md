# How to send a beautiful report - html format - with the result of differents queries

To illustrate the methodogy, I'm using a simple sample.

## Step 1 : Query informations an put in a var

below it's a fictional sample. TO illustrate this, I'm puting the result of the query in a var like a Csv.

````powershell
$Query = @"
Item1, A
Item2, B
"@ | ConvertFrom-Csv
````

As you can see there are several value/key in my $query var

````powershell
$Query
Item1 A
----- -
Item2 B
````

## Step 2 : Unit treatment

Now, unit treatment for each pair Key/value in my $Query var

````powershell
$Body =@() # intialization of hash table array
$Body += foreach ($Item in $query)
{
 # do something and put the result in a [PSCustomObject]
 [PSCustomObject]@{
    Prop1 = "value1"
    Prop2 = "value2"
    Prop3 = "Value3"
 }
}
````

Each turn of the ````Foreach```` loop, I'm building a ````[PSCustomObject]```` and feed the result in a Var [Array] using ````+=````.

Here, named $Body because this represent the Body of our future mail report

Take a look on $Body Var

````powershell
$Body.GetType()
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Object[]                                 System.Array
````

As we can see, the $Body is an [Array]

## Step 3 - Preparing format for the mail

### Step 3.1 - Preparing Header

The header define some html properties is an internal CSS. This allow to have a beautiful html report. Customize it as you want.

````powershell
$Header = @"
<style>
TABLE { width: 100%; table-layout: fixed; border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse; }
TH { border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED; }
TD { border-width: 1px; padding: 3px; border-style: solid; border-color: black; }
column-count: 4;
column-gap: 40px;
</style>
"@
````

As you can see, the $Header is an Here-String

````powershell
$Header.gettype()
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     String                                   System.Object
````

### Step 3.2 : Preparing Splat to Send mail message

````powershell
$SendMailParams = @{
                    From = "it.admin@contoso.com"
                    To = "it.manager@contoso.com"
                    Subject = "Daily report"
                    Body = $Body
                    BodyAsHtml = $true
                    SmtpServer = "smtp.contoso.com"
                    }
````

A splat is a Hash table

````powershell
$SendMailParams.gettype()
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Hashtable                                System.Object
````

Why use Splat ? When and what info put in the Splat ?

- When there is more than 4 parameters  (mandatory or not)
- What : All commons parameters, mandatory or not, put them in a splat and pass specific value for one or more parameters out of the splat
- Why : a splat is easy to read and give short cmdline to use. Very practical and useful

## Step 4 : Send Mail Message report

### without Additional parameter

````powershell
Send-MailMessage @SendMailParams
````

### with Additional parameter (s)

````powershell
Send-MailMessage @SendMailParams -Cc "additionalUser.contoso.com"
````
