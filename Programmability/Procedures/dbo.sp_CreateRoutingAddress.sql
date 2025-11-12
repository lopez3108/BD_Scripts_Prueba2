SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateRoutingAddress] 
@AddressXRoutingId INT = NULL,
@RoutingId      INT          = NULL,
@ZipCode     VARCHAR(6)   = NULL,
@Address     VARCHAR(50)  = NULL,
@City        VARCHAR(255) = NULL,
@State       VARCHAR(255) = NULL,
@County      VARCHAR(255) = NULL
AS
BEGIN

    IF(@AddressXRoutingId IS NULL OR @AddressXRoutingId = 0)
    BEGIN
        
            INSERT INTO [dbo].[AddressXRouting]
            VALUES (@RoutingId,@Address,@ZipCode,@State,@City,@County)

            SELECT @@IDENTITY
		
	END
	ELSE
	BEGIN

	UPDATE [dbo].[AddressXRouting]
	SET RoutingId = @RoutingId, Address = @Address, ZipCode = @ZipCode, [State] = @State, City = @City, County = @County
	WHERE AddressXRoutingId = @AddressXRoutingId
	
	SELECT @AddressXRoutingId

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