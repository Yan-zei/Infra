# Read server names from a file
$serverNames = Get-Content -Path "c:\tem\LoviApps.txt"
 
# Function to get IP address from server name
function Get-IPFromHostname {
    param (
        [string]$hostname
    )
    
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($hostname) | Select-Object -First 1
        return $ip.IPAddressToString
    } catch {
        return "Error: Unable to resolve"
    }
}
 
# Resolve each server name to an IP address and output the results
foreach ($serverName in $serverNames) {
    $ipAddress = Get-IPFromHostname -hostname $serverName
    Write-Output "${serverName}: $ipAddress"
}