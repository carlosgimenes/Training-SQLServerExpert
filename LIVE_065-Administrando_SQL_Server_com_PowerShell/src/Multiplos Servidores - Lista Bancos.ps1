$servers = @("SRVSQL2022", "SRVSQL2019")

foreach ($srv in $servers) {
    Write-Host "Conectando ao servidor: $srv" -ForegroundColor Cyan
    try {
        $connString = "Server=$srv;Database=master;Integrated Security=True;TrustServerCertificate=True;"
        $result = Invoke-Sqlcmd `
            -ConnectionString $connString `
            -Query "SELECT name, state_desc FROM sys.databases"
        
        $result | Select-Object @{Name="Servidor";Expression={$srv}}, name, state_desc
    }
    catch {
        Write-Warning "Erro ao conectar no servidor $srv - $($_.Exception.Message)"
    }
}

