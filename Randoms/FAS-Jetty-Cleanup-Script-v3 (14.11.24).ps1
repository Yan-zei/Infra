# Modified: 14/11/2024
# It checks multiple locations for 'jetty*' folders and deletes them if they exist.
# Removed the check for the Futura Application Server executable at "C:\futura4retail\fas\service\bin\Futura4AS.exe".
# Removed the $svc variable and WaitForStatus('Stopped', '00:00:15') to avoid waiting for the FAS service to stop.
# The script now directly checks each specified path and deletes 'jetty*' folders if they exist.


# Define possible paths for Jetty temp files
$tempPaths = @(
    'C:\futura4retail\fas\data\temp',
    'C:\Remira\RISB\data\temp'
)

# Loop through each path and delete 'jetty*' folders if the path exists
foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Filter 'jetty*' -Recurse | 
        Where-Object { $_.PsIsContainer } | 
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}