# Connect to vCenter and remove old snapshots older than a specified number of days
# Make sure VMware.PowerCLI module is installed
Import-Module VMware.PowerCLI

# Variables
$vCenterServer = "your-vcenter-server"
$daysOld = 7 # Snapshots older than this number of days will be marked for deletion
$currentDate = Get-Date

# Connect to vCenter
Try {
    Connect-VIServer -Server $vCenterServer -ErrorAction Stop
} Catch {
    Write-Error "Failed to connect to vCenter: $_"
    exit
}

# Get all VMs with snapshots
$snapshots = Get-VM | Get-Snapshot | Select-Object VM, Name, Created, Description, @{
    Name="Age(Days)"; 
    Expression={[math]::Round(($currentDate - $_.Created).TotalDays,1)}
}

# Display all snapshots
Write-Host "`nAll existing snapshots:" -ForegroundColor Green
$snapshots | Format-Table -AutoSize

# Find old snapshots
$oldSnapshots = $snapshots | Where-Object {$_."Age(Days)" -gt $daysOld}

if ($oldSnapshots) {
    Write-Host "`nSnapshots older than $daysOld days:" -ForegroundColor Yellow
    $oldSnapshots | Format-Table -AutoSize

    # Prompt for deletion
    $confirmation = Read-Host "Do you want to remove these old snapshots? (Y/N)"
    if ($confirmation -eq 'Y') {
        foreach ($snapshot in $oldSnapshots) {
            Try {
                Remove-Snapshot -Snapshot (Get-Snapshot -VM $snapshot.VM -Name $snapshot.Name) -Confirm:$false
                Write-Host "Successfully removed snapshot: $($snapshot.Name) from VM: $($snapshot.VM)" -ForegroundColor Green
            } Catch {
                Write-Host "Failed to remove snapshot: $($snapshot.Name) from VM: $($snapshot.VM)" -ForegroundColor Red
                Write-Host "Error: $_" -ForegroundColor Red
            }
        }
    }
} else {
    Write-Host "`nNo snapshots older than $daysOld days found." -ForegroundColor Green
}

# Disconnect from vCenter
Disconnect-VIServer -Server $vCenterServer -Confirm:$false