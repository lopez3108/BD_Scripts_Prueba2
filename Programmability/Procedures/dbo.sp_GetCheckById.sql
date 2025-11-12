SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCheckById] @CheckId INT
AS
     BEGIN
         SELECT CheckTypes.CheckTypeId,
                CheckTypes.Description,
                Checks.CheckId,
                Checks.CheckFront,
                Checks.CheckBack,
                Checks.DateCashed,
                Makers.MakerId,
                Makers.Name AS Maker,
                Checks.Account,
                Checks.Routing,
                Checks.DateCheck,
                --Checks.IsBounced,
                --Checks.BouncedReason,
                --Checks.DateBounced,
                Users.UserId,
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
                Checks.ClientId,
                ZipCodes.County,
                [User],
				Checks.CheckStatusId,
				ds.Code CheckStatusCode,
				Checks.CashierId,
				Checks.Number,
				Checks.Amount,
				Checks.ValidatedCheckDateBy,
        Checks.ValidateCheckTypeBy,
				Checks.ValidatedRoutingBy,
				Checks.LastUpdatedOn,
				Checks.ValidatedRangeBy,
				Checks.ValidatedMaxAmountBy,
				Checks.AgencyId,
				Users.Birthday
         FROM ZipCodes
              RIGHT JOIN Users ON ZipCodes.ZipCode = Users.ZipCode
              LEFT JOIN Checks
              LEFT JOIN CheckTypes ON Checks.CheckTypeId = CheckTypes.CheckTypeId
              LEFT JOIN Makers ON Checks.Maker = Makers.MakerId
              INNER JOIN Clientes ON Checks.ClientId = Clientes.ClienteId ON Users.UserId = Clientes.UsuarioId
              LEFT JOIN TypeID ON Clientes.Doc1Type = TypeID.TypeId
              LEFT JOIN Countries AS Countries_1 ON Clientes.Doc1Country = Countries_1.CountryId
              LEFT OUTER JOIN Countries AS Countries_2 ON Clientes.Doc2Country = Countries_2.CountryId
              LEFT OUTER JOIN TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId
			  LEFT JOIN DocumentStatus ds ON ds.DocumentStatusId = Checks.CheckStatusId 
         WHERE Checks.CheckId = @CheckId;
     END;
GO