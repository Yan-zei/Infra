# Update Birthday Attribute, this updates immediately


# The scopes that will be needed to update the user information
$scopes = "User.Read.All", "Directory.ReadWrite.All", "Sites.FullControl.All"
 
# Connect to Microsoft Graph
Connect-MgGraph -Scopes $scopes

$userId = "hayyanz@lovisa.com"

# Prepare the body to send the new Birthdate
$params = @{
    Birthday = [System.DateTime]::Parse("11/10/1997")
   # HireDate = [System.DateTime]::Parse("1/12/2009")
}

# Update the user information
Update-MgUser -UserId $userId -BodyParameter $params

# Disconnect from Microsoft Graph
Disconnect-MgGraph

<# can retreive with MS Graph Explorer

https://graph.microsoft.com/v1.0/users/hayyanz@lovisa.com?$select=displayName,mail,id,jobTitle,extensions,birthday

#> 