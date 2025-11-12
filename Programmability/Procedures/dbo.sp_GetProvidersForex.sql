SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetProvidersForex]
                 @AgencyId int = NULL
AS
BEGIN

  IF @AgencyId IS NOT NULL
  BEGIN
    SELECT p.ProviderId, p.Name + ' (' + mt.Number + ')' [Name]
    FROM Providers p
         INNER JOIN
         ProviderTypes pt
         ON p.ProviderTypeId = pt.ProviderTypeId
         INNER JOIN
         MoneyTransferxAgencyNumbers mt
         ON p.ProviderId = mt.ProviderId AND
           mt.AgencyId = @AgencyId
    WHERE ForexType = 1 AND
          p.Active = CAST(1 AS bit)
  END

  ELSE

  BEGIN
    SELECT p.ProviderId, p.Name + ' (FOREX)' AS [Name]
    FROM Providers p
    WHERE ForexType = 1 AND
          p.Active = CAST(1 AS bit)

  END





END;
GO