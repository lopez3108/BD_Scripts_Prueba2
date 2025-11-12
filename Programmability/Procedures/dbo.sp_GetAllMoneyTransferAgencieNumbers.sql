SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllMoneyTransferAgencieNumbers]
 
AS 

BEGIN

SELECT    
dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId,
dbo.MoneyTransferxAgencyNumbers.AgencyId, 
dbo.MoneyTransferxAgencyNumbers.ProviderId, 
dbo.MoneyTransferxAgencyNumbers.Number, 
dbo.Agencies.Name as AgencyName, 
dbo.Providers.Name AS ProviderName,
ISNULL(dbo.Providers.LimitBalance, CAST(0 as BIT)) as LimitBalance,
dbo.Providers.Name + ' (' + dbo.MoneyTransferxAgencyNumbers.Number + ')' + ' / ' + dbo.Agencies.Code + ' - ' + dbo.Agencies.Name as Name
FROM            dbo.MoneyTransferxAgencyNumbers INNER JOIN
                         dbo.Agencies ON dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Providers ON dbo.MoneyTransferxAgencyNumbers.ProviderId = dbo.Providers.ProviderId
						 WHERE dbo.Agencies.IsActive = 1 AND
						 dbo.Providers.Active = 1
						 ORDER BY dbo.Providers.Name, dbo.Agencies.Name

	
	END
GO