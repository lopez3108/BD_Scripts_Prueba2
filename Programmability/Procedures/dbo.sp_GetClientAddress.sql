SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClientAddress] @ClientId INT
AS
BEGIN
  IF (EXISTS (SELECT
        *
      FROM AddressXClient
      WHERE ClientId = @ClientId
      AND Address IS NOT NULL
      AND Zipcode IS NOT NULL)
    )
  BEGIN
    SELECT
      *
    FROM AddressXClient
    WHERE ClientId = @ClientId
  END


END

GO