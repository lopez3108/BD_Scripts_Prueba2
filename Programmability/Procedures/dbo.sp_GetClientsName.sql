SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClientsName] @Name varchar(50) 
AS

BEGIN
  SELECT DISTINCT u.Name,
u.Telephone,
c.Doc1Number,
CAST(u.BirthDay AS DATE) DOB
  FROM dbo.Clientes c
       INNER JOIN
       dbo.Users u
       ON c.UsuarioId = u.UserId
WHERE u.Name LIKE '%'+@Name+'%' 
  ORDER BY u.Name ASC;
END;


GO