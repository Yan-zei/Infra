# Script to run gpupdate /force only when connected to company network
# Save this as CompanyNetworkGPUpdate.ps1

# Configuration - adjust these values
$domainController = "your-dc.company.domain"  # Replace with your domain controller or server
$logFilePath = "C:\Logs\GPUpdate"            # Log directory
$logFile = "$logFilePath\GPUpdate.log"        # Log file
$maxRetryMinutes = 60                         # Maximum retry delay in minutes
$minRetryMinutes = 5                          # Minimum retry delay in minutes

# Create log directory if it doesn't exist
if (!(Test-Path $logFilePath)) {
    New-Item -ItemType Directory -Force -Path $logFilePath | Out-Null
}

# Function to write to log file
function Write-Log {
    param (
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
}

# Function to check if connected to company network
function Test-CompanyNetwork {
    $pingResult = Test-Connection -ComputerName $domainController -Count 2 -Quiet
    return $pingResult
}

Write-Log "Script started"

# Check if we're on the company network
if (Test-CompanyNetwork) {
    Write-Log "Connected to company network. Running gpupdate..."
    
    try {
        # Run gpupdate /force and capture output
        $result = gpupdate /force
        Write-Log "GPUpdate completed successfully with output: $result"
    }
    catch {
        Write-Log "Error running gpupdate: $_"
    }
}
else {
    # Generate random retry time
    $retryMinutes = Get-Random -Minimum $minRetryMinutes -Maximum $maxRetryMinutes
    Write-Log "Not connected to company network. Will retry via scheduled task."
    
    # Create a scheduled task to run again after the random delay
    $taskName = "CompanyNetworkGPUpdate_Retry"
    $currentScriptPath = $MyInvocation.MyCommand.Path
    
    # Delete any existing retry task
    schtasks /delete /tn $taskName /f 2>$null
    
    # Create new retry task
    $Command = "schtasks /create /tn $taskName /tr 'powershell.exe -ExecutionPolicy Bypass -File `"$currentScriptPath`"' /sc once /st $(Get-Date).AddMinutes($retryMinutes).ToString('HH:mm') /f"
    Invoke-Expression $Command
    
    Write-Log "Scheduled retry in $retryMinutes minutes ($(Get-Date).AddMinutes($retryMinutes).ToString('HH:mm'))"
}
