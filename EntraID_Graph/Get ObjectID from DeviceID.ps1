<#used to get corresponding ObjectID for each DeviceID from Entra ID
Sample Input CSV (device_ids.csv)
DeviceID
12345678-xxxx-xxxx-xxxx-xxxxxxxxxxxx
abcdefgh-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#>
# Import the Microsoft.Graph module
Import-Module Microsoft.Graph

# Step 1: Install and import the Microsoft.Graph module if not done already
# Install-Module Microsoft.Graph -Scope CurrentUser -AllowClobber

# Step 2: Authenticate to Microsoft Graph
Connect-MgGraph -Scopes "Device.Read.All"

# Step 3: Import the CSV containing device IDs (modify path as needed)
$inputCsv = "C:\Users\hayyanz\Downloads\toadd.csv"
$outputCsv = "C:\Users\hayyanz\Downloads\updated_devices.csv"

$deviceIds = Import-Csv -Path $inputCsv

# Step 4: Initialize an array to store the results
$results = @()

# Step 5: Loop through each device ID, get corresponding object ID, and add to the results
foreach ($device in $deviceIds) {
    try {
        # Search for the device by device ID or another attribute like registrationId or displayName
        $deviceDetails = Get-MgDevice -Filter "deviceId eq '$($device.DeviceID)'"

        # If the device exists, store the device ID and Object ID
        if ($deviceDetails) {
            $results += [PSCustomObject]@{
                DeviceID  = $device.DeviceID
                ObjectID  = $deviceDetails.Id
            }
        } else {
            Write-Warning "Device ID $($device.DeviceID) not found"
            $results += [PSCustomObject]@{
                DeviceID  = $device.DeviceID
                ObjectID  = "Not Found"
            }
        }
    }
    catch {
        # Handle any errors (e.g., if a device is not found)
        Write-Warning "Error retrieving device ID $($device.DeviceID): $_"
        $results += [PSCustomObject]@{
            DeviceID  = $device.DeviceID
            ObjectID  = "Error"
        }
    }
}

# Step 6: Export the results to a new CSV
$results | Export-Csv -Path $outputCsv -NoTypeInformation

# Step 7: Optionally, disconnect from Microsoft Graph
Disconnect-MgGraph