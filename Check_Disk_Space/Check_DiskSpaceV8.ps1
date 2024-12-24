#v8
#New Version (08/10/2024)
# Checks the free disk space.
# Locks the file for writing when needed to avoid simultaneous writes.
# Adds/updates/removes the entry based on whether the device's disk space is below or above the threshold.
# Unlocks the file once the operation is complete to allow other devices to access it.

# Define the threshold percentage (e.g., 90% means if free space is less than 10%, it triggers action)
$thresholdPercentage = 10

# Get the device name
$deviceName = $env:COMPUTERNAME

# Get the free space and total size on the C: drive
$disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"

# Calculate the threshold in bytes based on the percentage
$thresholdBytes = $disk.Size * ($thresholdPercentage / 100)

# Path for the log file on the network share
$logFile = "\\Aueasthqfs01\pos_roqqio$\Test_DiskCheck_Kaartik\CheckDiskSpace_07.10_New.txt"

# Proper formatting for the log entry
$freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
$freeSpacePercentage = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)

# Properly formatted log entry
$logEntry = "$deviceName, $freeSpaceGB GB free ($freeSpacePercentage% free)"

# File locking mechanism
$lockFile = $logFile + ".lock"

function Lock-File {
    while (Test-Path $lockFile) {
        Start-Sleep -Milliseconds 100
    }
    New-Item -Path $lockFile -ItemType File -Force
}

function Unlock-File {
    Remove-Item -Path $lockFile -Force
}

# Function to update the log file
function Update-LogFile {
    Lock-File
    try {
        $existingEntries = Get-Content -Path $logFile -Encoding UTF8 | Where-Object { $_ -ne "" } # Remove empty lines
        
        $entryExists = $existingEntries | Where-Object { $_ -match "^$deviceName" }
        
        if ($entryExists) {
            # Update the entry if disk space has changed
            $updatedEntries = $existingEntries | ForEach-Object {
                if ($_ -match "^$deviceName") {
                    $logEntry
                } else {
                    $_
                }
            }
            $updatedEntries | Set-Content -Path $logFile -Encoding UTF8
        } else {
            # Append the new entry if it doesn't exist
            Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
        }
    } finally {
        Unlock-File
    }
}

# Function to remove the entry from the log file
function Remove-LogEntry {
    Lock-File
    try {
        $existingEntries = Get-Content -Path $logFile -Encoding UTF8 | Where-Object { $_ -ne "" } # Remove empty lines

        $updatedEntries = $existingEntries | Where-Object { $_ -notmatch "^$deviceName" }
        
        if ($updatedEntries.Count -eq 0) {
            # Clear the log file if no entries are left
            Clear-Content -Path $logFile
        } else {
            # Otherwise, update the log file with the remaining entries
            $updatedEntries | Set-Content -Path $logFile -Encoding UTF8
        }
    } finally {
        Unlock-File
    }
}

# Check if the free space is below or equal to the threshold
if ($disk.FreeSpace -le $thresholdBytes) {
    # Check if the log file exists, and update or add the entry
    if (-not(Test-Path $logFile)) {
        # Create the file and write the result if the file doesn't exist
        $logEntry | Out-File -FilePath $logFile -Encoding UTF8
    } else {
        Update-LogFile
    }
} else {
    # If the free space is above the threshold, remove the device entry if it exists
    if (Test-Path $logFile) {
        Remove-LogEntry
    }
}
