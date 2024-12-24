<# 
Purpose: disable Bitlocker on all encrypted drives, log decyption time
Version: 1.0 

#>

<# Check if the script is running with administrative privileges
if (-not [Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    exit
}
#>


# Define log file path
$logFilePath = "C:\ProgramData\Lovisa\logs\BitLockerDecryptionLog.txt"

# Ensure the log directory exists
$logDir = Split-Path $logFilePath
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force
}

# Clear the log file if it already exists
if (Test-Path $logFilePath) {
    Clear-Content $logFilePath
} else {
    # Create the log file if it doesn't exist
    New-Item -Path $logFilePath -ItemType File -Force
}

# Get all drives with BitLocker status
$drives = Get-BitLockerVolume | Where-Object { $_.VolumeStatus -eq 'FullyEncrypted' }

# Disable BitLocker on each encrypted drive silently
foreach ($drive in $drives) {
    $startTime = Get-Date

    # Log the start time
    $startTimeFormatted = $startTime.ToString("yyyy-MM-dd HH:mm:ss")
    $startLogEntry = "Decryption started for drive $($drive.MountPoint) at $startTimeFormatted."
    Add-Content -Path $logFilePath -Value $startLogEntry

    Disable-BitLocker -MountPoint $drive.MountPoint | Out-Null

    # Wait for the decryption to finish without output
    do {
        Start-Sleep -Seconds 10
        $status = Get-BitLockerVolume -MountPoint $drive.MountPoint
    } while ($status.ProtectionStatus -eq 'On')

    $endTime = Get-Date

    # Log the end time
    $endTimeFormatted = $endTime.ToString("yyyy-MM-dd HH:mm:ss")
    $endLogEntry = "Decryption completed for drive $($drive.MountPoint) at $endTimeFormatted."
    Add-Content -Path $logFilePath -Value $endLogEntry
}
