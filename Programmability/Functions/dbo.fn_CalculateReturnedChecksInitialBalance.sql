SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateReturnedChecksInitialBalance](
@AgencyId   INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
    RETURN ((

-- Initial balance Los returned chack no deben de tener initial balance 4298
--ISNULL((SELECT TOP 1 InitialBalance FROM ReturnedChecksxAgencyInitialBalances
--WHERE AgencyId = @AgencyId),0) +

-- Return checks
ISNULL((SELECT      SUM(USD + ProviderFee)
FROM            dbo.ReturnedCheck
WHERE CAST(ReturnDate as DATE) < CAST(@EndDate as DATE) AND
ReturnedAgencyId = @AgencyId),0) -

-- Return payments
ISNULL((SELECT SUM(dbo.ReturnPayments.Usd)
FROM            dbo.ReturnPayments 
						 WHERE 
						 CAST(dbo.ReturnPayments.CreationDate as DATE) < CAST(@EndDate as DATE) AND
dbo.ReturnPayments.AgencyId = @AgencyId),0) 

-- Provider commissions
--ISNULL((SELECT        SUM(dbo.ProviderCommissionPayments.Usd)
--select * FROM            dbo.ProviderCommissionPayments INNER JOIN
--                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
--                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--						 WHERE CAST(CreationDate as DATE) < CAST(@EndDate as DATE) AND
--AgencyId = @AgencyId AND
--dbo.ProviderTypes.Code = 'C08'),0)

))

END
GO