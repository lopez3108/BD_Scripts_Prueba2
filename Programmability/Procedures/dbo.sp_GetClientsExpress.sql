SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClientsExpress](@ClientId INT = NULL)
AS
     BEGIN
         SELECT DISTINCT
                c.ClienteId,
                c.UsuarioId,
                u.Name,
                u.Telephone,
                u.BirthDay,
                c.Doc1Number,
                CAST(u.BirthDay AS DATE) DOB
         FROM dbo.Clientes c
              INNER JOIN dbo.Users u ON c.UsuarioId = u.UserId
         WHERE c.ClienteId = CASE
                                 WHEN @ClientId IS NULL
                                 THEN c.ClienteId
                                 ELSE @ClientId
                             END
         ORDER BY u.Name ASC;
     END;




GO