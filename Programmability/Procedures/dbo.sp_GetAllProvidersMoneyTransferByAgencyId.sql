SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransferByAgencyId] @AgencyId INT = NULL
AS
     BEGIN
         SELECT p.ProviderId,
                p.Name AS Name,
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
                p.MoneyOrderService
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
              
         WHERE pt.Code = 'C02' and p.Active = 1
         ORDER BY Name;
     END;
GO