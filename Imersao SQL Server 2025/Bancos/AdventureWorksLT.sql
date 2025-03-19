/*************************************************
 Autor: Landry Duailibe

 - Banco de Dados AdventureWorks para Hands On
*************************************************/
use master
go

RESTORE DATABASE AdventureWorksLT FROM DISK = 'H:\Backup\AdventureWorksLT.bak' WITH stats=5,
MOVE 'AdventureWorksLT2012_Data' TO 'E:\MSSQL_Data\AdventureWorksLT.mdf',
MOVE 'AdventureWorksLT2012_Log'  TO 'F:\MSSQL_Data\AdventureWorkLT_log.ldf'

-- Troca o Owner do Banco para "SA"
ALTER AUTHORIZATION ON DATABASE::AdventureWorksLT TO sa

-- Grau de compatibilidade SQL Server 2022
ALTER DATABASE AdventureWorksLT SET COMPATIBILITY_LEVEL = 160 

-- Troca o Recovery Model para FULL
ALTER DATABASE AdventureWorksLT SET RECOVERY FULL

-- Atualiza as estatisticas de banco de dados
use AdventureWorksLT
go

exec sp_updatestats




