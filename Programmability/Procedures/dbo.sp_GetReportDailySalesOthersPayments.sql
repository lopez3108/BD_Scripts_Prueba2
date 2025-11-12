SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesOthersPayments]
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
         SELECT Provider = ISNULL(P.Provider, 'TOTAL'),
                Transactions = ISNULL(SUM(p.Transactions), 0),
                Usd = ISNULL(SUM(p.Usd), 0)
         FROM
         (
             SELECT Provider = 'OTHER PAYMENTS',
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
             FROM dbo.OtherPayments T
             WHERE T.AgencyId = @AgencyId
			AND T.PayMissing =0
                   AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                  
             UNION ALL
             SELECT Provider = 'MISSING PAY',
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.UsdPayMissing)), 0) Usd
           FROM dbo.OtherPayments T
             WHERE T.AgencyId = @AgencyId 
			 		AND T.PayMissing =1
                   AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                  
         ) P
         GROUP BY ROLLUP((p.Provider));
     END;
GO