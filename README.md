# Elenco dei nomi delle snapshot da cancellare 

$snapshotNames = @( 

    "RC-WLT-L-AS2_SUPVMW-18059_25-03-2025" 

) 

 

# Cerca e cancella snapshot con quei nomi 

foreach ($snapName in $snapshotNames) { 

    $snapshots = Get-VM | Get-Snapshot | Where-Object { $_.Name -eq $snapName } 

     

    foreach ($snap in $snapshots) { 

        Write-Host "🗑️ Eliminazione snapshot '$($snap.Name)' dalla VM '$($snap.VM.Name)'" -ForegroundColor Cyan 

        Remove-Snapshot -Snapshot $snap -Confirm:$false 

    } 

} 

