SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateOhersInitialBalance](
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
SUM(ISNULL(dbo.OthersDetails.Usd, 0)) AS Usd
        FROM  dbo.OthersDetails
						 WHERE 
						 dbo.OthersDetails.AgencyId = @AgencyId 
						AND CAST(dbo.OthersDetails.CreationDate AS DATE) < CAST(@EndDate AS DATE))
,0))

-- Commissions

-

						(ISNULL((SELECT        

SUM(ISNULL(Usd,0))
FROM            dbo.ProviderCommissionPayments INNER JOIN
                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
						 WHERE 
						 dbo.ProviderTypes.Code = 'C07' AND
						 dbo.ProviderCommissionPayments.AgencyId = @AgencyId 
						AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) < CAST(@EndDate AS DATE)),0))


						)

END
GO