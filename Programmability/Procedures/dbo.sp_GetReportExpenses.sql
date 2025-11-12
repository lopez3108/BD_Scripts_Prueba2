SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de expense
CREATE PROCEDURE [dbo].[sp_GetReportExpenses]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)

AS


BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
  DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = ISNULL((SELECT
      SUM(CAST(Balance AS DECIMAL(18, 2)))
    FROM [dbo].fn_GenerateExpenseReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)

       CREATE TABLE #Temp
        ( [ID] INT IDENTITY (1, 1),
        [Index]       INT, 
         [Type]        VARCHAR(30), 
         CreationDate  DATETIME, 
         [Description] VARCHAR(100), 
         Usd           DECIMAL(18, 2) NULL, 
         Credit        DECIMAL(18, 2) NULL
            ,Balance DECIMAL(18, 2)

        );

INSERT INTO #Temp
    SELECT
      0 [Index]
     ,'INITIAL BALANCE' Type
     ,CAST(@initialBalanceFinalDate AS DATE) CreationDate
     ,'INITIAL BALANCE' Description
     ,NULL
     ,NULL 
     ,@BalanceDetail Balance


    UNION ALL

    SELECT
      *
    FROM [dbo].fn_GenerateExpenseReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY CreationDate,
    [Index];



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Balance AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID
      )
    BalanceFinal
  FROM #Temp T1

  ORDER BY CreationDate,
  [Index];
  DROP TABLE #Temp;



END   

--    BEGIN
--        IF(@FromDate IS NULL)
--            BEGIN
--                SET @FromDate = DATEADD(day, -10, @Date);
--                SET @ToDate = @Date;
--        END;
--          DECLARE @initialBalanceFinalDate DATETIME
--  SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
--        CREATE TABLE #Temp
--        ([Index]       INT, 
--         [Type]        VARCHAR(30), 
--         CreationDate  DATETIME, 
--         [Description] VARCHAR(100), 
--         Usd           DECIMAL(18, 2) NULL, 
--         Credit        DECIMAL(18, 2) NULL
--        );
--
--        -- Initial cash balance
--        INSERT INTO #Temp
--               SELECT 1, 
--                      'INITIAL BALANCE', 
--                      CAST(@initialBalanceFinalDate AS DATE), 
--                      'INITIAL BALANCE', 
--                      0, 
--                      0;
--
--        -- Daily
--
--        INSERT INTO #Temp
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
--        SELECT *
--        FROM #Temp
--        ORDER BY CreationDate, 
--                 [Index];
--        DROP TABLE #Temp;
--    END;



GO