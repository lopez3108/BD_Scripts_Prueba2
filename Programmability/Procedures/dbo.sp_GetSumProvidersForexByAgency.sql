SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumProvidersForexByAgency] @UserId       INT      = NULL,
                                                                @AgencyId     INT      = NULL,
                                                                @CreationDate DATETIME = NULL
AS
     BEGIN
        
		
		SELECT ISNULL(SUM(b.Usd), 0) AS Suma
         FROM dbo.Forex b INNER JOIN
		 dbo.Providers p ON p.ProviderId = b.ProviderId
         WHERE b.AgencyId = @AgencyId
               AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
			   AND (p.ForexType IS NOT NULL AND p.ForexType = 1)
               AND (b.CreatedBy = @UserId
                    OR @UserId IS NULL)
               
     END;

GO