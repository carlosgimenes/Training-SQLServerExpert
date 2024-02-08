/*********************************************
 Autor: Landry Duailibe
 Demonstração Backup/Restore
**********************************************/
USE master
go

-- Identificando Recovery Model dos Bancos
SELECT [name] as Banco, recovery_model_desc as RecoveryModel
FROM sys.databases
WHERE database_id > 4
ORDER BY Banco

/**************************
 Backup Device
***************************/

-- Cria DEVICE
EXEC master.dbo.sp_addumpdevice  
@devtype = N'disk', 
@logicalname = N'BackupMaster', 
@physicalname = N'C:\Backup\BackupMaster.bak'
go

-- Backup Device
BACKUP DATABASE master TO BackupMaster

-- Backup File
BACKUP DATABASE master TO DISK = 'C:\Backup\BackupMaster.bak' WITH noinit
go

-- Verificando conteúdo da media de Backup
RESTORE HEADERONLY FROM BackupMaster
RESTORE FILELISTONLY FROM BackupMaster

-- Backup com compressão
BACKUP DATABASE master TO BackupMaster WITH format, compression, checksum, stats=2

-- Verifica a integridade do arquivo de Backup
RESTORE VERIFYONLY FROM BackupMaster WITH CHECKSUM

-- Verificando conteúdo da media de Backup
RESTORE HEADERONLY FROM BackupMaster
RESTORE FILELISTONLY FROM BackupMaster


/************************************************
 Demonstração Tipos de Backup: FULL, DIF e LOG
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

SELECT * FROM dbo.Clientes


-- Inclui a 1a linha e faz Backup FULL
INSERT dbo.Clientes VALUES (1,'Jose','1111-1111')

BACKUP DATABASE VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH format, compression, stats=2

-- Inclui a 2a linha e faz Backup DIF
INSERT dbo.Clientes VALUES (2,'Maria','2222-2222')

BACKUP DATABASE VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH differential, noinit, compression, stats=2

-- Inclui a 2a linha e faz Backup DIF
INSERT dbo.Clientes VALUES (3,'Luana','3333-3333')

BACKUP LOG VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH noinit, compression, stats=2

-- Verificando o arquivo de Backup com 3 Backups: FULL, DIF e LOG
RESTORE HEADERONLY FROM DISK = 'C:\Backup\VendasDB.bak'
/*
BackupType:
1 FULL
5 DIF
2 LOG
*/

/**********************************************************************************
 Backup Log com NO_TRUNCATE ("RM")
 Salvando a última atividade que após o último Backup e antes da falha
***********************************************************************************/

INSERT dbo.Clientes VALUES (4,'Erick','4444-4444')
SELECT * FROM VendasDB.dbo.Clientes

/*
 Para simular uma falha:
 1) Parar o serviço do SQL Server
 2) Renomear o arquivo de Dados do banco "VendasDB"
 3) Iniciar o serviço do SQL Server
*/

BACKUP LOG VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH noinit, compression, stats=2
/*
Msg 945, Level 14, State 2, Line 100
Database 'VendasDB' cannot be opened due to inaccessible files or insufficient memory or disk space.  See the SQL Server errorlog for details.
Msg 3013, Level 16, State 1, Line 100
BACKUP LOG is terminating abnormally.
*/

BACKUP LOG VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH continue_after_error, noinit, compression, stats=2
-- ou
BACKUP LOG VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH no_truncate, noinit, compression, stats=2

/*************************************
 Recuperando o Banco de Dados
 1) Restore Backup FULL
 2) Restore Backup DIF
 3) Restore Backup LOG
 4) Restore Backup LOG (último "RM")
***************************************/
RESTORE HEADERONLY FROM DISK = 'C:\Backup\VendasDB.bak'

RESTORE DATABASE VendasDB FROM DISK = 'C:\Backup\VendasDB.bak' WITH file = 1, norecovery, replace, stats=2
RESTORE DATABASE VendasDB FROM DISK = 'C:\Backup\VendasDB.bak' WITH file = 2, norecovery, stats=2
RESTORE LOG VendasDB FROM DISK = 'C:\Backup\VendasDB.bak' WITH file = 3, norecovery, stats=2
RESTORE LOG VendasDB FROM DISK = 'C:\Backup\VendasDB.bak' WITH file = 4, recovery, stats=2


SELECT * FROM VendasDB.dbo.Clientes

