/*****************************************************
 Autor: Landry Duailibe
 
 LIVE #063 - GROUP BY com CUBE, ROLLUP e GROUPING
*****************************************************/
use Aula
go
DROP TABLE IF exists dbo.Venda
go
CREATE TABLE dbo.Venda (
VendedorID varchar(50), 
Ano int, 
Valor decimal(10,2))
go

INSERT dbo.Venda VALUES(1, 2005, 12000),
(1, 2005, 48000),(1, 2005, 500)

INSERT dbo.Venda VALUES(1, 2006, 18000),
(1, 2006, 65500),(1, 2006, 560)

INSERT dbo.Venda VALUES(1, 2007, 25000),
(1, 2007, 54400),(1, 2007, 340)

INSERT dbo.Venda VALUES(2, 2005, 15000),
(2, 2005, 76000),(2, 2005, 324)

INSERT dbo.Venda VALUES(2, 2006, 6000),
(2, 2006, 15000),(2, 2006, 890)

INSERT dbo.Venda VALUES(3, 2006, 20000),
(3, 2006, 89000),(3, 2006, 765)

INSERT dbo.Venda VALUES(3, 2007, 24000),
(3, 2007, 56000),(3, 2007, 123)
go

/**********************
 GROUP BY
***********************/
SELECT * FROM dbo.Venda order by VendedorID, Ano

SELECT VendedorID, Ano, sum(Valor) as Valor
FROM dbo.Venda
GROUP BY VendedorID, Ano
ORDER BY VendedorID, Ano

SELECT VendedorID,  sum(Valor) as Valor
FROM dbo.Venda
GROUP BY VendedorID
ORDER BY VendedorID

/**********************
 GROUP BY com ROLLUP
***********************/
SELECT * FROM dbo.Venda order by VendedorID, Ano

SELECT VendedorID, Ano, sum(Valor) as Valor
FROM dbo.Venda
GROUP BY VendedorID, Ano WITH ROLLUP
ORDER BY VendedorID, Ano

SELECT Ano,VendedorID, SUM(Valor) AS Valor
FROM dbo.Venda
GROUP BY Ano,VendedorID WITH ROLLUP
ORDER BY Ano,VendedorID

/**********************
 GROUP BY com CUBE
***********************/
SELECT VendedorID, Ano, sum(Valor) as Valor
FROM dbo.Venda
GROUP BY VendedorID, Ano WITH CUBE
ORDER BY VendedorID, Ano

SELECT Ano,VendedorID, sum(Valor) as Valor
FROM dbo.Venda
GROUP BY Ano,VendedorID WITH CUBE
ORDER BY Ano,VendedorID

/*********************************
 GROUPING SET = ROLLUP ou CUBE
**********************************/
SELECT VendedorID, Ano, sum(Valor) as Valor
FROM dbo.Venda
GROUP BY VendedorID, Ano WITH ROLLUP
ORDER BY VendedorID, Ano

SELECT VendedorID, Ano, sum(Valor) as Valor
FROM dbo.Venda
GROUP BY GROUPING SETS((VendedorID, Ano),(VendedorID),())
ORDER BY VendedorID, Ano

SELECT VendedorID, Ano, sum(Valor) as Valor
FROM dbo.Venda
GROUP BY GROUPING SETS((VendedorID, Ano),())
ORDER BY VendedorID, Ano


-- CUBE
SELECT VendedorID, Ano, SUM(Valor) AS Valor
FROM dbo.Venda
GROUP BY GROUPING SETS((VendedorID, Ano),(VendedorID),(Ano),())
ORDER BY VendedorID, Ano


/************************
 Exclui tabela
*************************/
use Aula
go
DROP TABLE IF exists dbo.Venda
go