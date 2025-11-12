SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetClienteById](@ClientId INT)
AS
     BEGIN
         SELECT Clientes.ClienteId,
                Clientes.UsuarioId,
                Clientes.Foto,
                Clientes.FingerPrint,
                Clientes.Note,
                Clientes.Doc1Front,
                Clientes.Doc1Back,
                Clientes.Doc1Type,
                Clientes.Doc1Number,
                Clientes.Doc1Country,
                Clientes.Doc1State,
                Clientes.Doc1Expire,
                Clientes.Doc2Front,
                Clientes.Doc2Back,
                Clientes.Doc2Type,
                Clientes.Doc2Number,
                Clientes.Doc2Country,
                Clientes.Doc2State,
                Clientes.Doc2Expire,
                Users.Name,
                Users.Telephone,
                Users.Telephone2,
                Users.ZipCode,
                Users.Address,
                Users.Lenguage,
                Users.[User],
                Countries_1.Name AS Doc2CountryName,
                Countries.Name AS Doc1CountryName,
                --dbo.fn_GetClientBounced(ClienteId) AS IsBounced,
                ZipCodes.State,
                ZipCodes.City,
                ZipCodes.County,
                dbo.Users.BirthDay,
                PhoneValidated,
                PhoneValidationCode,
                PhoneValidationExpirationDate,
				ISNULL(IsClientVIP , 0 ) IsClientVIP
         FROM Clientes
              INNER JOIN Users ON Clientes.UsuarioId = Users.UserId
              LEFT JOIN ZipCodes ON ZipCodes.ZipCode = Users.ZipCode
              LEFT JOIN Countries ON Clientes.Doc1Country = Countries.CountryId
              LEFT OUTER JOIN Countries AS Countries_1 ON Clientes.Doc2Country = Countries_1.CountryId
         WHERE ClienteId = @ClientId;
     END;
GO