SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransfersConfigurationByState]
	 @State BIT = NULL
AS
BEGIN
    SELECT p.ProviderId, 
               p.Name +' (M.T)' Name ,
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
			 
        WHERE pt.Code = 'C02'
              AND (p.Active = 1)
        ORDER BY Name;
	
	

   
	
END
GO