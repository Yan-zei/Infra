#PowerShell script that checks the disk space on the C drive, exports the names of machines below the specified threshold to a text file on a network file share
#Basic Version (4.11.2024)

# Define the threshold percentage (e.g., 10 for 10%)
$thresholdPercentage = 10

# Get the device name
$deviceName = $env:COMPUTERNAME

# Get the free space and total size on the C:
$disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"

# Calculate the threshold in bytes based on the percentage
$thresholdBytes = $disk.Size * ($thresholdPercentage / 100)

# Path for the log file and the lock file on the network share
$logFile = "\\Aueasthqfs01.lovisa.hq\DS_Report$\CheckDiskSpace\CheckDiskSpace.log"
$lockFile = "\\Aueasthqfs01.lovisa.hq\DS_Report$\CheckDiskSpace\CheckDiskSpace.lock"

# Check if the free space is less than or equal to the threshold
if ($disk.FreeSpace -le $thresholdBytes) {
    # Create a log entry with the device name and free space
    $logEntry = "{0}, {1}GB free ({2}% free)" -f $deviceName, [math]::Round($disk.FreeSpace / 1GB, 2), [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)
    
    # Wait until the lock file is available (avoid simultaneous access)
    while (Test-Path $lockFile) {
        Start-Sleep -Milliseconds 500  # Adjust the sleep time as needed
    }

    # Create the lock file to indicate the script is writing
    New-Item -Path $lockFile -ItemType File -Force | Out-Null

    try {
        # Check if the file exists and if the computer name is already in the file
        if (Test-Path $logFile) {
            $existingEntries = Get-Content $logFile
            if ($existingEntries -notcontains $logEntry) {
                # Append the result to the file if it does not already exist
                Add-Content -Path $logFile -Value $logEntry
            }
        } else {
            # Create the file and write the result if the file does not exist
            $logEntry | Out-File -FilePath $logFile
        }
    }
    finally {
        # Remove the lock file after writing
        Remove-Item -Path $lockFile -Force
    }
}
