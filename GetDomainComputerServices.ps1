$scriptPath = "C:\Scripts\interactive"
if(!(Test-Path $scriptPath)){mkdir $scriptPath -Force}
cd $scriptPath
# Get computers in domain
$computers = Get-ADComputer -Filter {OperatingSystem -like '*Windows Server*'} -ResultSetSize 9999
$total = $computers.Count
Write-Host "Computers Found: $total"
# Check for valid computers to get services from. Computers that are outside of the current network context will not be contactable if blocked by firewall
$counter = 0
$validComputers = @()
$invalidComputers = @()
foreach ($computer in $computers) {
    $counter++
    if ($validComputers -notcontains $computer -and $invalidComputers -notcontains $computer) { # This is for testing to reduce overall run time if not resetting the array variables
        if ((Test-Connection $computer.Name -BufferSize 32 -Count 1 -Quiet)) {
            $validComputers += $computer
            Write-Host "[$counter/$total] $($computer.Name): Connection test successful. Adding to list of valid computers." -NoNewline -ForegroundColor Green
        }
        else {
            $invalidComputers += $computer
            Write-Host "[$counter/$total] $($computer.Name): Connection test failed. Computer either not on or not communicable." -NoNewline -ForegroundColor Yellow
        }
        Write-Host " Valid = $($validComputers.Count). Invalid = $($invalidComputers.Count)"
    }
}
$totalValid = $validComputers.Count
Write-Host "Valid Computers: $totalValid"
Write-Host "$($validComputers | Select-Object Name | Out-String)"
Write-Host "Invalid Computers: $($invalidComputers.Count). Output to InvalidComputers.txt"
$invalidComputers | Select-Object Name | Tee-Object -FilePath InvalidComputers.txt
$folderName = "output"
if(!(Test-Path $folderName)){mkdir $folderName -Force}
# Get services running on each valid computer and save results to {computer}.csv
$serviceCheckCounter = 0
foreach ($computerName in $validComputers.Name) {
    $serviceCheckCounter++
    try {
        Write-Host "Getting services for $computerName [$serviceCheckCounter/$totalValid]. " -NoNewline
        $services = $null
        # Set params for getting services as Get-CimInstance errors when passing in the local machine name for target
        $servicesParams = @{
            ClassName = "win32_service"
        }
        if($computerName -ne $env:COMPUTERNAME){
            $servicesParams.ComputerName = $computerName
        }
        # PowerShell version 7+ uses Get-CimInstance as Get-WmiObject has been deprecated
        if($psVersionTable.PSVersion.Major -ge 7){
            $services = Get-CimInstance @servicesParams | Select-Object @{n = "Computer"; e = { $_.SystemName } }, @{n = "ServiceName"; e = { $_.name } }, @{n = "User"; e = { $_.startname } }, @{n = "StartMode"; e = { $_.startmode } }, @{n = "State"; e = { $_.state } }, @{n = "Path"; e = { $_.pathname } }
        }else{
            $services = Get-WmiObject @servicesParams | Select-Object @{n = "Computer"; e = { $_.pscomputername } }, @{n = "ServiceName"; e = { $_.name } }, @{n = "User"; e = { $_.startname } }, @{n = "StartMode"; e = { $_.startmode } }, @{n = "State"; e = { $_.state } }, @{n = "Path"; e = { $_.pathname } }
        }
        
        $fileName = "$($computerName).csv"
        $services | Export-Csv -Path "$folderName/$fileName" -NoTypeInformation -Encoding UTF8
        $csv = Get-Item "$folderName/$fileName"
        Write-Host "Exported results to $($csv.FullName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error while getting/saving services for $computer. $($_.Exception.Message)" -ForegroundColor Yellow
    }
}