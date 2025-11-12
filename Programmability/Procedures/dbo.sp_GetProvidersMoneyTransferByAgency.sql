SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetProvidersMoneyTransferByAgency] (@AgencyId INT)
AS
BEGIN
  SELECT
    dbo.Providers.ProviderId
   ,dbo.Providers.ReturnedCheckCommission
   ,dbo.Providers.Name + ' - ' + dbo.MoneyTransferxAgencyNumbers.Number AS Name
  FROM dbo.Providers
  INNER JOIN dbo.MoneyTransferxAgencyNumbers
    ON dbo.Providers.ProviderId = dbo.MoneyTransferxAgencyNumbers.ProviderId
  WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = @AgencyId;
END;
GO