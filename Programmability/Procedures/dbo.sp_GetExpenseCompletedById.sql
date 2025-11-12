SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created By: Felipe
--Date:08-12-2023
--CAMBIOS EN 5559, Problemas guardando expenses

CREATE PROCEDURE [dbo].[sp_GetExpenseCompletedById]
(
                 @ExpenseId int

)
AS
BEGIN

  SELECT *
  FROM Expenses
  WHERE Validated = 1 AND
        ExpenseId = @ExpenseId
END;
GO