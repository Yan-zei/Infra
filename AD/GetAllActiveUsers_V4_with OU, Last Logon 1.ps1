# Script to Fetch Active Users and their Name, Username, E-mail Add, Dept, Title, Country, Office, Manager, Manager's e-mail add, OU they're in, and Last Logon Details.

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the properties to retrieve, including LastLogonDate
$properties = "GivenName", "Surname", "DisplayName", "SamAccountName", "UserPrincipalName" , "EmailAddress", "Department", "Country", "Manager", "DistinguishedName", "Office", "LastLogonDate" , "title"

# Define the output file path
$outputFile = "C:\Temp\AD Dump\ActiveUsersWithDetails_23.12.24.csv"

# Get all active users
$allActiveUsers = Get-ADUser -Filter {Enabled -eq $true} -Property $properties

# Add OU information by extracting it from DistinguishedName
$allActiveUsers = $allActiveUsers | ForEach-Object {
    $ou = ($_.DistinguishedName -split ",") -match "^OU=" -join "/"
    $_ | Add-Member -NotePropertyName "OU" -NotePropertyValue $ou -Force -PassThru
}

# Add Line Manager information including their email address
$allActiveUsers = $allActiveUsers | ForEach-Object {
    if ($_.Manager) {
        $manager = Get-ADUser -Identity $_.Manager -Property "EmailAddress"
        $_ | Add-Member -NotePropertyName "LineManager" -NotePropertyValue $manager.SamAccountName -Force
        $_ | Add-Member -NotePropertyName "LineManagerEmailAddress" -NotePropertyValue $manager.EmailAddress -Force
    } else {
        $_ | Add-Member -NotePropertyName "LineManager" -NotePropertyValue "" -Force
        $_ | Add-Member -NotePropertyName "LineManagerEmailAddress" -NotePropertyValue "" -Force
    }
    $_
}

# Select required properties including LastLogonDate
$exportData = $allActiveUsers | Select-Object GivenName, Surname, DisplayName, SamAccountName, UserPrincipalName, EmailAddress, Department, Title, Country, Office, LineManager, LineManagerEmailAddress, OU, LastLogonDate

# Export to CSV file
$exportData | Export-Csv -Path $outputFile -NoTypeInformation

Write-Output "Export completed. The file is located at $outputFile"
