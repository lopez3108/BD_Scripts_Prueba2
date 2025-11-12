SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[fn_CalculateCancellationInitialBalance](
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
SUM(ISNULL(dbo.Cancellations.RefundAmount, 0)) AS Usd
      FROM  dbo.Cancellations
						 WHERE 
						 dbo.Cancellations.AgencyId = @AgencyId 
						AND CAST(dbo.Cancellations.CancellationDate AS DATE) < CAST(@EndDate AS DATE))
,0))




						)

END
GO