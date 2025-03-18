
Connect-MgGraph

# Get user object
$user = Get-MgUser -UserId hayyanz@lovisa.com

# Get extension attribute value
$extensionAttribute = Get-MgUserExtension -UserId $user.Id -ExtensionName "msDS-cloudExtensionAttribute2"

# Print attribute value
Write-Host "msDS-cloudExtensionAttri..bute value: $($extensionAttribute.Value)"