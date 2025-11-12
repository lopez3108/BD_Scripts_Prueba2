SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-03-13 5632: Implemented cache client creation in returned checks module

CREATE PROCEDURE [dbo].[sp_CreateClientExpress] (@ClientId INT = NULL,
@UserId INT = NULL,
@Name VARCHAR(50),
@User VARCHAR(80) = null,
@Telephone VARCHAR(20) = NULL,
@ZipCode VARCHAR(10) = NULL
, @City VARCHAR(20) = NULL
, @State VARCHAR(20) = NULL
, @County VARCHAR(20) = NULL,
@Address VARCHAR(100) = NULL,
@Note VARCHAR(400) = NULL,
@DOB DATETIME = NULL,
@IsCacheSaving BIT = NULL -- 5632

)
AS

BEGIN

  DECLARE @ClientStatusId INT = NULL;
  SET @ClientStatusId = (SELECT
      DocumentStatusId
    FROM DocumentStatus
    WHERE Code = 'C01');

  IF (@ZipCode IS NOT NULL
    AND NOT EXISTS (SELECT
        *
      FROM ZipCodes
      WHERE ZipCode = @ZipCode)
    )
  BEGIN

    INSERT INTO [dbo].[ZipCodes] ([ZipCode]
    , [City]
    , [State]
    , [County])
      VALUES (@ZipCode, @City, @State, @County)



  END

  IF (@ClientId IS NULL)
  BEGIN

    IF (EXISTS (SELECT
          dbo.Users.Name
        FROM dbo.Clientes
        INNER JOIN dbo.Users
          ON dbo.Users.UserId = dbo.Clientes.UsuarioId
        WHERE Name = @Name)
      )
    BEGIN
      SELECT
        -1;
    END
    ELSE
    BEGIN


	IF(@IsCacheSaving IS NULL OR @IsCacheSaving = CAST(0 as BIT))
	BEGIN

	INSERT INTO [dbo].[Users] ([Name],
        [User]
      , [Telephone]
      , [ZipCode]
      , [Address]
      , [UserType]
	  ,[BirthDay])
        VALUES (@Name,@User, @Telephone, @ZipCode, @Address, 1002, @DOB)

      SET @UserId = @@identity

      INSERT INTO [dbo].[Clientes] ([UsuarioId],
      [Note],
      [ClientStatusId])
        VALUES (@UserId, @Note, @ClientStatusId)

      SET @ClientId = @@identity

	        IF (EXISTS (SELECT
            *
          FROM AddressXClient
          WHERE ClientId = @ClientId
          AND Address = @Address
          AND ZipCode = @ZipCode
          AND State = @State
          AND City = @City
          AND County = @County)
        )
      BEGIN
        SELECT
          -2
      END
      ELSE
      BEGIN
        INSERT INTO AddressXClient
          VALUES (@ClientId, @Address, @ZipCode, @State, @City, @County)

        SELECT
          @ClientId
      END
	
	END
	ELSE
	BEGIN

	SELECT 0 -- 5632: Cache creation

	END


    END
  END
  ELSE
  BEGIN

    --edita client por returned check
    IF (NOT EXISTS (SELECT
          *
        FROM AddressXClient
        WHERE ClientId = @ClientId
        AND Address = @Address
        AND ZipCode = @ZipCode
        AND State = @State
        AND City = @City
        AND County = @County)
      )
    BEGIN

      IF (NOT EXISTS (SELECT
            *
          FROM AddressXClient
          WHERE ClientId = @ClientId)
        )
      BEGIN
        INSERT INTO AddressXClient
          VALUES (@ClientId, @Address, @ZipCode, @State, @City, @County)
      END
      ELSE
      BEGIN
        UPDATE [dbo].AddressXClient
        SET Address = @Address
           ,State = @State
           ,ZipCode = @ZipCode
           ,City = @City
           ,County = @County
        WHERE ClientId = @ClientId
      END




    END
    ELSE
    BEGIN
      SELECT
        -2
    END

    UPDATE [dbo].[Users]
    SET [Name] = @Name
       ,[Telephone] = @Telephone
        --         ,[Telephone2] = @Telephone2
       ,[ZipCode] = @ZipCode
       ,[Address] = @Address
		,[BirthDay] = @DOB
    WHERE UserId = @UserId

    UPDATE [dbo].[Clientes]
    SET [Note] = @Note
    WHERE ClienteId = @ClientId

    SELECT
      @ClientId


  END

END
GO