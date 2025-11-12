SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetExchangeRatesByCountry](@CountryId AS INT)
AS
    BEGIN
        SELECT *, 
               u.Name LastUdpateUser, 
               P.Name AS Company
        FROM Countries c
             RIGHT JOIN ExchangeRates e ON c.CountryId = e.CountryId
             LEFT JOIN Users u ON U.UserId = e.LastUpdatedBy
             LEFT JOIN Providers P ON P.ProviderId = e.ProviderId
        WHERE C.CountryId = @CountryId
              AND p.Active = 1
        ORDER BY E.Usd DESC;
    END;
GO