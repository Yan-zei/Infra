$RegKey = 'HKCU:\SOFTWARE\Beside.com\Import Wizard 10'
$RegValues = @{

    "RegCode" = "34V2Y-4082A-N0793-LK1Y4-7N20V-I10A2:Lovisa Pty Ltd"

    "RegCodeOk" = "Y"

    "RegCode2" = "1"

    "AutoUpdateDate" = "2021-12-06"

    "AutoUsageDate" = "2021-12-06"

}

New-Item -Path $RegKey -Force 

foreach ( $item in $RegValues.GetEnumerator() ) {
    New-ItemProperty -Path $RegKey -Name $item.Key -Value $item.Value
}