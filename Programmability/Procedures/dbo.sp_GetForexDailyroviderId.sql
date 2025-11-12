SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetForexDailyroviderId] @AgencyId INT, @UserId   INT,  @Date	DATETIME, @ProviderId int = NULL
AS
     BEGIN
         
		SELECT 
		p.ProviderId,
    f.ForexId, 
      p.Name+' - '+mt.Number AS Name,
		ISNULL(f.Usd, 0) AS Usd
	
FROM     dbo.Providers AS p 
 INNER JOIN MoneyTransferxAgencyNumbers mt ON p.ProviderId = mt.ProviderId
                                                           AND mt.AgencyId = @AgencyId
				LEFT OUTER JOIN dbo.Forex AS f ON f.ProviderId = p.ProviderId  AND f.CreatedBy = @UserId 
        AND CAST(f.CreationDate as DATE) = CAST(@Date as DATE)  AND f.AgencyId = @AgencyId  AND (F.ProviderId = @ProviderId OR @ProviderId IS NULL)       
				  INNER JOIN dbo.Users AS u ON u.UserId = f.LastUpdatedBy
		 WHERE p.Active = CAST(1 AS BIT)
		 AND p.ForexType IS NOT NULL
		 AND p.ForexType = 1 OR  f.Usd > 0




     END;
GO