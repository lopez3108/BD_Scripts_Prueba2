SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateVentraInitialBalanceCost](
@AgencyId   INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
    RETURN (


	ISNULL((SELECT       
SUM(ISNULL(dbo.Ventra.ReloadUsd,0))
        FROM  dbo.Ventra
						 WHERE 
						 dbo.Ventra.AgencyId = @AgencyId 
						AND CAST(dbo.Ventra.CreationDate AS DATE) < CAST(@EndDate AS DATE)), 0)

						-

						ISNULL((SELECT 
SUM(ISNULL(dbo.ConciliationVentras.Usd,0)) as Usd
FROM            dbo.ConciliationVentras 
						 WHERE 
						 dbo.ConciliationVentras.AgencyId = @AgencyId AND
						 CAST(dbo.ConciliationVentras.Date AS DATE) < CAST(@EndDate AS DATE) AND
						 dbo.ConciliationVentras.IsCredit = 1),0)

						+

						ISNULL((SELECT 
SUM(ISNULL(dbo.ConciliationVentras.Usd,0)) as Usd
FROM            dbo.ConciliationVentras 
						 WHERE 
						 dbo.ConciliationVentras.AgencyId = @AgencyId AND
						 CAST(dbo.ConciliationVentras.Date AS DATE) < CAST(@EndDate AS DATE) AND
						 dbo.ConciliationVentras.IsCredit = 0),0)
  


)

END
GO