SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-24 Carlos/5761: Employee commissions payment

CREATE PROCEDURE [dbo].[sp_DeleteExpenseById] (@ExpenseId INT)
AS
BEGIN

  DECLARE @expenseTypeId INT
  SET @expenseTypeId = (SELECT TOP 1
      ExpenseTypeId
    FROM dbo.Expenses e
    WHERE e.ExpenseId = @ExpenseId)

  DECLARE @expenseCode VARCHAR(10)
  SET @expenseCode = (SELECT TOP 1
      Code
    FROM dbo.ExpensesType e
    WHERE e.ExpensesTypeId = @expenseTypeId)

  DECLARE @cashierId INT
  SET @cashierId = (SELECT TOP 1
      CashierId
    FROM dbo.Expenses e
    WHERE e.ExpenseId = @ExpenseId)

  DECLARE @agencyId INT
  SET @agencyId = (SELECT TOP 1
      AgencyId
    FROM dbo.Expenses e
    WHERE e.ExpenseId = @ExpenseId)

  IF (@expenseCode = 'C10')--CASHIER COMMISSION
  BEGIN

    DECLARE @expenseDate DATETIME
    SET @expenseDate = (SELECT TOP 1
        CreatedOn
      FROM dbo.Expenses e
      WHERE e.ExpenseId = @ExpenseId)

    DECLARE @paid BIT
    SET @paid = CAST(0 AS BIT)
--Se actualizan todas las comisiones a estado sin pagar 
    EXEC dbo.sp_UpdateEmployeeCommissionsPaid @cashierId
                                             ,@agencyId
                                             ,NULL
                                             ,@ExpenseId
--Se eliminan todas las comisiones retornadas para el expenseid
    EXEC dbo.sp_DeleteCommissionsEmployeesReturn @ExpenseId
  END

  DELETE FROM Expenses
  WHERE ExpenseId = @ExpenseId;

END;





GO