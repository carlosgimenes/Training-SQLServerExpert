/********************************************
 Evento Imersão SQL Server 2025
 Autor: Landry Duailibe

 Backup Todos os Bancos - FULL
*********************************************/
use master
go

/******************************************************
 Cria tabela para excluir bancos da rotina de Backup
*******************************************************/
DROP TABLE IF exists DBA.dbo.DBA_BackupExcluir
go
CREATE TABLE DBA.dbo.DBA_BackupExcluir (
Nomebanco sysname not null primary key)
go
INSERT DBA.dbo.DBA_BackupExcluir VALUES ('DBA')
go

SELECT Nomebanco FROM DBA.dbo.DBA_BackupExcluir


/****************************************************
 Criar JOB
 Step 1) Backup de todos os bancos para uma pasta
*****************************************************/ 
DECLARE @Caminho varchar(4000), @Banco varchar(500), @Compacta char(1),@Arquivo varchar(4000)
DECLARE @state_desc varchar(200)
SET @Caminho = 'C:\_LIVE\Backup\FULL\' 
SET @Compacta = 'S'

IF object_id('dbo.tmpBancosBackupFULL') is not null
   DROP TABLE dbo.tmpBancosBackupFULL

SELECT name,state_desc 
INTO dbo.tmpBancosBackupFULL 
FROM sys.databases 
WHERE source_database_id is null
and state_desc = 'ONLINE' 
and name not in ('tempdb','model') 
and name not in (SELECT Nomebanco FROM DBA.dbo.DBA_BackupExcluir)
ORDER BY name

DECLARE vCursor CURSOR FOR
SELECT name,state_desc FROM dbo.tmpBancosBackupFULL ORDER BY NAME

OPEN vCursor
FETCH NEXT FROM vCursor INTO @Banco, @state_desc

WHILE @@FETCH_STATUS = 0 BEGIN

   IF db_id(@Banco) is null BEGIN
      PRINT '*** ERRO: DB_ID retornou NULL para o banco ' + @Banco 
      FETCH NEXT FROM vCursor INTO @Banco, @state_desc
      CONTINUE
   END
   
   IF @state_desc <> 'ONLINE' BEGIN
     PRINT '*** Banco: ' +  @Banco + ' está: ' + @state_desc
     FETCH NEXT FROM vCursor INTO @Banco,@state_desc 
     CONTINUE
  END

   PRINT 'Backup do Banco de Dados: ' + @Banco 
   SET @Arquivo = @Banco + '_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','')

   IF @Compacta = 'S'
      exec('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + '.bak'' WITH FORMAT, COMPRESSION')
   ELSE
      exec('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + '.bak'' WITH FORMAT')

   IF @@ERROR <> 0 BEGIN
      PRINT '*** ERRO: backup do banco ' + @Banco + ' - Código de erro: ' + ltrim(str(@@error))
      FETCH NEXT FROM vCursor INTO @Banco, @state_desc
      CONTINUE
   END   
   FETCH NEXT FROM vCursor INTO @Banco, @state_desc

END

CLOSE vCursor
DEALLOCATE vCursor

IF object_id('dbo.tmpBancosBackupFULL') is not null
   DROP TABLE dbo.tmpBancosBackupFULL
go


/********************************************
 Step 2) Exclui Histórico dos Backups
*********************************************/
DECLARE @DelDate datetime
SET @DelDate = DATEADD(wk,-4,getdate())

EXECUTE master.dbo.xp_delete_file 0,N'C:\_LIVE\Backup\FULL',N'bak',@DelDate,0
go

