# test SMTP Outbound server which uses TLS 1.2 or higher on port 587

# Define email parameters
$smtpServer = "your_smtp_server"
$fromAddress = "your_email_address"
$toAddress = "recipient_email_address"
$subject = "Test Email from PowerShell"
$body = "This is a test email sent from PowerShell"
$username = "your_email_username"
$password = "your_email_password"

# Set SSL/TLS protocols (TLS 1.2 or higher)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Define SMTP client settings
$smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, 587)
$smtpClient.EnableSsl = $true
$smtpClient.Credentials = New-Object System.Net.NetworkCredential($username, $password)

# Define mail message
$mailMessage = New-Object System.Net.Mail.MailMessage
$mailMessage.From = $fromAddress
$mailMessage.To.Add($toAddress)
$mailMessage.Subject = $subject
$mailMessage.Body = $body

try {
    # Send email
    $smtpClient.Send($mailMessage)
    Write-Host "Email sent successfully!"
} catch {
    Write-Host "Error sending email: $($Error[0].Message)"
    Write-Host "Error details: $($Error[0].Exception.InnerException.Message)"
}