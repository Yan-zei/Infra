#adding users to a Securty Group

# Define the path to the CSV file and the target security group
$csvPath = "C:\Temp\hz\Managers.csv"
$groupName = "GLO_PERM_UKG_Training_Manuals_RW"  # Replace with the name of your security group

# Import the CSV file containing email addresses or UPNs
$users = Import-Csv -Path $csvPath

# Loop through each user and add to the group
foreach ($user in $users) {
    $userUPN = $user.User  # Assumes the column is named 'User' (email/UPN)
    
    # Try to find the user in Active Directory
    try {
        # If you have UPNs (email addresses) in the CSV, you can use Get-ADUser to search for the UPN
        $userObject = Get-ADUser -Filter {UserPrincipalName -eq $userUPN} -ErrorAction Stop

        # Add the user to the security group
        Add-ADGroupMember -Identity $groupName -Members $userObject.SamAccountName
        Write-Host "Added $userUPN to $groupName"
    } catch {
        Write-Host "Error adding $userUPN "
    }
}
