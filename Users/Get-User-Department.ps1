# Import the Active Directory module (if not already imported)
Import-Module ActiveDirectory

# Query users where the department is "Warehouse"
$users = Get-ADUser -Filter {Department -eq "Warehouse"} -Properties Department

# Display the results
$users | Select-Object SamAccountName, Name, Department | Format-Table

# Export the results to a CSV file
$users | Select-Object SamAccountName, Name, Department | Export-Csv -Path "C:\Temp\hz\Warehouse_Users.csv" -NoTypeInformation