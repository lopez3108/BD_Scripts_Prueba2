SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllExpensesCommissionsCashierByDates]
(@YearStart  INT, 
 @MonthStart INT, 
 @YearEnd    INT, 
 @MonthEnd   INT, 
 @UserId     INT, 
 @AgencyId   INT
)
AS
    BEGIN
        SELECT e.Usd, 
               e.Year, 
               m.Number Month, 
               e.AgencyId, 
               e.CreatedBy
        FROM expenses e
             INNER JOIN months m ON e.MonthsId = m.MonthId
             INNER JOIN ExpensesType et ON et.ExpensesTypeId = e.ExpenseTypeId
        WHERE((e.[Year] >= @YearStart
               AND m.Number >= @MonthStart)
              AND (e.[Year] <= @YearEnd
                   AND m.Number <= @MonthEnd))
             AND et.Code = 'C10'-- CASHIER COMMISSIONS
             AND (e.CreatedBy = @UserId)
             AND (e.AgencyId = @AgencyId);
    END;
GO