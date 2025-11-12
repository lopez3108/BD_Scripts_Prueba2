SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersBillPayment] @Active BIT = NULL
AS
     BEGIN
         SELECT p.ProviderId,
                REPLACE(p.Name, CHAR(13) + CHAR(10), '') AS Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
                --'true' AS 'Disabled',
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
                                             AND P.Active = 1
         WHERE(pt.Code = 'C01')
              AND (p.Active = @Active
                   OR @Active IS NULL)
         ORDER BY Name;
     END;

	
GO