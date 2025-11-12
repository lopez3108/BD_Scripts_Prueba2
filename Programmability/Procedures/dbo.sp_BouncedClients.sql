SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_BouncedClients]
AS
     BEGIN
         SELECT DISTINCT
                Clientes.ClienteId,
                Users.Name,
                dbo.fn_GetClientNumberOfChecks(Clientes.ClienteId) AS ChecksCashed,
                dbo.fn_GetClientNumberOfChecksBounced(Clientes.ClienteId) AS ChecksBounced,
                dbo.fn_GetClientBouncedAmount(Clientes.ClienteId) AS AmountBounced,
                dbo.fn_GetClientCashedAmount(Clientes.ClienteId) AS AmountCashed
         FROM Clientes
              INNER JOIN Checks ON Clientes.ClienteId = Checks.ClientId
              INNER JOIN Users ON Clientes.UsuarioId = Users.UserId
         --WHERE Checks.IsBounced = 1;
     END;
GO