SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTicketsReportByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN

         DECLARE @MoneyOrderFeeSet DECIMAL(18, 2);
         SET @MoneyOrderFeeSet =
         (
             SELECT TOP 1 MoneyOrderFee
             FROM [dbo].[ConfigurationELS]
         );
         SELECT SUM(QSUP.USD) + SUM(QSUP.UsdFeeServices) - SUM(QSUP.MoneyOrders) USD,
                QSUP.Date,
                'TRAFFIC TICKETS' Name
         FROM
         (
             SELECT(ISNULL(SUM(t.Usd), 0) + ISNULL(SUM(t.Fee1), 0) + ISNULL(SUM(t.Fee2), 0)) USD,
                   ISNULL(SUM(tsfq.Usd), 0) UsdFeeServices,
                   ISNULL(SUM(tpq.UsdMoneyOrders), 0) MoneyOrders,
                   CASE
                       WHEN CAST(t.CreationDate AS DATE) IS NOT NULL
                       THEN CAST(t.CreationDate AS DATE)
                       WHEN CAST(t.CreationDate AS DATE) IS NULL
                            AND CAST(tsfq.CreationDate AS DATE) IS NOT NULL
                       THEN CAST(tsfq.CreationDate AS DATE)
                       WHEN CAST(t.CreationDate AS DATE) IS NULL
                            AND CAST(tsfq.CreationDate AS DATE) IS NULL
                            AND CAST(tpq.UpdateToPendingDate AS DATE) IS NOT NULL
                       THEN CAST(tpq.UpdateToPendingDate AS DATE)
                   END AS Date
             FROM Tickets t
                  INNER JOIN TicketStatus ts ON t.TicketStatusId = ts.TicketStatusId
                                                AND T.CreatedBy = @CreatedBy
                                                AND t.AgencyId = @AgencyId
                                                AND CAST(T.CreationDate AS DATE) >= CAST(@From AS DATE)
                                                AND CAST(T.CreationDate AS DATE) <= CAST(@To AS DATE)
                  INNER JOIN Users u ON u.UserId = t.CreatedBy
                  INNER JOIN Agencies a ON a.AgencyId = t.AgencyId
                  FULL OUTER JOIN
             (
                 SELECT CreationDate,
                        SUM(Usd) Usd
                 FROM TicketFeeServices  tsf
                 WHERE tsf.CreatedBy = @CreatedBy
                 --AND tsf.CreatedBy = @CreatedBy
                       AND tsf.AgencyId = @AgencyId
				     GROUP BY tsf.CreationDate
             ) tsfq ON tsfq.CreationDate = T.CreationDate
                  FULL OUTER JOIN
             (
                 SELECT tp.UpdateToPendingDate,
                        (SUM(tp.Usd) + (COUNT(*) * @MoneyOrderFeeSet)) UsdMoneyOrders
                 FROM Tickets tp
                 WHERE TP.MoneyOrderFee IS NOT NULL
                       AND TP.MoneyOrderFee > 0
                       AND TP.UpdateToPendingBy = @CreatedBy
                       AND TP.AgencyId = @AgencyId
                 GROUP BY tp.UpdateToPendingDate
             ) tpq ON tpq.UpdateToPendingDate = t.CreationDate
             GROUP BY CAST(t.CreationDate AS DATE),
                      CAST(tsfq.CreationDate AS DATE),
                      CAST(tpq.UpdateToPendingDate AS DATE)
         ) AS QSUP
         GROUP BY QSUP.Date;
     END;

GO