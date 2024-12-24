#(v4) (16.08.24) Updated script, which will modify the existing entry if needed if there's any change in DiskSpace.

# Define the threshold percentage (e.g. 90 for 90%)
$thresholdPercentage = 10
# Retry logic
$retryCount = 5
$maxDelay = 600 # 10 seconds

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
        # Read existing entries from the log file
        $existingEntries = if (Test-Path $logFile) { Get-Content $logFile } else { @() }

        # Initialize the updated entries array
        $updatedEntries = @()

        if ($disk.FreeSpace -le $thresholdBytes) {
            # Update existing entries or add new entry
            $entryUpdated = $false
            foreach ($entry in $existingEntries) {
                if ($entry -like "$deviceName,*") {
                    # Replace existing entry
                    $updatedEntries += $logEntry
                    $entryUpdated = $true
                } else {
                    $updatedEntries += $entry
                }
            }
            if (-not $entryUpdated) {
                # Add new entry if not updated
                $updatedEntries += $logEntry
            }
        } else {
            # Remove the device entry if it exists
            foreach ($entry in $existingEntries) {
                if ($entry -notlike "$deviceName,*") {
                    $updatedEntries += $entry
                }
            }
        }

        # Write the updated entries to the log file
        if ($updatedEntries.Count -eq 0) {
            # If there are no remaining entries, clear the log file
            Clear-Content -Path $logFile
        } else {
            $updatedEntries | Set-Content -Path $logFile
        }

        # If everything is successful, exit the loop
        Write-Output "File updated successfully."
        break
    } catch {
        Write-Output "Attempt $i failed with error: $_"
        $randomDelay = Get-Random -Minimum 1 -Maximum $maxDelay
        Write-Output "Retrying in $randomDelay seconds..."
        Start-Sleep -Seconds $randomDelay
    }
}

if ($i -gt $retryCount) {
    Write-Output "Failed to update the file after $retryCount attempts."
}
