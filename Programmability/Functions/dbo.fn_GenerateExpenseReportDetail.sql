SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de expense
CREATE   FUNCTION [dbo].[fn_GenerateExpenseReportDetail] (@AgencyId INT,
@FromDate DATETIME = NULL, @ToDate DATETIME = NULL)

RETURNS @result TABLE (
  [Index] INT
 ,Date DATETIME
 ,Type VARCHAR(1000)
 ,Description VARCHAR(1000)
 ,TypeId INT
 ,Debit DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)
)
AS
BEGIN

  INSERT INTO @result
    SELECT
          ROW_NUMBER() OVER (
          ORDER BY 
          CAST(Query1.Date AS Date) ASC , Query1.TypeId ASC) [Index]
		  ,*
        FROM (
    SELECT
      --2 [Index]
           CAST(E.CreatedOn AS DATE) AS Date
     ,dbo.ExpensesType.Description AS Type

     ,U.Name AS Description
     ,1 TypeId
     ,ABS(SUM(E.Usd)) AS Debit
     ,0 Credit
     ,SUM(E.Usd) AS Balance
    FROM dbo.Expenses E
    INNER JOIN dbo.ExpensesType
      ON E.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
    INNER JOIN Users U
      ON U.UserId = E.CreatedBy
    WHERE E.AgencyId = @AgencyId
    AND (CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY CAST(E.CreatedOn AS DATE)
            ,U.Name
            ,dbo.ExpensesType.Description
            ,E.ExpenseId
		 ) AS Query1


  INSERT INTO @result
  SELECT
          ROW_NUMBER() OVER (
          ORDER BY 
          CAST(Query2.Date AS Date) ASC, Query2.TypeId ASC) [Index]
		  ,*
        FROM (
    SELECT
      --3 [Index]
      CAST(E.CreatedOn AS DATE) AS Date
     ,dbo.ExpensesType.Description AS Type
     
     ,U.Name AS Description
     ,2 TypeId
     ,0 AS Debit
     ,ABS(SUM(E.Usd)) Credit
     ,-SUM(E.Usd) AS Balance
    FROM dbo.Expenses E
    INNER JOIN dbo.ExpensesType
      ON E.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
    INNER JOIN Users U
      ON U.UserId = E.CreatedBy
    WHERE (E.Validated = 1)
    AND E.AgencyId = @AgencyId
    AND (CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY CAST(E.CreatedOn AS DATE)
            ,U.Name
            ,dbo.ExpensesType.Description
            ,E.ExpenseId
			 ) AS Query2



  RETURN

END
GO