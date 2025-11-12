SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesCancellations]
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
         SELECT Provider = ISNULL(p.Name, 'TOTAL'),
                Transactions = ISNULL(COUNT(Mov.ProviderId), 0),
                ISNULL(SUM(Mov.Usd), 0) Usd
         FROM ProviderTypes PT
              LEFT JOIN Providers P ON PT.ProviderTypeId = p.ProviderTypeId
              LEFT JOIN
         (

--New transaction

             SELECT 'CANCELLATIONS' Type,
                    'CLOSING DAILY' Description,
                    t.ProviderNewId ProviderId,
                    COUNT(*) Transactions,
                    (SUM(ABS(t.TotalTransaction)) + SUM(ABS(t.Fee))) Usd,
                    t.AgencyId
             FROM Cancellations t
             WHERE T.AgencyId = @AgencyId
                   AND CAST(t.NewTransactionDate AS DATE) IS NOT NULL
                   AND CAST(t.NewTransactionDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.NewTransactionDate AS DATE) <= CAST(@ToDate AS DATE)
             GROUP BY CAST(t.NewTransactionDate AS DATE),
                      t.RefundFee,
                      t.ProviderNewId,
                      t.AgencyId
             UNION ALL

 --- REFUND SIN FEE

             SELECT 'CANCELLATIONS' Type,
                    'CLOSING DAILY' Description,
                    t.ProviderCancelledId ProviderId,
                    COUNT(*) Transactions,
                    SUM(ABS(t.RefundAmount)) Usd,
                    t.AgencyId
             FROM Cancellations t
             WHERE T.AgencyId = @AgencyId
                   AND CAST(t.RefundDate AS DATE) IS NOT NULL
                   AND (RefundFee IS NULL
                        OR RefundFee = 0)
                   AND CAST(t.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.RefundDate AS DATE) <= CAST(@ToDate AS DATE)
             GROUP BY CAST(t.RefundDate AS DATE),
                      t.RefundFee,
                      t.ProviderCancelledId,
                      t.AgencyId
             UNION ALL 

--REFUND CON FEE

             SELECT 'CANCELLATIONS' Type,
                    'CLOSING DAILY' Description,
                    t.ProviderCancelledId ProviderId,
                    COUNT(*) Transactions,
                    SUM(ABS(t.RefundAmount)) + SUM(ABS(t.Fee)) Usd,
                    t.AgencyId
             FROM Cancellations t
             WHERE T.AgencyId = @AgencyId
                   AND CAST(t.RefundDate AS DATE) IS NOT NULL
                   AND RefundFee = 1
                   AND CAST(t.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.RefundDate AS DATE) <= CAST(@ToDate AS DATE)
             GROUP BY CAST(t.RefundDate AS DATE),
                      t.RefundFee,
                      t.ProviderCancelledId,
                      t.AgencyId
         ) Mov ON p.ProviderId = Mov.ProviderId
         WHERE PT.CODE IN('C01', 'C02')
         --AND T.AgencyId = Mov.;                                            
         GROUP BY ROLLUP((p.Name));
     END;
GO