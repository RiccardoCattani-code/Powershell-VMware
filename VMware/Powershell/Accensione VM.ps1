# Connessione all'host ESXi (senza vCenter)
$securePass = ConvertTo-SecureString "passwordhost" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("root", $securePass)
Connect-VIServer -Server "esx01.ourtde.com" -Credential $cred


# Lista delle VM da accendere - da array o da file
$vmNames = @("VM1", "VM2", "VM3")  # oppure: Get-Content -Path "C:\path\to\vm_list.txt"

foreach ($vmName in $vmNames) {
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm -and $vm.PowerState -ne "PoweredOn") {
        Start-VM -VM $vm -Confirm:$false
        Write-Output "Accesa VM: $vmName"
    } elseif ($vm) {
        Write-Output "VM già accesa: $vmName"
    } else {
        Write-Warning "VM non trovata: $vmName"
    }
}

# Disconnessione
Disconnect-VIServer -Confirm:$false