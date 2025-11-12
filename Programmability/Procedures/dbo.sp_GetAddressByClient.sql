SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAddressByClient]
	@ClientId int
AS
BEGIN
    SELECT top 1 *
    FROM AddressXClient
	WHERE ClientId = @ClientId
	ORDER BY AddressXClientId DESC
END
GO