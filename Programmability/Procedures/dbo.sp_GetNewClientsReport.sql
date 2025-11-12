SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetNewClientsReport]
 @StartDate datetime = null,
 @EndDate datetime = null
AS 

BEGIN

SELECT        Users.Name, Users.Telephone, Users.ZipCode, ZipCodes.City, ZipCodes.State, Users.Address, Clientes.IsNewClient, Clientes.RegistrationDate,
dbo.fn_GetClientNumberOfChecks(Clientes.ClienteId) as NumberChecks, [dbo].[fn_GetClientMakers] (Clientes.ClienteId) as Makers
FROM            Clientes INNER JOIN
                         Users ON Clientes.UsuarioId = Users.UserId  INNER JOIN
                         ZipCodes ON Users.ZipCode = ZipCodes.ZipCode
						 WHERE 
						 Clientes.IsNewClient = 1 AND
						 CAST(Clientes.RegistrationDate as DATE) >= CAST(@StartDate as DATE) AND
						 CAST(Clientes.RegistrationDate as DATE) <= CAST(@EndDate as DATE)



	END

GO