/**************************************
 Demonstração
 Autor: Landry Duailibe

 - SQL Server Agent Alertas
***************************************/
use master
go

DROP DATABASE IF exists AlertaDB
go
CREATE DATABASE AlertaDB
go
BACKUP DATABASE AlertaDB TO DISK = 'C:\Backup\AlertaDB.bak' WITH format, compression
go

ALTER DATABASE AlertaDB MODIFY FILE (name = 'AlertaDB_log', maxsize = 70mb)
go

/*******************************************************
 Alerta para código de erro 9002, arquivo de Log cheio
********************************************************/
use msdb
go

EXEC msdb.dbo.sp_add_alert @name=N'Transction Log FULL', @message_id=9002,@delay_between_responses=0 
EXEC msdb.dbo.sp_add_notification @alert_name=N'Transction Log FULL', @operator_name=N'Landry', @notification_method = 1

use AlertaDB
go

CREATE TABLE Cliente (
Cliente_ID int not null identity,
Nome char(6000) not null)
go

-- Gera atividade
DECLARE @i int = 1
WHILE @i <= 10000 BEGIN
	INSERT Cliente VALUES ('Jose')
	DELETE Cliente WHERE Nome = 'Jose'
	SET @i += 1
END
go


BACKUP LOG AlertaDB TO DISK = 'C:\Backup\AlertaDB.trn' WITH format, compression

/*******************************************************
 Alerta para contador do System Monitor
********************************************************/
use master
go
ALTER DATABASE AlertaDB MODIFY FILE (name = 'AlertaDB_log', size = 100mb ,maxsize = 100mb)
go

USE msdb
GO
EXEC msdb.dbo.sp_add_alert @name=N'Ocupacao Arq Log', 
@enabled=1, 
@delay_between_responses=0, 
@include_event_description_in=0, 
@performance_condition=N'Databases|Percent Log Used|AlertaDB|>|60', 
@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Ocupacao Arq Log', @operator_name=N'Landry', @notification_method = 1
GO

-- Gera atividade
use AlertaDB
go
DECLARE @i int = 1
WHILE @i <= 2000 BEGIN
	INSERT Cliente VALUES ('Jose')
	DELETE Cliente WHERE Nome = 'Jose'
	SET @i += 1
END
go




/********************************* Alertas Padrão *******************************************/

/****************************
 Operador
*****************************/
use msdb
go

EXEC msdb.dbo.sp_add_operator @name=N'DBA', 
@enabled=1, 
@weekday_pager_start_time=90000, 
@weekday_pager_end_time=180000, 
@saturday_pager_start_time=90000, 
@saturday_pager_end_time=180000, 
@sunday_pager_start_time=90000, 
@sunday_pager_end_time=180000, 
@pager_days=0, 
@email_address=N'dsai.erro@gmail.com', 
@category_name=N'[Uncategorized]'
GO

/************************************
 Alertas
*************************************/

-- Cria Alerta para codigo de erro
EXEC msdb.dbo.sp_add_alert @name=N'Suspect Pages Error', @message_id=824,@delay_between_responses=1800 
EXEC msdb.dbo.sp_add_alert @name=N'Transction Log FULL', @message_id=9002,@delay_between_responses=1800  
EXEC msdb.dbo.sp_add_alert @name=N'Transction Log nao esta disponivel', @message_id=9001,@delay_between_responses=1800 

-- Cria Alertas para Serverity 20 a 25 (erro fatal)
EXEC msdb.dbo.sp_add_alert @name=N'Erro Fatal Serverity 25', @severity=25,@delay_between_responses=1800 
EXEC msdb.dbo.sp_add_alert @name=N'Erro Fatal Serverity 24', @severity=24,@delay_between_responses=1800 
EXEC msdb.dbo.sp_add_alert @name=N'Erro Fatal Serverity 23', @severity=23,@delay_between_responses=1800 
EXEC msdb.dbo.sp_add_alert @name=N'Erro Fatal Serverity 22', @severity=22,@delay_between_responses=1800 
EXEC msdb.dbo.sp_add_alert @name=N'Erro Fatal Serverity 21', @severity=21,@delay_between_responses=1800 
EXEC msdb.dbo.sp_add_alert @name=N'Erro Fatal Serverity 20', @severity=20,@delay_between_responses=1800 
go


/******************************
 Criar operador DBA
*******************************/ 
EXEC msdb.dbo.sp_add_notification @alert_name=N'Suspect Pages Error', @operator_name=N'DBA', @notification_method = 1
EXEC msdb.dbo.sp_add_notification @alert_name=N'Transction Log FULL', @operator_name=N'DBA', @notification_method = 1
EXEC msdb.dbo.sp_add_notification @alert_name=N'Transction Log nao esta disponivel', @operator_name=N'DBA', @notification_method = 1

EXEC msdb.dbo.sp_add_notification @alert_name=N'Erro Fatal Serverity 25', @operator_name=N'DBA', @notification_method = 1
EXEC msdb.dbo.sp_add_notification @alert_name=N'Erro Fatal Serverity 24', @operator_name=N'DBA', @notification_method = 1
EXEC msdb.dbo.sp_add_notification @alert_name=N'Erro Fatal Serverity 23', @operator_name=N'DBA', @notification_method = 1
EXEC msdb.dbo.sp_add_notification @alert_name=N'Erro Fatal Serverity 22', @operator_name=N'DBA', @notification_method = 1
EXEC msdb.dbo.sp_add_notification @alert_name=N'Erro Fatal Serverity 21', @operator_name=N'DBA', @notification_method = 1
EXEC msdb.dbo.sp_add_notification @alert_name=N'Erro Fatal Serverity 20', @operator_name=N'DBA', @notification_method = 1
GO

