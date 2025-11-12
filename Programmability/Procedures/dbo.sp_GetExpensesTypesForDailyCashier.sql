SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetExpensesTypesForDailyCashier]
AS
SET NOCOUNT ON
     BEGIN

	 DECLARE @forexExpenseType INT, @payrollExpenseType INT
		   SET @forexExpenseType =   (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C15')
       SET @payrollExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C16')

         SELECT e.*
         FROM dbo.ExpensesType e
		 WHERE e.ExpensesTypeId NOT IN (@forexExpenseType,@payrollExpenseType)
     END;


GO