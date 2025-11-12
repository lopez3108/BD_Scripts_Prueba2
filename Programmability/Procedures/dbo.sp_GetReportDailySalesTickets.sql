SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesTickets]
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
	    Type = ISNULL(P.Type, 5),
                Transactions = ISNULL(SUM(p.Transactions), 0),
                Usd = ISNULL(SUM(p.Usd), 0)
         FROM
         (
             SELECT Provider = 'FEE SERVICES',
                    1 Type,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(T.Usd), 0) Usd
             FROM TicketFeeServices t
             WHERE t.AgencyId = @AgencyId
                   AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'MONEY ORDER',
                    2 Type,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL((SUM(ISNULL(t.MoneyOrderFee, 0)) + SUM(t.Usd)), 0) Usd
             FROM Tickets t
             WHERE T.MoneyOrderNumber IS NOT NULL
                   AND UpdateToPendingDate IS NOT NULL
                   AND t.ChangedToPendingByAgency = @AgencyId
                   AND CAST(t.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'CARD PAYMENT',
                    3 Type,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL((SUM(t.Usd)), 0) Usd
             FROM Tickets t
             WHERE T.CardBankId > 0
                   AND UpdateToPendingDate IS NOT NULL
                   AND t.ChangedToPendingByAgency = @AgencyId
                   AND CAST(t.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
             UNION ALL
             SELECT Provider = 'BANK ACCOUNT',
                    4 Type,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL((SUM(t.Usd)), 0) Usd
             FROM Tickets t
             WHERE T.BankAccountId > 0
                   AND UpdateToPendingDate IS NOT NULL
                   AND t.ChangedToPendingByAgency = @AgencyId
                   AND CAST(t.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(t.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
         ) P
         GROUP BY ROLLUP((p.Provider,
                          Type))
         ORDER BY Type;
     END;
GO