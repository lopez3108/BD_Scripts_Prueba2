SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDailyByDateByListCashier] @CashierId VARCHAR(500) = NULL, 
                                                        @FromDate  DATE         = NULL, 
                                                        @ToDate    DATE         = NULL
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT D.DailyId, 
               D.CashierId, 
			      u.UserId,
               D.AgencyId, 
               D.CreationDate, 
               D.Total, 
               D.TotalFree, 
               D.Missing, 
               D.Surplus, 
               D.Note, 
               D.LastEditedOn, 
               D.LastEditedBy, 
			u.Name,
               ISNULL(D.Cash, 0) AS Cash, 
               ISNULL(D.CashAdmin, 0) AS CashAdmin, 
               ISNULL(D.CardPayments, 0) AS CardPayments, 
               ISNULL(D.CardPaymentsAdmin, 0) AS CardPaymentsAdmin, 
               ISNULL(DA.DailyAdjustmentId, 0) DailyAdjustmentId, 
               ISNULL(D.ClosedOn, NULL) ClosedOn, 
               ISNULL(D.ClosedBy, 0) ClosedBy, 
               ISNULL(D.ClosedOnCashAdmin, NULL) ClosedOnCashAdmin, 
               ISNULL(D.ClosedByCashAdmin, 0) ClosedByCashAdmin, 
               ISNULL(D.ClosedOnCardPaymentsAdmin, NULL) ClosedOnCardPaymentsAdmin, 
               ISNULL(D.ClosedByCardPaymentsAdmin, 0) ClosedByCardPaymentsAdmin
        FROM Daily D
             LEFT JOIN DailyAdjustments DA ON D.DailyId = DA.DailyId
			      inner JOIN Cashiers c ON c.CashierId = d.CashierId
             left JOIN Users u ON u.userId = c.UserId
        WHERE(d.CashierId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@CashierId)
        )
        OR (@CashierId = ''
            OR @CashierId IS NULL))
             AND (((CAST(d.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                    OR @FromDate IS NULL))
                  AND ((CAST(d.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
                       OR @ToDate IS NULL));
    END;
GO