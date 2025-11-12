SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesEls]
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
            SELECT Provider = 'CITY STICKER', 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + t.Fee1 + t.FeeEls + t.CardPaymentFee), 0) Usd
            FROM CityStickers t
            WHERE t.AgencyId = @AgencyId
                  AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL
            SELECT Provider = 'COUNTY TAXES', 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + t.Fee1 + t.FeeEls + t.CardPaymentFee), 0) Usd
            FROM CountryTaxes t
            WHERE t.AgencyId = @AgencyId
                  AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL
            SELECT Provider = 'PARKING TICKETS CARDS', 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + t.Fee1 + t.Fee2 + t.CardPaymentFee), 0) Usd
            FROM ParkingTicketsCards T
            WHERE t.AgencyId = @AgencyId
                  AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL
            SELECT Provider = 'REGISTRATION RENEWALS', 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee), 0) Usd
            FROM PlateStickers t
            WHERE t.AgencyId = @AgencyId
                  AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL
            SELECT Provider = 'TITLE INQUIRY', 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee), 0) Usd
            FROM TitleInquiry t
            WHERE t.AgencyId = @AgencyId
                  AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL
            SELECT Provider = 'TITLES', 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee), 0) Usd
            FROM Titles t
            WHERE T.ProcessAuto = 1
                  AND t.AgencyId = @AgencyId
                  AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL
            SELECT Provider = 'TRP', 
                   ISNULL(COUNT(*), 0) Transactions, 
                   SUM(T.Usd + t.Fee1 + T.TrpFee) Usd
            FROM TRP T
            WHERE T.AgencyId = @AgencyId
                  AND CAST(T.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(T.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
        ) P
        GROUP BY ROLLUP((p.Provider));
    END;
GO