/*******************************************
 Autor: Landry Duailibe
 
 Hands On: Usu�rios �rf�os
********************************************/
USE master
go

-- Cria Login Teste01
CREATE LOGIN Teste01 WITH PASSWORD=N'1234', CHECK_POLICY=OFF
CREATE LOGIN Teste02 WITH PASSWORD=N'1234', CHECK_POLICY=OFF
CREATE LOGIN Teste03 WITH PASSWORD=N'1234', CHECK_POLICY=OFF
go

/***********************
 Preparando Hands On 
***********************/
DROP DATABASE IF exists HandsOn
go
CREATE DATABASE HandsOn
go

USE HandsOn
go
-- DROP TABLE dbo.Clientes 
CREATE TABLE dbo.Clientes 
(ClienteID int not null primary key,Nome varchar(50),Telefone varchar(20))
go

INSERT dbo.Clientes VALUES 
(1,'Jose','1111-1111'),
(2,'Maria','2222-2222'),
(3,'Maria','3333-3333')
go

SELECT * FROM HandsOn.dbo.Clientes



-- Cria Usu�rio de Banco de Dados
CREATE USER Teste01 FOR LOGIN Teste01
CREATE USER Teste02 FOR LOGIN Teste02
CREATE USER Teste03 FOR LOGIN Teste03
go

ALTER ROLE db_datareader ADD MEMBER Teste01
ALTER ROLE db_datawriter ADD MEMBER Teste01

ALTER ROLE db_datareader ADD MEMBER Teste02
ALTER ROLE db_datareader ADD MEMBER Teste03
go

/********************************** Fim Prepara Hands On *************************************/


/***************
 Backup
****************/
USE master
go
BACKUP DATABASE HandsOn TO DISK = 'C:\_LIVE\Backup\HandsOn.bak' WITH format,compression


/*******************************************
 Restore em outra inst�ncia
********************************************/
USE master
go
RESTORE DATABASE HandsOn FROM DISK = 'C:\_LIVE\Backup\HandsOn.bak' with recovery,replace,
MOVE 'HandsOn' TO 'C:\MSSQL_Data_SQL02\HandsOn.mdf',
MOVE 'HandsOn_log' TO 'C:\MSSQL_Data_SQL02\HandsOn_log.ldf'

USE HandsOn
go

/*****************************************
 Identificando Usu�rios �rf�os
 https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-change-users-login-transact-sql?view=sql-server-ver16
******************************************/
EXEC sp_change_users_login @Action = 'Report'

-- ou

SELECT dp.[sid] as SID_UsuarioBD, dp.[name] as UsuarioBD, 
sp.[sid] as SID_Login, sp.[name] as [Login],
dp.type_desc as Tipo, dp.authentication_type_desc 
FROM sys.database_principals dp  
LEFT JOIN sys.server_principals sp ON dp.[sid] = sp.[sid]  
WHERE 1=1
and sp.sid IS NULL 
and dp.authentication_type_desc = 'INSTANCE'
ORDER BY UsuarioBD

-- Cria Login Teste01
CREATE LOGIN Teste01 WITH PASSWORD = '1234', CHECK_POLICY=OFF
go
-- Mostrar que continua sem link com Usu�rio de Banco

EXEC sp_change_users_login @Action = 'Report'

-- JOIN pelo nome
SELECT dp.[sid] as SID_UsuarioBD, dp.[name] as UsuarioBD, 
sp.[sid] as SID_Login, sp.[name] as [Login],
dp.[type_desc] as Tipo, dp.authentication_type_desc 
FROM sys.database_principals dp  
LEFT JOIN sys.server_principals sp ON dp.[name] = sp.[name]
WHERE 1=1
--and sp.sid IS NULL 
and dp.authentication_type_desc = 'INSTANCE'
ORDER BY UsuarioBD

/***********************************************************
 1) Resolvendo criando o Login com mesmo SID do usu�rio
************************************************************/
CREATE LOGIN Teste02 WITH PASSWORD = '1234',  CHECK_POLICY=OFF,
SID = 0x85FD9ABCB64BEA4094A0235E99ADAB10

/***********************************************************
 2) Resolvendo utilizando sp_change_users_login
    - O problema � que altera o SID do Usu�rio para ficar
	  igual ao Login.
	- Toda vez que restaurar o banco, vai ter que fazer
	  o mesmo procedimento.
************************************************************/

EXEC sp_change_users_login @Action = 'Update_One', @UserNamePattern = 'Teste01', @LoginName = 'Teste01'

EXEC sp_change_users_login @Action = 'Auto_Fix', @UserNamePattern = 'Teste01', @LoginName = null


/***************************
 Remove objetos do Hands On
****************************/
use master
go
DROP DATABASE If exists HandsOn
go
DROP LOGIN Teste01
DROP LOGIN Teste02
DROP LOGIN Teste03
go