SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- se cambió BalanceDetail por usd y se comenta la parte del initial balance task: 5891
-- by: sergio 
-- date: 05/05/2024

CREATE PROCEDURE [dbo].[sp_GetReportOtherPayment] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL, @Date DATETIME)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  --  IF OBJECT_ID('#TempTableOtherPayment') IS NOT NULL
  --  BEGIN
  --    DROP TABLE #TempTableOtherPayment;
  --  END;

  -- INITIAL BALANCE

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)


  DECLARE @Balance DECIMAL(18, 2)
  SET @Balance = ISNULL((SELECT
      SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
    FROM dbo.FN_GetReportOtherPayment(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)

  CREATE TABLE #TempTableOtherPayment (
    [ID] INT IDENTITY (1, 1)
   ,RowNumber INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,Usd DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
  );

  INSERT INTO #TempTableOtherPayment
--    SELECT
--      0 RowNumber
--     ,NULL AgencyId
--     ,CAST(@initialBalanceFinalDate AS Date) Date 
--     ,'INITIAL BALANCE' Description
--     ,'INITIAL BALANCE' Type
--     ,0 TypeId
--     ,0 Usd
--     ,0 Credit
--     ,ISNULL(@Balance, 0) BalanceDetail
--
--    UNION ALL


    SELECT
      *
    FROM [dbo].FN_GetReportOtherPayment(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,
    RowNumber;



  --         SELECT *
  --         FROM (SELECT ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC, CAST(Query.Date AS date) ASC) RowNumber, *
  --       FROM (SELECT O.AgencyId, CAST(O.CreationDate AS date) AS DATE, 'OTHERS PAYMENTS' Description, 'CLOSING DAILY' Type, 1 TypeId, SUM(ISNULL(O.Usd, 0) + ISNULL(O.UsdPayMissing, 0)) AS Usd, 0 Credit, SUM(ISNULL(O.Usd, 0) + ISNULL(O.UsdPayMissing, 0)) AS BalanceDetail
  --     FROM OtherPayments O
  --          INNER JOIN
  --          Agencies A
  --          ON A.AgencyId = O.AgencyId
  --     WHERE A.AgencyId = @AgencyId AND
  --           CAST(O.CreationDate AS date) >= CAST(@FromDate AS date) AND
  --           CAST(O.CreationDate AS date) <= CAST(@ToDate AS date)
  --     GROUP BY O.AgencyId, CAST(O.CreationDate AS date)) AS Query) AS QueryFinal;


  --  SELECT *, (SELECT SUM(t2.BalanceDetail)
  --FROM #TempTableOtherPayment t2
  --WHERE t2.RowNumber <= t1.RowNumber) BalanceFinal
  --  FROM #TempTableOtherPayment t1
  --  ORDER BY RowNumber ASC;
  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Usd AS DECIMAL(18, 2))), 0) -- se cambió BalanceDetail por usd -sergio 05/05/2024
      FROM #TempTableOtherPayment t2
      WHERE t2.RowNumber <= T1.RowNumber)
    BalanceFinal

  FROM #TempTableOtherPayment T1



END;


GO