SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetForexList] 
@AgencyId INT, 
@ProviderId   INT = NULL,  
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Type INT = NULL
AS
     BEGIN

	  DECLARE @forexExpenseType INT
		   SET @forexExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C15')

		    CREATE TABLE #Temp (
    [ForexId] INT
    ,[AgencyId] INT
   ,[AgencyName] VARCHAR(100)
   ,ProviderId INT
   ,[ProviderName] VARCHAR(100)
   ,[Type] VARCHAR(20)
      ,TypeNum INT
	  ,Usd DECIMAL(18,2)
	  ,CreatedBy INT
	  ,CreatedByName VARCHAR(100)
	  ,CreationDate DATETIME
	  ,[LastUpdatedBy] INT
	  , LastUpdatedByName VARCHAR(100)
	  , [LastUpdatedOn] DATETIME
	  ,FromDate DATETIME
	  ,ToDate DATETIME
	  ,Validated BIT NULL)


	  IF(@Type IS NULL OR @Type = 2)
	  BEGIN

	  INSERT INTO #Temp
	  SELECT [ForexId]
      ,f.[AgencyId]
	  ,a.Code + ' - ' + a.Name AgencyName
      ,f.[ProviderId]
	  ,p.Name ProviderName
	  ,'CREDIT' as Type
	  ,2 as TypeNum
      ,f.[Usd]
      ,[CreatedBy]
	  ,u.Name CreatedByName
      ,[CreationDate]
      ,[LastUpdatedBy]
	  ,uu.Name LastUpdatedByName
      ,[LastUpdatedOn]
      ,[FromDate]
      ,[ToDate]
	  ,NULL as Validated
  FROM [dbo].[Forex] f
  INNER JOIN dbo.Providers p ON p.ProviderId = f.ProviderId
  INNER JOIN dbo.Agencies a ON a.AgencyId = f.AgencyId
  INNER JOIN dbo.Users u ON u.UserId = f.CreatedBy
  LEFT JOIN dbo.Users uu ON uu.UserId = f.LastUpdatedBy
  WHERE f.AgencyId = @AgencyId
  AND (@ProviderId IS NULL OR f.ProviderId = @ProviderId)
  AND  (@FromDate IS NULL OR (CAST(f.FromDate AS DATE) >= @FromDate and
    (f.ToDate <= @ToDate)))

	  END

	   IF(@Type IS NULL OR @Type = 1)
	  BEGIN

	  INSERT INTO #Temp
	SELECT f.ExpenseId as ForexId
      ,f.[AgencyId]
	  ,a.Code + ' - ' + a.Name AgencyName
      ,f.[ProviderId]
	  ,p.Name ProviderName
	  ,'DEBIT' as Type
	  ,1 as TypeNum
      ,f.[Usd]
      ,[CreatedBy]
	  ,u.Name CreatedByName
      ,f.CreatedOn as CreationDate
      ,f.UpdatedBy [LastUpdatedBy]
	  ,uu.Name LastUpdatedByName
      ,f.UpdatedOn [LastUpdatedOn]
      ,[FromDate]
      ,[ToDate]
	  ,f.Validated as Validated
  FROM [dbo].[Expenses] f
  INNER JOIN dbo.Providers p ON p.ProviderId = f.ProviderId
  INNER JOIN dbo.Agencies a ON a.AgencyId = f.AgencyId
  INNER JOIN dbo.Users u ON u.UserId = f.CreatedBy
  LEFT JOIN dbo.Users uu ON uu.UserId = f.UpdatedBy
  WHERE f.ExpenseTypeId = @forexExpenseType
  AND f.AgencyId = @AgencyId
  AND (@ProviderId IS NULL OR f.ProviderId = @ProviderId)
  AND  (@FromDate IS NULL OR (CAST(f.FromDate AS DATE) >= CAST(@FromDate as DATE) and
    CAST(f.ToDate AS DATE) <= CAST(@ToDate AS DATE)))

	  END

	  SELECT * FROM #Temp ORDER BY CreationDate ASC, FromDate ASC

	  DROP TABLE #Temp
	

	END
GO