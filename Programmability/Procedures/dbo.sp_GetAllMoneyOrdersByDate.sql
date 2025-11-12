SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllMoneyOrdersByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT dbo.MoneyTransfers.CreationDate AS Date,
                SUM(ISNULL(dbo.MoneyTransfers.UsdMoneyOrders , 0 )) USD,
			 --SUM(ISNULL(dbo.MoneyTransfers.Usd, 0) + ISNULL(dbo.MoneyTransfers.UsdMoneyOrders, 0)) USD,
                dbo.Providers.Name+' (M.O)' Name,
                dbo.MoneyTransfers.AgencyId
         FROM dbo.MoneyTransfers
              INNER JOIN dbo.Providers ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
         WHERE CAST(dbo.MoneyTransfers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
			   AND MoneyTransfers.TransactionsNumberMoneyOrders > 0
               --AND MoneyOrderService = 1 
         GROUP BY dbo.MoneyTransfers.CreationDate,
                  dbo.Providers.Name,
                  dbo.MoneyTransfers.AgencyId;
     END;
GO