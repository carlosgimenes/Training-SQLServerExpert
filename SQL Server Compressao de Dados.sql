/************************************************************
 Autor: Landry Duailibe

 - Compreção de Dados em Tabelas e Indices no SQL Server
 https://learn.microsoft.com/en-us/previous-versions/sql/sql-server-2008/dd894051(v=sql.100)?redirectedfrom=MSDN
*************************************************************/
USE master
go

DROP DATABASE IF exists DB_Compressao
go
CREATE DATABASE DB_Compressao
go
ALTER DATABASE DB_Compressao SET recovery simple
go

USE DB_Compressao
go

/**************************
 1) Tabela Sem Compressão
***************************/
DROP TABLE IF exists dbo.Produto
go
CREATE TABLE dbo.Produto ( 
ProdutoID int not null primary key, 
Produto char(100) null,
Modelo char(100) null,
Cor char(15) null,
ValorUnitario decimal(18,4) null,
Data_Ini_Venda datetime null,
Data_Fim_Venda datetime null)
go

DECLARE @i int = 0

WHILE @i <= 10000000 BEGIN

	INSERT INTO dbo.Produto 

	SELECT a.ProductID + @i as ProdutoID, b.[Name] + isnull(' - ' + b.[name],'') as Produto,
	b.[name] as Modelo, a.Color as Cor, a.ListPrice as Valorunitario, 
	a.SellStartDate as Data_Ini_Venda, a.SellEndDate as Data_Fim_Venda
	FROM AdventureWorks.Production.Product a
	JOIN AdventureWorks.Production.ProductModel b on b.ProductModelID = a.ProductModelID 

	SET @i += 1000
END
go
UPDATE dbo.Produto SET Produto = 'Valor Pesquisa' WHERE ProdutoID = 994
-- +- 1 minuto

SELECT count(*) FROM dbo.Produto -- 2.950.295 linhas

/*************************
 https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-estimate-data-compression-savings-transact-sql?view=sql-server-ver16

 - size_with_current_compression_setting (KB): Size of the requested table, index, or partition as it currently exists.
 - size_with_requested_compression_setting (KB): Estimated size of the table, index, or partition that uses the requested compression setting; and, if applicable, the existing fill factor, and assuming there's no fragmentation.
 - sample_size_with_current_compression_setting (KB): Size of the sample with the current compression setting. This includes any fragmentation.
 - sample_size_with_requested_compression_setting (KB):	Size of the sample that is created by using the requested compression setting; and, if applicable, the existing fill factor and no fragmentation.
**************************/
EXEC sp_estimate_data_compression_savings @schema_name = 'dbo', @object_name = 'Produto', @index_id = NULL, @partition_number = NULL, @data_compression = 'ROW'
EXEC sp_estimate_data_compression_savings @schema_name = 'dbo', @object_name = 'Produto', @index_id = NULL, @partition_number = NULL, @data_compression = 'PAGE'


/***********************************
 2) Tabela Com Compressão de Linha
************************************/
DROP TABLE IF exists dbo.Produto_Comp_Row
go
CREATE TABLE dbo.Produto_Comp_Row ( 
ProdutoID int not null primary key, 
Produto char(100) null,
Modelo char(100) null,
Cor char(15) null,
ValorUnitario decimal(18,4) null,
Data_Ini_Venda datetime null,
Data_Fim_Venda datetime null)
WITH (DATA_COMPRESSION = ROW)
go

INSERT dbo.Produto_Comp_Row SELECT * FROM dbo.Produto

/***********************************
 3) Tabela Com Compressão de Página
************************************/
DROP TABLE IF exists dbo.Produto_Comp_Page
go
CREATE TABLE dbo.Produto_Comp_Page ( 
ProdutoID int not null primary key, 
Produto char(100) null,
Modelo char(100) null,
Cor char(15) null,
ValorUnitario decimal(18,4) null,
Data_Ini_Venda datetime null,
Data_Fim_Venda datetime null)
WITH (DATA_COMPRESSION = PAGE)
go

INSERT dbo.Produto_Comp_Page SELECT * FROM dbo.Produto

