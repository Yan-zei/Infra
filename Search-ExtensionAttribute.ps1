<#script to check if a specific extension attribute is populated for user accounts in AD

#>
# Import Active Directory module
Import-Module ActiveDirectory

# Define the attribute name to check
$attributeName = "msDS-cloudExtensionAttribute1"  # Replace with your attribute name

# Define the search filter (e.g., all user accounts)
$searchFilter = "ObjectClass -eq 'User'"

# Get all user accounts with the specified attribute populated
$usersWithAttribute = Get-ADUser -Filter $searchFilter -Properties $attributeName | 
    Where-Object {$_.$attributeName -ne $null}

# Get all user accounts without the specified attribute populated
$usersWithoutAttribute = Get-ADUser -Filter $searchFilter -Properties $attributeName | 
    Where-Object {$_.$attributeName -eq $null}

# Print results
Write-Host "Users with '$attributeName' populated:" -foregroundcolor "Green"
$usersWithAttribute | Select-Object Name, $attributeName | Format-Table

# Users with Attribute not set
<#
Write-Host "`nUsers without '$attributeName' populated:"
$usersWithoutAttribute | Select-Object Name | Format-Table
#>