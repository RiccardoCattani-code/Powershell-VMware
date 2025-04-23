# This script creates a snapshot of a managed disk attached to a virtual machine in Azure.

# Variables
$resourceGroupName = "YourResourceGroupName"
$vmName = "YourVMName"
$snapshotName = "YourSnapshotName"
$description = "Snapshot of $vmName"


# Login to Azure account
Connect-AzAccount

# Get the VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Get the OS disk of the VM
$osDisk = $vm.StorageProfile.OsDisk

# Create a snapshot configuration
$snapshotConfig = New-AzSnapshotConfig -SourceUri $osDisk.ManagedDisk.Id -Location $location -CreateOption Copy

# Create the snapshot
New-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName -Snapshot $snapshotConfig

Write-Host "Snapshot '$snapshotName' created successfully in resource group '$resourceGroupName'."