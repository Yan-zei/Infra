# Script to be deployed via Intune to create scheduled task for GPUpdate
# Save as Create-GPUpdateTask.ps1

# Task configuration
$taskName = "DailyNetworkGPUpdate"
$taskDescription = "Runs gpupdate /force once per day when connected to corporate network"
$scriptPath = "C:\Scripts\DailyNetworkGPUpdate.ps1"
$logPath = "C:\Logs\GPUpdate"

# Create directories if they don't exist
if (!(Test-Path "C:\Scripts")) {
    New-Item -ItemType Directory -Path "C:\Scripts" -Force | Out-Null
}

if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
}

# Create the GPUpdate script
$gpUpdateScript = @'
# Script to run gpupdate /force once per day when connected to corporate network
# Created by Intune deployment

# Configuration
$domainController = "EUWESTCMDC01.lovisa.com"  # Replace with your domain controller
$logPath = "C:\Logs\GPUpdate"
$computerName = $env:COMPUTERNAME
$logFile = "$logPath\$computerName-gpupdatelog.txt"

# Create log directory if it doesn't exist
if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
}

# Function to write to log file
function Write-Log {
    param([string]$message)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
}

# Check if already run today
$today = Get-Date -Format "yyyy-MM-dd"
$alreadyRun = $false

if (Test-Path $logFile) {
    $logContent = Get-Content $logFile
    foreach ($line in $logContent) {
        if ($line -match "$today.*GPUpdate completed successfully") {
            $alreadyRun = $true
            break
        }
    }
}

# If already run today, exit
if ($alreadyRun) {
    Write-Log "GPUpdate already successfully run today. Skipping."
    exit 0
}

# Check if connected to corporate network
$networkConnected = Test-Connection -ComputerName $domainController -Count 2 -Quiet -ErrorAction SilentlyContinue

if ($networkConnected) {
    Write-Log "Connected to corporate network. Running gpupdate..."
    
    try {
        $result = gpupdate /force
        Write-Log "GPUpdate completed successfully"
    }
    catch {
        Write-Log "Error running gpupdate: $_"
        exit 1
    }
}
else {
    Write-Log "Not connected to corporate network. Will try again next scheduled run."
    exit 0
}
'@

# Save the GPUpdate script
$gpUpdateScript | Out-File -FilePath $scriptPath -Force

# Create or update the scheduled task
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($taskExists) {
    # Remove existing task
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create action to run PowerShell script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Create triggers
# Daily trigger at 9am
$dailyTrigger = New-ScheduledTaskTrigger -Daily -At 9am

# Additional trigger at logon (optional)
$logonTrigger = New-ScheduledTaskTrigger -AtLogOn
$logonTrigger.StartBoundary = (Get-Date).Date.AddSeconds(20)  # Delay logon by 20 seconds - this hasn't been tested yet


# Task settings
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -WakeToRun -ExecutionTimeLimit (New-TimeSpan -Minutes 10)

# Register the task to run with system privileges
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Action $action -Trigger @($dailyTrigger, $logonTrigger) -Settings $settings -User "SYSTEM" -RunLevel Highest


Write-Output "Scheduled task '$taskName' created successfully."