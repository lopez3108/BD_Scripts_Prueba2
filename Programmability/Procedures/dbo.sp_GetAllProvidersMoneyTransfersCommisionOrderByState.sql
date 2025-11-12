SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransfersCommisionOrderByState] @State BIT = NULL
AS
     BEGIN
         SELECT
		
			  p.*,
                0 AS 'Disabled',
                0 Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType,
                0 transactions,
                p.MoneyOrderCommission AS 'moneyvalue',
		
                'true' AS 'Set'
				
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
         WHERE pt.Code = 'C02'
               AND (p.Active = @State
                    OR @State IS NULL)
         ORDER BY Name;
     END;
GO