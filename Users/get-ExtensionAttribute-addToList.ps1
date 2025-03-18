# Get Extenstion Attribute value for active users and append it to a csv list

# Import the Active Directory module (make sure it’s installed and available)
Import-Module ActiveDirectory

# Import the CSV with user data
$users = Import-Csv -Path "C:\Temp\hz\ActiveUsers-22.01.25v3.csv"

# Create a new list to store updated data
$updatedUsers = @()

# Loop through each user in the CSV
foreach ($user in $users) {
    # Get the user's SamAccountName (or another identifier)
    $samAccountName = $user.SamAccountName

    # Retrieve user info from AD, including msDS-cloudExtensionAttribute4 and Enabled status
    $adUser = Get-ADUser -Identity $samAccountName -Properties msDS-cloudExtensionAttribute4, Enabled

    # If the user is enabled, retrieve msDS-cloudExtensionAttribute4
    if ($adUser.Enabled) {
        # Retrieve the msDS-cloudExtensionAttribute4 value
        $cloudExtensionValue = $adUser."msDS-cloudExtensionAttribute4"

        # Add the msDS-cloudExtensionAttribute4 value as a new column to the user data
        $user | Add-Member -MemberType NoteProperty -Name "CloudExtensionAttribute4" -Value $cloudExtensionValue -Force

        # Add the updated user data to the list
        $updatedUsers += $user
    }
}

# Export the updated data to a new CSV file
$updatedUsers | Export-Csv -Path "C:\Temp\hz\ActiveUsers-updated.csv" -NoTypeInformation
