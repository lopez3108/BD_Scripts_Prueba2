SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransfer] @AgencyId INT = NULL
AS
     BEGIN
         SELECT p.ProviderId,
                p.Name+' - '+mt.Number AS Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,				
               --'false' AS 'Disabled',
                0 Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType,
                0 transactions,
                '0.00' AS 'moneyvalue',
                p.CostAndCommission,
                p.DetailedTransaction,
                p.MoneyOrderService,
				mt.MoneyTransferxAgencyNumbersId
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
              INNER JOIN MoneyTransferxAgencyNumbers mt ON p.ProviderId = mt.ProviderId
                                                           AND mt.AgencyId = @AgencyId
                                                           OR @AgencyId IS NULL
         WHERE pt.Code = 'C02'
         ORDER BY Name;
     END;
GO