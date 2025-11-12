SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateHeadPhonesAndChargersInitialBalance](
@AgencyId   INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
    RETURN ((

-- Initial balance
SELECT ISNULL((SELECT SUM((HeadphonesUsd + ChargersUsd) - ((CostHeadPhones * HeadphonesQuantity) - (CostChargers * ChargersQuantity)))
FROM            dbo.Daily  INNER JOIN
dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId INNER JOIN
                         dbo.HeadphonesAndChargers ON dbo.Daily.AgencyId = dbo.HeadphonesAndChargers.AgencyId
						 AND CAST(HeadphonesAndChargers.CreationDate as date) = CAST(daily.CreationDate as date) AND
						 dbo.Cashiers.UserId = HeadphonesAndChargers.CreatedBy
						 WHERE dbo.Daily.AgencyId = @AgencyId and 
						 CAST(dbo.Daily.CreationDate as date) < cast(@EndDate as DATE)),0))

						 -


(SELECT ISNULL((SELECT        SUM(dbo.ProviderCommissionPayments.Usd)
FROM            dbo.ProviderCommissionPayments INNER JOIN
                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE dbo.ProviderTypes.Code = 'C22' AND
dbo.ProviderCommissionPayments.AgencyId = @AgencyId and 
						 CAST(dbo.ProviderCommissionPayments.CreationDate as date) < cast(@EndDate as DATE)),0))





						 )

END
GO