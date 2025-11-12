SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Modificado JF 28-03-2025-- add @PayrollExpenseType para excluir este tipo  
-- JF 01-04-2025-- Al pagar nómina no se está reflejando el expense

CREATE PROCEDURE [dbo].[sp_GetAllExpensesByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
     DECLARE @PayrollExpenseType INT
		   SET @PayrollExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C16')

         SELECT SUM(dbo.Expenses.Usd) AS USD,
                CAST(dbo.Expenses.CreatedOn AS DATE) AS Date,
                'EXPENSES' AS Name
         FROM dbo.Expenses
         WHERE CAST(dbo.Expenses.CreatedOn AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.Expenses.CreatedOn AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
                 AND dbo.Expenses.ExpenseTypeId NOT IN (@PayrollExpenseType)
         GROUP BY CAST(dbo.Expenses.CreatedOn AS DATE);
     END;
GO