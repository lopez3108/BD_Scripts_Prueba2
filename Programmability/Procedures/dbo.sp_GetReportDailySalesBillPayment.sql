SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesBillPayment]
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
                Transactions =  ISNULL(count(t.BillPaymentId), 0) , 
                ISNULL(SUM(T.Usd), 0) Usd
         FROM ProviderTypes PT
              left JOIN  Providers P ON PT.ProviderTypeId = p.ProviderTypeId
               LEFT JOIN  BillPaymentS T ON p.ProviderId = t.ProviderId
                                            AND T.AgencyId = @AgencyId
                                            AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                                 OR @FromDate IS NULL)
                                            AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                                 OR @ToDate IS NULL)
         WHERE PT.Code = 'C01' 
         GROUP BY ROLLUP((p.Name));
     END;
GO