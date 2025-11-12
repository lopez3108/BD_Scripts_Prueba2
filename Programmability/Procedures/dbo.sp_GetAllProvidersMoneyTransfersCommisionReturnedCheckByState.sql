SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransfersCommisionReturnedCheckByState] @State BIT = NULL
AS
     BEGIN
         SELECT p.ProviderId,
                p.Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
                0 AS 'Disabled',
                0 Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType,
                0 transactions,
                ISNULL(p.ReturnedCheckCommission , 0) AS 'moneyvalue',
			  p.CheckCommission,
			  p.MoneyOrderCommission,
                'true' AS 'Set',
			 p.LimitBalance
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
         WHERE pt.Code = 'C02'
               AND (p.Active = @State
                    OR @State IS NULL)
         ORDER BY Name;
     END;
GO