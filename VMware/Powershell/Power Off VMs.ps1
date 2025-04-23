
# Connessione all'host ESXi (senza vCenter)
$securePass = ConvertTo-SecureString "passwordhost" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("root", $securePass)
Connect-VIServer -Server "esx01.dominio.com" -Credential $cred

# Lista delle VM da spegnere - da array o da file
$vmNames = @("VM1", "VM2", "VM3")  # oppure: Get-Content -Path "C:\path\to\vm_list.txt"

foreach ($vmName in $vmNames) {
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm -and $vm.PowerState -ne "PoweredOff") {
        Stop-VM -VM $vm -Confirm:$false
        Write-Output "Spenta VM: $vmName"
    } elseif ($vm) {
        Write-Output "VM già spenta: $vmName"
    } else {
        Write-Warning "VM non trovata: $vmName"
    }
}

# Disconnessione
Disconnect-VIServer -Confirm:$false