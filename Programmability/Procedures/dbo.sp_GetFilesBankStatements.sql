SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		cmontoya
-- Create date: 11Mayo2020
-- Description:	<Description,,>
-- =============================================
/*
	exec [dbo].[sp_GetFilesBankStatements]
	@AgencyId = NULL,
	@BankId = NULL,
	@Account = NULL,
	@StartDate = '2017-01-01',
	@EndDate = '2019-01-01'
*/

CREATE PROCEDURE [dbo].[sp_GetFilesBankStatements] @AgencyId INT = NULL,
@BankId INT = NULL,
@Account INT = NULL,
@StartDate DATETIME  = NULL,
@EndDate DATETIME  = NULL,
@SearchByRangePeriod BIT ,
@ListMonthsSelected VARCHAR(1000) = NULL,
@ListYearsSelected VARCHAR(1000) = NULL
AS
BEGIN
  DECLARE @PrimeraFecha DATETIME;
  DECLARE @UltimaFecha DATETIME;
  SET NOCOUNT ON;
  --SELECT TOP (1) @PrimeraFecha = CONVERT(DATETIME, CONVERT(VARCHAR(4), Year) + '-' + CASE
  --                                                                                       WHEN CONVERT(VARCHAR, Month) < 10
  --                                                                                       THEN '0' + CONVERT(VARCHAR, Month)
  --                                                                                       ELSE CONVERT(VARCHAR, Month)
  --                                                                                   END + '-01', 120)
  --FROM dbo.BankStatements
  --ORDER BY CONVERT(DATETIME, CONVERT(VARCHAR(4), Year) + '-' + CASE
  --                                                                 WHEN CONVERT(VARCHAR, Month) < 10
  --                                                                 THEN '0' + CONVERT(VARCHAR, Month)
  --                                                                 ELSE CONVERT(VARCHAR, Month)
  --                                                             END + '-01', 120) ASC;
  --SELECT TOP (1) @UltimaFecha = CONVERT(DATETIME, CONVERT(VARCHAR(4), Year) + '-' + CASE
  --                                                                                      WHEN CONVERT(VARCHAR, Month) < 10
  --                                                                                      THEN '0' + CONVERT(VARCHAR, Month)
  --                                                                                      ELSE CONVERT(VARCHAR, Month)
  --                                                                                  END + '-01', 120)
  --FROM dbo.BankStatements
  --ORDER BY CONVERT(DATETIME, CONVERT(VARCHAR(4), Year) + '-' + CASE
  --                                                                 WHEN CONVERT(VARCHAR, Month) < 10
  --                                                                 THEN '0' + CONVERT(VARCHAR, Month)
  --                                                                 ELSE CONVERT(VARCHAR, Month)
  --                                                             END + '-01', 120) DESC;

  --SELECT TOP(1) @PrimeraFecha = CreationDate
  --FROM dbo.BankStatements
  --ORDER BY CreationDate ASC
  --SELECT TOP(1) @UltimaFecha = CreationDate
  --FROM dbo.BankStatements
  --ORDER BY CreationDate DESC

  SET NOCOUNT OFF;

  -- Creo la primera tabla temporal
  DECLARE @Table1 TABLE (
    BankStatementsId INT
   ,Year INT
   ,Month INT
   ,Agencies VARCHAR(100)
   ,Bank INT
   ,Account INT
   ,CreationDate DATETIME
   ,CreationDateFormat VARCHAR(50)
   ,UserId INT
   ,Name VARCHAR(200)
   ,Extension VARCHAR(10)
   ,AgencyName VARCHAR(250)
   ,AgencyId INT
  );

  -- Tambla temporal para el While e ir eliminando registros
  DECLARE @Table3 TABLE (
    BankStatementsId INT
   ,Year INT
   ,Month INT
   ,Agencies VARCHAR(100)
   ,Bank INT
   ,Account INT
   ,CreationDate DATETIME
   ,CreationDateFormat VARCHAR(50)
   ,UserId INT
   ,Name VARCHAR(200)
   ,Extension VARCHAR(10)
   ,AgencyName VARCHAR(250)
   ,AgencyId INT
  );

  -- Inserto los datos con el SPLIT en la tabla temporal
  INSERT INTO @Table3
    SELECT
      BankStatementsId
     ,Year
     ,Month
     ,Agencies
     ,Bank
     ,Account
     ,O.CreationDate
     ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
     ,UserId
     ,O.Name
     ,Extension
     ,C.Code
     ,C.AgencyId
    FROM dbo.BankStatements O
    OUTER APPLY STRING_SPLIT(O.Agencies, ',') s
    LEFT JOIN dbo.Agencies AS C
      ON C.AgencyId = s.value
    WHERE Bank =
    CASE
      WHEN @BankId IS NULL THEN Bank
      ELSE @BankId
    END
    AND Account =
    CASE
      WHEN @Account IS NULL THEN Account
      ELSE @Account
    END
