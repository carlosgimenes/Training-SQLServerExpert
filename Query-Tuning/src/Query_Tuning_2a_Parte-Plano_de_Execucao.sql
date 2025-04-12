/**************************************
 Demonstração Plano de Execução
 Autor: Landry Duailibe
***************************************/
USE AdventureWorks
go


/*******************
 Plano de Execução
 - Texto
********************/
SET STATISTICS PROFILE ON
SET STATISTICS PROFILE OFF

SET STATISTICS IO ON
SET STATISTICS IO OFF

SET STATISTICS TIME ON
SET STATISTICS TIME OFF

SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20140604'
/*
Table 'Person'. Scan count 0, logical reads 97
Table 'Customer'. Scan count 0, logical reads 68
Table 'SalesOrderHeader'. Scan count 1, logical reads 689

Total de IO = 854pg x 8kb = 6832kb = 6.67mb
*/

/*******************
 Plano de Execução
 - XML
********************/
SET STATISTICS XML ON
SET STATISTICS XML OFF

SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20140604'

/*******************
 Plano Estimado
********************/
-- Texto
SET SHOWPLAN_ALL ON 
SET SHOWPLAN_ALL OFF

-- XML
SET SHOWPLAN_XML ON
SET SHOWPLAN_XML ON

SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20140604'

