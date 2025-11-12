SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesReturnChecks]
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
                Transactions = ISNULL(COUNT(rc.ReturnedCheckId), 0),
                ISNULL(SUM(RC.Usd + RC.ProviderFee), 0) Usd
         FROM ProviderTypes PT
              LEFT JOIN Providers P ON PT.ProviderTypeId = p.ProviderTypeId
              LEFT JOIN dbo.ReturnedCheck rc ON RC.ProviderId = P.ProviderId
                                                AND RC.ReturnedAgencyId = @AgencyId
                                                AND (CAST(rc.ReturnDate AS DATE) >= CAST(@FromDate AS DATE)
                                                     OR @FromDate IS NULL)
                                                AND (CAST(rc.ReturnDate AS DATE) <= CAST(@ToDate AS DATE)
                                                     OR @ToDate IS NULL)
         WHERE PT.CODE = 'C02'
         GROUP BY ROLLUP((p.Name));
     END;

	
GO