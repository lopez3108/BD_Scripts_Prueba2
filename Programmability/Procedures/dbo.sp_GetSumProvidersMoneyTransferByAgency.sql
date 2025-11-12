SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumProvidersMoneyTransferByAgency] @UserId       INT      = NULL,
                                                                @AgencyId     INT      = NULL,
                                                                @CreationDate DATETIME = NULL
AS
     BEGIN
         SELECT ISNULL(SUM(ISNULL(b.Usd, 0)) + SUM(ISNULL(b.UsdMoneyOrders, 0)), '0') AS Suma
         FROM MoneyTransfers b
         WHERE b.AgencyId = @AgencyId
               AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
               AND (b.CreatedBy = @UserId
                    OR @UserId IS NULL)
               AND (b.TotalTransactions > 0
                    OR TransactionsNumberMoneyOrders > 0);
     END;

GO