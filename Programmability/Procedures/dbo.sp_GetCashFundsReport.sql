SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashFundsReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@Type INT = NULL)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN

    SET @FromDate = DATEADD(DAY, -10, @Date)
    SET @ToDate = @Date

  END
  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
 DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = ISNULL((SELECT ISNULL(SUM(Balance), 0) FROM dbo.fn_GenerateCashFundReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @Type)), 0)

  CREATE TABLE #Temp (
   [ID] INT IDENTITY (1, 1),
    [Index] INT
   ,[Type] VARCHAR(30)
   ,CreationDate DATETIME
   ,[Description] VARCHAR(100)
   ,Debit DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)
  )

  -- Initial cash fund
  INSERT INTO #Temp
    SELECT
      0  [Index]
     ,'INITIAL BALANCE' AS Type
     ,CAST(@initialBalanceFinalDate AS DATE) AS CreationDate
     ,'INITIAL BALANCE' AS [Description]
     ,0
     ,0
     ,@BalanceDetail Balance
  UNION ALL

    SELECT
      *
    FROM [dbo].fn_GenerateCashFundReport(@AgencyId, @FromDate, @ToDate, @Type)
    WHERE Debit > 0 OR Credit > 0

    ORDER BY CreationDate,
    [Index];


  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Balance AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal
  FROM #Temp T1
--  WHERE Debit > 0 OR T1.Credit > 0
  
     ORDER BY ID, CreationDate ASC;
  DROP TABLE #Temp

--  -- Cash fund increase
--  IF (@Type IS NULL
--    OR @Type = 2)
--  BEGIN
--
--    INSERT INTO #Temp
--      SELECT
--        2
--       ,'CASH FUND INCREASE' AS Type
--       ,dbo.CashFundModifications.CreationDate
--       ,dbo.Users.Name
--       ,(dbo.CashFundModifications.OldCashFund - dbo.CashFundModifications.NewCashFund) AS Usd
--      FROM dbo.CashFundModifications
--      INNER JOIN dbo.Cashiers
--        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
--      INNER JOIN dbo.Users
--        ON dbo.Cashiers.UserId = dbo.Users.UserId
--      WHERE CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--      AND dbo.CashFundModifications.AgencyId = @AgencyId
--      AND (dbo.CashFundModifications.OldCashFund < dbo.CashFundModifications.NewCashFund)
--
--
--  END
--
--  -- Cash fund decrease
--  IF (@Type IS NULL
--    OR @Type = 3)
--  BEGIN
--
--    INSERT INTO #Temp
--      SELECT
--        3
--       ,'CASH FUND DECREASE' AS Type
--       ,dbo.CashFundModifications.CreationDate
--       ,dbo.Users.Name
--       ,(dbo.CashFundModifications.OldCashFund - dbo.CashFundModifications.NewCashFund) AS Usd
--      FROM dbo.CashFundModifications
--      INNER JOIN dbo.Cashiers
--        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
--      INNER JOIN dbo.Users
--        ON dbo.Cashiers.UserId = dbo.Users.UserId
--      WHERE CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--      AND dbo.CashFundModifications.AgencyId = @AgencyId
--      AND (dbo.CashFundModifications.OldCashFund > dbo.CashFundModifications.NewCashFund)


 -- END

--  SELECT
--    *
--  FROM #Temp
--  ORDER BY CreationDate, [Index], Description
--
--  DROP TABLE #Temp



END

GO