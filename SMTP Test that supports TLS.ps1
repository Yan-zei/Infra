#Edit the below From and To field, then when run, enter the credentials of teh sending account


$creds = get-credential

Send-MailMessage –From lovisaapps@lovisa.com –To chrisp@lovisa.com –Subject "Powershell Check at 11:22am" –Body "Test SMTP Service from Powershell on Port 587" -SmtpServer smtp.office365.com -Credential $creds -UseSsl -Port 587