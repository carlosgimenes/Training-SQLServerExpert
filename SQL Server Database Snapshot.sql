/**************************************
 Demonstração
 Autor: Landry Duailibe

 - Database Snapshot
***************************************/
USE Master
go

DROP DATABASE IF exists Vendas_DB
go

CREATE DATABASE Vendas_DB
ON 
(name='Vendas_DB', filename='C:\MSSQL_Data\Vendas_DB.mdf', size=10MB, filegrowth=5MB)
LOG ON 
(name='Vendas_DB_log', filename='C:\MSSQL_Data\Vendas_DB_log.ldf', size=5MB, filegrowth=1MB) 
go

EXEC sp_helpdb Vendas_DB

use Vendas_DB
go
EXEC sp_helpfile

CREATE TABLE Cliente (
Cliente_PK int not null primary key,
Nome varchar(40) not null,
Sexo char(1) null,
Telefone varchar(20) null)
go

INSERT Cliente (Cliente_PK, Nome, Sexo, Telefone)
VALUES (1,'Jose','M','2343-2289')

INSERT Cliente (Cliente_PK, Nome, Sexo, Telefone)
VALUES (2,'Ana','F','3432-2184')

INSERT Cliente (Cliente_PK, Nome, Sexo, Telefone)
VALUES (3,'Maria','F','5449-2580')
go

CREATE DATABASE Vendas_DB_Hist ON
(NAME = 'Vendas_DB', FILENAME = 'C:\MSSQL_Data\Vendas_DB.ss')
AS SNAPSHOT OF Vendas_DB
go

/*********************** FIM Prepara ambiente ************************/

SELECT * FROM Vendas_DB.dbo.Cliente
SELECT * FROM Vendas_DB_Hist.dbo.Cliente

-- Esta nova linha vai aparecer no Snapshot?
INSERT Cliente (Cliente_PK, Nome, Sexo, Telefone)
VALUES (4,'Landry','M','99125-5579')

-- Qual será o conteúdo da coluna "Nome" no Snapshot?
UPDATE Cliente SET Nome = 'Ana Claudia' WHERE Cliente_PK = 2

-- Qual será o conteúdo da coluna "Nome" no Snapshot?
UPDATE Cliente SET Nome = 'Ana Claudia Soares' WHERE Cliente_PK = 2


-- Exclui todas as linhas e recupera utilizando Snapshot
TRUNCATE TABLE Cliente

INSERT Cliente SELECT * FROM Vendas_DB_Hist.dbo.Cliente


use master
go

RESTORE DATABASE Vendas_DB
FROM DATABASE_SNAPSHOT = 'Vendas_DB_Hist'


-- Drop database
DROP DATABASE Vendas_DB_Hist
DROP DATABASE Vendas_DB

