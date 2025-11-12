SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Ya no esta en funcionamiento
--CAMBIOS EN 5424, Refactoring reporte de tax commissions
CREATE FUNCTION [dbo].[fn_CalculatePayrollCommissionsInitialBalance](
@AgencyId   INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
    RETURN ((

-- Daily
 ISNULL(
(
SELECT
SUM(ISNULL((dbo.ChecksEls.Amount * dbo.ChecksEls.Fee / 100), 0)) AS Commission
        FROM  dbo.ChecksEls INNER JOIN dbo.ProviderTypes ON
		dbo.ProviderTypes.ProviderTypeId = dbo.ChecksEls.ProviderTypeId
						 WHERE 
						 dbo.ProviderTypes.Code = 'C03' AND
						 dbo.ChecksEls.AgencyId = @AgencyId 
						AND CAST(dbo.ChecksEls.CreationDate AS DATE) < CAST(@EndDate AS DATE))
,0))

-- Commissions

-

						(ISNULL((SELECT        

SUM(ISNULL(Usd,0))
FROM            dbo.ProviderCommissionPayments INNER JOIN
                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
						 WHERE 
						 dbo.ProviderTypes.Code = 'C03' AND
						 dbo.ProviderCommissionPayments.AgencyId = @AgencyId 
						AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) < CAST(@EndDate AS DATE)),0))


						)

END
GO