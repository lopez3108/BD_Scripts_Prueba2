SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClientsExpress1](@ClientId INT = NULL)
AS
     BEGIN
         SELECT DISTINCT
        
                u.Name
      
         FROM dbo.Clientes c
              INNER JOIN dbo.Users u ON c.UsuarioId = u.UserId
--         WHERE c.ClienteId = CASE
--                                 WHEN @ClientId IS NULL
--                                 THEN c.ClienteId
--                                 ELSE @ClientId
--                             END
         ORDER BY u.Name ASC;
     END;


GO