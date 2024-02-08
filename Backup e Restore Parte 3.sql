/*********************************************
 Autor: Landry Duailibe
 Demonstração Backup/Restore
**********************************************/
USE master
go


/************************************
 Criando Operador
*************************************/
EXEC msdb.dbo.sp_add_operator @name=N'DBA', @enabled=1, @pager_days=0, 
							  @email_address=N'proflandry.sqlexpert@gmail.com'
go


/************************************************
 Agendando Backup no SQL Server Agent
*************************************************/
CREATE DATABASE VendasDB
go

use VendasDB
go

-- Cria tabela Clientes para demonstração
CREATE TABLE dbo.Clientes (
ClienteID int not null primary key,
Nome varchar(50) not null,
Telefone varchar(20) null)
go

INSERT dbo.Clientes VALUES (1,'Jose','1111-1111')
INSERT dbo.Clientes VALUES (2,'Maria','2222-2222')
INSERT dbo.Clientes VALUES (3,'Luana','3333-3333')
INSERT dbo.Clientes VALUES (4,'Erick','4444-4444')
go
SELECT * FROM VendasDB.dbo.Clientes


/****************************************************
 JOB para fazer um Backup por Arquivo
 - Criar pasta BackupDB
****************************************************/

/*******************
 Backup FULL
********************/
DECLARE @Caminho varchar(4000) = 'C:\BackupDB\FULL'
DECLARE @Arquivo varchar(max)

SET @Arquivo = @Caminho + '\VendasDB_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','') + '.bak'
--print @Arquivo
BACKUP DATABASE VendasDB TO DISK = @Arquivo WITH FORMAT, COMPRESSION

-- Exclui Histórico dos Backups
DECLARE @DelDate datetime
SET @DelDate = DATEADD(wk,-4,getdate())

EXECUTE master.dbo.xp_delete_file 0,@Caminho,'bak',@DelDate,0
go

/********************
 Backup LOG
*********************/
DECLARE @Caminho varchar(4000) = 'C:\BackupDB\LOG'
DECLARE @Arquivo varchar(max)

SET @Arquivo = @Caminho + '\VendasDB_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','') + '.trn'
BACKUP LOG VendasDB TO DISK = @Arquivo WITH FORMAT, COMPRESSION

-- Exclui Histórico dos Backups
DECLARE @DelDate datetime
SET @DelDate = DATEADD(wk,-4,getdate())

EXECUTE master.dbo.xp_delete_file 0,@Caminho,'trn',@DelDate,0
go


