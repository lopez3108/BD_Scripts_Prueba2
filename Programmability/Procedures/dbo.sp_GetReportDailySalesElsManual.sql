SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesElsManual]
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
         SELECT Provider = ISNULL(PT.Description, 'TOTAL'),
                Transactions = ISNULL(COUNT(t.TitleId), 0),
                ISNULL(SUM(T.Usd + ISNULL(t.Fee1, 0) + ISNULL(T.FeeEls, 0) + ABS(ISNULL(t.FeeILDOR, 0)) + ABS(ISNULL(t.FeeILSOS, 0)) + ABS(ISNULL(t.FeeOther, 0)) + ISNULL(t.FeeOther, 0)), 0) Usd
         FROM ProcessTypes PT
              LEFT JOIN Titles T ON pt.ProcessTypeId = t.ProcessTypeId
                                    AND T.AgencyId = @AgencyId
                                    AND T.ProcessAuto = 0
                                    --AND PT.ProcessAuto = 0
                                    AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                         OR @FromDate IS NULL)
                                    AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                         OR @ToDate IS NULL)
         
         GROUP BY ROLLUP((pT.Description));
     END;

GO