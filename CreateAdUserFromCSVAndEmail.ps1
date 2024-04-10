# ERROR REPORTING ALL 
Set-StrictMode -Version latest 
Set-ExecutionPolicy Unrestricted 
#---------------------------------------------------------- 
# LOAD ASSEMBLIES AND MODULES 
#---------------------------------------------------------- 
Try 
{ 
Import-Module ActiveDirectory -ErrorAction Stop
Import-Module MSOnline -ErrorAction Stop

} 
Catch 
{ 
  Write-Host "[ERROR]`t Some Module(s) couldn't be loaded. Script will stop!" 
  Exit 1 
}

#---------------------------------------------------------
# Email Function to be called once user is created
#---------------------------------------------------------


Function email-user
{ 

     $ts = New-TimeSpan -Days 0 -Hours 2 -Minutes 00
     $loginTime = (get-date) + $ts
    
	$SmtpServer = 'smtp.office365.com'
	#$SmtpUser = 
	$MailtTo = $Email
	$MailFrom = 'noreply@DOMAIN.COM'
	$MailSubject = "Your account Details"
	$SmtpServer = 'smtp.office365.com'

$MessageBody =@"

Dear $firstname,<br/><br/>

Your new Account has been created. 
<br/><br/>

This account is used to login to services that are available in the company. 
For Example: Logging in to the PCs and Using the print facilities  
<br/><br/>
<br/><br/>
<b>
Please NOTE it can take up to 2 hours for your new account to be fully synchronized. We estimate that your account 
will be ready to use by: $loginTime
</b>
<br/><br/>
<br/><br/>
Your Username is: $UPN 
<br/><br/>

Your Password is your date of birth. DD/MM/YYYY  EG 31/01/1970 (Including the /  ) 
<br/><br/>
<br/><br/>


You can change your password after you have logged into a PC.
<br/><br/>
<br/><br/>




Disclaimer:<br/>
<br/><br/>
 <br/><br/>


<br/><br/>
"@
 

Send-MailMessage -To $MailtTo -from $MailFrom -Port 587 -Subject $MailSubject -BodyAsHtml $MessageBody -SmtpServer $SmtpServer -UseSsl -Credential $Credentials 

}

#-----------------------------
#IMPORT USER FROM CSV
#-----------------------------

$Credentials = Get-Credential -UserName "USERNAME"

$Users = Import-Csv -Path "rentalUserCreation.csv"            
foreach ($User in $Users)            
{            
    $Displayname = $User.Firstname + " " + $User.Lastname            
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname            
    $OU = $User.OU            
    $SAM = $User.SAM            
    $UPN = $User.Firstname + "." + $User.Lastname + "@" + $User.Maildomain            
    $Description = $User.Description            
    $DOB = $User.DOB
    $Email = $User.Email           
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $DOB -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $False -PasswordNeverExpires $false -server DC.DOMAIN.COM         

    email-user
}
