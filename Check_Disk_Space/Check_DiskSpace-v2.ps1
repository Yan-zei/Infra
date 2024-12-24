#This script will check available disk space percentage on C: drive as per defined threshold to write to a log file
 
# Define the threshold percentage (e.g. 10 for 90%)
$thresholdPercentage = 10
# Retry logic
$retryCount = 5
$maxDelay = 600 # 600 seconds (10 minutes)
 
# Get the device name
$deviceName = $env:COMPUTERNAME
 
# Get the free space and total size on the C: drive
$disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
 
# Calculate the threshold in bytes based on the percentage
$thresholdBytes = $disk.Size * ($thresholdPercentage / 100)
 
# The path for the log file on the network share
$logFile = "\\Aueasthqfs01.lovisa.hq\DS_Report$\CheckDiskSpace\CheckDiskSpace.txt"
 
# Create a log entry with the device name and free space
$logEntry = "{0}, {1}GB free ({2}% free)" -f $deviceName, [math]::Round($disk.FreeSpace / 1GB, 2), [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
 
 
for ($i = 1; $i -le $retryCount; $i++) {
    try {
        # Check if the free space is less than or equal to the threshold
        if ($disk.FreeSpace -le $thresholdBytes) {
            # Check if the file exists and if the computer name is already in the file
            $newEntryAdded = $false
            if (Test-Path $logFile) {
                $existingEntries = Get-Content $logFile
                if ($existingEntries -notcontains $logEntry) {
                    # Append the result to the file if it does not already exist
                    Add-Content -Path $logFile -Value $logEntry
                    $newEntryAdded = $true
                }
            } else {
                # Create the file and write the result if the file does not exist
                $logEntry | Out-File -FilePath $logFile
                $newEntryAdded = $true
            }
        } else {
            # If the free space is above the threshold, remove the device entry if it exists
            if (Test-Path $logFile) {
                $existingEntries = Get-Content $logFile
                if ($existingEntries -contains $logEntry) {
                    # Remove the entry from the log file
                    $updatedEntries = $existingEntries | Where-Object { $_ -ne $logEntry }
                    if ($updatedEntries.Count -eq 0) {
                        # If there are no remaining entries, clear the log file
                        Clear-Content -Path $logFile
                    } else {
                        # Otherwise, update the log file with the remaining entries
                        $updatedEntries | Set-Content -Path $logFile
                    }
                }
            }
        }
 
        # If everything is successful, exit the loop
        Write-Output "File updated successfully."
        break
    } catch {
        $randomDelay = Get-Random -Minimum 1 -Maximum $maxDelay
        Write-Output "Attempt $i failed. Retrying in $randomDelay seconds..."
        Start-Sleep -Seconds $randomDelay
    }
}
 
if ($i -gt $retryCount) {
    Write-Output "Failed to update the file after $retryCount attempts."
}