/************************************************************
 Autor: Landry Duailibe

 COMPRESS()
 https://learn.microsoft.com/en-us/sql/t-sql/functions/compress-transact-sql?view=sql-server-ver16

 DECOMPRESS()
 https://learn.microsoft.com/en-us/sql/t-sql/functions/decompress-transact-sql?view=sql-server-ver16

 - utiliza algoritmo GZIP de compressão
*************************************************************/
USE Aula
go

-- Retorna um VARBINARY(max) com o resultado da compressão
SELECT COMPRESS('Olá, Bem vindo ao Canal SQL Server Expert') as [COMPRESS]

-- Retorna um VARBINARY(max) com o resultado da decompressão
SELECT DECOMPRESS(0x1F8B0800000000000400F3CF79A8A3E0949AAB5096999792AF9098AFE09C989798A3101CE8A3109C5A54965AA4E05A51905A5402002D988EE029000000) as [DECOMPRESS]

-- Conversão para VARCHAR
SELECT cast(DECOMPRESS(0x1F8B0800000000000400F3CF79A8A3E0949AAB5096999792AF9098AFE09C989798A3101CE8A3109C5A54965AA4E05A51905A5402002D988EE029000000) as varchar(max)) as [DECOMPRESS]

/***********************************************************************
 Eficiência do algoritmo GZIP com tamanhos de Strings diferentes

 - DATALENGTH: retorna a quantidade de Bytes
 https://learn.microsoft.com/pt-br/sql/t-sql/functions/datalength-transact-sql?view=sql-server-ver16
************************************************************************/
DECLARE @String1 VARCHAR(MAX) = 'Olá, Bem vindo ao Canal SQL Server Expert!'
DECLARE @String2 VARCHAR(MAX) = 'Olá, Bem vindo ao Canal SQL Server Expert! O objetivo deste canal é fornecer material técnico sobre o Microsoft SQL Server'
DECLARE @String3 VARCHAR(MAX) = 'Olá, Bem vindo ao Canal SQL Server Expert! O objetivo deste canal é fornecer material técnico sobre o Microsoft SQL Server, abrangendo atividades de administração e desenvolvimento de bancos de dados, desenvolvimento em Business Intelligence e Engenharia de dados.'

SELECT DATALENGTH(@String1) String1, DATALENGTH(COMPRESS(@String1)) as String1_Compressao,
       DATALENGTH(@String2) String2, DATALENGTH(COMPRESS(@String2)) as String2_Compressao,
	   DATALENGTH(@String3) String3, DATALENGTH(COMPRESS(@String3)) as String3_Compressao


/***************************************************************
 Coluna "Description" da tabela "Production.ProductDescription"
****************************************************************/
SELECT len(Description) FROM AdventureWorks.Production.ProductDescription ORDER BY 1 desc

DROP TABLE IF EXISTS Products
go
CREATE TABLE Products (
ProductID int,
[Name] nvarchar(50),
ProductModel nvarchar(50),
[Description] nvarchar(400),
Description_COMP varbinary(max))
go

-- Popula tabela com linhas a partir do Banco AdventureWorks
INSERT INTO Products (ProductID,[Name],ProductModel,[Description],Description_COMP)

SELECT ProductID,[Name],ProductModel,[Description],COMPRESS([Description]) as Description_COMP
FROM AdventureWorks.Production.vProductAndDescription

-- Consulta tabela
SELECT ProductID,[Name],ProductModel,[Description], Description_COMP,
CAST(DECOMPRESS(Description_COMP) AS NVARCHAR(400)) AS Description_COMP_CAST
FROM Products

-- Compara eficiência do algoritmo GZIP com tamanhos de Strings diferentes
SELECT ProductID,[Name],[Description],
DATALENGTH([Description]) as Tamanho_SemCOMP,
DATALENGTH(Description_COMP) AS Tamanho_COMP
FROM Products


-- Remove tabela
DROP TABLE IF EXISTS Products
go

