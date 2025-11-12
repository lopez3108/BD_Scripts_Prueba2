SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllExpenseRefund]
(@SurplusDate DATE,
 @Code        VARCHAR(5),
 @listIdSaves VARCHAR(500) = NULL,
 @CashierId   INT,
 @UserId   INT
)
AS
     BEGIN
         SELECT *
         FROM Expenses e
              INNER JOIN expensestype ex ON ex.ExpensesTypeId = e.ExpenseTypeId
         WHERE(ex.code = @Code)
              AND E.RefundCashierId = @CashierId
              AND CAST(e.RefundSurplusDate AS DATE) = CAST(@SurplusDate AS DATE)
		    AND E.CreatedBy = @UserId
              AND (e.ExpenseId NOT IN
                  (
                      SELECT item
                      FROM dbo.FN_ListToTableInt(@listIdSaves)
                  )
         OR @listIdSaves IS NULL OR @listIdSaves = '');
     END;
GO