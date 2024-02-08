/**************************************
 Demonstração
 Autor: Landry Duailibe

 - Transaction Log
***************************************/
USE master
go

DROP DATABASE IF exists DB_HandsOn

CREATE DATABASE DB_HandsOn ON
(NAME = 'DB_HandsOn', FILENAME = 'C:\MSSQL_Data\DB_HandsOn.mdf', SIZE = 512MB,FILEGROWTH = 100MB)
LOG ON 
(NAME = 'DB_HandsOn_log', FILENAME = 'C:\MSSQL_Data\DB_HandsOn_log.ldf', SIZE = 1MB,FILEGROWTH = 1MB)
go

ALTER DATABASE DB_HandsOn SET RECOVERY FULL

DBCC SQLPERF (LOGSPACE)
/*
Log Size (MB): 0.9921875
Log Space Used (%): 42.51968
*/


USE DB_HandsOn
go
CREATE TABLE Teste (c1 INT IDENTITY, C2 CHAR (8000) DEFAULT (REPLICATE ('F', 8000)));
go 

-- Transação vai ficar aberta!!
set nocount on

BEGIN TRAN

DECLARE @i int
set @i = 0
WHILE (@i < 50500)
BEGIN
   INSERT INTO Teste DEFAULT VALUES
   SELECT @i = @i + 1
END

DBCC SQLPERF (LOGSPACE)
/* 
O Transaction Log passou de 0,34 MB para 534 MB:

Log Size (MB): 0.9921875 -> 534.9922
Log Space Used (%): 42.51968 -> 99.84302
*/


SELECT log_reuse_wait_desc 
FROM sys.databases
WHERE [name] = 'DB_HandsOn'
-- ACTIVE_TRANSACTION

-- Finaliza a transação com COMMIT
COMMIT
go
CHECKPOINT

DBCC SQLPERF (LOGSPACE)
/* 
O Transaction Log passou de 0,34 MB para 534 MB:

Log Size (MB): 0.9921875 -> 534.9922 -> 535.9922
Log Space Used (%): 42.51968 -> 99.84302 -> 3.328377
*/


-- Exclui Banco
use master
go
DROP DATABASE IF exists DB_HandsOn

