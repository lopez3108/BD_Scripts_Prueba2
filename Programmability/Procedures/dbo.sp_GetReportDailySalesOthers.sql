SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesOthers]
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
         SELECT Provider = ISNULL(t.Name, 'TOTAL'),
                Transactions = ISNULL(COUNT(p.OtherDetailId), 0),
                ISNULL(SUM(p.Usd), 0) Usd
         FROM OthersServices t
              LEFT JOIN OthersDetails P ON p.OtherServiceId = t.OtherId
                                           AND P.AgencyId = @AgencyId
                                           AND (CAST(p.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                                OR @FromDate IS NULL)
                                           AND (CAST(p.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                                OR @ToDate IS NULL)
         GROUP BY ROLLUP((t.Name));
     END;
GO