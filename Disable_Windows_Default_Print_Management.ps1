$RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows'
$Name         = 'LegacyDefaultPrinterMode'
$Value        = '1'
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force