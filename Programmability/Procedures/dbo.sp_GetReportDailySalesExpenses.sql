SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesExpenses]
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
         SELECT Provider = ISNULL(ET.Description, 'TOTAL'),
                Transactions = ISNULL(COUNT(E.ExpenseId), 0),
                ISNULL(SUM(ABS(E.Usd)), 0) Usd
         FROM ExpensesType ET
              LEFT JOIN expenses E ON ET.ExpenseSTypeId = e.ExpenseTypeId
                                      AND E.AgencyId = @AgencyId
                                      AND (CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                                           OR @FromDate IS NULL)
                                      AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                                           OR @ToDate IS NULL)
         GROUP BY ROLLUP((ET.Description));
     END;
GO