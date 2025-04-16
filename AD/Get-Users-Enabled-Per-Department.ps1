# Active Directory who belong to certain departments but not others (enabled accounts only)

# Define the departments to include and exclude
$includeDepartments = @("Finance", "Leasing")   # Replace with the departments you want to include
$excludeDepartments = @("Service_Account", "Store")   # Replace with the departments you want to exclude

# Create an array to store user information
$userList = @()

# Get users in the included departments but not in the excluded departments and only active accounts
Get-ADUser -Filter {Enabled -eq $true} -Property GivenName,Surname,DisplayName,Mail,Department,Manager,PhysicalDeliveryOfficeName,City,Country | Where-Object {
    $includeDepartments -contains $_.Department -and
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
$userList | Export-Csv -Path "C:\temp\hz\TodayUsersList.csv" -NoTypeInformation

# Output to console (optional)
$userList
