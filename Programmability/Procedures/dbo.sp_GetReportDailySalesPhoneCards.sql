SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesPhoneCards]
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
             SELECT Provider = ISNULL('PHONE CARDS', 'TOTAL'),
                    ISNULL(SUM(T.Quantity), 0) Transactions,
                    ISNULL(SUM(T.PhoneCardsUsd), 0) Usd
             FROM PhoneCards T
             WHERE T.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
         ) P
         GROUP BY ROLLUP((p.Provider));
     END;
GO