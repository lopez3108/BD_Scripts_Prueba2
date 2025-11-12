SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATEDBY: JOHAN
--CREATEDON:22-09-2023
--CAMBIOS EN 5311, actualizar cambio del client telephone


CREATE PROCEDURE [dbo].[sp_UpdateClientTel] (@ClientId INT = NULL,

@Telephone VARCHAR(20) = NULL)

AS

BEGIN

 DECLARE @UserId INT;
 SET @UserId = (SELECT c.UsuarioId FROM Clientes c WHERE c.ClienteId = @ClientId)

    UPDATE [dbo].Users
    SET [Telephone] = @Telephone
    WHERE UserId = @UserId

END


GO