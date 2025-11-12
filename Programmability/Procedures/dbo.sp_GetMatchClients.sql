SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMatchClients] 
@Name VARCHAR(80) = NULL, 
@Telephone VARCHAR(10) = NULL, 
@ClientId INT = NULL,
@DOB DATETIME
AS
    BEGIN
	 IF EXISTS 
	  (
	  SELECT TypeID.TypeId    
         FROM TypeID
              RIGHT JOIN ZipCodes
              INNER JOIN Users ON ZipCodes.ZipCode = Users.ZipCode
              INNER JOIN Clientes ON Users.UserId = Clientes.UsuarioId ON TypeID.TypeId = Clientes.Doc1Type
              LEFT JOIN Countries AS Countries_1 ON Clientes.Doc1Country = Countries_1.CountryId
              LEFT OUTER JOIN Countries AS Countries_2 ON Clientes.Doc2Country = Countries_2.CountryId
              LEFT OUTER JOIN TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId
			  WHERE Users.Name = @Name AND Users.Telephone = @Telephone AND  (Clientes.ClienteId != @ClientId OR @ClientId IS NULL)
	  )
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
         FROM TypeID
              RIGHT JOIN ZipCodes
              INNER JOIN Users ON ZipCodes.ZipCode = Users.ZipCode
              INNER JOIN Clientes ON Users.UserId = Clientes.UsuarioId ON TypeID.TypeId = Clientes.Doc1Type
              LEFT JOIN Countries AS Countries_1 ON Clientes.Doc1Country = Countries_1.CountryId
              LEFT OUTER JOIN Countries AS Countries_2 ON Clientes.Doc2Country = Countries_2.CountryId
              LEFT OUTER JOIN TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId
         WHERE Users.Name = @Name AND Users.Telephone = @Telephone AND (Clientes.ClienteId != @ClientId OR @ClientId IS NULL)
		  ELSE 
		 BEGIN
		 SELECT Users.UserId,
		 2 TypeSearch ,--Cliente 'like' por nombre y tel
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
		 Users 
		  INNER JOIN Clientes ON Users.UserId = Clientes.UsuarioId 
		 LEFT JOIN TypeID ON TypeID.TypeId = Clientes.Doc1Type
		 LEFT JOIN ZipCodes ON ZipCodes.ZipCode = Users.ZipCode             
              LEFT JOIN Countries AS Countries_1 ON Clientes.Doc1Country = Countries_1.CountryId
              LEFT JOIN Countries AS Countries_2 ON Clientes.Doc2Country = Countries_2.CountryId
              LEFT JOIN TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId
         WHERE
		 ((FREETEXT (Users.[Name], @Name)) OR
		 (Users.Telephone= @Telephone) ) OR
		 (CAST(Users.BirthDay as DATE) = CAST(@DOB as DATE) AND Users.Name LIKE '%' + @Name + '%')
		 AND  (Clientes.ClienteId <> @ClientId OR @ClientId IS NULL)
	  END;
	   END;
GO