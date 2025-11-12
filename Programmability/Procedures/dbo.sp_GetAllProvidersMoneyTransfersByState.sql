SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransfersByState] @State    BIT = NULL, 
                                                                @AgencyId INT = NULL
AS
    BEGIN
        SELECT p.ProviderId, 
               p.Name + ' - ' + mt.Number AS Name, 
               p.Active, 
               p.ProviderTypeId, 
               p.AcceptNegative, 
               0 AS 'Disabled', 
               0 Comision, 
               pt.Code AS ProviderTypeCode, 
               pt.Description AS ProviderType, 
               0 transactions, 
               p.CheckCommission AS 'moneyvalue', 
               p.MoneyOrderCommission, 
               P.ReturnedCheckCommission, 
               'true' AS 'Set'
        FROM Providers p
             INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
             INNER JOIN MoneyTransferxAgencyNumbers mt ON p.ProviderId = mt.ProviderId
                                                          AND mt.AgencyId = @AgencyId
                                                          OR @AgencyId IS NULL
        WHERE pt.Code = 'C02'
              AND (p.Active = 1)
        ORDER BY Name;
    END;
GO