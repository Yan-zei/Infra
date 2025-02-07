# Execute script if Futura Application Server executable exists
if ((Test-Path "C:\futura4retail\fas\service\bin\Futura4AS.exe"))
{
# Sets variable for Futura Application Server (FAS) service
$svc = Get-Service Futura4AS

# Waits 15 seconds for Futura Application Server (FAS) service to stop before continuing
$svc.WaitForStatus('Stopped','00:00:15')

# Delete all accessible ‘jetty*’ temp folders (and its contents) from C:\futura4retail\fas\service\temp
Get-ChildItem 'C:\futura4retail\fas\data\temp' -Filter 'jetty*' -Recurse | Where-Object {$_.PsIsContainer} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}