# Verifica presenza modulo ImportExcel
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Error "Il modulo 'ImportExcel' non è installato. Esegui 'Install-Module -Name ImportExcel' per installarlo."
    exit
}
# Assicurati di avere il modulo ImportExcel
# Install-Module -Name ImportExcel
# File Excel con colonne: VMName, vCenter
$excelPath = "C:\Users\sqz75768\vm_list.xlsx"

# Caricamento dati dal file Excel
$vmData = Import-Excel -Path $excelPath

# Per tenere traccia delle connessioni attive
$connectedVCs = @{}

# Risultati
$result = @()

foreach ($entry in $vmData) {
    $vmName = $entry.VMName
    $vcServer = $entry.vCenter
    $username = $entry.Username
    $password = $entry.Password


   # Connessione se non già fatta
   if (-not $connectedVCs.ContainsKey($vcServer)) {
    try {
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
        $vcConnection = Connect-VIServer -Server $vcServer -Credential $credential -WarningAction SilentlyContinue
        $connectedVCs[$vcServer] = $vcConnection
    } catch {
        Write-Warning "Impossibile connettersi a $vcServer con l'utente $username"
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
$result | Export-Csv -Path "C:\Users\sqz75768\export_hot_plug" -NoTypeInformation

# Mostra risultati
$result


#📌 Istruzioni per l'uso:
#Creazione del file Excel:

#Apri Microsoft Excel.

#Inserisci i dati in un excel con due colonne: VMName e vCenter.
#Esempio:   Colonna1    Colonna2        Colonna3                    Colonna4
#            VMName	    vCenter         username                    password
#            VM1	    vcenter1.local  administrator@vsphere.local password
#            VM2	    vcenter2.local  administrator@vsphere.local password

#Salva il file con il nome vm_list.xlsx in una directory a tua scelta, ad esempio C:\Scripts\vm_list.xlsx.​ 

#Utilizzo nello script PowerShell:

#Assicurati che lo script PowerShell punti al percorso corretto del file Excel.

#Esegui lo script per ottenere le informazioni desiderate sulle VM