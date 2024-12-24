<#
. WRITTEN BY
  Hayyan Zeini
. DESCRIPTION
  Inactive computers in Active Directory for X days, excluding POS OU and Computer name starting with 'POS'
. DATE
  19/06/2024
#>

# Import the Active Directory module
Import-Module ActiveDirectory
 
# Set the number of days to filter computers that have not logged in for more than X days
$daysInactive = 90
 
# Calculate the date that is X days ago from today
$inactiveDate = (Get-Date).AddDays(-$daysInactive)
 
# Function to extract OU from DistinguishedName
function Get-OU {
    param (
        [string]$DistinguishedName
    )
    $ou = ($DistinguishedName -split ',')[1..($DistinguishedName.Length)]
    return ($ou -join ',').TrimEnd(',')
}
 
# Define the OU to exclude
$excludedOU = "OU=POS"
 
# Query Active Directory for computers with a lastLogonTimestamp older than the inactive date, excluding names starting with 'POS' and those in the POS OU
$computers = Get-ADComputer -Filter * -Properties lastLogonTimestamp, DistinguishedName | Where-Object {
    $_.lastLogonTimestamp -ne $null -and
    ([datetime]::FromFileTime($_.lastLogonTimestamp) -lt $inactiveDate) -and
    ($_.Name -notlike "POS*") -and
    ($_.DistinguishedName -notlike "*$excludedOU*")
}
 
# Select the properties you want to export, including the OU
$selectedComputers = $computers | Select-Object Name, @{Name="LastLogonDate";Expression={[datetime]::FromFileTime($_.lastLogonTimestamp)}}, @{Name="OU";Expression={Get-OU $_.DistinguishedName}}
 
# Export the results to a CSV file
$selectedComputers | Export-Csv -Path "C:\Temp\InactiveComputers.csv" -NoTypeInformation
 
Write-Output "Export complete. The CSV file is saved at C:\Temp\InactiveComputers.csv"