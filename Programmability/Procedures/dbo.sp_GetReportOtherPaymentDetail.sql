SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- se cambió BalanceDetail por usd y se comenta la parte del initial balance task: 5891
-- by: sergio 
-- date: 05/05/2024

CREATE PROCEDURE [dbo].[sp_GetReportOtherPaymentDetail] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL, @Date DATETIME)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  --  IF OBJECT_ID('#TempTableOtherPaymentDetail') IS NOT NULL
  --  BEGIN
  --    DROP TABLE #TempTableOtherPaymentDetail;
  --  END;

  -- INITIAL BALANCE

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)


  DECLARE @Balance DECIMAL(18, 2)
  SET @Balance = ISNULL((SELECT
      SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
    FROM dbo.FN_GetReportOtherPaymentDetail(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)

  CREATE TABLE #TempTableOtherPaymentDetail (
    [ID] INT IDENTITY (1, 1)
   ,RowNumber INT
   ,OtherPaymentId INT
   ,AgencyId INT
   ,Date DATETIME
   ,Type VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,NameEmployee VARCHAR(80)
   ,TypeId INT
   ,Usd DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
  );

  INSERT INTO #TempTableOtherPaymentDetail
--    SELECT
--      0 RowNumber
--     ,NULL OtherPaymentId
--     ,NULL AgencyId
--     ,CAST(@initialBalanceFinalDate AS Date) Date
--     ,'INITIAL BALANCE' Type
--     ,'INITIAL BALANCE' Description
--     ,'-' NameEmployee
--     ,0 TypeId
--     ,0 Usd
--     ,0 Credit
--     ,ISNULL(@Balance, 0) BalanceDetail
--
--    UNION ALL


    SELECT
      *
    FROM [dbo].FN_GetReportOtherPaymentDetail(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,
    RowNumber;


  --
  --         SELECT *
  --         FROM (SELECT ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC, CAST(Query.Date AS date) ASC) RowNumber, *
  --       FROM (SELECT E.OtherPaymentId, E.AgencyId, E.CreationDate Date, 'CLOSING DAILY' Type, CASE WHEN E.PayMissing = 1 THEN 'PAY MISSING' ELSE SUBSTRING(E.Description, 1, 20) END AS Description, U.Name, 1 TypeId, CASE WHEN E.PayMissing = 1 THEN ISNULL(E.UsdPayMissing, 0) ELSE ISNULL(E.Usd, 0) END AS Usd, 0 Credit, CASE WHEN E.PayMissing = 1 THEN ISNULL(E.UsdPayMissing, 0) ELSE ISNULL(E.Usd, 0) END AS BalanceDetail
  --
  --     FROM OtherPayments E
  --          INNER JOIN
  --          Agencies A
  --          ON A.AgencyId = E.AgencyId
  --          INNER JOIN
  --          dbo.Users U
  --          ON U.UserId = E.CreatedBy
  --     WHERE E.AgencyId = @AgencyId AND
  --           (CAST(E.CreationDate AS date) >= CAST(@FromDate AS date) OR
  --           @FromDate IS NULL) AND
  --           (CAST(E.CreationDate AS date) <= CAST(@ToDate AS date) OR
  --           @ToDate IS NULL)) AS Query) AS QueryFinal;


  --  SELECT *, (SELECT SUM(t2.BalanceDetail)
  --FROM #TempTableOtherPaymentDetail t2
  --WHERE t2.RowNumber <= t1.RowNumber) BalanceFinal
  --  FROM #TempTableOtherPaymentDetail t1
  --  ORDER BY RowNumber ASC;

  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(Usd AS DECIMAL(18, 2))), 0) -- se cambió BalanceDetail por usd -sergio 31/05/2024
      FROM #TempTableOtherPaymentDetail t2
      WHERE t2.RowNumber <= T1.RowNumber)
    BalanceFinal

  FROM #TempTableOtherPaymentDetail T1

END;



GO