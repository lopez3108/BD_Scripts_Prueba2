SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetForexByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT CAST(f.CreationDate as DATE) AS Date,
                SUM(ISNULL(f.USD, 0)) USD,
			 --SUM(ISNULL(dbo.MoneyTransfers.Usd, 0) + ISNULL(dbo.MoneyTransfers.UsdMoneyOrders, 0)) USD,
                p.Name+' (FOREX)' Name,
                f.AgencyId
         FROM dbo.Forex f
              INNER JOIN dbo.Providers p ON f.ProviderId = p.ProviderId
         WHERE CAST(f.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(f.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND f.CreatedBy = @CreatedBy
               AND f.AgencyId = @AgencyId
         GROUP BY CAST(f.CreationDate as DATE),
                  p.Name,
                  f.AgencyId;
     END;
GO