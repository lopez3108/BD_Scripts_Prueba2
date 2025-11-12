SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClienteByName](@Name VARCHAR(200) = NULL)
AS
     BEGIN
         SELECT TOP 1 c.ClienteId AS ClientId,
                u.Name,
                u.Telephone,
                u.Address,
                c.Doc1Number,
                CAST(u.BirthDay AS DATE) DOB,
				UPPER(u.Address + ' ' + z.City + ', ' + z.State + ' ' + u.ZipCode) as AddressWithZipCode
         FROM Clientes c
              INNER JOIN Users u ON c.UsuarioId = u.UserId
			  LEFT JOIN dbo.ZipCodes z ON z.ZipCode = u.ZipCode
         WHERE u.Name LIKE '%'+@Name+'%' OR @Name IS NULL;
     END;
GO