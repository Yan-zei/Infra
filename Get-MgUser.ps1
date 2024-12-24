Import-Module Microsoft.Graph

Connect-MgGraph -Scopes "User.Read.All"

<#
$user = Get-MgUser -UserId 'hayyanz@lovisa.com' -Property "id, displayName, extensions, birthday"
$user.* | Format-Table


Get-MgUser -UserId "hayyanz@lovisa.com" -Property *
Get-MgUserExtension -UserId "hayyanz@lovisa.com"
Get-MgUser -UserId "hayyanz@lovisa.com" -Property "extensions" | Select-Object -ExpandProperty extensions
Get-MgUserExtension -UserId "hayyanz@lovisa.com" -Filter "name eq 'extensionAttribute2'"

#>

#or use another depricated module 
<#
Connect-AzureAD
$aadUser = Get-AzureADUser -ObjectId Hayyanz@lovisa.com
$aadUser | Select -ExpandProperty ExtensionProperty
#>

# Replace with the actual user ID or user principal name (UPN, e.g., 'username@domain.com')
$user = Get-MgUser -UserId 'hayyanz@lovisa.com'

# View all properties of the user
$user | Format-List *

$user | Format-List * | Where-Object { $_.Name -like "msDS_cloudExtensionAttribute*" }

$user.extension.extension_4058b5e11a26476ea02184bf1bac2b17_msDS_cloudExtensionAttribute2