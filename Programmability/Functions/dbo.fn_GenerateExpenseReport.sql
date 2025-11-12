SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de expense
CREATE FUNCTION [dbo].[fn_GenerateExpenseReport] (@AgencyId INT,
@FromDate DATETIME = NULL, @ToDate DATETIME = NULL
 )

RETURNS @result TABLE (
  [Index]       INT, 
         [Type]        VARCHAR(30), 
         CreationDate  DATETIME, 
         [Description] VARCHAR(100), 
         Usd           DECIMAL(18, 2) NULL, 
         Credit        DECIMAL(18, 2) NULL
            ,Balance DECIMAL(18, 2)
)
AS
BEGIN
 INSERT INTO @result
 SELECT 2, dbo.ExpensesType.Description AS Type, 
                          CAST(dbo.Expenses.CreatedOn AS DATE) AS CreationDate, 
                          'CLOSING DAILY' AS Description, 
                          ABS(SUM(dbo.Expenses.Usd)) AS Usd, 
                          0 AS Credit,
                           SUM(dbo.Expenses.Usd) AS Balance
                   FROM dbo.Expenses
                        INNER JOIN dbo.ExpensesType ON dbo.Expenses.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
                   WHERE dbo.Expenses.AgencyId = @AgencyId
                         AND CAST(dbo.Expenses.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                         AND CAST(dbo.Expenses.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                          GROUP BY CAST(dbo.Expenses.CreatedOn AS DATE),
                          dbo.ExpensesType.Description


INSERT INTO @result
SELECT 3, dbo.ExpensesType.Description AS Type, 
                          CAST(E.CreatedOn AS DATE) AS CreationDate, 
                          'CLOSING DAILY EXPENSE' AS Description, 
                          0 AS Usd, 
                          ABS(SUM(E.Usd)) Credit,
                           -SUM(E.Usd) Balance
                   FROM dbo.Expenses E
                        INNER JOIN dbo.ExpensesType ON E.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
                        INNER JOIN Users U ON u.UserId = E.CreatedBy
                   WHERE(E.Validated = 1)
                   AND E.AgencyId = @AgencyId
                   AND (CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
                       GROUP BY CAST(E.CreatedOn AS DATE),
                        dbo.ExpensesType.Description

--    -- Daily
--
--        INSERT INTO @result
--               SELECT 2, 
--                      t.Type, 
--                      t.CreationDate, 
--                      t.Description, 
--                      SUM(t.Usd), 
--                      SUM(t.Credit)
--               FROM
--               (
--                   SELECT dbo.ExpensesType.Description AS Type, 
--                          CAST(dbo.Expenses.CreatedOn AS DATE) AS CreationDate, 
--                          'CLOSING DAILY' AS Description, 
--                          ABS(dbo.Expenses.Usd) AS Usd, 
--                          0 AS Credit
--                   FROM dbo.Expenses
--                        INNER JOIN dbo.ExpensesType ON dbo.Expenses.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
--                   WHERE dbo.Expenses.AgencyId = @AgencyId
--                         AND CAST(dbo.Expenses.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
--                         AND CAST(dbo.Expenses.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
--
--                   UNION ALL
--                   SELECT dbo.ExpensesType.Description AS Type, 
--                          CAST(E.CreatedOn AS DATE) AS CreationDate, 
--                          'CLOSING DAILY EXPENSE' AS Description, 
--                          0 AS Usd, 
--                          ABS(E.Usd) Credit
--                   FROM dbo.Expenses E
--                        INNER JOIN dbo.ExpensesType ON E.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
--                        INNER JOIN Users U ON u.UserId = E.CreatedBy
--                   WHERE(E.Validated = 1)
--                   AND E.AgencyId = @AgencyId
--                   AND (CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
--                        OR @FromDate IS NULL)
--                   AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
--                        OR @ToDate IS NULL)
--
--               ) t
--               GROUP BY t.CreationDate, 
--                        t.Type, 
--                        t.Description;



  RETURN

END





GO