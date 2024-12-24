# Import Active Directory module
Import-Module ActiveDirectory

# Get disabled users
$disabledUsers = Get-ADUser -Filter 'Enabled -eq $false'

# Output the list of disabled users
Write-Host "List of Disabled Users:"
$disabledUsers | Select-Object Name, UserPrincipalName, DistinguishedName | Format-Table

# Output the total count of disabled users
Write-Host "Total Number of Disabled Users: $($disabledUsers.Count)"