AND ((@SearchByRangePeriod = 0   
    
    AND ((CAST(O.CreationDate AS DATE) >= CAST(@StartDate AS DATE) OR @StartDate IS NULL )
    AND (CAST(O.CreationDate AS DATE) <= CAST(@EndDate AS DATE) OR @EndDate IS NULL))
    ) OR (@SearchByRangePeriod = 1  

    AND (O.Month IN (SELECT
          item
        FROM dbo.FN_ListToTableInt(@ListMonthsSelected))
      OR @ListMonthsSelected IS NULL)  
      AND (O.Year IN (SELECT
          item
        FROM dbo.FN_ListToTableInt(@ListYearsSelected))
      OR @ListYearsSelected IS NULL)
      
      ))
  
    --AND (CONVERT(VARCHAR(4), YEAR) + '-' + CASE
    --                                           WHEN Month < 10
    --                                           THEN '0' + CONVERT(VARCHAR, Month)
    --                                           ELSE CONVERT(VARCHAR, Month)
    --                                       END + '-01') BETWEEN CASE
    --                                                                WHEN @StartDate IS NOT NULL
    --                                                                THEN CONVERT(VARCHAR(10), @StartDate, 120)
    --                                                                ELSE CONVERT(VARCHAR(10), @PrimeraFecha, 120)
    --                                                            END AND CASE
    --                                                                        WHEN @EndDate IS NOT NULL
    --                                                                        THEN CONVERT(VARCHAR(10), @EndDate, 120)
    --                                                                        ELSE CONVERT(VARCHAR(10), @UltimaFecha, 120)
    --                                                                    END
    --AND CONVERT(VARCHAR(10), CreationDate, 120) BETWEEN 
    --		CASE WHEN @StartDate IS NOT NULL THEN CONVERT(VARCHAR(10), @StartDate, 120) ELSE CONVERT(VARCHAR(10), @PrimeraFecha, 120) END 
    --		AND 
    --		CASE WHEN @EndDate IS NOT NULL THEN CONVERT(VARCHAR(10), @EndDate, 120) ELSE CONVERT(VARCHAR(10), @UltimaFecha, 120) END
    ORDER BY CreationDate DESC;
  DECLARE @Length INT;
  SELECT
    @Length = COUNT(*)
  FROM @Table3;
  WHILE @Length > 0
  BEGIN
  DECLARE @BankIdId INT;
  SELECT DISTINCT TOP (1)
    @BankIdId = BankStatementsId
  FROM @Table3;
  IF ((SELECT
        COUNT(*)
      FROM @Table3
      WHERE BankStatementsId = @BankIdId
      AND AgencyId =
      CASE
        WHEN @AgencyId IS NULL THEN AgencyId
        ELSE @AgencyId
      END)
    <= 0)
  BEGIN
    DELETE @Table3
    WHERE BankStatementsId = @BankIdId;
  END;
  ELSE
  BEGIN
    INSERT INTO @Table1
      SELECT
        *
      FROM @Table3
      WHERE BankStatementsId = @BankIdId;
    DELETE TOP (1) FROM @Table3;
  END;
  SELECT
    @Length = COUNT(*)
  FROM @Table3;
  END;
  DECLARE @TableDistinct TABLE (
    BankStatementsId INT
   ,Year INT
   ,Month INT
   ,Agencies VARCHAR(100)
   ,Bank INT
   ,Account INT
   ,CreationDate DATETIME
   ,CreationDateFormat VARCHAR(50)
   ,UserId INT
   ,Name VARCHAR(200)
   ,Extension VARCHAR(10)
   ,AgencyName VARCHAR(250)
   ,AgencyId INT
  );
  INSERT INTO @TableDistinct
    SELECT DISTINCT
      *
    FROM @Table1;
  DECLARE @Length2 INT;
  SELECT
    @Length2 = COUNT(*)
  FROM @TableDistinct;

  -- Creo la segunda tabla temporal donde irá el resultado final concatenado por comas(,) las agencias
  DECLARE @Table2 TABLE (
    BankStatementsId INT
   ,Year INT
   ,Month INT
   ,Agencies VARCHAR(100)
   ,Bank INT
   ,Account INT
   ,CreationDate DATETIME
   ,CreationDateFormat VARCHAR(50)
   ,UserId INT
   ,Name VARCHAR(200)
   ,Extension VARCHAR(10)
   ,AgencyNames VARCHAR(250)
  );
  WHILE @Length2 > 0
  BEGIN
  DECLARE @Id INT;
  DECLARE @AgencyName VARCHAR(50);
  SELECT TOP (1)
    @Id = BankStatementsId
  FROM @TableDistinct;
  SELECT TOP (1)
    @AgencyName = AgencyName
  FROM @TableDistinct;
  IF ((SELECT
        COUNT(*)
      FROM @Table2
      WHERE BankStatementsId = @Id)
    > 0)
  BEGIN
    UPDATE @Table2
    SET AgencyNames = AgencyNames + ', ' + @AgencyName
    WHERE BankStatementsId = @Id;
  END;
  ELSE
  BEGIN
    INSERT INTO @Table2 (BankStatementsId,
    Year,
    Month,
    Agencies,
    Bank,
    Account,
    CreationDate,
    CreationDateFormat,
    UserId,
    Name,
    Extension,
    AgencyNames)
      SELECT TOP (1)
        BankStatementsId
       ,Year
       ,Month
       ,Agencies
       ,Bank
       ,Account
       ,CreationDate
       ,CreationDateFormat
       ,UserId
       ,Name
       ,Extension
       ,AgencyName
      FROM @TableDistinct;
  END;
  DELETE TOP (1) FROM @TableDistinct;
  SELECT
    @Length2 = COUNT(*)
  FROM @TableDistinct;
  END;
  SELECT DISTINCT
    BankStatementsId
   ,Year
   ,Month
   ,m.Description MonthDescription
   ,Bank
   ,b.Name BankName
   ,Account
   ,ba.AccountNumber
   ,Agencies
   ,AgencyNames
   ,TM.CreationDate
   ,CreationDateFormat
   ,tm.UserId
   ,u.Name AS CreatedByName
   ,tm.Name
   ,Extension
  FROM @Table2 tm
  INNER JOIN dbo.Months m
    ON m.MonthId = tm.Month
  INNER JOIN dbo.Bank b
    ON b.BankId = tm.Bank
  INNER JOIN dbo.BankAccounts ba
    ON ba.BankAccountId = tm.Account
  INNER JOIN dbo.Users u
    ON tm.UserId = u.UserId;
  SELECT
    BankStatementsId
   ,Year
   ,Month
   ,m.Description MonthDescription
   ,Bank
   ,b.Name BankName
   ,Account
   ,ba.AccountNumber
   ,Agencies
   ,AgencyNames
   ,TM.CreationDate
   ,CreationDateFormat
   ,tm.UserId
   ,u.Name AS CreatedByName
   ,tm.Name
   ,Extension
  FROM @Table2 tm
  INNER JOIN dbo.Months m
    ON m.MonthId = tm.Month
  INNER JOIN dbo.Bank b
    ON b.BankId = tm.Bank
  INNER JOIN dbo.BankAccounts ba
    ON ba.BankAccountId = tm.Account
  INNER JOIN dbo.Users u
    ON tm.UserId = u.UserId;
END;

GO