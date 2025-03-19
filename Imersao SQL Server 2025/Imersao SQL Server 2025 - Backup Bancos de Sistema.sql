/********************************************
 Evento Imersão SQL Server 2025
 Autor: Landry Duailibe

 Backup Bancos de Sistema
*********************************************/
use master
go

/***************************************************
 Backup Master e MSDB
****************************************************/
DECLARE @Arquivo varchar(4000),@Caminho varchar(4000)
set @Caminho = 'C:\_LIVE\Backup\'

set @Arquivo = @Caminho + 'master_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','') + '.bak'
BACKUP DATABASE master TO DISK = @Arquivo WITH FORMAT, COMPRESSION

set @Arquivo = @Caminho + 'msdb_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','') + '.bak'
BACKUP DATABASE msdb TO DISK = @Arquivo WITH FORMAT, COMPRESSION
go