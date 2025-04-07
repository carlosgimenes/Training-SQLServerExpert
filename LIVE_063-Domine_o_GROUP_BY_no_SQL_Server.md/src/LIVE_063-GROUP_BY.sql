/*******************************
 Autor: Landry Duailibe
 
 LIVE #063 - GROUP BY
********************************/

/*********************************
 Funções de Agregação
**********************************/ 
use AdventureWorks
go

SELECT count(*) as TotLinhas, count(SalesPersonID) as TotSalesPerson,
avg(SalesPersonID) as MediaComNULL, avg(isnull(SalesPersonID,0)) as MediaSemNULL
FROM Sales.SalesOrderHeader


SELECT sum(TotalDue) as ValorTotalVendas
FROM Sales.SalesOrderHeader

SELECT count(*) as TotLinhas
FROM Sales.SalesOrderHeader
-- 31.465 linhas

SELECT count(CurrencyRateID) as TotLinhas
FROM Sales.SalesOrderHeader
-- 13.976 linhas com NOT NULL na coluna CurrencyRateID

SELECT *
FROM Sales.SalesOrderHeader
WHERE CurrencyRateID is null


/**************************
 GROUP BY
***************************/ 

SELECT CustomerID, sum(TotalDue) as Total
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CustomerID

-- Filtro WHERE
SELECT CustomerID, sum(TotalDue) as Total
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '20130101' and OrderDate < '20140101'
GROUP BY CustomerID
ORDER BY CustomerID

-- Filtro HAVING
SELECT CustomerID, sum(TotalDue) as Total
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '20130101' and OrderDate < '20140101'
GROUP BY CustomerID
HAVING sum(TotalDue) >= 5000
ORDER BY CustomerID

/**************************************************************************
 Mostrar FKs para agrupar pelo nome do cliente
 Tabelas Sales.SalesOrderHeader -> Sales.Customer -> Person.Person
***************************************************************************/
SELECT a.CustomerID,c.FirstName,c.MiddleName,c.LastName,sum(TotalDue) as Total
FROM Sales.SalesOrderHeader a
JOIN Sales.Customer b on b.CustomerID = a.CustomerID
JOIN Person.Person c on c.BusinessEntityID = b.PersonID
GROUP BY a.CustomerID,c.FirstName,c.MiddleName,c.LastName
ORDER BY CustomerID

/**************************************************************************
 Outras possibilidades de análise
 Tabelas Sales.SalesOrderHeader -> Sales.Customer -> Person.Person
								   Sales.Customer -> Sales.Store
								   Sales.Customer -> Sales.SalesTerritory
****************************************************************************/
SELECT * FROM Sales.Store
SELECT * FROM Sales.SalesTerritory

SELECT a.CustomerID,c.FirstName,c.MiddleName,c.LastName,sum(TotalDue) as Total
FROM Sales.SalesOrderHeader a
JOIN Sales.Customer b on b.CustomerID = a.CustomerID
JOIN Person.Person c on c.BusinessEntityID = b.PersonID
GROUP BY a.CustomerID,c.FirstName,c.MiddleName,c.LastName
ORDER BY CustomerID

SELECT d.[Group],d.Name as Territory,a.CustomerID,c.FirstName,c.MiddleName,c.LastName,sum(TotalDue) as Total
FROM Sales.SalesOrderHeader a
JOIN Sales.Customer b on b.CustomerID = a.CustomerID
JOIN Person.Person c on c.BusinessEntityID = b.PersonID
JOIN Sales.SalesTerritory d on d.TerritoryID = b.TerritoryID
GROUP BY d.[Group],d.Name,a.CustomerID,c.FirstName,c.MiddleName,c.LastName
ORDER BY [Group],Territory,CustomerID

SELECT d.[Group],d.Name as Territory,sum(TotalDue) as Total
FROM Sales.SalesOrderHeader a
JOIN Sales.Customer b on b.CustomerID = a.CustomerID
JOIN Person.Person c on c.BusinessEntityID = b.PersonID
JOIN Sales.SalesTerritory d on d.TerritoryID = b.TerritoryID
GROUP BY d.[Group],d.Name
ORDER BY [Group],Territory


/********************************************
 Retornar valores duplicados em uma chave
*********************************************/
SELECT * FROM Sales.SalesOrderDetail

SELECT SalesOrderID, count(*) as QtdLinhas
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING count(*) > 1

SELECT *
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43659

SELECT SalesOrderID, SalesOrderDetailID, count(*) as QtdLinhas
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID, SalesOrderDetailID
HAVING count(*) > 1
