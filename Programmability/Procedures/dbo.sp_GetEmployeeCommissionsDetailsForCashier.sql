SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-04-01 felipe/5678: Gets the commissions payments details 

CREATE PROCEDURE [dbo].[sp_GetEmployeeCommissionsDetailsForCashier] @StartDate DATETIME,
@EndDate DATETIME,
@AgencyId INT,
@UserId INT = NULL,
@OnlyPendings BIT = NULL
AS
BEGIN
  IF OBJECT_ID('tempdb..#TempCashierCommissions') IS NOT NULL
    DROP TABLE #TempCashierCommissions;

  CREATE TABLE #TempCashierCommissions (
    [ReportId] INT IDENTITY (1, 1)
   ,[Index] INT
   ,[OperationName] VARCHAR(100)
   ,[Quantity] INT
   ,[CreationDate] DATETIME
   ,[Employee] VARCHAR(100)
   ,[ExpenseId] INT
   ,ExpensePaidId INT
   ,[CashierCommissionPaid] BIT
   ,[CommissionPaidStatus] VARCHAR(10)
   ,[moneyvalue] DECIMAL(18, 2)
   ,[Value] DECIMAL(18, 2)
   ,Disabled BIT
   ,[Set] BIT
   ,[Debit] DECIMAL(18, 2)
   ,[Credit] DECIMAL(18, 2)
   ,[Balance] DECIMAL(18, 2)
  );

  INSERT INTO #TempCashierCommissions
    SELECT
      QUERY1.[Index]
     ,QUERY1.[OperationName]
     ,QUERY1.[Quantity]
     ,QUERY1.[CreationDate]
     ,QUERY1.[Employee]
     ,QUERY1.[ExpenseId]
     ,QUERY1.ExpensePaidId
     ,QUERY1.[CashierCommissionPaid]
     ,QUERY1.[CommissionPaidStatus]
     ,QUERY1.[moneyvalue]
     ,QUERY1.[Value]
     ,QUERY1.Disabled
     ,QUERY1.[Set]
     ,QUERY1.[Debit]
     ,QUERY1.[Credit]
     ,QUERY1.[Balance]
    -- SELECT QUERY1.*   
    FROM (
      --    SELECT
      --        0 AS [Index]
      --       ,'INITIAL BALANCE' AS [OperationName]
      --       , CASE
      --        WHEN @initialBalance > 0 THEN 1
      --        ELSE 0
      --      END Quantity
      --       ,@initialBalanceFinalDate AS CreationDate
      --       ,'INITIAL BALANCE' AS Employee
      --       ,NULL [ExpenseId]
      --       ,NULL ExpensePaidId
      --       ,CASE
      --          WHEN @initialBalance > 0 THEN CAST(0 AS BIT)
      --          ELSE CAST(1 AS BIT)
      --        END AS CashierCommissionPaid
      --       ,CASE
      --          WHEN @initialBalance > 0 THEN 'PENDING'
      --          ELSE 'PAID'
      --        END AS CommissionPaidStatus
      --       ,@initialBalance [moneyvalue]
      --       ,@initialBalance Value
      --       ,1 Disabled
      --       ,1 [Set]
      --       ,0 AS Debit
      --       ,0 AS Credit
      --       ,@initialBalance [Balance]
      --      UNION ALL
      --      SELECT
      --        q.[Index]
      --       ,q.[OperationName]
      --        ,(q.[Quantity])
      --       ,q.[CreationDate]
      --       ,q.[Employee]
      --       ,q.[ExpenseId]
      --       ,q.ExpensePaidId
      --        --     ,CASE
      --        --        WHEN q.[ExpenseId] IS NULL THEN 0
      --        --        ELSE 1
      --        --      END AS CashierCommissionPaid
      --        --     ,CASE
      --        --        WHEN q.[ExpenseId] IS NULL THEN 'PENDING'
      --        --        ELSE 'PAID'
      --        --      END AS CommissionPaidStatus
      --       ,CASE
      --          WHEN q.[Index] <> 12 AND
      --            q.[ExpenseId] IS NULL THEN 0
      --          WHEN q.[Index] <> 12 AND
      --            q.[ExpenseId] > 0 THEN 1
      --          WHEN q.[Index] = 12 AND
      --            q.ExpensePaidId IS NULL THEN 0
      --          WHEN q.[Index] = 12 AND
      --            q.ExpensePaidId > 0 THEN 1
      --        END AS CashierCommissionPaid
      --       ,CASE
      --          WHEN q.[Index] <> 12 AND
      --            q.[ExpenseId] IS NULL THEN 'PENDING'
      --          WHEN q.[Index] <> 12 AND
      --            q.[ExpenseId] > 0 THEN 'PAID'
      --          WHEN q.[Index] = 12 AND
      --            q.ExpensePaidId IS NULL THEN 'PENDING'
      --          WHEN q.[Index] = 12 AND
      --            q.ExpensePaidId > 0 THEN 'PAID'
      --
      --        END AS CommissionPaidStatus
      --       ,(q.Balance) moneyvalue
      --       ,(q.Balance) Value
      --       ,1 Disabled
      --       ,1 [Set]
      --       ,ABS(q.[Debit]) [Debit]
      --       ,ABS(q.[Credit]) [Credit]
      --       ,q.[Balance] [Balance]
      --      FROM dbo.FN_GetEmployeeCommissionsData(@StartDate, @EndDate, @AgencyId, @UserId, 0, 0, @OnlyPendings) q
      --
      --      UNION ALL

      SELECT
        f.[Index]
       ,[OperationName]
       ,f.CreationDate
       ,(f.[Quantity]) [Quantity]
        --     f.CreationDate CreationDate
        --       ,CASE
        --          WHEN UPPER(f.Employee) <> UPPER(f.Employee) THEN f.[Employee] + ' PAYED BY: ' + f.[Employee]
        --          ELSE f.[Employee]
        --        END [Employee]
        --
        --  ,CASE
        --          WHEN UPPER(f.Employee) <> UPPER(u.Name) THEN f.[Employee] + ' PAYED BY: ' + u.Name
        --          ELSE f.[Employee]
        --        END [Employee]
       ,f.[Employee]
       ,f.[ExpenseId]
       ,f.ExpensePaidId
       ,f.[CashierCommissionPaid]
       ,f.CommissionPaidStatus
       ,(f.Balance) moneyvalue
       ,(f.Balance) Value
       ,1 Disabled
       ,1 [Set]
       ,ABS((f.[Debit])) [Debit]
       ,ABS((f.[Credit])) [Credit]
       ,(f.Balance)
        Balance
      FROM dbo.FN_GetEmployeeCommissionPayments(@StartDate, @EndDate, @AgencyId, @UserId, @OnlyPendings) f

    --      GROUP BY f.ExpenseId
    --              ,f.[Index]
    --              ,f.[OperationName]
    --              ,f.[Employee]
    --              ,f.[ExpenseId]
    --              ,f.CreationDate
    --              ,[CashierCommissionPaid]
    --              ,[CommissionPaidStatus]
    --              ,ExpensePaidId
    ) AS QUERY1
    ORDER BY CreationDate, [Index], ExpenseId

  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST([Balance] AS DECIMAL(18, 2))), 0)
      FROM #TempCashierCommissions T2
      WHERE T2.[ReportId] <= T1.[ReportId])
    RunningSum
  FROM #TempCashierCommissions T1
  WHERE ([Balance] IS NOT NULL
  AND [Balance] <> 0)


  DROP TABLE #TempCashierCommissions;
END;

GO