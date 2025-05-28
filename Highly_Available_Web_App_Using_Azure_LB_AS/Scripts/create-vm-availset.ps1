# Authenticate to Azure
Connect-AzAccount

# Define variables
$resourcegroup = 'Mywebapp-rg'
$location = 'East US'
$vnetname = 'Myvnet'
$vnetAddressPrefix = '10.0.0.0/16'
$subnetname = 'webapp-subnet'
$subnetAddressprefix = '10.0.1.0/24'
$availablesetname = 'WebAvailSet'
$adminname = 'azureuser'
$adminpassword = ConvertTo-SecureString "Qazwsxedc123" -AsPlainText -Force
$imagepublisher = "MicrosoftWindowsServer"
$imageoffer = 'WindowsServer'
$imagesku = '2019-Datacenter'
$nsgname = 'webapp-nsg'

# Create a resource group
New-AzResourceGroup -Name $resourcegroup -Location $location

# Create virtual network and subnet
$subnetconfig = New-AzVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix $subnetAddressprefix
$vnet = New-AzVirtualNetwork -Name $vnetname -ResourceGroupName $resourcegroup -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnetconfig

# Retrieve subnet (used later in NIC creation)
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetname -VirtualNetwork $vnet

# Create availability set
$availset = New-AzAvailabilitySet -Name $availablesetname -ResourceGroupName $resourcegroup -Location $location `
    -Sku aligned -PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2

# Create NSG rules (HTTP and RDP)
$nsgrule1 = New-AzNetworkSecurityRuleConfig -Name "AllowHTTP" -Protocol Tcp -Direction Inbound -Priority 100 `
    -SourcePortRange * -SourceAddressPrefix * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow

$nsgrule2 = New-AzNetworkSecurityRuleConfig -Name "AllowRDP" -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourcePortRange * -SourceAddressPrefix * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow

# Create NSG and apply rules
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourcegroup -Location $location -Name $nsgname `
    -SecurityRules $nsgrule1, $nsgrule2

# Deploy 2 VMs in availability set
for ($i = 1; $i -le 2; $i++) {
    $Vmname = "webappvm$i"
    $NicName = "webNic$i"
    $publicIpName = "pip$i"

    # Create public IP
    $publicip = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourcegroup `
        -Location $location -Sku Standard -AllocationMethod Static

    # Create NIC with NSG and public IP
    $nic = New-AzNetworkInterface -Name $NicName -ResourceGroupName $resourcegroup -Location $location `
        -SubnetId $subnet.Id -PublicIpAddressId $publicip.Id -NetworkSecurityGroupId $nsg.Id

    # Configure VM
    $vmconfig = New-AzVMConfig -VMName $Vmname -VMSize 'Standard_DS2_v2' -AvailabilitySetId $availset.Id
    $vmconfig = Set-AzVMOperatingSystem -VM $vmconfig -Windows -ComputerName $Vmname `
        -Credential (New-Object pscredential($adminname, $adminpassword))
    $vmconfig = Set-AzVMSourceImage -VM $vmconfig -PublisherName $imagepublisher -Offer $imageoffer `
        -Skus $imagesku -Version 'latest'
    $vmconfig = Add-AzVMNetworkInterface -VM $vmconfig -Id $nic.Id

    # Create VM
    New-AzVM -ResourceGroupName $resourcegroup -Location $location -VM $vmconfig
}

# Remove-AzResourceGroup -Name $resourcegroup -Force
