# Assicurati di avere il modulo ImportExcel
# Install-Module -Name ImportExcel
# File Excel con colonne: VMName, vCenter
$excelPath = "\\wp-ctx-fs01\folderredirection$\sqz75768_OURLOTTO\Desktop\vm_list"

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
$result | Export-Csv -Path "\\wp-ctx-fs01\folderredirection$\sqz75768_OURLOTTO\Desktop\export_hot_plug" -NoTypeInformation

# Mostra risultati
$result


#📌 Istruzioni per l'uso:
#Creazione del file Excel:

#Apri Microsoft Excel.

#Inserisci i dati in un excel con due colonne: VMName e vCenter.
#Esempio:   VMName	    vCenter
#            VM1	    vcenter1.local
#            VM2	    vcenter2.local

#Salva il file con il nome vm_list.xlsx in una directory a tua scelta, ad esempio C:\Scripts\vm_list.xlsx.​

#Utilizzo nello script PowerShell:

#Assicurati che lo script PowerShell punti al percorso corretto del file Excel.

#Esegui lo script per ottenere le informazioni desiderate sulle VM.