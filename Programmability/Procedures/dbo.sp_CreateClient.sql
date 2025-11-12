SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateClient] (@ClientId INT = NULL,
@UserId INT = NULL,
@Name VARCHAR(80),
@Telephone VARCHAR(20),
@Telephone2 VARCHAR(20) = NULL,
@ZipCode VARCHAR(10) = NULL,
@City VARCHAR(20) = NULL,
@State VARCHAR(20) = NULL,
@County VARCHAR(20) = NULL,
@Address VARCHAR(100) = NULL,
@Foto VARCHAR(200) = NULL,
@DocBack VARCHAR(200) = NULL,
@FingerPrint VARCHAR(200) = NULL,
@FingerPrintTemplate VARCHAR(MAX) = NULL,
@Note VARCHAR(400) = NULL,
@Doc1Front VARCHAR(200) = NULL,
@Doc1Back VARCHAR(200) = NULL,
@Doc1Type INT = NULL,
@Doc1Number VARCHAR(200) = NULL,
@Doc1Country INT = NULL,
@Doc1State VARCHAR(200) = NULL,
@Doc1Expire DATETIME = NULL,
@Doc2Front VARCHAR(200) = NULL,
@Doc2Back VARCHAR(200) = NULL,
@Doc2Type INT = NULL,
@Doc2Number VARCHAR(200) = NULL,
@Doc2Country INT = NULL,
@Doc2State VARCHAR(200) = NULL,
@Doc2Expire DATETIME = NULL,
@IsNewClient BIT,
@RegistrationDate DATETIME = NULL,
@User VARCHAR(50) = NULL,
@BirthDay DATETIME = NULL,
@PhoneValidated BIT = NULL,
@PhoneValidationCode VARCHAR(4) = NULL,
@PhoneValidationExpirationDate DATETIME = NULL,
@ClientStatusCode VARCHAR(10) = NULL,
@ValidatedBy INT = NULL,
@ValidatedOn DATETIME = NULL,
@CreationDate DATETIME = NULL,
@CreatedBy INT = NULL)
AS
BEGIN
  DECLARE @ClientStatusId INT = NULL;
  SET @ClientStatusId = (SELECT
      DocumentStatusId
    FROM DocumentStatus
    WHERE Code = @ClientStatusCode);
  IF (@ZipCode IS NOT NULL
    AND NOT EXISTS (SELECT
        *
      FROM ZipCodes
      WHERE Zipcode = @ZipCode)
    )
  BEGIN
    INSERT INTO [dbo].[ZipCodes] ([Zipcode],
    [City],
    [State],
    [County])
      VALUES (@ZipCode, @City, @State, @County);
  END;
  IF (@ClientId IS NULL)
  BEGIN
    INSERT INTO [dbo].[Users] ([Name],
    [Telephone],
    [Telephone2],
    [Zipcode],
    [Address],
    [UserType],
    [Lenguage],
    [User],
    [BirthDay])
      VALUES (@Name, @Telephone, @Telephone2, @ZipCode, @Address, 1002, 1, @User, @BirthDay);
    SET @UserId = @@identity;
    INSERT INTO [dbo].[Clientes] ([UsuarioId],
    [Foto],
    [FingerPrint],
    [FingerPrintTemplate],
    [Note],
    [Doc1Front],
    [Doc1Back],
    [Doc1Type],
    [Doc1Number],
    [Doc1Country],
    [Doc1State],
    [Doc1Expire],
    [Doc2Front],
    [Doc2Back],
    [Doc2Type],
    [Doc2Number],
    [Doc2Country],
    [Doc2State],
    [Doc2Expire],
    [IsNewClient],
    [RegistrationDate],
    PhoneValidated,
    PhoneValidationCode,
    PhoneValidationExpirationDate,
    ClientStatusId,
    CreatedBy,
    CreationDate)
      VALUES (@UserId, @Foto, @FingerPrint, @FingerPrintTemplate, @Note, @Doc1Front, @Doc1Back, @Doc1Type, @Doc1Number, @Doc1Country, @Doc1State, @Doc1Expire, @Doc2Front, @Doc2Back, @Doc2Type, @Doc2Number, @Doc2Country, @Doc2State, @Doc2Expire, @IsNewClient, @RegistrationDate, @PhoneValidated, @PhoneValidationCode, @PhoneValidationExpirationDate, @ClientStatusId, @CreatedBy, @CreationDate);
    SET @ClientId = @@identity;
    SELECT
      @ClientId;
    --IF(EXISTS
    --  (
    --      SELECT 1
    --      FROM AddressXClient
    --      WHERE ClientId = @ClientId
    --            AND Address = @Address
    --            AND ZipCode = @ZipCode
    --            AND State = @State
    --            AND City = @City
    --            AND County = @County
    --  ))
    --    BEGIN
    --        SELECT-1;
    --END;
    --ELSE
    BEGIN
      IF (@Address IS NOT NULL
        OR @ZipCode IS NOT NULL)
      BEGIN
        INSERT INTO AddressXClient
          VALUES (@ClientId, @Address, @ZipCode, @State, @City, @County);
      --SELECT @ClientId;
      END
    END;
  END;
  ELSE
  BEGIN
    IF (EXISTS (SELECT
          1
        FROM AddressXClient
        WHERE ClientId = @ClientId)
      )
    BEGIN
      UPDATE [dbo].AddressXClient
      SET Address = @Address
         ,Zipcode = @ZipCode
         ,State = @State
         ,City = @City
         ,County = @County
      WHERE ClientId = @ClientId
    END
    ELSE
    IF (@Address IS NOT NULL
      OR @ZipCode IS NOT NULL)
    BEGIN
      INSERT INTO AddressXClient
        VALUES (@ClientId, @Address, @ZipCode, @State, @City, @County);
    END

    UPDATE [dbo].[Users]
    SET [Name] = @Name
       ,[Telephone] = @Telephone
       ,[Telephone2] = @Telephone2
       ,[Zipcode] = @ZipCode
       ,[Address] = @Address
       ,[Pass] = NULL
       ,[UserType] = 1002
       ,[Lenguage] = 1
       ,[User] = @User
       ,[BirthDay] = @BirthDay
    WHERE UserId = @UserId;

    UPDATE [dbo].[Clientes]
    SET [UsuarioId] = 
        CASE
          WHEN @UserId IS NULL THEN [UsuarioId]
          ELSE @UserId
        END
       ,[Foto] =
        CASE
          WHEN @Foto IS NULL THEN Foto
          ELSE @Foto
        END
       ,[FingerPrint] =
        CASE
          WHEN @FingerPrint IS NULL THEN FingerPrint
          ELSE @FingerPrint
        END
       ,[FingerPrintTemplate] = 
        CASE
          WHEN @FingerPrintTemplate IS NULL THEN FingerPrintTemplate
          ELSE @FingerPrintTemplate
        END
       ,[Note] = @Note
       ,[Doc1Front] =
        CASE
          WHEN @Doc1Front IS NULL THEN Doc1Front
          ELSE @Doc1Front
        END
       ,[Doc1Back] = 
        CASE
          WHEN @Doc1Back IS NULL THEN Doc1Back
          ELSE @Doc1Back
        END
       ,[Doc1Type] = @Doc1Type
       ,[Doc1Number] = @Doc1Number
       ,[Doc1Country] = @Doc1Country
       ,[Doc1State] = @Doc1State
       ,[Doc1Expire] = @Doc1Expire
       ,[Doc2Front] = @Doc2Front
