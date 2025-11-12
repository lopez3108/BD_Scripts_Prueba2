SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Juan Felipe
-- Create date: 23Abril2023
-- Description:	<Description,,>
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetFilesProviderStatement]
@AgencyId INT = NULL,
@ProviderId INT = NULL,
--@BankId INT = NULL,
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


  SET NOCOUNT OFF;

  -- Creo la primera tabla temporal
  DECLARE @Table1 TABLE (
   ProviderStatementsId INT
   ,Year INT
   ,Month INT
   ,ProviderId INT
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
   ProviderStatementsId INT
   ,Year INT
   ,Month INT
   ,ProviderId INT
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
      ProviderStatementsId
     ,Year
     ,Month
     ,ProviderId
     ,O.CreationDate
     ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
     ,UserId
     ,O.Name
     ,Extension
     ,C.Code
     ,O.AgencyId
    FROM dbo.ProviderStatements O
       LEFT JOIN dbo.Agencies AS C
      ON C.AgencyId = O.AgencyId
    WHERE ProviderId =
    CASE
      WHEN @ProviderId  IS NULL THEN ProviderId
      ELSE @ProviderId 
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
  
  
    ORDER BY CreationDate DESC;
  DECLARE @Length INT;
  SELECT
    @Length = COUNT(*)
  FROM @Table3;
  WHILE @Length > 0
  BEGIN
  DECLARE @ProviderIdId INT;
  SELECT DISTINCT TOP (1)
    @ProviderIdId  = ProviderStatementsId
  FROM @Table3;
  IF ((SELECT
        COUNT(*)
      FROM @Table3
      WHERE ProviderStatementsId = @ProviderIdId
      AND AgencyId =
      CASE
        WHEN @AgencyId IS NULL THEN AgencyId
        ELSE @AgencyId
      END)
    <= 0)
  BEGIN
    DELETE @Table3
    WHERE ProviderStatementsId = @ProviderIdId;
  END;
  ELSE
  BEGIN
    INSERT INTO @Table1
      SELECT
        *
      FROM @Table3
      WHERE ProviderStatementsId = @ProviderIdId;
    DELETE TOP (1) FROM @Table3;
  END;
  SELECT
    @Length = COUNT(*)
  FROM @Table3;
  END;
  DECLARE @TableDistinct TABLE (
    ProviderStatementsId INT
   ,Year INT
   ,Month INT
   ,ProviderId INT
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
    ProviderStatementsId INT
   ,Year INT
   ,Month INT
   ,AgencyId INT
   ,ProviderId INT
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
    @Id = ProviderStatementsId
  FROM @TableDistinct;
  SELECT TOP (1)
    @AgencyName = AgencyName
  FROM @TableDistinct;
  IF ((SELECT
        COUNT(*)
      FROM @Table2
      WHERE ProviderStatementsId = @Id)
    > 0)
  BEGIN
    UPDATE @Table2
    SET AgencyNames = AgencyNames + ', ' + @AgencyName
    WHERE ProviderStatementsId = @Id;
  END;
  ELSE
  BEGIN
    INSERT INTO @Table2 (
    ProviderStatementsId,
    Year,
    Month,
	  AgencyId,
    ProviderId,
    CreationDate,
    CreationDateFormat,
    UserId,
    Name,
    Extension,
    AgencyNames)
      SELECT TOP (1)
    ProviderStatementsId,
    Year,
    Month,
	  AgencyId,
    ProviderId,
    CreationDate,
    CreationDateFormat,
    UserId,
    Name,
    Extension,
    AgencyName
      FROM @TableDistinct;
  END;
  DELETE TOP (1) FROM @TableDistinct;
  SELECT
    @Length2 = COUNT(*)
  FROM @TableDistinct;
  END;
  SELECT DISTINCT
    ProviderStatementsId
   ,Year
   ,Month
   ,m.Description MonthDescription 
   ,p.Name ProviderName 
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
  INNER JOIN dbo.Providers p
    ON p.ProviderId = tm.ProviderId
  INNER JOIN dbo.Users u
    ON tm.UserId = u.UserId;
  SELECT
    ProviderStatementsId
   ,Year
   ,Month
   ,m.Description MonthDescription  
   ,p.Name ProviderName
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
  INNER JOIN dbo.Providers p
    ON p.ProviderId = tm.ProviderId
  INNER JOIN dbo.Users u
    ON tm.UserId = u.UserId;
END;


GO