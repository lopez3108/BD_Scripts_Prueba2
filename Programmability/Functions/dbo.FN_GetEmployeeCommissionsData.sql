SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--10-10-2024 Jt/6085 Add new commissions InsurancePolicy, InsuranceMonthlyPayment, InsuranceRegistration
-- 2024-03-22 CREATED BY JT/5475: Adding initial balance + report refactoring
-- UPDATED 2024-05-10 BY JT/5865: Change the position for traffic tickets module and daily


CREATE FUNCTION [dbo].[FN_GetEmployeeCommissionsData] (@StartDate DATETIME,
@EndDate DATETIME,
@AgencyId INT,
@UserId INT = NULL,
--@NeedCommissions BIT = 0,
@OnlyCommissions BIT = 0,
@OnlyPendings BIT = NULL)

RETURNS @result TABLE (
  [Index] INT
 ,[OperationName] VARCHAR(100)
 ,[Quantity] INT
 ,[CreationDate] DATETIME
 ,[ExpenseId] INT NULL
 ,[ExpensePaidId] INT NULL
 ,[MonthNumber] INT
 ,[YearNumber] INT
 ,[Month] VARCHAR(20)
 ,[Year] VARCHAR(5)
 ,[Type] VARCHAR(50)
 ,[Description] VARCHAR(50) NULL
 ,[Employee] VARCHAR(200)
 ,EmployeeId INT
 ,[Debit] DECIMAL(18, 2)
 ,[Credit] DECIMAL(18, 2)
 ,[Balance] DECIMAL(18, 2)
)

