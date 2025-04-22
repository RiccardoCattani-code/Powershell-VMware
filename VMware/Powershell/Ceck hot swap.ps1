# Assicurati di avere il modulo ImportExcel
# Install-Module -Name ImportExcel

# File Excel con colonne: VMName, vCenter
$excelPath = "C:\path\to\vm_list.xlsx"

# Caricamento dati dal file Excel
$vmData = Import-Excel -Path $excelPath

# Per tenere traccia delle connessioni attive
$connectedVCs = @{}

# Risultati
$result = @()

foreach ($entry in $vmData) {
    $vmName = $entry.VMName
    $vcServer = $entry.vCenter

    # Connessione se non già fatta
    if (-not $connectedVCs.ContainsKey($vcServer)) {
        try {
            $vcConnection = Connect-VIServer -Server $vcServer -WarningAction SilentlyContinue
            $connectedVCs[$vcServer] = $vcConnection
        } catch {
            Write-Warning "Impossibile connettersi a $vcServer"
            continue
        }
    }

    # Recupera la VM
    $vm = Get-VM -Name $vmName -Server $connectedVCs[$vcServer] -ErrorAction SilentlyContinue
    if ($vm) {
        $cpuHotAdd = $vm.ExtensionData.Config.CpuHotAddEnabled
        $memHotAdd = $vm.ExtensionData.Config.MemoryHotAddEnabled
        $result += [PSCustomObject]@{
            VMName         = $vm.Name
            vCenter        = $vcServer
            CPU_HotAdd     = $cpuHotAdd
            Memory_HotAdd  = $memHotAdd
        }
    } else {
        Write-Warning "VM '$vmName' non trovata su $vcServer"
    }
}

# Disconnessione da tutti i vCenter
$connectedVCs.Values | ForEach-Object { Disconnect-VIServer -Server $_ -Confirm:$false }

# (Opzionale) Esportazione in CSV
$result | Export-Csv -Path "C:\path\to\hotplug_report.csv" -NoTypeInformation

# Mostra risultati
$result
