/***************************************************************************************
 Evento Imersão SQL Server 2025
 Autor: Landry Duailibe
 
 DBCC CHECKDB
 - Descricao: Verifica a integridade de todos os bancos de dados de  uma instancia.
 
 OBS: executa o comando DBCC CHECKDB
 DBCC CHECKDB 
[
    [ ( database_name | database_id | 0
        [ , NOINDEX 
        | , { REPAIR_ALLOW_DATA_LOSS | REPAIR_FAST | REPAIR_REBUILD } ]
        ) ]
    [ WITH 
        {
            [ ALL_ERRORMSGS ]
            [ , EXTENDED_LOGICAL_CHECKS ] 
            [ , NO_INFOMSGS ]
            [ , TABLOCK ]
            [ , ESTIMATEONLY ]
            [ , { PHYSICAL_ONLY | DATA_PURITY } ]
        }
    ]
]
**********************************************************/
use DBA
go
DROP TABLE IF exists DBA_Monitora_Hist_CheckDB
go
CREATE TABLE DBA_Monitora_Hist_CheckDB (
DataHora datetime not null,
Servidor varchar(128) not null default (@@SERVERNAME),
Banco varchar(128) not null,
Error int null, -- Error
Level int null, -- Level
State int null, -- State
Mensagem varchar(7000) null, -- MessageText
NivelReparo varchar(7000) null, -- RepairLevel
Arquivo int null, -- File
Pagina bigint null, -- Page
Objeto bigint null, -- ObjectID
Notificacao char(1) not null default ('N'))
go
-- select * from msdb.dbo.DBA_Monitora_Hist_CheckDB


/************************************ 
  Criar JOB Semanal com este Script
*************************************/
set nocount on

DECLARE @NomeBanco varchar(2000), @state_desc varchar(200) 
DECLARE @command varchar(4000)
DECLARE @Empresa varchar(1000) = 'SQL SERVER EXPERT'
DECLARE @ProfileDatabaseMail varchar(2000) = 'Profile_SMTP'
DECLARE @Operador varchar(2000) = 'DBA'

if object_id('dbo.tmpBancosCHECKDB') is not null
   drop table dbo.tmpBancosCHECKDB

SELECT name,state_desc 
INTO dbo.tmpBancosCHECKDB 
FROM sys.databases 
WHERE source_database_id is null
and state_desc = 'ONLINE' 
and name not in ('tempdb','model') 
and name not in ('AdventureWorksGR','AdventureWorks_ComIndice','AdventureWorks_SemIndice','CensoEscolar_DW') 
ORDER BY name

DROP TABLE IF exists #CheckDBResult

CREATE TABLE #CheckDBResult(
ServerName varchar(100),
Error int NULL,
Level int NULL,
State int NULL,
MessageText varchar(7000) null,
RepairLevel varchar(7000) NULL,
Status int NULL,
DbId int NULL,
DbFragld bigint null,
ObjectID bigint null,
IndexId bigint null,
PartitionId bigint NULL,
AllocUnitId bigint NULL,
RidDbld bigint NULL,
RidPruld bigint NULL,
[File] int NULL,
Page bigint NULL,
Slot int NULL,
RefDbld bigint null,
RefPruld bigint null,
RefFile bigint NULL,
RefPage bigint NULL,
RefSlot bigint NULL,
Allocation bigint NULL,
insert_date datetime NOT NULL CONSTRAINT DF_CheckDBResult_insert_date  DEFAULT (getdate()))

-- Cria Cursor com a lista de bancos ONLINE da instancia
DECLARE vCursor CURSOR STATIC FOR 
SELECT name,state_desc FROM dbo.tmpBancosCHECKDB ORDER BY name

OPEN vCursor
FETCH NEXT FROM vCursor INTO @NomeBanco,@state_desc 

