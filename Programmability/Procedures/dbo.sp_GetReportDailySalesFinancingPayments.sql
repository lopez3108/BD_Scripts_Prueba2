SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesFinancingPayments]
(@AgencyId INT,
 @FromDate DATETIME = NULL,
 @ToDate   DATETIME = NULL,
 @Date     DATETIME
)
AS
     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
         SELECT Provider = ISNULL(Q.Provider, 'TOTAL'),
                Transactions = ISNULL(SUM(Q.Transactions), 0),
                Usd = ISNULL(SUM(Q.Usd), 0)
         FROM
         (
             SELECT Provider = ISNULL('FINANCING', 'TOTAL'),
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(t.CardPaymentFee) + SUM(T.Usd), 0) Usd
             FROM Payments T
                  INNER JOIN Financing f ON f.FinancingId = T.FinancingId
             WHERE f.AgencyId = @AgencyId
                   AND (CAST(T.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
         ) Q
         GROUP BY ROLLUP((Q.Provider));
     END;
GO