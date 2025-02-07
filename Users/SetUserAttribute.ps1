#Update an attribute from a csv in AD 
# Import the CSV file
$csvPath = "C:\Temp\hz\sampleimport.csv"  # Update with your actual CSV file path
$csvData = Import-Csv -Path $csvPath

# Loop through each row in the CSV
foreach ($row in $csvData) {
    $upn = $row.UPN
    $hireDate = $row.HireDate  # Updated to match the correct column name

    # Find the user in Active Directory by UPN
    $user = Get-ADUser -Filter {UserPrincipalName -eq $upn} -Properties msDS-cloudExtensionAttribute4

    # If the user exists, update msDS-cloudExtensionAttribute4
    if ($user) {
        # Update the hire date in msDS-cloudExtensionAttribute4
        Set-ADUser -Identity $user -Replace @{ "msDS-cloudExtensionAttribute4" = $hireDate }
        Write-Host "Updated hire date for $upn to $hireDate"
    } else {
        Write-Host "User with UPN $upn not found in Active Directory."
    }
}