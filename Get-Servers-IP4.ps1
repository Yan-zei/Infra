# Import necessary modules
Import-Module ActiveDirectory
Import-Module DnsClient

# Define DNS server to query (optional, defaults to local system's DNS)
$dnsServer = "10.216.128.5"  # Uncomment and specify if needed

# Define output CSV file path
$outputCsv = "C:\Temp\hz\server_ips.csv"

# Get all servers from Active Directory
$servers = Get-ADComputer -Filter 'OperatingSystem -like "*Server*"' -Properties Name, DNSHostName

# Create an empty array to store results
$serverIpResults = @()

foreach ($server in $servers) {
    # Resolve DNS hostname to IP addresses
    $ipAddresses = Resolve-DnsName -Name $server.DNSHostName -Server $dnsServer -Type A -ErrorAction SilentlyContinue
    
    # Extract IP addresses from DNS response
    $ips = @()
    foreach ($ipAddress in $ipAddresses) {
        $ips += $ipAddress.IPAddress
    }
    
    # Create custom object to store server name and IP addresses
    $result = [PSCustomObject]@{
        ServerName = $server.Name
        IPAddresses = ($ips -join ";")
    }
    
    # Add result to array
    $serverIpResults += $result
}

# Export results to CSV
$serverIpResults | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Host "Results saved to $outputCsv"