SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllMoneyTransfersByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT CAST(dbo.MoneyTransfers.CreationDate as DATE) AS Date,
                SUM(ISNULL(dbo.MoneyTransfers.USD, 0)) USD,
			 --SUM(ISNULL(dbo.MoneyTransfers.Usd, 0) + ISNULL(dbo.MoneyTransfers.UsdMoneyOrders, 0)) USD,
                dbo.Providers.Name+' (M.T)' Name,
                dbo.MoneyTransfers.AgencyId
         FROM dbo.MoneyTransfers
              INNER JOIN dbo.Providers ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
         WHERE CAST(dbo.MoneyTransfers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
               AND (MoneyTransfers.TotalTransactions > 0)
             
         GROUP BY CAST(dbo.MoneyTransfers.CreationDate as DATE),
                  dbo.Providers.Name,
                  dbo.MoneyTransfers.AgencyId;
     END;

GO