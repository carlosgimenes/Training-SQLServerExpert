$saida = @()
$servers = @("SRVSQL2022", "SRVSQL2019")

foreach ($srv in $servers) {
    try {
        $connString = "Server=$srv;Database=master;Integrated Security=True;TrustServerCertificate=True;"
        $dados = Invoke-Sqlcmd `
            -ConnectionString $connString `
            -Query "SELECT name, create_date FROM sys.databases"

        foreach ($linha in $dados) {
            $saida += [PSCustomObject]@{
                Servidor = $srv
                Nome     = $linha.name
                CriadoEm = $linha.create_date
            }
        }
    } catch {
        Write-Warning "Falha em $srv - $($_.Exception.Message)"
    }
}

$saida | Export-Csv "C:\_LIVE\Bancos_MultiplosServidores.csv" -NoTypeInformation

