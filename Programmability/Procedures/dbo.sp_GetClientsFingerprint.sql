SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClientsFingerprint]
 
AS 

BEGIN

SELECT [ClienteId] as ClientId
      ,[dbo].[Clientes].FingerPrint
	  ,[dbo].[Clientes].FingerPrintTemplate
	  ,u.Name
	  ,u.Telephone
	  ,u.Telephone ClientTelephone
	  ,u.Address
	  ,Clientes.Doc1Number
	  ,Clientes.Doc2Number
  FROM [dbo].[Clientes] INNER JOIN
  [dbo].[Users] u ON u.UserId = [dbo].[Clientes].UsuarioId
  WHERE [dbo].[Clientes].FingerPrint IS NOT NULL AND [dbo].[Clientes].FingerPrint <> ''
	
	END

GO