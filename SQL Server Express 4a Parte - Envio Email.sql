/********************************************************
 Autor: Landry Duailibe

 Database Mail no SQL Server Express
 - NÃO MOSTRAR CONFIG ORIGINAL SMTP DSAI

 SPs Database Mail:
 https://learn.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sysmail-add-account-sp-transact-sql?view=sql-server-ver16
********************************************************/
use msdb
go

/******************************************
 Cria conta SMTP
 - SP: msdb.dbo.sysmail_add_account_sp
 - SP: msdb.dbo.sysmail_delete_account_sp
 - VIEW: msdb.dbo.sysmail_account
******************************************/

-- CRIA Conta SMTP
EXECUTE msdb.dbo.sysmail_add_account_sp 
@account_name            = 'SQLProfileSMTP', 
@email_address           = 'landry@xpto.com.br', 
@display_name            = 'Aula SQL Server Express', 
@replyto_address         = 'noreply@xpto.com.br', 
@description             = 'Conta SMTP', 
@mailserver_name         = 'smtp.xpto.com.br', 
@mailserver_type         = 'SMTP', 
@port                    = '587', 
@username                = 'landry@xpto.com.br', 
@password                = '*******',  
@use_default_credentials =  0 , 
@enable_ssl              =  1

-- EXCLUI Conta SMTP
EXEC msdb.dbo.sysmail_delete_account_sp @account_name = 'SQLProfileSMTP'

SELECT * FROM msdb.dbo.sysmail_account

/******************************************
 Cria Profile SMTP
 - SP: msdb.dbo.sysmail_add_profile_sp
 - SP: msdb.dbo.sysmail_delete_profile_sp
 - VIEW: msdb.dbo.sysmail_profile
*******************************************/

-- CRIA Profile SMTP 
EXECUTE msdb.dbo.sysmail_add_profile_sp 
@profile_name = 'SQLProfileSMTP', 
@description  = 'Profile SMTP'

-- EXCLUI Conta SMTP
EXEC msdb.dbo.sysmail_delete_profile_sp @profile_name = 'SQLProfileSMTP'

SELECT * FROM msdb.dbo.sysmail_profile

/****************************************************
 Associa Profile com Conta SMTP
 - SP: msdb.dbo.sysmail_add_profileaccount_sp
 - SP: msdb.dbo.sysmail_delete_profileaccount_sp
 - VIEW: msdb.dbo.sysmail_profileaccount
****************************************************/

-- CRIA Associação
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
@profile_name = 'SQLProfileSMTP', 
@account_name = 'SQLProfileSMTP', 
@sequence_number = 1 

-- EXCLUI Associação
EXEC msdb.dbo.sysmail_delete_profileaccount_sp
@profile_name = 'SQLProfileSMTP',
@account_name = 'SQLProfileSMTP'

SELECT * 
FROM msdb.dbo.sysmail_profileaccount pa 
INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
WHERE p.name = 'SQLProfileSMTP'


/**************************************
 Enviando Email de Teste
***************************************/

EXEC msdb.dbo.sp_send_dbmail  
@profile_name = 'SQLProfileSMTP',  
@recipients = 'proflandry.sqlexpert@gmail.com',  
@body = 'Teste de envio de email a partir do SQL Server Express',  
@subject = 'Teste de envio de email'
go
/*
Msg 15281, Level 16, State 1, Procedure msdb.dbo.sp_send_dbmail, Line 0 [Batch Start Line 75]
SQL Server blocked access to procedure 'dbo.sp_send_dbmail' of component 'Database Mail XPs' because this component is turned off as part of the security configuration for this server. A system administrator can enable the use of 'Database Mail XPs' by using sp_configure. For more information about enabling 'Database Mail XPs', search for 'Database Mail XPs' in SQL Server Books Online.
*/

EXEC sp_configure 'show advanced options', 1
go
RECONFIGURE
go
 
-- Habilita Database Mail XPs
EXEC sp_configure 'Database Mail XPs', 1
go
RECONFIGURE
go

/**************************************
 Enviando Email
***************************************/

EXEC msdb.dbo.sp_send_dbmail  
@profile_name = 'SQLProfileSMTP',  
@recipients = 'proflandry.sqlexpert@gmail.com',  
@body = 'Teste de envio de email a partir do SQL Server Express, com arquivo anexado.',  
@importance='High',
@sensitivity='Confidential',  
@file_attachments='C:\Scripts_Canal\SQL Server Express 4a Parte - Envio Email.sql',
@subject = 'Teste de envio de email com anexo'
go

