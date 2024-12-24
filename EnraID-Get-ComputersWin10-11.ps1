<# a list of EntraID computers which
os is Windows 10 or windows 11
hybrid joined and activity or last logon time stamp is more than inactive days threshold
#>


# Parameters
$daysInactive = 20
$dateThreshold = (Get-Date).AddDays(-$daysInactive)
$outputFile = "C:\Users\hayyanz\OneDrive - Lovisa Pty Ltd\Documents\Scripts\Infra\Devices\EntraID-InactiveDevices90.csv"

# Import required module
Import-Module Microsoft.Graph.DeviceManagement
Import-Module Microsoft.Graph.Groups 
 
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
Connect-MgGraph -Scopes "Device.Read.All", "Group.Read.All"
 
# Get all devices that are Windows 10 or Windows 11 and hybrid joined
$devices = Get-MgDevice -Filter "operatingSystem eq 'Windows 10' or operatingSystem eq 'Windows 11'" -All
 
# Create an array to store the results
$results = @()
 
foreach ($device in $devices) {
    # Exclude devices with names that start with "POS"
    if ($device.DisplayName -like "POS*") {
        continue
    }
 
    # Get device activity details
    $activity = Get-MgDevice -DeviceId $device.Id | Select-Object Id, OperatingSystem, OperatingSystemVersion, ApproximateLastSignInDateTime
 
    # Get the device owner (UPN)
    $owners = Get-MgDeviceOwner -DeviceId $device.Id | Select-Object UserPrincipalName
 
    # Check if the device is hybrid joined and inactive
    if ($device.DeviceTrustType -eq "ServerAD" -and $activity.ApproximateLastSignInDateTime -lt $dateThreshold) {
        $results += [PSCustomObject]@{
            DeviceId              = $device.Id
            OperatingSystem       = $device.OperatingSystem
            OSVersion             = $device.OperatingSystemVersion
            LastSignIn            = $activity.ApproximateLastSignInDateTime
            OwnerUPN              = $owners.UserPrincipalName -join ", "
        }
    }
}
 
# Save the results to a CSV file
$results | Export-Csv -Path $outputFile -NoTypeInformation
 
Write-Host "Results saved to $outputFile"