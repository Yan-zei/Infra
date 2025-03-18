# Set variables
$userName = "ClaudiaC" # Replace with actual username
$domainControllers = @("LOVIPDC.lovisa.com","LV-INT-DC01.lovisa.com", "LV-INT-DC02.lovisa.com", "LOVISDC.lovisa.com", "ZANORTHCMDC01.lovisa.com"
"AUEASTCMDC01.lovisa.com", "EUWESTCMDC01.lovisa.com", "USWEST3CMDC01.lovisa.com", "CNNORTH3CMDC01.lovisa.com", "LOVISAUS-DC01.lovisa.com"
"LOVISAUK-DC01.lovisa.com", "LOVISAZA-DC01.lovisa.com") # Replace with your DC list

$startDate = (Get-Date).AddDays(-15) # Adjust time range as needed

$creationLogPath = "C:\Temp\Scripts-Output\EventDetails2.txt" # Path for the creation log file

# Create an array to store results
$creationResults = @()

foreach ($dc in $domainControllers) {
    Write-Host "Searching $dc for creation events of user $userName..." -ForegroundColor Cyan
    
    # Event ID 4720 is for user account creation
    $events = Get-WinEvent -ComputerName $dc -FilterHashtable @{
        LogName = 'Security'
        ID = 4720
        StartTime = $startDate
    } -ErrorAction SilentlyContinue | 
    Where-Object {$_.Properties[0].Value -like "*$userName*"}
    
    foreach ($event in $events) {
        $creationResults += [PSCustomObject]@{
            TimeCreated = $event.TimeCreated
            DomainController = $dc
            CreatedBy = $event.Properties[4].Value
            UserCreated = $event.Properties[0].Value
        }
    }
}

# Export results to CSV
if ($creationResults.Count -gt 0) {
    $creationResults | Export-Csv -Path $creationLogPath -NoTypeInformation
    Write-Host "User creation events exported to $creationLogPath" -ForegroundColor Green
} else {
    Write-Host "No user creation events found for $userName" -ForegroundColor Yellow
}