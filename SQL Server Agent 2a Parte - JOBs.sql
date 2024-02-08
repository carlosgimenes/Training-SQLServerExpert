/**************************************
 Demonstração
 Autor: Landry Duailibe

 - JOB Backup e Atualização das Estatísticas
***************************************/
use master
go

-- Tarefa 1: Atualização Estatísticas - Banco Aula
use Aula
go

EXEC sp_updatestats

-- Tarefa 2: Backup - Banco MASTER
DECLARE @Arquivo varchar(4000) = 'C:\Backup'
SET @Arquivo = '\Aula_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','') + '.bak'

BACKUP DATABASE Aula TO DISK = @Arquivo WITH format, compression

