SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetForexDaily] @AgencyId INT, @UserId   INT,  @Date	DATETIME, @ProviderId int = NULL
AS
     BEGIN
         
		SELECT 
		p.ProviderId,
    f.ForexId, 
--		p.Name, 
      p.Name+' - '+mt.Number AS Name,
		ISNULL(f.Usd, 0) AS Usd, 
		CONVERT(varchar, ISNULL(f.Usd,0)) AS moneyvalue,
		f.LastUpdatedBy, 
		f.LastUpdatedOn, 
		u.Name AS LastUpdatedByName, 
		CAST(1 AS BIT) AS [Set], CAST(1 AS BIT) AS Disabled, 
		CAST(0 AS BIT) AS AcceptNegative
FROM     dbo.Providers AS p 
 INNER JOIN MoneyTransferxAgencyNumbers mt ON p.ProviderId = mt.ProviderId
                                                           AND mt.AgencyId = @AgencyId
				LEFT OUTER JOIN dbo.Forex AS f ON f.ProviderId = p.ProviderId  AND f.CreatedBy = @UserId 
        AND CAST(f.CreationDate as DATE) = CAST(@Date as DATE)  AND f.AgencyId = @AgencyId         
				  LEFT OUTER JOIN dbo.Users AS u ON u.UserId = f.LastUpdatedBy
		 WHERE p.Active = CAST(1 AS BIT)
		 AND p.ForexType IS NOT NULL
		 AND p.ForexType = 1 OR  f.Usd > 0
--     AND (F.ProviderId = @ProviderId OR @ProviderId IS NULL)



     END;
GO