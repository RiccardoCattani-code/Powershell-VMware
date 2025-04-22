# Importa il modulo VMware PowerCLI
Import-Module VMware.PowerCLI

# Disabilita i messaggi di conferma per i certificati SSL non validi
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Path dei file di input
#Il primo è la lista dei vcenter
#Il secondo la lista delle VMs
$vcenterListFile = "pathdovesitrovailfile\Elencofarm.txt"
$vmListFile = "pathdovesitrovailfile\lista.txt"

# Credenziali per l'accesso ai vCenter
$username = "adminstrator@vsphere.local"
$password = "password"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword

# Collega a tutti i vCenter elencati nel file
$vcenters = Get-Content -Path $vcenterListFile
foreach ($vcenter in $vcenters) {
    Write-Host "Connessione a $vcenter..."
    Connect-VIServer -Server $vcenter -Credential $cred
}

# Legge l'elenco delle VM dal file
$vms = Get-Content -Path $vmListFile

# Per ogni VM nella lista
foreach ($vmName in $vms) {
    Write-Host "Controllo snapshot per la VM: $vmName" -ForegroundColor Yellow

    # Verifica se la VM esiste su uno dei vCenter collegati
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm -eq $null) {
        Write-Host "VM $vmName non trovata su nessun vCenter" -ForegroundColor Red
        continue
    }

    # Elenca le snapshot della VM
    $snapshots = Get-Snapshot -VM $vm -ErrorAction SilentlyContinue
    if ($snapshots) {
        foreach ($snapshot in $snapshots) {
            Write-Host "Snapshot trovata: $($snapshot.Name) - Creata il $($snapshot.Created)" -ForegroundColor Cyan
            $response = Read-Host "Vuoi eliminare questa snapshot? (s/n)"
            if ($response -eq 's') {
                Write-Host "Eliminazione della snapshot $($snapshot.Name)..." -ForegroundColor Magenta
                Remove-Snapshot -Snapshot $snapshot -Confirm:$false
                Write-Host "Snapshot $($snapshot.Name) eliminata con successo!" -ForegroundColor Green
            }
            else {
                Write-Host "Snapshot $($snapshot.Name) mantenuta." -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "Nessuna snapshot trovata per la VM $vmName." -ForegroundColor Green
    }
}

# Disconnessione da tutti i vCenter
Disconnect-VIServer -Server * -Confirm:$false