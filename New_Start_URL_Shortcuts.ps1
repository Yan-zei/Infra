$Shell = New-Object -ComObject ("WScript.Shell")
$Favorite = $Shell.CreateShortcut($env:ProgramData + "\Microsoft\Windows\Start Menu\Programs\Lovisa SharePoint.url")
$Favorite.TargetPath = "https://lovisahq.sharepoint.com";
$Favorite.Save()

$Shell = New-Object -ComObject ("WScript.Shell")
$Favorite = $Shell.CreateShortcut($env:ProgramData + "\Microsoft\Windows\Start Menu\Programs\Lovisa Support.url")
$Favorite.TargetPath = "https://lovisait.zendesk.com";
$Favorite.Save()