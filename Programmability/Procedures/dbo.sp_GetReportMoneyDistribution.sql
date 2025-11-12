SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportMoneyDistribution]
(
                 @AgencyId int, @FromDate datetime = NULL, @ToDate datetime = NULL, @Date datetime
)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  --  IF OBJECT_ID('#TempTableMoneyDistribution') IS NOT NULL
  --  BEGIN
  --    DROP TABLE #TempTableMoneyDistribution;
  --  END;

  DECLARE @initialBalanceFinalDate datetime
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)


  DECLARE @Balance decimal(18, 2)
  SET @Balance = ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
FROM dbo.FN_GetReportMoneyDistribution(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)

  CREATE TABLE #TempTableMoneyDistribution
  (           
             [ID] int IDENTITY (1, 1),
              RowNumber int,
              AgencyId int,
              Date datetime,
              Type varchar(1000),
              TypeId int,
              Description varchar(1000),
              Debit decimal(18, 2),
              Credit decimal(18, 2),
              BalanceDetail decimal(18, 2)
  );

  INSERT INTO #TempTableMoneyDistribution
         SELECT 0 RowNumber,
         NULL AgencyId,
         CAST(@initialBalanceFinalDate AS date) Date,
         'INITIAL BALANCE' Type,
         0 TypeId,
         'INITIAL BALANCE' Description,
         0 Debit,
         0 Credit,
         ISNULL(@Balance, 0) BalanceDetail

         UNION ALL

  SELECT *
  FROM [dbo].FN_GetReportMoneyDistribution(@AgencyId, @FromDate, @ToDate)
  ORDER BY Date,
  RowNumber;




  --         SELECT *
  --         FROM (SELECT ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC, CAST(Query.Date AS date) ASC) RowNumber, *
  --       FROM (SELECT d.AgencyId, CAST(d.CreationDate AS date) AS Date, 'CLOSING DAILY' AS Type, 1 AS TypeId, 'CLOSING DAILY' AS Description, SUM(d.Cash) AS Debit, 0 AS Credit, SUM(d.Cash) BalanceDetail
  --     FROM Daily d
  --     WHERE d.DailyId IN (SELECT DailyId
  --         FROM DailyDistribution
  --         WHERE DailyId = d.DailyId) AND
  --           d.AgencyId = @AgencyId AND
  --           (CAST(d.CreationDate AS date) >= CAST(@FromDate AS date) OR
  --           @FromDate IS NULL) AND
  --           (CAST(d.CreationDate AS date) <= CAST(@ToDate AS date) OR
  --           @ToDate IS NULL)
  --     GROUP BY CAST(d.CreationDate AS date), d.AgencyId
  --     UNION ALL
  --     SELECT d.AgencyId, CAST(d.CreationDate AS date) AS Date, 'MONEY DISTRIBUTION' AS Type, 1 AS TypeId, 'CLOSING DAILY' AS Description, 0 AS Debit, SUM(dd.Usd) AS Credit, -SUM(dd.Usd) AS BalanceDetail
  --     FROM DailyDistribution dd
  --          INNER JOIN
  --          Daily d
  --          ON d.DailyId = dd.DailyId
  --     WHERE d.AgencyId = @AgencyId AND
  --           (CAST(d.CreationDate AS date) >= CAST(@FromDate AS date) OR
  --           @FromDate IS NULL) AND
  --           (CAST(d.CreationDate AS date) <= CAST(@ToDate AS date) OR
  --           @ToDate IS NULL)
  --     GROUP BY CAST(d.CreationDate AS date), d.AgencyId) AS Query) AS QueryFinal;

  --  SELECT *, (SELECT SUM(t2.BalanceDetail)
  --FROM #TempTableMoneyDistribution t2
  --WHERE t2.RowNumber <= t1.RowNumber) BalanceFinal
  --  FROM #TempTableMoneyDistribution t1
  --  ORDER BY RowNumber ASC;


  SELECT *, (SELECT ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
FROM #TempTableMoneyDistribution t2
WHERE t2.RowNumber <= T1.RowNumber) BalanceFinal

  FROM #TempTableMoneyDistribution T1

END;




GO