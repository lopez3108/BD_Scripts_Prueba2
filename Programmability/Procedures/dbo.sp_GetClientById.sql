SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetClientById] @ClientId INT, @Date DATETIME
AS
     BEGIN
         SELECT Users.UserId,
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
				Countries_1.CountryAbre,
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
                PhoneValidationExpirationDate,
				Clientes.ClientStatusId,
				ds.Code ClientStatusCode,
				CASE 
				WHEN
				(CAST(Clientes.Doc1Expire as DATE) < CAST(@Date as DATE)) OR
				(Clientes.Doc2Expire IS NOT NULL AND (CAST(Clientes.Doc2Expire as DATE) < CAST(@Date as DATE)))
				THEN
				CAST(1 as BIT)
				ELSE
				CAST(0 as BIT)
				END as DocExpired,
				Clientes.IsNewClient,
				Clientes.CreationDate,
				Clientes.CreatedBy,
				u1.Name as CreatedByName
         FROM TypeID
              RIGHT JOIN ZipCodes
              RIGHT JOIN Users ON ZipCodes.ZipCode = Users.ZipCode
              INNER JOIN Clientes ON Users.UserId = Clientes.UsuarioId ON TypeID.TypeId = Clientes.Doc1Type
              LEFT JOIN Countries AS Countries_1 ON Clientes.Doc1Country = Countries_1.CountryId
              LEFT OUTER JOIN Countries AS Countries_2 ON Clientes.Doc2Country = Countries_2.CountryId
              LEFT OUTER JOIN TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId
			  LEFT JOIN DocumentStatus ds ON ds.DocumentStatusId = Clientes.ClientStatusId 
			  LEFT JOIN Users as u1 ON Clientes.CreatedBy = u1.UserId
         WHERE Clientes.ClienteId = @ClientId;
     END;
GO