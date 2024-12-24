<#
. WRITTEN BY
  Shelton D'Rozario
. DESCRIPTION
  Creates a single CSV File to identify POS devices which have less than 15% of free space on the C: drive volume
. DATE
  19/12/2022
#>

# Removes old Computer Name Disk Space CSV file if previously existed
Remove-Item \\AUEASTHQFS01\DS_Report$\$env:ComputerName-C_Drive_FreeDiskSpace.csv -Recurse -Force -ErrorAction SilentlyContinue

# Collect free disk space of C: drive and append details to a single CSV file if less than 15%
Get-WmiObject -Class Win32_LogicalDisk |
Where-Object {$_.DriveType -eq 3 -AND (($_.FreeSpace/$_.Size)*100) -lt 15} | 
Select-Object DeviceID, Description,`
@{"Label"="ComputerName";"Expression"={$env:ComputerName}}, `
@{"Label"="DiskSize(GB)";"Expression"={"{0:N}" -f ($_.Size/1GB) -as [float]}}, `
@{"Label"="FreeSpace(GB)";"Expression"={"{0:N}" -f ($_.FreeSpace/1GB) -as [float]}},`
@{"Label"="PercentFreeSpace";"Expression"={"{0:N}" -f (($_.FreeSpace/$_.Size)*100) -as [float]}} |
Export-CSV \\AUEASTHQFS01\DS_Report$\$env:ComputerName-C_Drive_FreeDiskSpace.csv -ErrorAction SilentlyContinue

# Sleep Script for 5 seconds
Start-Sleep -Seconds 5

# Deletes free disk space CSV if file is 0 bytes
Get-ChildItem -File \\AUEASTHQFS01\DS_Report$\$env:ComputerName-C_Drive_FreeDiskSpace.csv | Where-Object {$_.Length -eq 0} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue