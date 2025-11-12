SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetChecksToday] @DateCashed DATETIME,
                                          @CashierId  INT
AS
     BEGIN
         SELECT Checks.CheckId,
                Checks.ClientId,
                Checks.CashierId,
                Checks.DateCashed,
                Checks.Maker,
                Checks.Amount,
                Checks.Fee,
                Checks.Number,
                Checks.Account,
                Checks.Routing,
                Checks.DateCheck,
                Users.Name AS Cliente,
                Users_1.Name AS Cashier,
                Agencies.Name AS Agency,
                Makers.Name AS MakerName,
                --Checks.IsBounced,
                --Checks.BouncedReason,
                --Checks.DateBounced,
                CheckTypes.Description AS CheckType
         FROM Checks
              INNER JOIN Cashiers ON Checks.CashierId = Cashiers.CashierId
              INNER JOIN Clientes ON Checks.ClientId = Clientes.ClienteId
              INNER JOIN Users ON Clientes.UsuarioId = Users.UserId
              INNER JOIN Users AS Users_1 ON Cashiers.UserId = Users_1.UserId
              INNER JOIN Makers ON Checks.Maker = Makers.MakerId
              INNER JOIN Agencies ON Checks.AgencyId = Agencies.AgencyId
              INNER JOIN CheckTypes ON Checks.CheckTypeId = CheckTypes.CheckTypeId
         WHERE CAST(Checks.DateCashed AS DATE) = CAST(@DateCashed AS DATETIME)
               AND Checks.CashierId = @CashierId;
     END;
GO