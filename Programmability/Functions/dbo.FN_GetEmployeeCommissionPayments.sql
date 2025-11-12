SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- UPDATED 2024-05-10 BY JT/Task 5866, only show info from '2024-04-01'
-- UPDATED 2024-05-10 BY JT/5865: Change the position for traffic tickets module and daily
-- 2024-03-22 CREATED BY JT/5475: Adding initial balance + report refactoring
-- UPDATED 2024-05-10 BY JT/5865: 1-Change the position for traffic tickets module and daily 2-show the payment in the last day of month
-- 2024-12-05 CREATED BY JF/6244: Problema con el pago de comisiones

CREATE FUNCTION [dbo].[FN_GetEmployeeCommissionPayments] (@StartDate DATETIME,
@EndDate DATETIME,
@AgencyId INT,
@UserId INT = NULL,
@OnlyPendings BIT = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,[OperationName] VARCHAR(100)
 ,[CreationDate] DATETIME
 ,[Quantity] INT
 ,[Employee] VARCHAR(200)
 ,EmployeeId INT
 ,[ExpenseId] INT NULL
 ,[ExpensePaidId] INT NULL
 ,[CashierCommissionPaid] BIT
 ,[CommissionPaidStatus] VARCHAR(10)
 ,[MonthNumber] INT
 ,[YearNumber] INT
 ,[Month] VARCHAR(20)
 ,[Year] VARCHAR(5)
 ,[Type] VARCHAR(50)
 ,[TypeId] VARCHAR(50)
 ,[moneyvalue] DECIMAL(18, 2)
 ,[Value] DECIMAL(18, 2)
 ,Disabled BIT
 ,[Set] BIT
 ,[Debit] DECIMAL(18, 2)
 ,[Credit] DECIMAL(18, 2)
 ,[Balance] DECIMAL(18, 2)
)

