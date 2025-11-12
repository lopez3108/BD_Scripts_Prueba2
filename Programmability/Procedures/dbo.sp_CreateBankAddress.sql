SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateBankAddress] 
@AddressXBankId INT = NULL,
@BankId      INT          = NULL,
@ZipCode     VARCHAR(6)   = NULL,
@Address     VARCHAR(50)  = NULL,
@City        VARCHAR(255) = NULL,
@State       VARCHAR(255) = NULL,
@County      VARCHAR(255) = NULL
AS
BEGIN

    IF(@AddressXBankId IS NULL OR @AddressXBankId = 0)
    BEGIN
		IF (EXISTS(SELECT * FROM AddressXBank 
		WHERE BankId = @BankId AND Address = @Address AND ZipCode = @ZipCode AND State = @State AND City = @City AND County = @County))
		BEGIN
			SELECT -1
		END 
		ELSE
		BEGIN
			INSERT INTO [dbo].[AddressXBank]
			VALUES (@BankId,@Address,@ZipCode,@State,@City,@County)

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