AS
BEGIN

  INSERT INTO @result
    SELECT
      [Index]
     ,[OperationName]
     ,[Quantity]
     ,[CreationDate]
     ,[ExpenseId]
     ,[ExpensePaidId]
     ,[MonthNumber]
     ,[YearNumber]
     ,UPPER([Month]) [Month]
     ,[Year]
     ,[Type]
     ,[Description] [Description]
     ,UPPER(Employee) Employee
     ,q.EmployeeId
     ,q.Debit Debit
     ,q.Credit Credit
     ,q.Balance Balance
    FROM (SELECT -- Commision Phone Sales
        1 [Index]
       ,'PHONE SALES' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.ExpenseId ExpenseId
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name AS Employee
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit -- TO DO: Add commission real value from table
       ,--Last edit by JT 07-12-23 task 5559
        CAST(0.00 AS DECIMAL(18, 2)) Credit
       ,p.CashierCommission AS Balance
      FROM PhoneSales p
      INNER JOIN InventoryByAgency i
        ON i.InventoryByAgencyId = p.InventoryByAgencyId
      INNER JOIN Users u
        ON p.CreatedBy = u.UserId
      INNER JOIN Cashiers c
        ON c.UserId = u.UserId

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (i.AgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)
      --Lo que está pendiente, lo que ya fue pago o ambos
      UNION ALL


      SELECT  -- Commission Titles
        2 [Index]
       ,'TITLES AND PLATES' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,t.CreationDate CreationDate
       ,t.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, t.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, t.CreationDate) [YearNumber]
       ,DATENAME(MONTH, t.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, t.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name AS Employee
       ,u.UserId EmployeeId
       ,t.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,t.CashierCommission AS Balance
      FROM Titles t
      INNER JOIN Users u
        ON CreatedBy = u.UserId
      INNER JOIN Cashiers c
        ON c.UserId = u.UserId


      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (AgencyId = @AgencyId)
      AND t.CashierCommission > 0
      AND ((t.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND t.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)


      UNION ALL

      SELECT -- ComissionTrp730
        3 [Index]
       ,'T.R.P (7-90 DAYS)' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,t.CreatedOn CreationDate
       ,t.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, t.CreatedOn) [MonthNumber]
       ,DATEPART(YEAR, t.CreatedOn) [YearNumber]
       ,DATENAME(MONTH, t.CreatedOn) [Month]
       ,CAST(DATEPART(YEAR, t.CreatedOn) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name AS Employee
       ,u.UserId EmployeeId
       ,t.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,t.CashierCommission AS Balance
      FROM TRP t
      INNER JOIN PermitTypes pt
        ON t.PermitTypeId = pt.PermitTypeId
      INNER JOIN Users u
        ON t.CreatedBy = u.UserId
      INNER JOIN Cashiers c
        ON c.UserId = u.UserId


      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (AgencyId = @AgencyId)
      AND t.CashierCommission > 0
      AND ((t.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND t.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreatedOn AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreatedOn AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)

      UNION ALL

      SELECT -- Commission city stickers
        5 [Index]
       ,'CITY STICKERS' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,ci.CreationDate CreationDate
       ,ci.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, ci.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, ci.CreationDate) [YearNumber]
       ,DATENAME(MONTH, ci.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, ci.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --+ CAST(ci.[ExpenseId] AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,ci.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,ci.CashierCommission AS Balance

      FROM dbo.CityStickers ci
      INNER JOIN dbo.Users u
        ON ci.CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (AgencyId = @AgencyId)
      AND ci.CashierCommission > 0
      AND ((ci.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND ci.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)


      UNION ALL
      SELECT -- Commission plate stickers
        6 [Index]
       ,'REGISTRATION RENEWAL' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --       + CAST(p.[ExpenseId] AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,p.CashierCommission AS Balance
      FROM dbo.PlateStickers p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (AgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)


      UNION ALL

      SELECT --Lendify
        9 [Index]
       ,'LENDIFY' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,l.AprovedDate CreationDate
       ,l.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, l.AprovedDate) [MonthNumber]
       ,DATEPART(YEAR, l.AprovedDate) [YearNumber]
       ,DATENAME(MONTH, l.AprovedDate) [Month]
       ,CAST(DATEPART(YEAR, l.AprovedDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name AS Employee
       ,u.UserId EmployeeId
       ,3.5 AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,3.5 AS Balance

      FROM dbo.Lendify l
      INNER JOIN dbo.LendifyStatus ls
        ON l.LendifyStatusId = ls.LendifyStatusId
      INNER JOIN dbo.Users u
        ON l.CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      INNER JOIN dbo.CashierApplyComissions ca
        ON ca.CashierId = c.CashierId
        AND ca.ApplyLendify = 1

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (AgencyId = @AgencyId)
      --      AND L.CashierCommission > 0
      AND ((l.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND l.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      --      AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
      --      AND CAST(c.ValidComissions AS DATE) <= CAST(@EndDate AS DATE)
      --      AND (CAST(l.AprovedDate AS DATE) >= CAST(c.ValidComissions AS DATE))
      --      AND (CAST(l.AprovedDate AS DATE) <= CAST(@EndDate AS DATE)))
      --      OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
      AND CAST(l.AprovedDate AS DATE) >= CAST(@StartDate AS DATE)
      AND (CAST(l.AprovedDate AS DATE) <= CAST(@EndDate AS DATE))


      UNION ALL

      SELECT -- Commissions tickets
        queryTickets.IndexTickets [Index]
       ,queryTickets.OperationName
       ,queryTickets.Quantity
       ,queryTickets.CreationDate
       ,queryTickets.ExpenseId
       ,queryTickets.[ExpensePaidId]
       ,queryTickets.MonthNumber
       ,queryTickets.YearNumber
       ,queryTickets.Month
       ,queryTickets.Year
       ,queryTickets.Type
       ,queryTickets.Description
       ,queryTickets.Employee
       ,queryTickets.EmployeeId
       ,queryTickets.Debit
       ,queryTickets.Credit
       ,queryTickets.Balance

      FROM (SELECT -- Commissions tickets
          10 IndexTickets --Change the position for separate traffic tickets module and daily
         ,'TRAFFIC TICKETS-MODULE' [OperationName]
         ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
         ,t.CreationDate CreationDate
         ,t.[ExpenseId]
         ,NULL [ExpensePaidId]
         ,DATEPART(MONTH, t.CreationDate) [MonthNumber]
         ,DATEPART(YEAR, t.CreationDate) [YearNumber]
         ,DATENAME(MONTH, t.CreationDate) [Month]
         ,CAST(DATEPART(YEAR, t.CreationDate) AS VARCHAR(5)) [Year]
         ,'MONTH' [Type]
         ,NULL [Description]
         ,u.Name AS Employee
         ,u.UserId EmployeeId
         ,t.CashierCommission AS Debit
         ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
         ,t.CashierCommission AS Balance
        FROM dbo.Tickets t
        INNER JOIN dbo.Users u
          ON CreatedBy = u.UserId
        INNER JOIN dbo.Cashiers c
          ON c.UserId = u.UserId

        WHERE @OnlyCommissions = 0
        AND (@UserId IS NULL
        OR CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND t.CashierCommission > 0
        AND ((t.ExpenseId IS NULL
        AND @OnlyPendings = 1)--Solo pendientes
        OR (@OnlyPendings = 0
        AND t.ExpenseId IS NOT NULL)--Solo pagados
        OR @OnlyPendings IS NULL --Pendientes y pagados
        )
        AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        OR @StartDate IS NULL)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
        OR @EndDate IS NULL)

        UNION ALL

        SELECT -- Commissions tickets
          11 IndexTickets --Change the position for separate traffic tickets module and daily
         ,'TRAFFIC TICKETS-DAILY' [OperationName]
         ,1 [Quantity]
         ,tfsd.CompletedOn CreationDate
         ,tfsd.[ExpenseId]
         ,NULL [ExpensePaidId]
         ,DATEPART(MONTH, tfsd.CompletedOn) [MonthNumber]
         ,DATEPART(YEAR, tfsd.CompletedOn) [YearNumber]
         ,DATENAME(MONTH, tfsd.CompletedOn) [Month]
         ,CAST(DATEPART(YEAR, tfsd.CompletedOn) AS VARCHAR(5)) [Year]
         ,'MONTH' [Type]
         ,NULL [Description]
         ,u.Name AS Employee
         ,u.UserId EmployeeId
         ,tfsd.CashierCommission AS Debit
         ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
         ,tfsd.CashierCommission AS Balance
        FROM
        --        dbo.TicketFeeServices t
        --        INNER JOIN
        TicketFeeServiceDetails tfsd
        --          ON t.TicketFeeServiceId = tfsd.TicketFeeServiceId
        INNER JOIN dbo.Users u
          ON tfsd.CreatedBy = u.UserId
        INNER JOIN dbo.Cashiers c
          ON c.UserId = u.UserId

        WHERE @OnlyCommissions = 0
        AND (@UserId IS NULL
        OR tfsd.CreatedBy = @UserId)
        AND (tfsd.AgencyId = @AgencyId)
        AND CashierCommission > 0

        AND ((tfsd.ExpenseId IS NULL
        AND @OnlyPendings = 1)--Solo pendientes
        OR (@OnlyPendings = 0
        AND tfsd.ExpenseId IS NOT NULL)--Solo pagados
        OR @OnlyPendings IS NULL --Pendientes y pagados
        )
        AND (CAST(tfsd.CompletedOn AS DATE) >= CAST(@StartDate AS DATE)
        OR @StartDate IS NULL)
        AND (CAST(tfsd.CompletedOn AS DATE) <= CAST(@EndDate AS DATE)
        OR @EndDate IS NULL)) AS queryTickets

 UNION ALL
      SELECT -- InsurancePolicy
        12 [Index]
       ,'NEW POLICY' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --       + CAST(p.[ExpenseId] AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,p.CashierCommission AS Balance
      FROM dbo.InsurancePolicy p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)


 UNION ALL
      SELECT -- InsuranceMonthlyPayment
        13 [Index]
       ,ict.Description [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --       + CAST(p.[ExpenseId] AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,p.CashierCommission AS Balance
      FROM dbo.InsuranceMonthlyPayment p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      INNER JOIN InsuranceCommissionType ict ON p.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL) AND ict.Code = 'C04'

UNION ALL
      SELECT -- InsurancePolicy
        14 [Index]
       ,'REGISTRATION RELEASE (S.O.S)' [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --       + CAST(p.[ExpenseId] AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,p.CashierCommission AS Balance
      FROM dbo.InsuranceRegistration p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)

 UNION ALL
    -- endorsement

      SELECT -- endorsement
        15 [Index]
       ,ict.Description [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --       + CAST(p.[ExpenseId] AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,p.CashierCommission AS Balance
      FROM dbo.InsuranceMonthlyPayment p
      INNER JOIN dbo.Users u   ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c ON c.UserId = u.UserId
      INNER JOIN InsuranceCommissionType ict ON p.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL) AND ict.Code = 'C03'

 UNION ALL
    -- policyRenewal

      SELECT -- policyRenewal
        15 [Index]
       ,ict.Description [OperationName]
       ,COUNT(*) OVER (PARTITION BY 1) AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.ExpenseId [ExpenseId]
       ,NULL [ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --       + CAST(p.[ExpenseId] AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,p.CashierCommission AS Balance
      FROM dbo.InsuranceMonthlyPayment p
      INNER JOIN dbo.Users u   ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c ON c.UserId = u.UserId
      INNER JOIN InsuranceCommissionType ict ON p.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId

      WHERE @OnlyCommissions = 0
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpenseId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpenseId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL) AND ict.Code = 'C02'



      UNION ALL
      SELECT -- Commission returned paid
        28 [Index] --Change the position for separate traffic tickets module and daily
       ,'RETURN - ' + UPPER((SELECT
            dbo.fn_GetNameProviderTypesCommissionsCashiers(p.Provider))
        ) [OperationName]
       ,1 AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.[ExpenseId]
       ,p.[ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
       ,u.Name
        --        + CAST(p.ExpenseId AS VARCHAR(9))
        --     + CAST(cr.ExpensePaidId AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,p.CashierCommission AS Debit
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Credit
       ,p.CashierCommission
        AS Balance
      FROM dbo.CommissionsEmployeesReturn p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId

      WHERE @OnlyCommissions = 0
      AND p.ExpensePaidId IS NULL
      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (AgencyId = @AgencyId)
      AND p.CashierCommission > 0
      --       AND ((p.ExpensePaidId IS NULL
      --      AND @OnlyPendings = 1)--Solo pendientes
      --      OR (@OnlyPendings = 0
      --      AND p.ExpensePaidId IS NOT NULL)--Solo pagados
      --      OR @OnlyPendings IS NULL --Pendientes y pagados
      --      )

      AND ((p.ExpensePaidId IS NOT NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpensePaidId IS NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)

      UNION ALL
      SELECT -- Commissions returned
        29 [Index]  --Change the position for separate traffic tickets module and daily
       ,'COMMISSION RETURN - ' + UPPER((SELECT
            dbo.fn_GetNameProviderTypesCommissionsCashiers(p.Provider))
        ) [OperationName]
       ,1 AS [Quantity]
       ,p.CreationDate CreationDate
       ,p.[ExpenseId]
       ,[ExpensePaidId]
       ,DATEPART(MONTH, p.CreationDate) [MonthNumber]
       ,DATEPART(YEAR, p.CreationDate) [YearNumber]
       ,DATENAME(MONTH, p.CreationDate) [Month]
       ,CAST(DATEPART(YEAR, p.CreationDate) AS VARCHAR(5)) [Year]
       ,'MONTH' [Type]
       ,NULL [Description]
        --       ,u.Name AS Employee
       ,u.Name
        --        + CAST(p.[ExpenseId] AS VARCHAR(9))
        --     + CAST(cr.ExpensePaidId AS VARCHAR(9))
        [Employee]
       ,u.UserId EmployeeId
       ,CAST(0.00 AS DECIMAL(18, 2)) AS Debit
       ,-p.CashierCommission AS Credit
       ,-p.CashierCommission

        AS Balance
      FROM dbo.CommissionsEmployeesReturn p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId

      WHERE @OnlyCommissions = 0
      AND p.ExpensePaidId IS NULL

      AND (@UserId IS NULL
      OR CreatedBy = @UserId)
      AND (AgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND ((p.ExpensePaidId IS NULL
      AND @OnlyPendings = 1)--Solo pendientes
      OR (@OnlyPendings = 0
      AND p.ExpensePaidId IS NOT NULL)--Solo pagados
      OR @OnlyPendings IS NULL --Pendientes y pagados
      )
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)) AS q
  --    ORDER BY [YearNumber], [MonthNumber], [Employee], [Index], [Type]
  --    ORDER BY   ExpenseId DESC


  RETURN;
END;



GO