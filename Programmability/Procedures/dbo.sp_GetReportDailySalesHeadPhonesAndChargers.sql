SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetReportDailySalesHeadPhonesAndChargers]
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
             SELECT Provider = 'HEADPHONES',
                    ISNULL(SUM(T.HeadphonesQuantity), 0) Transactions,
                    ISNULL(SUM(T.HeadphonesUsd), 0) Usd
             FROM dbo.HeadphonesAndChargers T
             WHERE T.AgencyId = @AgencyId
                   AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                   AND (T.HeadphonesQuantity IS NOT NULL
                        AND T.HeadphonesQuantity > 0)
             UNION ALL
             SELECT Provider = 'CHARGERS',
                    ISNULL(SUM(T.ChargersQuantity), 0) Transactions,
                    ISNULL(SUM(T.ChargersUsd), 0) Usd
             FROM dbo.HeadphonesAndChargers T
             WHERE T.AgencyId = @AgencyId
                   AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                   AND (T.ChargersQuantity IS NOT NULL
                        AND T.ChargersQuantity > 0)
         ) P
         GROUP BY ROLLUP((p.Provider));
     END;
GO