-- Executa o comando DBCC CHECKDB para cada banco da instancia
WHILE @@FETCH_STATUS = 0 BEGIN
  --WAITFOR DELAY '00:00:05' 

  IF db_id(@NomeBanco) is null begin
     print '*** ERRO: DB_ID retornou NULL para o banco ' + @NomeBanco
     FETCH NEXT FROM vCursor INTO @NomeBanco,@state_desc 
     continue
  END
  
  IF @state_desc <> 'ONLINE' begin
     print '*** ERRO: Banco ' +  @NomeBanco + ' está: ' + @state_desc
     FETCH NEXT FROM vCursor INTO @NomeBanco,@state_desc 
     continue
  END
  
  PRINT 'Banco: ' + @NomeBanco
  SET @command = 'dbcc checkdb(''' + @NomeBanco + ''') with NO_INFOMSGS'
  
  INSERT #CheckDBResult (Error,[Level],[State],MessageText,RepairLevel,[Status],[DbId],DbFragld,ObjectID,
  indexid,PartitionId,AllocUnitId,RidDbld,RidPruld,[File],Page,Slot,RefDbld,RefPruld,RefFile,RefPage,RefSlot,Allocation)
  EXEC ('dbcc checkdb(''' + @NomeBanco + ''') with NO_INFOMSGS,TABLERESULTS')


  IF @@ERROR <> 0 begin
      print '*** ERRO: CHECKDB banco ' + @NomeBanco + ' - Código de erro: ' + ltrim(str(@@error))
      FETCH NEXT FROM vCursor INTO @NomeBanco,@state_desc 
      continue
  END   

  INSERT DBA.dbo.DBA_Monitora_Hist_CheckDB
  (DataHora, Banco, Error, [Level], [State], Mensagem, NivelReparo, Arquivo, Pagina,Objeto)
  SELECT insert_date, @NomeBanco, Error, [Level], [State], MessageText, RepairLevel, [File], [Page],ObjectID
  FROM #CheckDBResult

  TRUNCATE TABLE #CheckDBResult

  FETCH NEXT FROM vCursor INTO @NomeBanco,@state_desc 
END 
CLOSE vCursor 
DEALLOCATE vCursor 

IF object_id('dbo.tmpBancosCHECKDB') is not null
   DROP TABLE dbo.tmpBancosCHECKDB

/********************
 ENVIA EMAIL
*********************/
DECLARE @TableHead varchar(max),@TableTail varchar(max), @Subject varchar(2000), @QtdLinhas int 
DECLARE @TableJOB varchar(max)
DECLARE @Body varchar(max), @BodyJOB varchar(max), @BodyManutBD varchar(max), @BodyDisco varchar(max), @BodyMemoria varchar(max)
DECLARE @SQLversion varchar(max), @Email_TO varchar(2000), @Servidor varchar(2000)

SELECT @Email_TO = email_address FROM msdb.dbo.sysoperators WHERE name = @Operador

SELECT @SQLversion = left(@@VERSION,25) + ' - Build '
+ CAST(SERVERPROPERTY('productversion') AS VARCHAR) + ' - ' 
+ CAST(SERVERPROPERTY('productlevel') AS VARCHAR) + ' (' 
+ CAST(SERVERPROPERTY('edition') AS VARCHAR) + ')'

SELECT @Servidor = @@SERVERNAME

SET @TableTail = '</body></html>';
SET @TableHead = '<html><head>' +
			'<style>' +
			'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;} ' +
			'</style>' +
			'</head>' +
			'<body>' + 
			'<P style=font-size:18pt;" ><B>Servidor ' + @Servidor +  '</B></P>' +
			'<P style=font-size:12pt;" >' + @SQLversion + '</P><br>'

SET @Body = @TableHead

IF exists (select * from DBA.dbo.DBA_Monitora_Hist_CheckDB where Notificacao = 'N') BEGIN

	SET @TableJOB = '<P style=font-size:14pt;" ><B>Relatório CHECKDB</B></P>' +
				'<table cellpadding=0 cellspacing=0 border=0>' +
				'<tr bgcolor=#87CEEB>' + 
				'<td align=center><b>DataHora</b></td>' + 
				'<td align=center><b>Banco de Dados</b></td>' + 
				'<td align=center><b>Arquivo</b></td>' + 
				'<td align=center><b>Pagina</b></td>' + 
				'<td align=center><b>Objeto</b></td>' + 
				'<td align=center><b>Nivel de Reparo</b></td>' + 
				'<td align=center><b>Mensagem</b></td></tr>';
				
	SELECT @BodyJOB = (SELECT Row_Number() OVER(ORDER BY DataHora desc) % 2 As [TRRow],
	convert(varchar(10), DataHora,103) + ' ' + convert(varchar(8),DataHora,114) as [TD],isnull(Banco,'N/A') as [TD],
	isnull(Arquivo,0) as [TD],isnull(Pagina,0) as [TD],isnull(Objeto,0) as [TD],
	isnull(NivelReparo,'N/A') as [TD],isnull(left(Mensagem,90),'N/A') as [TD]
	FROM DBA.dbo.DBA_Monitora_Hist_CheckDB 
	WHERE Notificacao = 'N' 
	ORDER BY DataHora
	FOR XML raw('tr'),elements)

	-- Marca últimos registros notificados por email
    UPDATE DBA.dbo.DBA_Monitora_Hist_CheckDB SET Notificacao = 'S' WHERE Notificacao = 'N'

	SET @BodyJOB = Replace(@BodyJOB, '_x0020_', space(1))
	SET @BodyJOB = Replace(@BodyJOB, '_x003D_', '=')
	SET @BodyJOB = Replace(@BodyJOB, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#F0F0F0>')
	SET @BodyJOB = Replace(@BodyJOB, '<TRRow>0</TRRow>', '')
	SET @BodyJOB = @BodyJOB + '</table><p> </p><br>'
	SET @Body = @Body + @TableJOB + @BodyJOB

    /**************** Monta HTML Final e envia email ********************/
    SET @Body = @Body + @TableTail
    --Select @Body

    SET @Subject = @Empresa + ': Relatório CHECKDB - ' + @@SERVERNAME + ' do dia ' + CONVERT(varchar(30),getdate(),103)

	EXEC msdb.dbo.sp_send_dbmail
	@recipients=@Email_TO,
	@subject = @Subject,
	@body = @Body,
	@body_format = 'HTML' ,
	@profile_name=@ProfileDatabaseMail
END
/**************************** Fim JOB **************************************/



/**********************
 Testando a rotina
***********************/
RESTORE FILELISTONLY FROM DISK = 'C:\Backup\VendasDB_CorruptCluster.bak'

RESTORE DATABASE VendasDB FROM DISK = 'C:\Backup\VendasDB_CorruptCluster.bak' WITH recovery,replace,
MOVE 'VendasDB' TO 'C:\MSSQL_Data\VendasDB.mdf',
MOVE 'VendasDB_log' TO 'C:\MSSQL_Data\VendasDB_log.ldf'

-- Teste
DROP TABLE IF exists #CheckDBResult
go
CREATE TABLE #CheckDBResult(
Error int NULL,
Level int NULL,
State int NULL,
MessageText varchar(7000) null,
RepairLevel varchar(7000) NULL,
Status int NULL,
DbId int NULL,
DbFragld bigint null,
ObjectID bigint null,
IndexId bigint null,
PartitionId bigint NULL,
AllocUnitId bigint NULL,
RidDbld bigint NULL,
RidPruld bigint NULL,
[File] int NULL,
Page bigint NULL,
Slot int NULL,
RefDbld bigint null,
RefPruld bigint null,
RefFile bigint NULL,
RefPage bigint NULL,
RefSlot bigint NULL,
Allocation bigint NULL)

INSERT #CheckDBResult (Error,[Level],[State],MessageText,RepairLevel,[Status],[DbId],DbFragld,ObjectID,
indexid,PartitionId,AllocUnitId,RidDbld,RidPruld,[File],Page,Slot,RefDbld,RefPruld,RefFile,RefPage,RefSlot,Allocation)

EXEC ('dbcc checkdb(''VendasDB'') with NO_INFOMSGS,TABLERESULTS')

SELECT * FROM #CheckDBResult
