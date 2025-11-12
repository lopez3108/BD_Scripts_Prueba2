SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateBank] @BankId      INT          = NULL,
                                      @Name        VARCHAR(50),
                                      @Telephone   VARCHAR(10)  = NULL,
                                      @ContactName VARCHAR(50)  = NULL,
                                      @ZipCode     VARCHAR(6)   = NULL,
                                      @Address     VARCHAR(50)  = NULL,
                                      @City        VARCHAR(255) = NULL,
                                      @State       VARCHAR(255) = NULL,
                                      @County      VARCHAR(255) = NULL
AS
BEGIN

    IF(@BankId IS NULL OR @BankId = 0)
    BEGIN
        IF(EXISTS
        (
            SELECT Name
            FROM Bank
            WHERE Name = @Name
        ))
        BEGIN
            SELECT-1;
		END;
        ELSE
        BEGIN
			IF (EXISTS(SELECT * FROM AddressXBank 
			WHERE BankId = @BankId AND Address = @Address AND ZipCode = @ZipCode AND State = @State AND City = @City AND County = @County))
			BEGIN
				SELECT -2
			END 
			ELSE
			BEGIN
				INSERT INTO [dbo].[Bank]
				([Name],
				[Telephone],
				[ContactName])
				VALUES
				(@Name,
				@Telephone,
				@ContactName);

				SET @BankId = (SELECT @@IDENTITY);

				INSERT INTO AddressXBank 
				VALUES (@BankId,@Address,@ZipCode,@State,@City,@County)

				SELECT @BankId
			END
		END;
	END;
    ELSE
    BEGIN
        UPDATE [dbo].Bank
        SET
            [Name] = @Name,
            Telephone = @Telephone,
            ContactName = @ContactName
        WHERE BankId = @BankId;
        SELECT @BankId;

END;
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
    END;
END;
GO