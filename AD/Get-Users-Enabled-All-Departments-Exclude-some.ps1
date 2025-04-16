 # Active Directory who belong to all departments excluding others (enabled accounts only)

# Define the departments to exclude
$excludeDepartments = @("Department3", "Department4")   # Replace with the departments you want to exclude

# Create an array to store user information
$userList = @()

# Get users, including those with blank departments, and exclude certain ones, and only active accounts
Get-ADUser -Filter {Enabled -eq $true} -Property GivenName,Surname,DisplayName,Mail,Department,Manager,PhysicalDeliveryOfficeName,City,Country | Where-Object {
    # Include users with any department, including blank ones, but exclude specific departments
    -not ($excludeDepartments -contains $_.Department)
} | ForEach-Object {
    $user = New-Object PSObject -property @{
        FirstName = $_.GivenName
        LastName = $_.Surname
        DisplayName = $_.DisplayName
        Email = $_.Mail
        UPN = $_.UserPrincipalName
        Department = $_.Department
        Manager = (Get-ADUser $_.Manager -Properties DisplayName).DisplayName
        Office = $_.PhysicalDeliveryOfficeName
        City = $_.City
        Country = $_.Country
    }
    $userList += $user
}

# Export the list to a CSV file
$userList | Export-Csv -Path "C:\UsersList.csv" -NoTypeInformation

# Output to console (optional)
$userList
