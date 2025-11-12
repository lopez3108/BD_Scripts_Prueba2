SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyOrdersConfigurationByState]
	 @State BIT = NULL
AS
BEGIN
    SELECT p.ProviderId, 
               p.Name + ' (M.O)' Name ,
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
			 
			 -- Se comenta para que en el daily report el money orders pueda traer  todos los provider al igual que Money transfers
			 --AND P.MoneyOrderService = 1
			 
        WHERE pt.Code = 'C02'
              AND (p.Active = 1)
        ORDER BY Name;
	
	

   SELECT * FROM Providers
	
END
GO