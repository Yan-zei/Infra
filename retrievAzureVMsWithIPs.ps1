<# Retrieving all private and public IPs for all ARM VMs within an Azure tenant using non-ARG cmdlets
 VMs having more than 1 vmNic there will be multiple rows with the same VM name,

::Note:: 
Get-AzVM will only operate against machines deployed using the ARM model, as explicitly stated here: 
“However, the Resource Manager cmdlet Get-AzVM only returns virtual machines deployed through Resource Manager“. 
For the ASM, or Azure classic VMs, you’ll have to install the respective Powershell module, as described here,
 and use different code to get the list of classic VMs, based most likely on Select-AzureSubscription and Get-AzureVM.

 References:
 https://learn.microsoft.com/en-us/previous-versions/azure/virtual-machines/scripts/virtual-machines-powershell-sample-collect-vm-details

 Requirements:
 Azure PowerShell module
 Install-Module -Name Az -AllowClobber -Scope CurrentUser

#>

#Reqires

# Connect to Azure
Connect-AzAccount

$report = @()
Get-AzSubscription | % {
Select-AzSubscription $_
    $vms = Get-AzVM
    $publicIps = Get-AzPublicIpAddress
    $nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null}
    foreach ($nic in $nics) {
        $info = "" | Select-Object VmName, ResourceGroupName, Region, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, SubscriptionName
        $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id
        foreach($publicIp in $publicIps) {
            if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
                $info.PublicIPAddress = $publicIp.ipaddress
            }
        }
        $info.OsType = $vm.StorageProfile.OsDisk.OsType
        $info.VMName = $vm.Name
        $info.ResourceGroupName = $vm.ResourceGroupName
        $info.Region = $vm.Location
        $info.VirturalNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3]
        $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1]
        $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress
        $info.SubscriptionName=$_.Name
        $report+=$info
    }
}
$report | Select-Object VmName, ResourceGroupName, Region, VirtualNetwork, Subnet,`
    @{label="PrivateIpAddress";expression={$_.PrivateIpAddress}}, OsType, PublicIPAddress,`
    SubscriptionName | Export-Csv -NoTypeInformation "C:\Users\hayyanz\Downloads\Azure-Output\Azure_VMs.csv"
    #SubscriptionName | Export-Csv -NoTypeInformation "C:\Users\hayyanz\Downloads\Azure-Output\VMs_$(Get-Date -Uformat "%Y%m%d-%H%M%S").csv"