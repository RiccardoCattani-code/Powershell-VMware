# This script deletes all resource groups and their contents in an Azure subscription.
# WARNING: This action is irreversible. Use with caution.

# Login to Azure
Connect-AzAccount -UseDeviceAuthentication -TenantId 

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

# Loop through each resource group and delete it
foreach ($rg in $resourceGroups) {
    Write-Host "Deleting resource group:" $rg.ResourceGroupName -ForegroundColor Yellow
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob

    # Monitor the deletion status for the current resource group
    do {
        Start-Sleep -Seconds 10
        $status = az group show --name $rg.ResourceGroupName --query "properties.provisioningState" -o tsv 2>$null
        if ($status -eq $null) {
            Write-Host "Resource group '$($rg.ResourceGroupName)' has been deleted." -ForegroundColor Green
            break
        } else {
            Write-Host "Current status of resource group '$($rg.ResourceGroupName)': $status" -ForegroundColor Cyan
        }
    } while ($true)
}

Write-Host "All resource groups have been processed." -ForegroundColor Green
