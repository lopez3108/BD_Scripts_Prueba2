SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportMoneyTransfer] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL, @Date DATETIME, @ProviderId INT)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,[Type] VARCHAR(50)
   ,CreationDate DATETIME
   ,[Description] VARCHAR(500)
   ,Transactions INT
   ,Usd DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)
  );

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)

  DECLARE @agencyInitialBalance DECIMAL(18, 2)
  SET @agencyInitialBalance = (ISNULL((SELECT TOP 1
      InitialBalance
    FROM MoneyTransferxAgencyInitialBalances
    WHERE AgencyId = @AgencyId
    AND ProviderId = @ProviderId)
  , 0)) +
  ISNULL((SELECT
      SUM(CAST(Balance AS DECIMAL(18,2)))
    FROM dbo.[FN_GenerateMoneyTransferReport](@AgencyId, '1985-01-01', @initialBalanceFinalDate, @Date, @ProviderId))
  , 0)

  -- Initial cash balance

  INSERT INTO #Temp
    SELECT
      1 AS [Index]
     ,'INITIAL BALANCE'
     ,CAST(@initialBalanceFinalDate AS DATE) AS CreationDate
     ,'INITIAL BALANCE'
     ,0 Transactions
     ,@agencyInitialBalance
     ,@agencyInitialBalance
    UNION ALL
    SELECT
      *
    FROM [dbo].[FN_GenerateMoneyTransferReport](@AgencyId, @FromDate, @ToDate, @Date, @ProviderId) f
    ORDER BY CreationDate,
    [Index]

  SELECT
    *
   ,(SELECT
       ISNULL( SUM(CAST(Balance AS DECIMAL(18,2))),0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    RunningSum
  FROM #Temp T1

  DROP TABLE #Temp

END;



GO