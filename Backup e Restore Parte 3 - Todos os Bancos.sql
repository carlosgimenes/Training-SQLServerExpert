/*********************************************
 Autor: Landry Duailibe
 Demonstração Backup todos os Bancos
**********************************************/
USE master
go

DECLARE @Caminho varchar(4000), @Banco varchar(500), @Compacta char(1),@Arquivo varchar(4000)
DECLARE @state_desc varchar(200)
SET @Caminho = 'C:\BackupDB\FULL' 
SET @Compacta = 'S'

IF object_id('dbo.tmpBancosBackupFULL') is not null
   DROP TABLE dbo.tmpBancosBackupFULL

SELECT [name],state_desc 
INTO dbo.tmpBancosBackupFULL 
FROM sys.databases 
WHERE source_database_id is null
and state_desc = 'ONLINE' 
and [name] not in ('tempdb') 
ORDER BY [name]

DECLARE vCursor cursor FOR
SELECT [name],state_desc FROM dbo.tmpBancosBackupFULL ORDER BY [name]

OPEN vCursor
FETCH NEXT FROM vCursor INTO @Banco, @state_desc
WHILE @@FETCH_STATUS = 0
BEGIN   

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
   SET @Arquivo = '\' + @Banco + '_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','')

   IF @Compacta = 'S'
      EXEC('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + '.bak'' WITH FORMAT, COMPRESSION')
   ELSE
      EXEC('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + '.bak'' WITH FORMAT')

   IF @@ERROR <> 0 BEGIN
      PRINT '*** ERRO: backup do banco ' + @Banco + ' - Código de erro: ' + ltrim(str(@@error))
      FETCH NEXT FROM vCursor INTO @Banco, @state_desc
      CONTINUE
   END   
   FETCH NEXT FROM vCursor INTO @Banco, @state_desc
END
CLOSE vCursor
DEALLOCATE vCursor

if object_id('dbo.tmpBancosBackupFULL') is not null
   DROP TABLE dbo.tmpBancosBackupFULL
go


/********************************************
 Exclui Histórico dos Backups
*********************************************/
DECLARE @Caminho varchar(4000) = 'C:\BackupDB\FULL'
DECLARE @DelDate datetime
SET @DelDate = DATEADD(wk,-1,getdate())

EXECUTE master.dbo.xp_delete_file 0,@Caminho,'bak',@DelDate,0
go


/* Apaga Banco
use master
go
DROP DATABASE VendasDB
*/
