# Import the necessary modules
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Az.Accounts
 
# Authentication
$tenantId = "25895aa9-6a44-43ca-ad03-47a69d0945c3"
$clientId = "429dee45-d650-4709-8ab6-ac00b5b16d65"
$clientSecret = "Kby8Q~XrmwF4zONMfqbLVOuuihAOJygiLoufcagm"
 
# Authenticate to Microsoft Graph
$graphScopes = @("https://graph.microsoft.com/.default")
$authParams = @{
    TenantId        = $tenantId
    ClientId        = $clientId
    ClientSecret    = $clientSecret
    Scopes          = $graphScopes
    Authority       = "https://login.microsoftonline.com/$tenantId"
}
$token = Get-MgGraphAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $clientSecret -Scopes $graphScopes
Connect-MgGraph -AccessToken  ($token.Token | ConvertTo-SecureString -AsPlainText -Force)
  
# Define the group IDs
$groupIds = @("c684bddf-d8ab-4720-ba80-c57b4ba4649d", "69ef87b9-be87-45e0-b401-a3638821d1ab")
 
# Initialize the email body
$emailBody = "The following are the members of the HR-APAC security groups:<br><br>"
 
# Loop through each group
foreach ($groupId in $groupIds) {
    # Get the group details
    $group = Get-MgGroup -GroupId $groupId
    $emailBody += "<b>Group: $($group.DisplayName)</b><br>"
    
    # Get the members of the group
    $members = Get-MgGroupMember -GroupId $groupId -All
    foreach ($member in $members) {
        if ($member.AdditionalProperties['userPrincipalName']) {
            $emailBody += "$($member.DisplayName) ($($member.AdditionalProperties['userPrincipalName']))<br>"
        }
    }
    $emailBody += "<br>"
}
 
# Send the email using Office 365 SMTP
$smtpServer = "smtp.office365.com"
$smtpFrom = "hayyanz@lovisa.com"
$smtpTo = "hayyanz@lovisa.com"
$messageSubject = "Azure HR-APAC Security Group Members"
$smtpUsername = "hayyanz@lovisa.com"
$smtpPassword = "kgk#"
 
# Create the email message
$message = New-Object system.net.mail.mailmessage
$message.from = $smtpFrom
$message.To.Add($smtpTo)
$message.Subject = $messageSubject
$message.Body = $emailBody
$message.IsBodyHtml = $true
 
# Create the SMTP client and send the email
$smtp = New-Object Net.Mail.SmtpClient($smtpServer, 587)
$smtp.EnableSsl = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($smtpUsername, $smtpPassword)
$smtp.Send($message)
 