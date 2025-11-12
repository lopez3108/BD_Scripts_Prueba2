SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesDiscounts]
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
             SELECT Provider = 'DISCOUNT MONEY TRANSFERS',
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(T.Discount)), 0) Usd
             FROM DiscountMoneyTransfers t
             WHERE t.AgencyId = @AgencyId
                   AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'DISCOUNT CHECKS',
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(T.Discount)), 0) Usd
             FROM DiscountChecks t
             WHERE t.AgencyId = @AgencyId
                   AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'DISCOUNT PHONES',
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(T.Discount)), 0) Usd
             FROM DiscountPhones T
             WHERE t.AgencyId = @AgencyId
                   AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'DISCOUNT TITLES',
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(T.Discount)), 0) Usd
             FROM DiscountTitles t
             WHERE t.AgencyId = @AgencyId
                   AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'DISCOUNT CITY STYKERS',
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(T.Usd)), 0) Usd
             FROM DiscountCityStickers t
             WHERE t.AgencyId = @AgencyId
                   AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'DISCOUNT REGISTRATION RENEWALS',
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(T.Usd)), 0) Usd
             FROM DiscountPlateStickers t
             WHERE t.AgencyId = @AgencyId
                   AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'PROMOTIONAL CODES',
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(pc.Usd)), 0) Usd
             FROM PromotionalCodes pc
                  INNER JOIN PromotionalCodesStatus Pt ON pc.PromotionalCodeId = pt.PromotionalCodeId
             WHERE pt.AgencyUsedId = @agencyId
                   AND CAST(PT.UsedDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(PT.UsedDate AS DATE) <= CAST(@ToDate AS DATE)
         ) P
         GROUP BY ROLLUP((p.Provider));
     END;
GO