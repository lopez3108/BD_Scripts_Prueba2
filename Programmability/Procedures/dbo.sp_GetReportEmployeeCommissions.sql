SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-05-10 update by jt/task 5866 in report Employee commissions balance details (-El pago debe reflejarse debajo del debito del cajero al que le corresponde la comisión (como ya funcionaba anteriormente))
--Last edit by JT 07-12-23 task 5559
-- 2024-02-25 5475: Initial balanced added

-- 2024-03-17 DJ/5475: Adding initial balance + report refactoring

CREATE PROCEDURE [dbo].[sp_GetReportEmployeeCommissions] @StartDate DATETIME,
@EndDate DATETIME,
@AgencyId INT,
@UserId INT = NULL,
@IsDetails BIT
AS
BEGIN
  IF OBJECT_ID('tempdb..#TempCashierCommissions') IS NOT NULL
    DROP TABLE #TempCashierCommissions;

  CREATE TABLE #TempCashierCommissions (
    [ReportId] INT IDENTITY (1, 1)
    --   ,[Index] INT
   ,[MonthNumber] INT
   ,[YearNumber] INT
   ,[Month] VARCHAR(20)
   ,[Year] VARCHAR(5)
   ,[Type] VARCHAR(50)
   ,[TypeId] VARCHAR(50)
   ,ExpenseId INT
   ,[Employee] VARCHAR(200)
   ,[EmployeeId] INT
   ,[Debit] DECIMAL(18, 2)
   ,[Credit] DECIMAL(18, 2)
   ,[Balance] DECIMAL(18, 2)
  );

  INSERT INTO #TempCashierCommissions
    SELECT

      Q.[MonthNumber]
     ,Q.[YearNumber]
     ,UPPER(Q.[Month]) [Month]
     ,Q.[Year]
     ,Q.[Type]
     ,Q.[TypeId]
     ,Q.ExpenseId
     ,Q.[Employee]
     ,Q.[EmployeeId]
     ,SUM(Q.Debit) Debit
     ,SUM(Q.Credit) Credit
     ,SUM(Q.Balance)

    FROM (SELECT

        f.[MonthNumber]
       ,f.[YearNumber]
       ,f.[Month]
       ,f.[Year]
       ,f.[Type]
       ,f.[TypeId]
        --       ,f.ExpenseId

       ,CASE
          WHEN @IsDetails = 1 THEN EmployeeId
          ELSE CASE
              WHEN [TypeId] = 0 THEN -1--'INITIAL BALANCE'

              WHEN [TypeId] = 1 THEN -2--'CLOSING MONTH'
              ELSE -3 --'CLOSING PAYMENTS'
            END
        END AS ExpenseId
       ,CASE
          WHEN @IsDetails = 1 THEN UPPER(f.Employee)
          ELSE CASE
              WHEN [TypeId] = 0 THEN 'INITIAL BALANCE'

              WHEN [TypeId] = 1 THEN 'CLOSING MONTH'
              ELSE 'CLOSING PAYMENTS'
            END
        END AS Employee
       ,CASE
          WHEN @IsDetails = 1 THEN EmployeeId
          ELSE CASE
              WHEN [TypeId] = 0 THEN -1--'INITIAL BALANCE'

              WHEN [TypeId] = 1 THEN -2--'CLOSING MONTH'
              ELSE -3 --'CLOSING PAYMENTS'
            END
        END AS EmployeeId
        --        ,f.EmployeeId
       ,(f.Debit) Debit
       ,(f.Credit) Credit
       ,((f.Balance)
        )
        Balance
      FROM dbo.FN_GetEmployeeCommissionPayments(@StartDate, @EndDate, @AgencyId, @UserId, NULL) f) Q
    WHERE Q.Debit <> 0
    OR Q.Credit <> 0
    GROUP BY [YearNumber]
            ,[MonthNumber]
            ,[Year]
            ,[Month]
            ,[Type]
            ,[TypeId]
            ,[EmployeeId]
            ,[Employee]
            ,ExpenseId
    ORDER BY [YearNumber]
    , [MonthNumber]
    , [Year], [Employee]
    , [TypeId]
    --
    , CASE
      WHEN @IsDetails = 1 THEN [ExpenseId]--For detals order by for expenseid for show the comission generated and payment together
      ELSE NULL
    END DESC
    , [EmployeeId]

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