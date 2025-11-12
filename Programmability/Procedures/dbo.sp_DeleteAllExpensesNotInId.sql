SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllExpensesNotInId]
(@ExpensesIdList VARCHAR(1000),
 @Date           DATE,
 @UserId         INT,
 @AgencyId       INT
)
AS
     BEGIN
         DELETE FROM Expenses
         WHERE ExpenseId NOT IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@ExpensesIdList)
         )
         AND (CAST(CreatedOn AS DATE) = CAST(@Date AS DATE))
         AND CreatedBy = @UserId
         AND AgencyId = @AgencyId;
     END;
GO