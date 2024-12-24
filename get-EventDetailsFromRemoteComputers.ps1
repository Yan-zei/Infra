<#
 -need the following to be enabled on remote Firewall:
RPC TCP 135
Windows Management Instrumentation
Remote Event Log Management (RPC)

 -Ensure Services are listening / running use the following command
get-service -name "rpcSs", "Winrm"

 -Enable-PSRemoting -Force on remote computers
 ensure WinRM is configured on both local and remote computers, the above command should enable it as well.
 winrm quickconfig
  #>

# Define the list of servers
$servers = @("LOVIPDC", "LV-INT-DC01", "LV-INT-DC02", "LOVISDC", "ZANORTHCMDC01", "AUEASTCMDC01", "EUWESTCMDC01", 
"USWEST3CMDC01", "CNNORTH3CMDC01", "LOVISAUS-DC01", "LOVISAUK-DC01", "LOVISAZA-DC01") # server names

$eventId = 4720 # Replace with the event ID you are looking for
$logName = "Security" # Replace with the log name, e.g., System, Application, Security

 # Calculate the start date for the past 30 days
$startDate = (Get-Date).AddDays(-2)

# Define the output file path
$outputFile = "C:\Temp\hz\EventDetails.txt"
 
# Ensure the output directory exists
$outputDir = [System.IO.Path]::GetDirectoryName($outputFile)
if (-not (Test-Path -Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
}
 
# Initialize the output file
"" | Out-File -FilePath $outputFile
 
  
# Loop through each server
foreach ($server in $servers) {
    try {
        Write-Host "Processing server: $server"
 
        # Get the events with the specified Event ID and time range
        $events = Get-WinEvent -ComputerName $server -FilterHashtable @{LogName=$logName; Id=$eventId; StartTime=$startDate} -ErrorAction Stop
 
        if ($events) {
            foreach ($event in $events) {
                # Get general information about the event
                $eventDetails = @"
Server: $server
Event ID: $($event.Id)
Log Name: $($event.LogName)
Level: $($event.LevelDisplayName)
Time Created: $($event.TimeCreated)
Message: $($event.Message)
"@
 
                # Write the event details to the output file
                $eventDetails | Out-File -FilePath $outputFile -Append
            }
        } else {
            Write-Host "No events found with ID $eventId on server $server in the past 30 days."
        }
    } catch {
        Write-Host "Error processing server ${server}: $_"
        "Error processing server ${server}: $_" | Out-File -FilePath $outputFile -Append
    }
}
 
Write-Host "Script execution completed. Event details saved to $outputFile."