--        CASE
--          WHEN @Doc2Front IS NULL THEN Doc2Front
--          ELSE @Doc2Front
--        END
       ,[Doc2Back] = @Doc2Back
--        CASE
--          WHEN @Doc2Back IS NULL THEN Doc2Back
--          ELSE @Doc2Back
--        END
       ,[Doc2Type] = @Doc2Type
--        CASE
--          WHEN @Doc2Type IS NULL THEN Doc2Type
--          ELSE @Doc2Type
--        END
       ,[Doc2Number] = @Doc2Number
--        CASE
--          WHEN @Doc2Number IS NULL THEN Doc2Number
--          ELSE @Doc2Number
--        END
       ,[Doc2Country] = @Doc2Country
--        CASE
--          WHEN @Doc2Country IS NULL THEN Doc2Country
--          ELSE @Doc2Country
--        END
       ,[Doc2State] = @Doc2State
--        CASE
--          WHEN @Doc2State IS NULL THEN Doc2State
--          ELSE @Doc2State
--        END
       ,[Doc2Expire] = @Doc2Expire
--        CASE
--          WHEN @Doc2Expire IS NULL THEN Doc2Expire
--          ELSE @Doc2Expire
--        END
       ,PhoneValidated = @PhoneValidated
       ,PhoneValidationCode = @PhoneValidationCode
       ,PhoneValidationExpirationDate = @PhoneValidationExpirationDate
       ,ClientStatusId = @ClientStatusId
       ,ValidatedOn = @ValidatedOn
       ,ValidatedBy = @ValidatedBy
    WHERE ClienteId = @ClientId;
    SELECT
      @ClientId;
  END;
END;

GO