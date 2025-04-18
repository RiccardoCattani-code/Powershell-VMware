# This script deletes all resource groups and their contents in an Azure subscription.
# WARNING: This action is irreversible. Use with caution.

# Login to Azure
Connect-AzAccount

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

# Loop through each resource group and delete it
foreach ($rg in $resourceGroups) {
    Write-Host "Deleting resource group:" $rg.ResourceGroupName -ForegroundColor Yellow
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob
}

Write-Host "All resource groups and their contents have been scheduled for deletion." -ForegroundColor Green

# Monitoraggio dello stato tramite Azure CLI
do {
    Start-Sleep -Seconds 10
    $status = az group show --name $rg.ResourceGroupName --query "properties.provisioningState" -o tsv 2>$null
    if ($status -eq $null) {
        Write-Host "Il gruppo di risorse '$($rg.ResourceGroupName)' è stato eliminato." -ForegroundColor Green
        break
    } else {
        Write-Host "Stato attuale del gruppo di risorse '$($rg.ResourceGroupName)': $status" -ForegroundColor Cyan
    }
} while ($true)
}

Write-Host "Tutti i gruppi di risorse sono stati elaborati." -ForegroundColor Green