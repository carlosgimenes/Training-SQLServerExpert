


if (Get-Module -ListAvailable -Name SqlServer) {
    Write-Host "Módulo SqlServer está instalado."
} else {
    Write-Host "Módulo SqlServer NÃO está instalado."
}


if (Get-Module -ListAvailable -Name SqlServer) {
    Import-Module SqlServer
    Write-Host "Módulo SqlServer carregado com sucesso."
} else {
    Write-Warning "Módulo SqlServer não está instalado. Use Install-Module para instalar."
}
