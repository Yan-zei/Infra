# Calculate the date for 10 days ago
$startDate = (Get-Date).AddDays(-10)

# Get events related to shutdowns and restarts from the last 10 days
$shutdownEvents = Get-WinEvent -LogName System | Where-Object {
    ($_.Id -eq 1074 -or $_.Id -eq 6006 -or $_.Id -eq 6005) -and $_.TimeCreated -ge $startDate
} | Select-Object TimeCreated, Id, Message

# Filter out the relevant information (ID 1074 for shutdown/reboot initiations)
$shutdownInitiators = $shutdownEvents | Where-Object { $_.Id -eq 1074 }

# Display the shutdown/reboot initiators
$shutdownInitiators | Format-Table TimeCreated, Id, Message