/**********************************************
 Compressão em Tabelas pré existentes
***********************************************/
ALTER TABLE dbo.Produto REBUILD WITH (DATA_COMPRESSION = NONE) 
ALTER TABLE dbo.Produto REBUILD WITH (DATA_COMPRESSION = ROW) 
ALTER TABLE dbo.Produto REBUILD WITH (DATA_COMPRESSION = PAGE) 

/***********************************************
 Avaliando o desempenho
************************************************/
-- Atualiza informações de ocupação de espaço
EXEC sp_spaceused @updateusage = N'TRUE'

EXEC sp_spaceused @oneresultset = 1 

EXEC sp_spaceused 'dbo.Produto'
EXEC sp_spaceused 'dbo.Produto_Comp_Row'
EXEC sp_spaceused 'dbo.Produto_Comp_Page'

SELECT c.name + '.' + b.name as Tabela, a.rows as QtdLinhas, 
d.used_pages as QtdPaginas, (d.used_pages * 8) / 1024 as Tamanho_MB,
a.data_compression_desc as Compressao
FROM sys.partitions a
JOIN sys.tables b on b.object_id = a.object_id
JOIN sys.schemas c on c.schema_id = b.schema_id
JOIN sys.allocation_units d ON a.partition_id = d.container_id
WHERE b.name like 'Produto%'

/*
Tabela					QtdLinhas	QtdPaginas	Tamanho_MB	Compressao
dbo.Produto				2950295		92541		722			NONE
dbo.Produto_Comp_Page	2950295		15063		117			PAGE
dbo.Produto_Comp_Row	2950295		29985		234			ROW
*/
set statistics io on
set statistics io off

set statistics time on
set statistics time off

CHECKPOINT
dbcc freeproccache
dbcc dropcleanbuffers
dbcc freesystemcache ('ALL')
dbcc freesessioncache

SELECT * FROM dbo.Produto 
WHERE Produto = 'Valor Pesquisa'
OPTION (MAXDOP 1)
-- Paralelo -> Table 'Produto'. Scan count 4, logical reads 93907
-- Serial   -> Table 'Produto'. Scan count 1, logical reads 92541
-- 1a) CPU time = 656 ms,  elapsed time = 5463 ms.


SELECT * FROM dbo.Produto_Comp_Row 
WHERE Produto = 'Valor Pesquisa'
OPTION (MAXDOP 1)
-- Paralelo -> Table 'Produto_Comp_Row'. Scan count 4, logical reads 30455
-- Serial   -> Table 'Produto_Comp_Row'. Scan count 1, logical reads 29985
-- 1a) CPU time = 609 ms,  elapsed time = 798 ms.


SELECT * FROM dbo.Produto_Comp_Page 
WHERE Produto = 'Valor Pesquisa'
OPTION (MAXDOP 1)
-- Paralelo -> Table 'Produto'. Scan count 4, logical reads 15297
-- Serial   -> Table 'Produto'. Scan count 1, logical reads 15063
-- 1a) CPU time = 578 ms,  elapsed time = 700 ms.



/***********************************
 Estatísticas de Update
 Fonte: Microsoft Learning
************************************/
SELECT o.name AS [Table_Name], x.name AS [Index_Name],
       i.partition_number AS [Partition],
       i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
       i.leaf_update_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) AS [Percent_Update]
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
WHERE (i.range_scan_count + i.leaf_insert_count
       + i.leaf_delete_count + leaf_update_count
       + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
AND objectproperty(i.object_id,'IsUserTable') = 1
ORDER BY [Percent_Update] ASC

UPDATE top(100000) dbo.Produto SET produto = upper(Produto)

/***********************************
 Estatísticas de Scan
 Fonte: Microsoft Learning
************************************/
SELECT o.name AS [Table_Name], x.name AS [Index_Name],
       i.partition_number AS [Partition],
       i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
       i.range_scan_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) AS [Percent_Scan]
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
WHERE (i.range_scan_count + i.leaf_insert_count
       + i.leaf_delete_count + leaf_update_count
       + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
AND objectproperty(i.object_id,'IsUserTable') = 1
ORDER BY [Percent_Scan] DESC

SELECT * FROM dbo.Produto_Comp_Page 
WHERE Produto = 'Valor Pesquisa'
go 50


