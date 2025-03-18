# Script to run gpupdate /force only when connected to company network
<# Save this as CompanyNetworkGPUpdate.ps1
The script is designed to avoid unnecessary gpupdate runs by checking the log file first. 
It will only create retry tasks if gpupdate hasn't run successfully that day.
#>
# Configuration - adjust these values
$domainController = "EUWESTCMDC01.lovisa.com"  # Replace with your domain controller or server
$logFilePath = "\\aueasthqfs01.lovisa.hq\DS_Report$\GPUpdate-logs"            # Log directory
$computerName = $env:COMPUTERNAME
$logFile = "$logFilePath\$computerName-gpupdatelog.txt"  # Computer-specific log file
$retryHours = 3                              # Hours between retry attempts

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

# Function to check if gpupdate was run successfully today
function Test-SuccessfulGPUpdate {
    $today = Get-Date -Format "yyyy-MM-dd"
    
    if (Test-Path $logFile) {
        $logContent = Get-Content $logFile
        $successPattern = "$today.* - GPUpdate completed successfully"
        $hasSuccess = $logContent | Where-Object { $_ -match $successPattern }
        return $null -ne $hasSuccess
    }
    return $false
}

Write-Log "Script started"

# Check if gpupdate was already successful today
if (Test-SuccessfulGPUpdate) {
    Write-Log "GPUpdate already run successfully today. No action needed."
    exit 0
}

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
        # Schedule retry
        Create-RetryTask
    }
}
else {
    Write-Log "Not connected to company network. Will retry via scheduled task."
    Create-RetryTask
}

# Function to create a retry task
function Create-RetryTask {
    $taskName = "CompanyNetworkGPUpdate_Retry"
    $currentScriptPath = $MyInvocation.MyCommand.Path
    
    # Delete any existing retry task
    schtasks /delete /tn $taskName /f 2>$null
    
    # Calculate next run time
    $nextRunTime = (Get-Date).AddHours($retryHours).ToString('HH:mm')
    
    # Create new retry task
    $Command = "schtasks /create /tn $taskName /tr 'powershell.exe -ExecutionPolicy Bypass -File `"$currentScriptPath`"' /sc once /st $nextRunTime /f"
    Invoke-Expression $Command
    
    Write-Log "Scheduled retry in $retryHours hours ($nextRunTime)"
}