SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesReturnCheckPayments]
				   
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
                Transactions = ISNULL(COUNT(t.ReturnedCheckId), 0),
                ISNULL(SUM(T.Usd), 0) Usd
         FROM ProviderTypes PT
              LEFT JOIN Providers P ON PT.ProviderTypeId = p.ProviderTypeId
              LEFT JOIN dbo.ReturnedCheck rc ON RC.ProviderId = P.ProviderId
                                           
              LEFT JOIN ReturnPayments T ON t.ReturnedCheckId = rc.ReturnedCheckId
		         AND t.AgencyId = @AgencyId
                                            AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                                 OR @FromDate IS NULL)
                                            AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                                 OR @ToDate IS NULL)
         WHERE PT.CODE = 'C02'
         GROUP BY ROLLUP((p.Name
                          ));
     END;
GO