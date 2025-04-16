# Intune Remediation Script: GPUpdate Execution with Network Check
# This script checks connectivity to the domain controller, runs gpupdate /force
# when connected, and creates a success tag file. It retries every 20 minutes if not connected.

# Configuration
$domainController = "AUEASTCMDC01.lovisa.com" # Replace with your domain controller FQDN
$tagFilePath = "$env:ProgramData\Lovisa\logs\gpupdate-success.tag"
$logFilePath = "$env:ProgramData\Lovisa\logs\gpupdate-remediation.log"
$retryIntervalMinutes = 20

# Ensure the directory exists
$directory = Split-Path -Path $tagFilePath -Parent
if (-not (Test-Path -Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

# Function to write to log file
function Write-Log {
    param ([string]$message)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFilePath -Append
}

# Function to check if connected to internal network
function Test-InternalNetworkConnectivity {
    $pingResult = Test-Connection -ComputerName $domainController -Count 2 -Quiet
    return $pingResult
}

# Function to run gpupdate and handle result
function Run-GPUpdate {
    try {
        Write-Log "Running gpupdate /force..."
        $process = Start-Process -FilePath "gpupdate.exe" -ArgumentList "/force" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Log "GPUpdate executed successfully with exit code: $($process.ExitCode)"
            
            # Create tag file with timestamp
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Set-Content -Path $tagFilePath -Value "GPUpdate successfully executed at $timestamp" -Force
            
            Write-Log "Created success tag file at $tagFilePath"
            return $true
        } else {
            Write-Log "GPUpdate failed with exit code: $($process.ExitCode)"
            return $false
        }
    } catch {
        Write-Log "Error executing GPUpdate: $_"
        return $false
    }
}

# Main script execution
Write-Log "Script started"

# If tag file exists, check if we need to run again (could implement additional logic here)
if (Test-Path -Path $tagFilePath) {
    $fileContent = Get-Content -Path $tagFilePath -Raw
    Write-Log "Tag file already exists with content: $fileContent"
    # Comment out the exit if you want to run gpupdate regardless of tag file presence
     Exit 0
}

# Check network connectivity and run gpupdate
$maxRetries = 216
$retryCount = 0
$success = $false
+
while (-not $success -and $retryCount -lt $maxRetries) {
    if (Test-InternalNetworkConnectivity) {
        Write-Log "Connected to internal network (DC: $domainController)"
        $success = Run-GPUpdate
        
        if ($success) {
            Write-Log "Script executed successfully"
            Exit 0
        } else {
            $retryCount++
            Write-Log "GPUpdate failed, retry $retryCount of $maxRetries"
            Start-Sleep -Seconds 30  # Short pause before retry
        }
    } else {
        Write-Log "Not connected to internal network, scheduling retry in $retryIntervalMinutes minutes"
        
        # Create a scheduled task to run this script again after the interval
        $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes($retryIntervalMinutes)
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden
        
        # Use a unique task name based on the script name
        $taskName = "IntuneRemediation_GPUpdate_" + (Get-Date -Format "yyyyMMddHHmmss")
        
        try {
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
            Write-Log "Scheduled retry task created: $taskName"
            Exit 1  # Exit with code 1 to indicate we need to retry later
        } catch {
            Write-Log "Failed to create scheduled task: $_"
            Exit 1
        }
    }
}

if (-not $success) {
    Write-Log "Max retries reached, script failed"
    Exit 1
}