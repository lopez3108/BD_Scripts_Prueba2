SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[FN_GetReportEmployeeCommissions](
@StartDate DATETIME,
@EndDate DATETIME,
@AgencyId INT,
@UserId INT = NULL,
@IsDetails BIT)
RETURNS @result TABLE
(   
 [UserId] INT
   ,[Index] INT
   ,[MonthNumber] INT
   ,[YearNumber] INT
   ,[Month] VARCHAR(20)
   ,[Year] VARCHAR(5)
   ,[Type] VARCHAR(50)
   ,[Employee] VARCHAR(70)
   ,[Debit] DECIMAL(18, 2)
   ,[Credit] DECIMAL(18, 2)
   ,[Balance] DECIMAL(18, 2)
)

AS
     BEGIN

	 DECLARE @TemResult table (
   [UserId] INT
   ,[Index] INT
   ,[MonthNumber] VARCHAR(20)
   ,[YearNumber] VARCHAR(5)
   ,[Month] VARCHAR(20)
   ,[Year] VARCHAR(5)
   ,[Type] VARCHAR(50)
   ,[Employee] VARCHAR(70)
   ,[Debit] DECIMAL(18, 2)
   ,[Credit] DECIMAL(18, 2)
   ,[Balance] DECIMAL(18, 2)
  );

	  DECLARE @monthsDiff INT;
  SET @monthsDiff = (SELECT
      DATEDIFF(MONTH, CAST(@StartDate AS DATE), CAST(@EndDate AS DATE)));

  DECLARE @count INT;
  SET @count = @monthsDiff + 1;

  DECLARE @dateStart DATETIME;
  SET @dateStart = @StartDate;

  DECLARE @dateEnd DATETIME;
  SET @dateEnd = (SELECT
      EOMONTH(@dateStart));
 
 
 WHILE @count > 0
  BEGIN

  --select @dateStart

  INSERT INTO @TemResult
              SELECT qc.*
        FROM (    
    SELECT
      dbo.Users.UserId UserId
     ,1 [Index]
     ,DATEPART(MONTH, @dateStart) [MonthNumber]
     ,DATEPART(YEAR, @dateStart) [YearNumber]
     ,DATENAME(MONTH, @dateStart) [Month]
     ,CAST(DATEPART(YEAR, @dateStart) AS VARCHAR(5)) [Year]
     ,'MONTH' [Type]
     ,CASE
        WHEN @IsDetails = 1 THEN dbo.Users.Name
        ELSE 'CLOSING MONTH'
      END as Employee
     ,ABS((SELECT
          dbo.fn_CalculateCashierCommissions(@dateStart, @dateEnd, dbo.Users.UserId, @AgencyId))
      ) AS Debit
     ,--Last edit by JT 07-12-23 task 5559
      CAST(0.00 AS DECIMAL(18, 2)) Credit
     ,ABS((SELECT
          dbo.fn_CalculateCashierCommissions(@dateStart, @dateEnd, dbo.Users.UserId, @AgencyId))
      ) AS Balance
    FROM dbo.Cashiers
    INNER JOIN dbo.Users
      ON dbo.Cashiers.UserId = dbo.Users.UserId
    INNER JOIN AgenciesxUser au
      ON AU.UserId = Users.UserId
    WHERE dbo.Cashiers.IsActive = 1
    AND (@UserId IS NULL	
    OR dbo.Cashiers.UserId = @UserId)
    AND Cashiers.IsComissions = 1
    AND au.AgencyId = @AgencyId) as qc

  SET @dateStart = DATEADD(MONTH, 1, @dateStart);
  SET @dateEnd = (SELECT
      EOMONTH(@dateStart));
  
  SET @count = @count - 1;
  
  END

  SET @count = @monthsDiff + 1;
  SET @dateStart = @StartDate;
  SET @dateEnd = (SELECT
      EOMONTH(@dateStart));

  WHILE @count > 0
  BEGIN
 
 
  INSERT INTO @TemResult
              SELECT query.*
        FROM (    
    SELECT
      dbo.Users.UserId UserId
     ,2 [Index]
     ,DATEPART(MONTH, @dateStart) MonthNumber
     ,DATEPART(YEAR, @dateStart) YearNumber
     ,DATENAME(MONTH, @dateStart) [Month]
     ,CAST(DATEPART(YEAR, @dateStart) AS VARCHAR(5)) [Year]
     ,'COMMISSIONS' [Type]
     ,CASE
        WHEN @IsDetails = 1 THEN dbo.Users.Name
        ELSE 'CLOSING PAYMENTS'
      END Employee
     ,CAST(0.00 AS DECIMAL(18, 2)) Debit
     ,ABS(SUM(ex.Usd)) Credit
     ,--Last edit by JT 07-12-23 task 5559
      SUM(ex.Usd) Balance
    FROM dbo.Expenses ex
    INNER JOIN dbo.ExpensesType  ON ex.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
    INNER JOIN dbo.Users  ON ex.CreatedBy = dbo.Users.UserId
    INNER JOIN dbo.Months   ON ex.MonthsId = dbo.Months.MonthId
    INNER JOIN dbo.Cashiers  ON dbo.Users.UserId = dbo.Cashiers.UserId
    WHERE ex.AgencyId = @AgencyId
    AND dbo.Cashiers.IsActive = 1
    AND (@UserId IS NULL
    OR dbo.Cashiers.UserId = @UserId)
    AND dbo.ExpensesType.Code = 'C10'
    AND (dbo.Months.Number = DATEPART(MONTH, @dateStart))
    AND (ex.[Year] = DATEPART(YEAR, @dateStart))
    GROUP BY dbo.Users.UserId
            ,dbo.Users.Name
            ,dbo.Months.Number
            ,ex.[Year]
            ,ex.ExpenseId

			) as query
 
 SET @dateStart = DATEADD(MONTH, 1, @dateStart);
  SET @dateEnd = (SELECT
      EOMONTH(@dateStart));
  SET @count = @count - 1;
  
  END


  INSERT INTO @result 
    SELECT
      * FROM @TemResult
	  ORDER BY YearNumber ASC,
    [MonthNumber] ASC,
    [Index] ASC;


         RETURN;
     END;
GO