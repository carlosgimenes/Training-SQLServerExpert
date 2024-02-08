/*********************************************
 Autor: Landry Duailibe
 Demonstração Histórico Backup/Restore
**********************************************/
USE master
go
/*****************************************
 Histórico de Backup
******************************************/
SELECT * FROM msdb.dbo.backupmediafamily
SELECT * FROM msdb.dbo.backupset

SELECT a.backup_start_date as Datainicio,a.backup_finish_date as DataTermino,a.database_name as Banco, 
case a.type 
when 'D' then 'FULL'
when 'I' then 'DIF'
when 'L' then 'LOG' end as TipoBackup,
b.physical_device_name as ArquivoBackup,
a.user_name as usuario, a.is_copy_only
FROM  msdb..backupset a
JOIN msdb..backupmediafamily b on b.media_set_id = a.media_set_id
WHERE 1=1
--and database_name = 'Aula'
--and a.type <> 'L'
and backup_finish_date >= '20220601'
ORDER BY Banco,backup_finish_date desc

/*****************************************
 Histórico de Restore
******************************************/
SELECT * FROM msdb.dbo.restorehistory

SELECT restore_date as DataRestore, destination_database_name as Banco, user_name as 'Login',
case 
when restore_type = 'D' then 'FULL'
when restore_type = 'I' then 'DIF'
when restore_type = 'L' then 'LOG'
when restore_type = 'V' then 'VERIFY'
end as Tipo_Backup,
case [replace] when 0 then 'Não' else 'Sim' end [Replace],
case [recovery] when 0 then 'NoRecovery' else 'Recovery' end Tipo_Restor
FROM msdb.dbo.restorehistory
ORDER BY DataRestore desc

/*****************************************
 Limpa histórico de Backup
******************************************/
-- Limpa histórico backup
DECLARE @data date = dateadd(mm,-6,getdate())
--SELECT @data
EXEC msdb.dbo.sp_delete_backuphistory @oldest_date = @data 


/*********************************************************************
 Limpa histórico de Backup/Restore de um banco de dados específico
*********************************************************************/
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = 'VendasDB'

/********************************************
 Indices para evitar Deadlock
*********************************************/
USE msdb
GO
CREATE NONCLUSTERED INDEX NIX_BackupSet_Media_set_id
ON dbo.backupset (media_set_id)
--With (online=on)
GO

CREATE NONCLUSTERED INDEX NNX_BackupSet_Backup_set_id_Media_set_id
ON dbo.backupset
(backup_set_id, media_set_id)
--With (online=on)
GO

Create index IX_Backupset_Backup_set_uuid
on backupset(backup_set_uuid)
--With (online=on)
GO

Create index IX_Bbackupset_Media_set_id
on backupset(media_set_id)
--With (online=on)
GO

Create index IX_Backupset_Backup_finish_date_INC_Media_set_id
on backupset(backup_finish_date)
INCLUDE (media_set_id)
--With (online=on)
GO

Create index IX_backupset_backup_start_date_INC_Media_set_id
on backupset(backup_start_date)
INCLUDE (media_set_id)
--With (online=on)
GO

Create index IX_Backupmediaset_Media_set_id
on backupmediaset(media_set_id)
--With (online=on)
GO

Create index IX_Backupfile_Backup_set_id
on Backupfile(backup_set_id)
--With (online=on)
GO

Create index IX_Backupmediafamily_Media_set_id
on Backupmediafamily(media_set_id)
--With (online=on)
