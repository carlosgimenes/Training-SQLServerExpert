use master
go


RESTORE DATABASE Northwind FROM disk = 'H:\Backup\Northwind.bak' with replace,recovery,stats=2,
MOVE 'Northwind' TO 'E:\MSSQL_Data\Northwind.mdf',
MOVE 'Northwind_log' TO 'F:\MSSQL_Data\Northwind_log.ldf'

-- Troca o Owner do Banco para "SA"
ALTER AUTHORIZATION ON DATABASE::Northwind TO sa

-- Grau de compatibilidade SQL Server 2022
ALTER DATABASE Northwind SET COMPATIBILITY_LEVEL = 160 

-- Troca o Recovery Model para FULL
ALTER DATABASE Northwind SET RECOVERY FULL

-- Atualiza as estatisticas de banco de dados
use Northwind
go

exec sp_updatestats