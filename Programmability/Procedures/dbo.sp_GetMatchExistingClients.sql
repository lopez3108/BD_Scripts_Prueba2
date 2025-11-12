SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMatchExistingClients] 
@Name VARCHAR(80), 
@Telephone VARCHAR(10), 
@ClientId INT = NULL,
@DOB DATETIME,
@IsList BIT
AS
    BEGIN

	
	IF(EXISTS(SELECT TOP 1 1 FROM Users u INNER JOIN Clientes c ON c.UsuarioId = u.UserId WHERE
	u.Name = @Name AND u.Telephone = @Telephone AND (u.BirthDay IS NOT NULL AND CAST(u.BirthDay as DATE) = CAST(@DOB as DATE) )
	AND (@ClientId IS NULL OR c.ClienteId != @ClientId))
	)
	BEGIN

	SELECT 1 as MatchResult, c.ClienteId as ClientId FROM Users u INNER JOIN Clientes c ON c.UsuarioId = u.UserId WHERE
	u.Name = @Name AND u.Telephone = @Telephone 
	AND (u.BirthDay IS NOT NULL AND CAST(u.BirthDay as DATE) = CAST(@DOB as DATE) )

	END
	ELSE IF(EXISTS(SELECT TOP 1 1 FROM Users u INNER JOIN Clientes c ON c.UsuarioId = u.UserId WHERE
	(FREETEXT (u.[Name], @Name)) AND 
	(u.Telephone = @Telephone OR 
	(u.BirthDay IS NOT NULL AND CAST(u.BirthDay as DATE) = CAST(@DOB as DATE)) ) 
	AND (@ClientId IS NULL OR c.ClienteId <> @ClientId)
	))
	BEGIN

	IF(CAST(@IsList as BIT) = CAST(0 as BIT))
	BEGIN
	SELECT 2 as MatchResult
	END
	ELSE
	BEGIN

	SELECT Users.UserId,
	   1 TypeSearch ,--Cliente existente con mismo nombre y tel
                Users.Name AS UserName,
                Users.Telephone,
                Users.Telephone2,
                ZipCodes.ZipCode,
                ZipCodes.City,
                ZipCodes.State,
                ZipCodes.StateAbre,
                ZipCodes.Latitude,
                ZipCodes.Longitude,
                Users.Address,
                Clientes.Foto,
                Clientes.FingerPrint,
                Clientes.FingerPrintTemplate,
                Clientes.Note,
                Clientes.Doc1Front,
                Clientes.Doc1Back,
                TypeID.TypeId,
                TypeID.Description AS Expr3,
                Clientes.Doc1Number,
                Countries_1.CountryId AS Doc1Country,
                Countries_1.Name AS Doc1CountryName,
                Clientes.Doc1State,
                Clientes.Doc1Expire,
                Clientes.Doc2Front,
                Clientes.Doc2Back,
                TypeID_1.TypeId AS TypeId2,
                TypeID_1.Description AS Expr7,
                Clientes.Doc2Number,
                Countries_2.CountryId AS Doc2Country,
                Countries_2.Name AS Doc2CountryName,
                Clientes.Doc2State,
                Clientes.Doc2Expire,
                ZipCodes.County,
                Users.[User],
                Clientes.ClienteId AS ClientId,
                --dbo.fn_GetClientBounced(Clientes.ClienteId) AS IsBounced,
                dbo.Users.BirthDay,
                PhoneValidated,
                PhoneValidationCode,
                PhoneValidationExpirationDate
         FROM 
		 Users INNER JOIN
		 Clientes ON Clientes.UsuarioId = Users.UserId LEFT OUTER JOIN
		 ZipCodes ON ZipCodes.ZipCode = Users.ZipCode LEFT OUTER JOIN
		 TypeID ON TypeID.TypeId = Clientes.Doc1Type LEFT OUTER JOIN 
		 TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId LEFT OUTER JOIN 
		 Countries AS Countries_1 ON Clientes.Doc1Country = Countries_1.CountryId LEFT OUTER JOIN 
		 Countries AS Countries_2 ON Clientes.Doc2Country = Countries_2.CountryId
         WHERE
	(FREETEXT (Users.[Name], @Name)) AND (Users.Telephone = @Telephone 
	OR (Users.BirthDay IS NOT NULL AND CAST(Users.BirthDay as DATE) = CAST(@DOB as DATE)))
	AND (@ClientId IS NULL OR Clientes.ClienteId <> @ClientId)


	END

	END
	ELSE IF(EXISTS(SELECT TOP 1 1 FROM Users u INNER JOIN Clientes c ON c.UsuarioId = u.UserId WHERE
	u.Name = @Name AND (@ClientId IS NULL OR c.ClienteId <> @ClientId)))
	BEGIN

	IF(CAST(@IsList as BIT) = CAST(0 as BIT))
	BEGIN
	SELECT 2 as MatchResult
	END
	ELSE
	BEGIN

	SELECT Users.UserId,
	   1 TypeSearch ,
                Users.Name AS UserName,
                Users.Telephone,
                Users.Telephone2,
                ZipCodes.ZipCode,
                ZipCodes.City,
                ZipCodes.State,
                ZipCodes.StateAbre,
                ZipCodes.Latitude,
                ZipCodes.Longitude,
                Users.Address,
                Clientes.Foto,
                Clientes.FingerPrint,
                Clientes.FingerPrintTemplate,
                Clientes.Note,
                Clientes.Doc1Front,
                Clientes.Doc1Back,
                TypeID.TypeId,
                TypeID.Description AS Expr3,
                Clientes.Doc1Number,
                Countries_1.CountryId AS Doc1Country,
                Countries_1.Name AS Doc1CountryName,
                Clientes.Doc1State,
                Clientes.Doc1Expire,
                Clientes.Doc2Front,
                Clientes.Doc2Back,
                TypeID_1.TypeId AS TypeId2,
                TypeID_1.Description AS Expr7,
                Clientes.Doc2Number,
                Countries_2.CountryId AS Doc2Country,
                Countries_2.Name AS Doc2CountryName,
                Clientes.Doc2State,
                Clientes.Doc2Expire,
                ZipCodes.County,
                Users.[User],
                Clientes.ClienteId AS ClientId,
                --dbo.fn_GetClientBounced(Clientes.ClienteId) AS IsBounced,
                dbo.Users.BirthDay,
                PhoneValidated,
                PhoneValidationCode,
                PhoneValidationExpirationDate
        FROM 
		 Users INNER JOIN
		 Clientes ON Clientes.UsuarioId = Users.UserId LEFT OUTER JOIN
		 ZipCodes ON ZipCodes.ZipCode = Users.ZipCode LEFT OUTER JOIN
		 TypeID ON TypeID.TypeId = Clientes.Doc1Type LEFT OUTER JOIN 
		 TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId LEFT OUTER JOIN 
		 Countries AS Countries_1 ON Clientes.Doc1Country = Countries_1.CountryId LEFT OUTER JOIN 
		 Countries AS Countries_2 ON Clientes.Doc2Country = Countries_2.CountryId
         WHERE
	Users.Name = @Name AND (@ClientId IS NULL OR Clientes.ClienteId <> @ClientId)


	END

	END
	ELSE
	BEGIN

	SELECT 0 as MatchResult

	END

	   END;
GO