/**************************************
 Demonstração
 Autor: Landry Duailibe

 - Max e Min Server Memory
***************************************/
use master
go


/**************************************************
 - Abrir Performance Monitor
 - Abrir SqlQueryStress (Erik Ejlskov Jensen)
   https://github.com/ErikEJ/SqlQueryStress
***************************************************/
exec sp_configure 'show advanced options', 1
go
RECONFIGURE

exec sp_configure 'max server memory', 2000
go
RECONFIGURE
go



SELECT [name], [value], [value_in_use]
FROM sys.configurations
WHERE [name] = 'max server memory (MB)' OR [name] = 'min server memory (MB)'


