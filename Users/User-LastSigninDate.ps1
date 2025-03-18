# Sign in to Microsoft Graph
# Connect-MgGraph -Scopes "User.Read.All", "SignIn.Read.All"
Connect-MgGraph -Scopes Directory.Read.All,AuditLog.Read.All

# Import the list of users from CSV
$users = Import-Csv -Path "C:\Temp\HZ\Microsoft_365_E3_Users.csv"

# Initialize an array to store the results
$results = @()

# Loop through each user in the CSV
foreach ($user in $users) {
    try {
        # Get user details using ObjectId
        $userDetails = Get-MgUser -UserId $user.ObjectId -Property SignInActivity
        
        # Get the Last Successful Sign-In DateTime
        $lastSignInDate = $userDetails.SignInActivity.LastSuccessfulSignInDateTime

        # Add the result to the array
        $results += [PSCustomObject]@{
            UserPrincipalName = $userDetails.UserPrincipalName
            LastSignInDate = $lastSignInDate
        }
    } catch {
        Write-Host "Error fetching data for ObjectId $($user.ObjectId): $_"
        # If there's an error, you can still log the user with "No data"
        $results += [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            LastSignInDate = "Error"
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\Temp\HZ\Microsoft_365_E3_Userss_last_signins.csv" -NoTypeInformation
Write-Host "Results saved to 'user_last_signins.csv'"


<#The Following works for one user - use for testing

Connect-MgGraph -Scopes Directory.Read.All,AuditLog.Read.All
Get-MgUser -UserId "af802f3a-d27f-43de-a076-3858173a60cd" -Property SignInActivity | Select-Object UserPrincipalName, @{Name="LastSignInDate"; Expression={$_.SignInActivity.LastSuccessfulSignInDateTime}}
>#