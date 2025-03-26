/*******************************************
 Autor: Landry Duailibe

 Live #062 Hands On: Logins e Server Roles 
********************************************/
use master
go

-- Cria dois logins
CREATE LOGIN login_1 WITH PASSWORD = 'Pa$$w0rd'
CREATE LOGIN login_2 WITH PASSWORD = 'Pa$$w0rd'
GO

-- Verifica se o login login_1 pertence ao role PUBLIC
SELECT IS_SRVROLEMEMBER ('public', 'login_1')
SELECT IS_SRVROLEMEMBER ('sysadmin', 'login_1')

-- Verifica permissões efetivas 
EXECUTE AS LOGIN = 'login_1'
SELECT * FROM sys.fn_my_permissions (NULL, 'SERVER')
REVERT

-- Adicionando login a um role
ALTER SERVER ROLE diskadmin ADD MEMBER login_1

SELECT IS_SRVROLEMEMBER ('diskadmin', 'login_1')

-- Lista de roles que um login faz parte
SELECT spr.name as Role_Name, spm.name as Member_Name
FROM sys.server_role_members rm
JOIN sys.server_principals spr ON spr.principal_id = rm.role_principal_id
JOIN sys.server_principals spm ON spm.principal_id = rm.member_principal_id
--WHERE spm.name = 'login_1'
ORDER BY role_name, member_name


/*********************************
 Usuário de Banco de Dados
**********************************/
use Aula
go

-- Cria usuário de banco
CREATE USER login_1 FOR LOGIN login_1

-- Verifica se usuário pertence a um role
EXECUTE AS USER = 'login_1'
SELECT is_member('public') AS is_public_member
REVERT
GO

-- Adiciona usuário a dois databases roles
ALTER ROLE db_datareader ADD MEMBER login_1
GO
ALTER ROLE db_ddladmin ADD MEMBER login_1
GO

-- Metadata
SELECT rdp.name AS role_name, rdm.name AS member_name
FROM sys.database_role_members AS rm
JOIN sys.database_principals AS rdp
ON rdp.principal_id = rm.role_principal_id
JOIN sys.database_principals AS rdm
ON rdm.principal_id = rm.member_principal_id
WHERE rdm.name = 'login_1'
ORDER BY role_name, member_name


/*********************************
 Apaga objetos
**********************************/
use master
go
DROP LOGIN login_1
DROP LOGIN login_2


