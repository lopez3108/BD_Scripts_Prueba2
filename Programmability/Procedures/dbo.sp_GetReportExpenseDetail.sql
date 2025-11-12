SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de expense
CREATE PROCEDURE [dbo].[sp_GetReportExpenseDetail] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
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
    FROM [dbo].fn_GenerateExpenseReportDetail(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,Date DATETIME
   ,Type VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,TypeId INT
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)

  );

  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,CAST(@initialBalanceFinalDate AS Date) Date
     ,'INITIAL BALANCE' Type
     ,'INITIAL BALANCE' Description
     ,1 TypeId
     ,0
     ,0
     ,@BalanceDetail Balance


    UNION ALL
    SELECT
      *
    FROM [dbo].fn_GenerateExpenseReportDetail(@AgencyId, @FromDate, @ToDate)
    ORDER BY [Index] , Date, TypeId
    



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Balance AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal
  FROM #Temp T1

  ORDER BY Date,
  [Index], TypeId;
  DROP TABLE #Temp;



END






--    
--    BEGIN
--        IF(@FromDate IS NULL)
--            BEGIN
--                SET @FromDate = DATEADD(day, -10, @Date);
--                SET @ToDate = @Date;
--        END;
--         DECLARE @initialBalanceFinalDate DATETIME
--SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
--        IF OBJECT_ID('#TempTableExpenseDetail') IS NOT NULL
--            BEGIN
--                DROP TABLE #TempTableExpenseDetail;
--        END;
--        CREATE TABLE #TempTableExpenseDetail
--        (RowNumber     INT, 
--         Date          DATETIME, 
--         Type          VARCHAR(1000), 
--         Description   VARCHAR(1000), 
--         TypeId        INT, 
--         Debit         DECIMAL(18, 2), 
--         Credit        DECIMAL(18, 2), 
--         BalanceDetail DECIMAL(18, 2)
--        );
--        INSERT INTO #TempTableExpenseDetail
--        (RowNumber, 
--         Date, 
--         Type, 
--         Description, 
--         TypeId, 
--         Debit, 
--         Credit, 
--         BalanceDetail
--        )
--               SELECT *
--               FROM
--               (
--                   SELECT ROW_NUMBER() OVER(
--                          ORDER BY Query.TypeId ASC, 
--                                   CAST(Query.Date AS DATE) ASC) RowNumber, 
--                          *
--                   FROM
--                   (
--                       SELECT CAST(@initialBalanceFinalDate AS DATE) AS Date, 
--                              'INITIAL BALANCE' AS Type, 
--                              'INITIAL BALANCE' AS Description, 
--                              1 TypeId, 
--                              0 Debit, 
--                              0 Credit, 
--                              0 BalanceDetail
--                       UNION ALL
--                       SELECT CAST(E.CreatedOn AS DATE) AS Date, 
--                              dbo.ExpensesType.Description AS Type, 
--                              U.Name AS Description, 
--                              1 TypeId, 
--                              ABS(SUM(E.Usd)) AS Debit, 
--                              0 Credit, 
--                              ABS(SUM(E.Usd)) AS BalanceDetail
--                       FROM dbo.Expenses E
--                            INNER JOIN dbo.ExpensesType ON E.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
--                            INNER JOIN Users U ON u.UserId = E.CreatedBy
--                       WHERE E.AgencyId = @AgencyId
--                             AND (CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
--                                  OR @FromDate IS NULL)
--                             AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
--                                  OR @ToDate IS NULL)
--                       GROUP BY CAST(E.CreatedOn AS DATE), 
--                                U.Name, 
--                                dbo.ExpensesType.Description, 
--                                E.ExpenseId
--                       UNION ALL
--                       SELECT CAST(E.CreatedOn AS DATE) AS Date, 
--                              dbo.ExpensesType.Description AS Type, 
--                              U.Name AS Description, 
--                              2 TypeId, 
--                              0 AS Debit, 
--                              ABS(SUM(E.Usd)) Credit, 
--                              -ABS(SUM(E.Usd)) AS BalanceDetail
--                       FROM dbo.Expenses E
--                            INNER JOIN dbo.ExpensesType ON E.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
--                            INNER JOIN Users U ON u.UserId = E.CreatedBy
--                       WHERE(E.Validated = 1)
--                            AND E.AgencyId = @AgencyId
--                            AND (CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
--                                 OR @FromDate IS NULL)
--                            AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
--                                 OR @ToDate IS NULL)
--                       GROUP BY CAST(E.CreatedOn AS DATE), 
--                                U.Name, 
--                                dbo.ExpensesType.Description, 
--                                E.ExpenseId
--                   ) AS Query
--               ) AS QueryFinal;
--        SELECT *, 
--        (
--            SELECT SUM(t2.BalanceDetail)
--            FROM #TempTableExpenseDetail t2
--            WHERE T2.RowNumber <= T1.RowNumber
--                  AND (T2.BalanceDetail <= 0
--                       OR T2.BalanceDetail >= 0)
--        ) BalanceFinal
--        FROM #TempTableExpenseDetail t1
--        WHERE(T1.BalanceDetail <= 0
--              OR T1.BalanceDetail >= 0)
--        ORDER BY RowNumber ASC;
--    END;
GO