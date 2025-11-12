SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-04-22 JF/5811: Generate expense daily after paying payroll

CREATE PROCEDURE [dbo].[sp_GetSumExpensesByAgencyId] @AgencyId  INT,
                                                     @CreatedOn DATE = NULL,
                                                     @UserId    INT = NULL
AS
     BEGIN

	 DECLARE @forexExpenseType INT
		   SET @forexExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C15')

       DECLARE @PayrollExpenseType INT
		   SET @PayrollExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C16')

         SELECT ISNULL(SUM(e.Usd), 0) Suma
         FROM Expenses E
              INNER JOIN Agencies a ON e.AgencyId = a.AgencyId
              INNER JOIN Users u ON e.CreatedBy = u.UserId
         WHERE e.AgencyId = @AgencyId
               AND (CAST(e.CreatedOn AS DATE) = CAST(@CreatedOn AS DATE)
                    OR @CreatedOn IS NULL)
               AND (CreatedBy = @UserId OR @UserId IS NULL)
			   AND e.ExpenseTypeId NOT IN (@forexExpenseType,@PayrollExpenseType)
     END;

GO