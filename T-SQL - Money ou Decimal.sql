/**************************************
 HandsOn
 Autor: Landry Duailibe

 - Tipos de Dados Money x Decimal
***************************************/
use Aula
go


DROP TABLE IF exists Venda_Money
DROP TABLE IF exists Venda_Decimal
go
CREATE TABLE Venda_Money (Venda_Id int not null,
Valor_Total MONEY null,
Valor_Desconto MONEY null,
Valor_Liquido MONEY)
go

CREATE TABLE Venda_Decimal (Venda_Id int not null,
Valor_Total DECIMAL(19,4) null,
Valor_Desconto DECIMAL(19,4) null,
Valor_Liquido DECIMAL(19,4))
go

-- SMALLMONEY -> ocupa 4 bytes = 999.999,9999
-- MONEY -> ocupa 8 bytes = 999.999.999.999.999,9999
-- https://learn.microsoft.com/en-us/sql/t-sql/data-types/money-and-smallmoney-transact-sql?view=sql-server-ver16

-- DECIMAL(19,4) -> ocupa 9 bytes = 999.999.999.999.999,9999
-- DECIMAL(9,4) -> ocupa 5 bytes = 99.999,9999
-- https://learn.microsoft.com/en-us/sql/t-sql/data-types/decimal-and-numeric-transact-sql?view=sql-server-ver16

/******************************************************
 Alimenta tabela Venda_Money com 1 milhão de linhas
*******************************************************/
set nocount on

DECLARE @i int = 1

WHILE @i <= 200000 BEGIN
	INSERT Venda_Money VALUES (@i,100.1010 + @i, 5.2020 + @i, 90.4545 + @i)
	SET @i += 1
END
go
-- 30 segundos


/******************************************************
 Alimenta tabela Venda_Decimal com 1 milhão de linhas
*******************************************************/
set nocount on

DECLARE @i int = 1

WHILE @i <= 200000 BEGIN
	INSERT Venda_Decimal VALUES (@i,100.1010 + @i, 5.2020 + @i, 90.4545 + @i)
	SET @i += 1
END
go
-- 31 segundos

EXEC sp_spaceused  'Venda_Money' -- 7696 KB
EXEC sp_spaceused  'Venda_Decimal' -- 8296 KB


/************************
 Precisão no Cálculo
*************************/
SELECT 'Decimal' as TipoDeDado, *,
(Valor_Desconto / Valor_Total) * 100.0000 AS Percentual,
cast((Valor_Desconto / Valor_Total) * 100.0000 as decimal(19,4)) AS 'Percentual_19,4',
cast((Valor_Desconto / Valor_Total) * 100.0000 as decimal(19,2)) AS 'Percentual_19,2'
FROM Venda_Decimal with(nolock)
WHERE Venda_Id in (1,3,4)

SELECT 'Money' as TipoDeDado, *,
(Valor_Desconto / Valor_Total) * $100.0000 AS Percentual,
cast((Valor_Desconto / Valor_Total) * $100.0000 as decimal(19,2)) AS 'Percentual_DEC_Final',
cast((cast(Valor_Desconto  as decimal(19,4)) / cast(Valor_Total  as decimal(19,4))) * 100.0000 as decimal(19,2)) AS 'Percentual_DEC'
FROM Venda_Money with(nolock)
WHERE Venda_Id in (1,3,4)


