<# a script which gets all the details of all devices in an Azure AD Entra ID dynamic group
and save results to a file which is named same as group name
#>

# Define Variables
$groupName = "GRP-Intune-Device-Pilot"
$outputFolder = "C:\Users\hayyanz\OneDrive - Lovisa Pty Ltd\Documents\WIP\Device-Cleanup"

# Import required module
Import-Module Microsoft.Graph.DeviceManagement
Import-Module Microsoft.Graph.Groups 
# Authenticate and connect to Microsoft Graph
Connect-MgGraph -Scopes "Device.Read.All", "Group.Read.All"
 
# Get the group name and ID

$group = Get-MgGroup -Filter "displayName eq '$groupName'"
 
# Check if the group exists
if ($null -eq $group) {
    Write-Host "Group not found"
    exit
}
 
# Get all devices in the group
$devices = Get-MgGroupMember -GroupId $group.Id -All # -ExpandProperty device
 
# Define the output file location and name

$outputFile = Join-Path -Path $outputFolder -ChildPath "$($group.DisplayName).csv"
 
# Initialize an array to store device details
$deviceDetails = @()
 
# Retrieve details of all devices in the group
foreach ($device in $devices) {
   #  $deviceDetail = Get-MgDeviceManagementManagedDevice -AzureAdDeviceId $device.AzureAdDeviceId
    $deviceDetail = Get-MgDevice -All -DeviceId $device.Id
    

    # $activity = Get-MgDevice -DeviceId $device.Id | Select-Object Id, OperatingSystem, OperatingSystemVersion, ApproximateLastSignInDateTime
 
    # Store the device details in the array
    $deviceDetails += [pscustomobject]@{
        
        DeviceName = $deviceDetail.DisplayName
        DeviceId = $deviceDetail.Id
        OperatingSystem = $deviceDetail.OperatingSystem
        OSVersion = $deviceDetail.OperatingSystemVersion
        Model = $deviceDetail.Model
        TrustType =$deviceDetail.TrustType
        DdeviceOwnership = $deviceDetail.deviceOwnership
        ComplianceState = $deviceDetail.ComplianceState
        IsManaged = $deviceDetail.IsManaged
        RegistrationDateTime = $deviceDetail.RegistrationDateTime
        ApproximateLastSignInDateTime = $deviceDetail.ApproximateLastSignInDateTime
        OnPremisesLastSyncDateTime = $deviceDetail.OnPremisesLastSyncDateTime
        # LastSyncDateTime = $deviceDetail.LastSyncDateTime
       # SerialNumber = $deviceDetail.SerialNumber
        # UserDisplayName = $deviceDetail.UserDisplayName
        # UserPrincipalName = $deviceDetail.UserPrincipalName
       # TrustType = $deviceDetail.trustType
        ProfileType = $deviceDetail.profileType
        EnrollmentType = $deviceDetail.enrollmentType
       # LastSignIn     = $activity.ApproximateLastSignInDateTime

              
        
       # onPremisesSecurityIdentifier = $deviceDetail.onPremisesSecurityIdentifier
       # deviceCategory = $deviceDetail.deviceCategory

   
    }
}
 
# Export the device details to a CSV file
$deviceDetails | Export-Csv -Path $outputFile -NoTypeInformation -Force
$deviceDetails | out-gridview 
Write-Host "Device details saved to $outputFile"

