SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesRentPaymentsAndDeposits]
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
         SELECT Provider = CASE
                                      WHEN QueryFinal.RowNumberDetail = 1
                                      THEN 'RENT PAYMENTS'
                                      WHEN QueryFinal.RowNumberDetail = 2
                                      THEN 'DEPOSIT PAYMENTS'
                                      WHEN QueryFinal.RowNumberDetail = 3
                                      THEN 'DEPOSIT REFUNDS'
                                      WHEN QueryFinal.RowNumberDetail = 4
                                      THEN 'FEE DUE'
                                      ELSE 'TOTAL'
                                  END,
	     --Provider = ISNULL(QueryFinal.Provider, 'TOTAL'),
                Transactions = ISNULL(SUM(QueryFinal.Transactions), 0),
                Usd = ISNULL(SUM(QueryFinal.Usd), 0)
         FROM
         (
             SELECT ROW_NUMBER() OVER(ORDER BY P.TypeId ASC) RowNumberDetail,
                    *
             FROM
             (
                 SELECT 
                        TypeId = 1,
                        ISNULL(COUNT(*), 0) Transactions,
                        ISNULL(SUM(RP.Usd), 0) Usd
                 FROM RentPayments RP
                      INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
                      INNER JOIN Users u ON RP.CreatedBy = u.UserId
                 WHERE RP.AgencyId = @AgencyId
                   AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)

                 UNION ALL
                 SELECT
                        TypeId = 2,
                        ISNULL(COUNT(*), 0) Transactions,
                        ISNULL(SUM(DP.Usd), 0) Usd
                 FROM DepositFinancingPayments DP
                      INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
                      INNER JOIN Users u ON DP.CreatedBy = u.UserId
                 WHERE dp.AgencyId = @AgencyId
                   AND CAST(dp.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(dp.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 UNION ALL
                 SELECT 
                        TypeId = 3,
                        ISNULL(COUNT(*), 0) Transactions,
                        -ISNULL(SUM(C.RefundUsd), 0) Usd
                 FROM Contract c
                      INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
                      INNER JOIN Users u ON c.CreatedBy = u.UserId
                 WHERE c.AgencyRefundId = @AgencyId
                   AND CAST(c.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(c.RefundDate AS DATE) <= CAST(@ToDate AS DATE)
                 UNION ALL
                 SELECT 
                        TypeId = 4,
                        ISNULL(COUNT(*), 0) Transactions,
                        ISNULL(SUM(RP.FeeDue), 0) Usd
                 FROM RentPayments RP
                      INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
                      INNER JOIN Users u ON RP.CreatedBy = u.UserId
                 WHERE RP.AgencyId = @AgencyId
                   AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             ) P
         ) AS QueryFinal	    
         GROUP BY ROLLUP(RowNumberDetail)
     END;
GO