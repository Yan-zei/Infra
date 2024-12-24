<#
Retrive Object ID for hybrid joined Devices Name from Enta ID
#>


# Connect to Microsoft Graph (run this interactively first time)
Connect-MgGraph -Scopes "Device.Read.All"

# Read device names from CSV
$devices = Import-Csv -Path "C:\Users\hayyanz\OneDrive - Lovisa Pty Ltd\Documents\Bitlocker\Intune-Devices\DeviceName-CSV.csv"

# Create an array to store results
$results = @()

# Process each device
foreach ($device in $devices) {
    $deviceName = $device."Device Name"  # Adjust column name if different

    # Query for the device in Entra ID
    $entryDevices = Get-MgDevice -Filter "displayName eq '$deviceName'" -Property "Id,DisplayName,TrustType,ProfileType" -All

    # Check for hybrid joined devices
    $hybridDevices = $entryDevices | Where-Object { $_.TrustType -eq 'ServerAd' -and $_.ProfileType -eq 'RegisteredDevice' }

    if ($hybridDevices) {
        foreach ($hybridDevice in $hybridDevices) {
            $results += [PSCustomObject]@{
                DeviceName = $deviceName
                ObjectId = $hybridDevice.Id
            }
        }
    } else {
        $results += [PSCustomObject]@{
            DeviceName = $deviceName
            ObjectId = "Not found or not hybrid joined"
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path "C:\Users\hayyanz\Downloads\test32.csv" -NoTypeInformation