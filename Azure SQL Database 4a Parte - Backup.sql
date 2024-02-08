SELECT  FROM sys.dm_database_backups 
ORDER BY backup_finish_date DESC

SELECT logical_database_name as Banco, backup_start_date as DataHora_Inicio, backup_finish_date as DataHora_Fim,
CASE backup_type
WHEN 'D' THEN 'Full'
WHEN 'I' THEN 'Differential'
WHEN 'L' THEN 'Transaction Log'
END as Tipo_Backup,
CASE in_retention WHEN 1 THEN 'Dentro do Período' ELSE 'Fora do Período' END as Retencao

FROM sys.dm_database_backups
ORDER BY backup_start_date DESC
