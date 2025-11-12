SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateClientAddress] 
@AddressXClientId INT = NULL,
@ClientId      INT          = NULL,
@ZipCode     VARCHAR(6)   = NULL,
@Address     VARCHAR(50)  = NULL,
@City        VARCHAR(255) = NULL,
@State       VARCHAR(255) = NULL,
@County      VARCHAR(255) = NULL
AS
BEGIN

    IF(@AddressXClientId IS NULL OR @AddressXClientId = 0)
    BEGIN
		IF (EXISTS(SELECT * FROM AddressXClient 
		WHERE ClientId = @ClientId AND Address = @Address AND ZipCode = @ZipCode AND State = @State AND City = @City AND County = @County))
		BEGIN
			SELECT -1
		END 
		ELSE
		BEGIN
            INSERT INTO [dbo].[AddressXClient]
            VALUES (@ClientId,@Address,@ZipCode,@State,@City,@County)

            SELECT @@IDENTITY
		END
	END
	IF(NOT EXISTS
	(
		SELECT Zipcode
		FROM ZipCodes
		WHERE Zipcode = @Zipcode
	))
	BEGIN
					--Guardamos el zipcode en caso que no exista 
		EXEC sp_SaveZipCode
			@ZipCode,
			@City,
			@State,
			@County;
	END
END
GO