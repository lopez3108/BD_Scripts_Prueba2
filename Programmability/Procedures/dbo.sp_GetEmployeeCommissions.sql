SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-22 DJ/5475: Adding initial balance + report refactoring + employee commissions module refactoring

CREATE PROCEDURE [dbo].[sp_GetEmployeeCommissions] @StartDate DATETIME,
@EndDate DATETIME,
@AgencyId INT,
@UserId INT = NULL
--@IsDetails BIT =NULL
AS
BEGIN
  IF OBJECT_ID('tempdb..#TempCashierCommissions') IS NOT NULL
    DROP TABLE #TempCashierCommissions;

  CREATE TABLE #TempCashierCommissions (
    [ReportId] INT IDENTITY (1, 1)
   ,[Index] INT
   ,[OperationName] VARCHAR(100)
   ,[Quantity] INT
   ,[Debit] DECIMAL(18, 2)
   ,[Credit] DECIMAL(18, 2)
   ,[moneyvalue] DECIMAL(18, 2)
   ,[Value] DECIMAL(18, 2)
   ,Disabled BIT
   ,[Set] BIT
   ,[Balance] DECIMAL(18, 2)
  );

  INSERT INTO #TempCashierCommissions
    SELECT
      f.[Index]
     ,f.[OperationName]
     ,COUNT(*)[Quantity]
     ,SUM(f.Debit) Debit
     ,SUM(f.Credit) Credit
     ,SUM(f.Balance) moneyvalue
     ,SUM(f.Balance) Value
     ,1 Disabled
     ,1 [Set]
     ,(SUM(f.Balance)
      )
      Balance
    FROM dbo.FN_GetEmployeeCommissionPayments(@StartDate, @EndDate, @AgencyId, @UserId, NULL) f

    GROUP BY f.[Index]
            ,f.[OperationName]
            ,f.[Quantity]
    ORDER BY [Index]

  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST([Balance] AS DECIMAL(18, 2))), 0)
      FROM #TempCashierCommissions T2
      WHERE T2.[ReportId] <= T1.[ReportId])
    RunningSum
  FROM #TempCashierCommissions T1
  DROP TABLE #TempCashierCommissions;
END;


GO