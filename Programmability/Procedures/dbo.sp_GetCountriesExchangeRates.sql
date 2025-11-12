SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCountriesExchangeRates]
AS
    BEGIN
        DECLARE @LastUdpateUser VARCHAR(300);
        DECLARE @LastUdpateOn DATETIME;
        SELECT TOP 1 @LastUdpateUser = u.Name, 
                     @LastUdpateOn = e.LastUpdatedOn
        FROM Countries c
             INNER JOIN ExchangeRates e ON c.CountryId = e.CountryId
             INNER JOIN Users u ON U.UserId = e.LastUpdatedBy
             LEFT JOIN Providers P ON P.ProviderId = e.ProviderId
        WHERE p.Active = 1
        ORDER BY e.LastUpdatedOn DESC;
        SELECT DISTINCT 
               C.CountryId, 
               C.Name, 
               LastUdpateUser = @LastUdpateUser, 
               LastUdpatedOn = @LastUdpateOn
        FROM Countries c
             INNER JOIN ExchangeRates e ON c.CountryId = e.CountryId
             LEFT JOIN Providers P ON P.ProviderId = e.ProviderId
        WHERE p.Active = 1
        ORDER BY c.Name ASC;
    END;
GO