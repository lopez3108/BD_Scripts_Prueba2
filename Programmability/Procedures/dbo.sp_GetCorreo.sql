SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCorreo] (@InNombreUsuario VARCHAR(50))
AS

BEGIN
	SELECT
		*
	FROM dbo.Users u
	INNER JOIN dbo.Cashiers c
		ON u.UserId = c.UserId
	--WHERE UPPER([user]) = UPPER(@InNombreUsuario);
	 WHERE((@InNombreUsuario LIKE '%@%'
                               AND UPPER([User]) = UPPER(@InNombreUsuario))
                              OR UPPER(Telephone) = (@InNombreUsuario))


END
GO