# Import the Active Directory module
Import-Module ActiveDirectory

# Define the security group name
$groupName = "GLO_PERM_IT_Servicedesk"

# Get the members of the security group
$members = Get-ADGroupMember -Identity $groupName

# Check if any members were found
if ($members -eq $null -or $members.Count -eq 0) {
    Write-Host "No members found in the group: $groupName"
    exit
}

# Filter out only the enabled user accounts
$enabledUsers = $members | Where-Object { $_.objectClass -eq 'user' } | Get-ADUser -Property Enabled | Where-Object { $_.Enabled -eq $true }

# Check if any enabled users were found
if ($enabledUsers -eq $null -or $enabledUsers.Count -eq 0) {
    Write-Host "No enabled users found in the group: $groupName"
    exit
}

# Select the desired properties and export to CSV
$enabledUsers | Select-Object Name, SamAccountName, Enabled | Export-Csv -Path "C:\temp\hz\$groupName-enabled_users.csv" -NoTypeInformation

Write-Host "Export completed. Enabled users have been saved to C:\path\to\export\enabled_users.csv"
