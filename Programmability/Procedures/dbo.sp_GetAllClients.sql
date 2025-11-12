SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllClients]
AS
    BEGIN
        SELECT *,
		U.Address +' '+ ZipCodes.City +' '+  ZipCodes.State +', '+ ZipCodes.StateAbre +' '+ U.ZipCode  AS AddressWithZipCode
        FROM clientes C
        INNER JOIN Users U ON U.UserId = C.UsuarioId
		INNER JOIN   ZipCodes ON ZipCodes.ZipCode = U.ZipCode
    END;
	SELECT * FROM Cashiers
GO