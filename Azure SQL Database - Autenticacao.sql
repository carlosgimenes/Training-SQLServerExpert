/**************************************
 Demonstração Autenticação
 Autor: Landry Duailibe
***************************************/
use master
go

--GRANT ALTER ANY USER TO [adm-aula]

/*****************************************
 Informações de Metadata de segurança
******************************************/
-- Executar na MASTER
SELECT type_desc as Tipo, name as Login_Nome,principal_id as Login_ID,
is_disabled,create_date as Data_Criacao, modify_date as Data_Alteracao,
default_database_name
FROM sys.sql_logins
ORDER BY Tipo,Login_Nome

-- Executar em cada banco
SELECT [type_desc] Tipo, 
[name] as Usuario_Nome,principal_id as Usuario_ID,
authentication_type_desc as Tipo_Autenticacao,
create_date as Data_Criacao, modify_date as Data_Alteracao
FROM sys.database_principals
WHERE [type] <> 'R'
ORDER BY Tipo,Usuario_Nome

/*******************************************
 1) Criar um Login + Usuário de Banco
********************************************/

-- Executar na MASTER: cria Login do tipo SQL
CREATE LOGIN LuanaSalles WITH PASSWORD = 'Pa$$w0rd'

-- Executar no Banco de Dados que deseja fornecer acesso
CREATE USER LuanaSalles FROM LOGIN LuanaSalles 

-- Adicionar a um Role de Banco de Dados
ALTER ROLE db_datareader ADD MEMBER LuanaSalles

-- Executar na MASTER: Tornar ADM
CREATE USER LuanaSalles FROM LOGIN LuanaSalles 
ALTER ROLE dbmanager ADD MEMBER LuanaSalles


ALTER LOGIN LuanaSalles DISABLE

/***************************************************
 2) Criar Usuário de Banco com Autenticação direta
****************************************************/
-- Executar no Banco de Dados que deseja fornecer acesso
CREATE USER AppVendas WITH PASSWORD = 'Pa$$w0rd'



