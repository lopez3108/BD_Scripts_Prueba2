SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CalculateVentraInitialBalanceCommission](
@AgencyId   INT,
--@EndDate DATETIME = NULL
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL
)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
    RETURN (


	ISNULL((SELECT
SUM((ISNULL(dbo.Ventra.ReloadUsd, 0) * ISNULL(dbo.Ventra.Commission, 0) / 100))  AS Commission
        FROM  dbo.Ventra
						 WHERE 
						 dbo.Ventra.AgencyId = @AgencyId 
						AND 
            --CAST(dbo.Ventra.CreationDate AS DATE) < CAST(@EndDate AS DATE)
             (CAST(dbo.Ventra.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(dbo.Ventra.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
            
            ),0)

						-

						ISNULL((SELECT        

SUM(ISNULL(Usd,0))
FROM            dbo.ProviderCommissionPayments INNER JOIN
                         dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
						 WHERE 
						 dbo.ProviderTypes.Code = 'C20' AND
						 dbo.ProviderCommissionPayments.AgencyId = @AgencyId 
						AND 
            --CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) < CAST(@EndDate AS DATE)
             (CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
            
            ),0)
  


)

END
GO