AS
BEGIN
  --Task 5866, only show info from '2024-04-01'
  IF CAST(@StartDate AS DATE) < '2024-04-01'
  BEGIN
    SET @StartDate = CAST('2024-04-01' AS DATETIME)
  END
  DECLARE @futureStartDate DATETIME
         ,@futureEndtDate DATETIME;
  SET @futureStartDate = DATEADD(DAY, 1, @EndDate)
  SET @futureEndtDate = eomonth(@futureStartDate)


  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @StartDate)

  DECLARE @initialBalance DECIMAL(18, 2)
  SET @initialBalance = (SELECT
      ISNULL(SUM(ISNULL(CAST([Balance] AS DECIMAL(18, 2)), 0)), 0)
    FROM dbo.FN_GetEmployeeCommissionsData('2024-04-01', @initialBalanceFinalDate, @AgencyId, @UserId, 0, 1)) 
    --task 6244 '2024-04-01' fecha minima de donde se inicio a pagar las comisiones 

  INSERT INTO @result

    SELECT
      0 AS [Index]
     ,'INITIAL BALANCE' AS [OperationName]
     ,@initialBalanceFinalDate AS CreationDate
     ,CASE
        WHEN @initialBalance > 0 THEN 1
        ELSE 0
      END Quantity
     ,'INITIAL BALANCE' AS Employee
     ,0 EmployeeId
     ,NULL [ExpenseId]
     ,NULL ExpensePaidId
     ,CASE
        WHEN @initialBalance > 0 THEN CAST(0 AS BIT)
        ELSE CAST(1 AS BIT)
      END AS CashierCommissionPaid
     ,CASE
        WHEN @initialBalance > 0 THEN 'PENDING'
        ELSE 'PAID'
      END AS CommissionPaidStatus
     ,DATEPART(MONTH, @initialBalanceFinalDate) [MonthNumber]
     ,DATEPART(YEAR, @initialBalanceFinalDate) [YearNumber]
     ,DATENAME(MONTH, @initialBalanceFinalDate) [Month]
     ,CAST(DATEPART(YEAR, @initialBalanceFinalDate) AS VARCHAR(5)) [Year]
     ,'INITIAL BALANCE' [Type]
     ,0 [TypeId]
     ,@initialBalance [moneyvalue]
     ,@initialBalance Value
     ,1 Disabled
     ,1 [Set]
     ,@initialBalance AS Debit
     ,@initialBalance AS Credit
     ,@initialBalance [Balance]

    UNION ALL
    SELECT
      q.[Index]
     ,q.[OperationName]
     ,q.[CreationDate]
     ,(q.[Quantity])
     ,q.[Employee]
     ,q.EmployeeId
     ,q.[ExpenseId]
     ,q.ExpensePaidId
     ,CASE
        WHEN q.[Index] <> 12 AND
          q.[ExpenseId] IS NULL THEN 0
        WHEN q.[Index] <> 12 AND
          q.[ExpenseId] > 0 THEN 1
        WHEN q.[Index] = 12 AND
          q.ExpensePaidId IS NULL THEN 0
        WHEN q.[Index] = 12 AND
          q.ExpensePaidId > 0 THEN 1
      END AS CashierCommissionPaid
     ,CASE
        WHEN q.[Index] <> 12 AND
          q.[ExpenseId] IS NULL THEN 'PENDING'
        WHEN q.[Index] <> 12 AND
          q.[ExpenseId] > 0 THEN 'PAID'
        WHEN q.[Index] = 12 AND
          q.ExpensePaidId IS NULL THEN 'PENDING'
        WHEN q.[Index] = 12 AND
          q.ExpensePaidId > 0 THEN 'PAID'

      END AS CommissionPaidStatus
     ,[MonthNumber]
     ,[YearNumber]
     ,[Month]
     ,[Year]
     ,'MONTH' [Type]
     ,1 [TypeId]
     ,(q.Balance) moneyvalue
     ,(q.Balance) Value
     ,1 Disabled
     ,1 [Set]
     ,ABS(q.[Debit]) [Debit]
     ,ABS(q.[Credit]) [Credit]
     ,q.[Balance] [Balance]
    FROM dbo.FN_GetEmployeeCommissionsData(@StartDate, @EndDate, @AgencyId, @UserId, 0, @OnlyPendings) q

    UNION ALL
    SELECT
      30 [Index]  --Change the position for separate traffic tickets module and daily
     ,'COMMISSION PAYMENT' + ' ' + FORMAT(q.CreatedOn, 'MM-dd-yyyy', 'en-US') [OperationName]
      --     + cast(q.[ExpenseId] AS varchar(10)) + '-' + cast(cr.ExpensePaidId AS varchar(10))
      --     ,eomonth(datefromparts(q.[Year], dbo.Months.Number, 1)) CreationDate
     ,CONVERT(DATETIME, CONVERT(VARCHAR(10), eomonth(datefromparts(q.[Year], dbo.Months.Number, 1))) + ' 23:59:59') AS CreationDate--task 5865 show the payment in the last day of month
     ,1 [Quantity]
      --     ,UPPER(dbo.Users.Name) [Employee]

     ,CASE
        WHEN UPPER(u.UserId) <> UPPER(ur.UserId) THEN u.Name + ' PAID BY: ' + ur.Name
        ELSE u.Name
      END [Employee]
     ,u.UserId EmployeeId
     ,0 [ExpenseId]
     ,0 ExpensePaidId
     ,1 CashierCommissionPaid
     ,'PAID' AS CommissionPaidStatus
     ,dbo.Months.Number [MonthNumber]
     ,q.Year [YearNumber]
     ,UPPER(dbo.Months.Description) [Month]
     ,q.[Year]
     ,'COMMISSIONS' [Type]
     ,2 [TypeId]
     ,ABS(((q.Usd))) AS moneyvalue
     ,ABS(((q.Usd))) AS Value
     ,1 Disabled
     ,1 [Set]
     ,CAST(0.00 AS DECIMAL(18, 2)) Debit
     ,ABS(q.Usd) Credit
     ,q.Usd AS
      Balance
    FROM dbo.Expenses q
    INNER JOIN dbo.ExpensesType
      ON q.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
    INNER JOIN dbo.Cashiers
      ON q.RefundCashierId = dbo.Cashiers.CashierId
    INNER JOIN dbo.Users u
      ON dbo.Cashiers.UserId = u.UserId
    INNER JOIN dbo.Users ur
      ON q.CreatedBy = ur.UserId
    INNER JOIN dbo.Months
      ON q.MonthsId = dbo.Months.MonthId
    WHERE @OnlyPendings IS NULL
    AND q.AgencyId = @AgencyId
    --    AND dbo.Cashiers.IsActive = 1
    AND (@UserId IS NULL
    OR dbo.Cashiers.UserId = @UserId)
    AND dbo.ExpensesType.Code = 'C10'

    --    AND (dbo.Months.Number = DATEPART(MONTH, @StartDate))
    --    AND (q.[Year] = DATEPART(YEAR, @StartDate))
    --     AND (dbo.Months.Number = DATEPART(MONTH, @EndDate))
    --    AND (q.[Year] = DATEPART(YEAR, @StartDate))
    --    ORDER BY [YearNumber], [MonthNumber], [Employee], [Index], [Type]
    AND eomonth(datefromparts(q.[Year], dbo.Months.Number, 1)) >= @StartDate
    AND eomonth(datefromparts(q.[Year], dbo.Months.Number, 1)) <= @EndDate


  RETURN;
END;

GO