SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-23 DJ/5475: Adding initial balance + report refactoring + module refactoring

CREATE PROCEDURE [dbo].[sp_GetEmployeeCommissionsDetails] 
@StartDate DATETIME,
@EndDate DATETIME,
@AgencyId INT,
@UserId INT = NULL
AS
BEGIN
  IF OBJECT_ID('tempdb..#TempCashierCommissions') IS NOT NULL
    DROP TABLE #TempCashierCommissions;
 
 CREATE TABLE #TempCashierCommissions (
 [ReportId] INT IDENTITY (1, 1)
   ,[Index] INT
   ,[OperationName] VARCHAR(100)
   ,[CreationDate] DATETIME
   ,[Employee] VARCHAR(100)
   ,[CashierCommissionPaid] BIT
   ,[CommissionPaidStatus] VARCHAR(10)
   ,[Debit] DECIMAL(18, 2)
   ,[Credit] DECIMAL(18, 2)
   ,[Balance] DECIMAL(18, 2)
  );

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @StartDate)

  DECLARE @initialBalance DECIMAL(18,2)
  SET @initialBalance = (SELECT ISNULL(SUM(ISNULL(CAST([Balance] AS DECIMAL(18,2)),0)),0) FROM dbo.FN_GetEmployeeCommissionsData ('2018-01-01', @initialBalanceFinalDate, @AgencyId, @UserId,0,1))

   INSERT INTO #TempCashierCommissions
   SELECT
   0 as [Index],
   'INITIAL BALANCE1' as [OperationName],
   @initialBalanceFinalDate as CreationDate,
   'INITIAL BALANCE' as Employee,
   CASE WHEN @initialBalance > 0 THEN
    CAST(0 as BIT) ELSE
	CAST(1 as BIT) END AS CashierCommissionPaid,
	 CASE WHEN @initialBalance > 0 THEN
    'PENDING' ELSE
	'PAID' END AS CommissionPaidStatus,
	0 as Debit,
	0 as Credit,
   @initialBalance
UNION ALL
   SELECT  
  f.[Index],
  CASE WHEN f.[OperationName] = 'COMMISSION PAYMENT' THEN
  UPPER(f.[Description]) ELSE
  f.[OperationName] END AS [OperationName],
  f.[CreationDate],
  f.[Employee],
  f.[ExpenseId],
  CASE WHEN f.[ExpenseId] IS NULL THEN
  'PENDING' ELSE
  'PAID' END AS CommissionPaidStatus,
  ABS(f.[Debit]) [Debit],
  ABS(f.[Credit]) [Credit],
  f.[Balance] [Balance]
   FROM dbo.FN_GetEmployeeCommissionsData (@StartDate, @EndDate, @AgencyId, @UserId,0,NULL) f
   ORDER BY CreationDate

  SELECT *, 
(SELECT
       ISNULL( SUM(CAST([Balance] AS DECIMAL(18,2))),0)
      FROM #TempCashierCommissions T2
	  WHERE T2.[ReportId] <= T1.[ReportId])
    RunningSum FROM #TempCashierCommissions T1
	WHERE 
	  ([Balance] IS NOT NULL AND [Balance] <> 0)	

  DROP TABLE #TempCashierCommissions;
END;

GO