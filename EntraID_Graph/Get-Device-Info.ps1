# Get device info from Entra ID using MS Graph 

Connect-Graph -Scopes 'Device.Read.All'


# Define the device name
$deviceName = "LOVIL-hJDGPEgzG"

# Retrieve the device information
$device = Get-MgDevice -Filter "displayName eq '$deviceName'"

# Display the device information
$device | Format-List *

