# Caminho onde os backups serão armazenados
$backupPath = "C:\_LIVE\Backup"

# Nome da instância SQL Server
$instancia = "localhost"

# Obter todos os bancos ONLINE da instância
$bancos = Get-DbaDatabase -SqlInstance "SRVSQL2022" | Where-Object { $_.Status -eq "Normal" -and $_.Name -notin @("tempdb", "model", "CensoEscolar_DW", "AdventureWorksGR")}

foreach ($banco in $bancos) {
    Write-Host "Iniciando backup do banco: $($banco.Name)..."

    Backup-DbaDatabase -SqlInstance $instancia -Database $banco.Name -Path $backupPath -Type Full -CompressBackup

    Write-Host "✅ Backup concluído: $($banco.Name)"
}

Write-Host "Todos os backups foram concluídos."