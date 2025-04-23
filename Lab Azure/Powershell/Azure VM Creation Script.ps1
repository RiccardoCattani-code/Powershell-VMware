# Azure VM Creation Script

# Connect-AzAccount
Connect-AzAccount

# Select the Subscription
Get-AzSubscription
Set-AzContext -SubscriptionId "6b678711-e207-4bbe-bad3-cb45178f095c"

# Variables
$resourceGroupName = "demo-rg"
$location = "westeurope"
$vmName = "linux-demo-vm"
$vmSize = "Standard_B2s"
$image = "Canonical:UbuntuServer:18.04-LTS:latest"
$adminUsername = "azureuser"
$adminPassword = ConvertTo-SecureString "YourComplexPassword123!" -AsPlainText -Force

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create VM Configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential (New-Object PSCredential ($adminUsername, $adminPassword))
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"

# Create Network Resources
$subnetConfig = New-AzVirtualNetworkSubnet -Name "demo-subnet" -AddressPrefix "10.0.1.0/24"
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "demo-vnet" -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig
$pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "demo-pip" -AllocationMethod Dynamic
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "demo-nic" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Add NIC to VM Config
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Create VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig