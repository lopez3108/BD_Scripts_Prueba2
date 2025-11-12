SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--date 04-06-2025 task 6559 Ajustes discounts JF

CREATE PROCEDURE [dbo].[sp_GetReportDiscountsDetail] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

--  IF OBJECT_ID('#TempTableDiscounts') IS NOT NULL
--  BEGIN
--    DROP TABLE #TempTableDiscounts;
--  END;

DECLARE @initialBalanceFinalDate datetime
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)


  DECLARE @Balance decimal(18, 2)
  SET @Balance = ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
FROM dbo.FN_GetReportDiscountsDetail(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)

  CREATE TABLE #TempTableDiscounts (
    RowNumber INT
   ,AgencyId INT
   ,Date DATETIME 
   ,Employee VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,Transactions INT
   ,Usd DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
  );

  INSERT INTO #TempTableDiscounts
         SELECT 0 RowNumber,
              NULL AgencyId,
              CAST(@initialBalanceFinalDate AS DATE) Date,
             'INITIAL BALANCE' Description,
             '-' Employee,
             'INITIAL BALANCE'Type,
             0 TypeId,
             0 Transactions,
             0 Usd,
             0 Credit,
          ISNULL(@Balance, 0) BalanceDetail

 UNION ALL
     

         SELECT *
         FROM [dbo].FN_GetReportDiscountsDetail(@AgencyId, @FromDate, @ToDate)
         ORDER BY Date,
         RowNumber;
--  INSERT INTO #TempTableDiscounts (
--  RowNumber,
--  AgencyId,
--  Date,
--  Employee,
--  Description,
--  Type,
--  TypeId,
--  Transactions,
--  Usd,
--  Credit,
--  BalanceDetail)
--    SELECT
--      *
--    FROM (SELECT
--        ROW_NUMBER() OVER (
--        ORDER BY Query.TypeId ASC,
--        CAST(Query.Date AS Date) ASC) RowNumber
--       ,*
--      FROM (SELECT
--          S.AgencyId
--         , ---MONEY TRANSFER
--          CAST(S.CreationDate AS DATE) AS DATE
--         ,u.Name Employee
--         ,'CLOSING DAILY' Description
--         ,'MONEY TRANSFER' Type
--         ,1 TypeId
--         ,ISNULL(COUNT(*), 0) Transactions
--         ,SUM(ABS(ISNULL(S.Discount , 0))) AS Usd
--         ,0 Credit
--         ,SUM(ABS(ISNULL(S.Discount , 0))) AS BalanceDetail
--        FROM DiscountMoneyTransfers S
--        INNER JOIN Agencies A
--          ON A.AgencyId = S.AgencyId
--        INNER JOIN dbo.Users u
--          ON S.CreatedBy = u.UserId
--        WHERE A.AgencyId = @AgencyId
--        AND CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--        AND CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--        GROUP BY S.AgencyId
--                ,CAST(S.CreationDate AS DATE)
--                ,u.Name
--                ,S.DiscountMoneyTransferId
--        UNION ALL
--        SELECT
--          C.AgencyId
--         , ---CHECK
--          CAST(C.CreationDate AS DATE) AS DATE
--         ,u.Name Employee
--         ,'CLOSING DAILY' Description
--         ,'CHECKS' Type
--         ,1 TypeId
--         ,ISNULL(COUNT(*), 0) Transactions
--         ,SUM(ABS(ISNULL(c.Discount , 0))) AS Usd
--         ,0 Credit
--         ,SUM(ABS(ISNULL(C.Discount , 0))) AS BalanceDetail
--        FROM DiscountChecks C
--        INNER JOIN Agencies A
--          ON A.AgencyId = C.AgencyId
--        INNER JOIN dbo.Users u
--          ON C.CreatedBy = u.UserId
--        WHERE A.AgencyId = @AgencyId
--        AND CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--        AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--        GROUP BY C.AgencyId
--                ,CAST(C.CreationDate AS DATE)
--                ,u.Name
--                ,C.DiscountCheckId
--        UNION ALL
--        SELECT
--          P.AgencyId
--         , ---PHONES
--          CAST(P.CreationDate AS DATE) AS DATE
--         ,u.Name Employee
--         ,'CLOSING DAILY' Description
--         ,'PHONES' Type
--         ,1 TypeId
--         ,ISNULL(COUNT(*), 0) Transactions
--         ,SUM(ABS(ISNULL(p.Discount , 0))) AS Usd
--         ,0 Credit
--         ,SUM(ABS(ISNULL(p.Discount , 0))) AS BalanceDetail
--        FROM DiscountPhones P
--        INNER JOIN Agencies A
--          ON A.AgencyId = P.AgencyId
--        INNER JOIN dbo.Users u
--          ON P.CreatedBy = u.UserId
--        WHERE A.AgencyId = @AgencyId
--        AND CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--        AND CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--        GROUP BY P.AgencyId
--                ,CAST(P.CreationDate AS DATE)
--                ,u.Name
--                ,P.DiscountPhoneId
--        UNION ALL
--        SELECT
--          T.AgencyId
--         , ---TITLES
--          CAST(T.CreationDate AS DATE) AS DATE
--         ,u.Name Employee
--         ,'CLOSING DAILY' Description
--         ,'TITLES AND PLATE' Type
--         ,1 TypeId
--         ,ISNULL(COUNT(*), 0) Transactions
--         ,SUM(ABS(ISNULL(t.Discount , 0))) AS Usd
--         ,0 Credit
--         ,SUM(ABS(ISNULL(t.Discount , 0))) AS BalanceDetail
--        FROM DiscountTitles T
--        INNER JOIN Agencies A
--          ON A.AgencyId = T.AgencyId
--        INNER JOIN dbo.Users u
--          ON T.CreatedBy = u.UserId
--        WHERE A.AgencyId = @AgencyId
--        AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--        AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--        GROUP BY T.AgencyId
--                ,CAST(T.CreationDate AS DATE)
--                ,u.Name
--                ,T.DiscountTitleId
--        UNION ALL
--        SELECT
--          C.AgencyId
--         , ---CITY
--          CAST(C.CreationDate AS DATE) AS DATE
--         ,u.Name Employee
--         ,'CLOSING DAILY' Description
--         ,'CITY STICKER' Type
--         ,1 TypeId
--         ,ISNULL(COUNT(*), 0) Transactions
--         ,SUM(ABS(ISNULL(c.Discount , 0))) AS Usd
--         ,0 Credit
--         ,SUM(ABS(ISNULL(c.Discount , 0))) AS BalanceDetail
--        FROM DiscountCityStickers C
--        INNER JOIN Agencies A
--          ON A.AgencyId = C.AgencyId
--        INNER JOIN dbo.Users u
--          ON C.CreatedBy = u.UserId
--        WHERE A.AgencyId = @AgencyId
--        AND CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--        AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--        GROUP BY C.AgencyId
--                ,CAST(C.CreationDate AS DATE)
--                ,u.Name
--                ,C.DiscountCityStickerId
--        UNION ALL
--        SELECT
--          L.AgencyId
--         , ---PLATE
--          CAST(L.CreationDate AS DATE) AS DATE
--         ,u.Name Employee
--         ,'CLOSING DAILY' Description
--         ,'REGISTRATION RENEWALS' Type
--         ,1 TypeId
--         ,ISNULL(COUNT(*), 0) Transactions
--         ,SUM(ABS(ISNULL(l.Discount , 0))) AS Usd
--         ,0 Credit
--         ,SUM(ABS(ISNULL(l.Discount , 0))) AS BalanceDetail
--        FROM DiscountPlateStickers L
--        INNER JOIN Agencies A
--          ON A.AgencyId = L.AgencyId
--        INNER JOIN dbo.Users u
--          ON L.CreatedBy = u.UserId
--        WHERE A.AgencyId = @AgencyId
--        AND CAST(L.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--        AND CAST(L.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--        GROUP BY L.AgencyId
--                ,CAST(L.CreationDate AS DATE)
--                ,u.Name
--                ,L.DiscountPlateStickerId
--        UNION ALL
--        SELECT
--          Pt.AgencyUsedId AgencyId
--         ,CAST(pt.UsedDate AS DATE) AS DATE
--         ,u.Name Employee
--         ,pc.Description as Description
--         ,'PROMOTIONAL CODES' Type
--         ,2 TypeId
--         ,1 AS Transactions
--         ,(ISNULL(pt.Usd , 0)) AS Usd
--         ,0 Credit
--         ,(ISNULL(pt.Usd , 0)) AS Balance
--        FROM PromotionalCodes pc
--        INNER JOIN PromotionalCodesStatus Pt
--          ON pc.PromotionalCodeId = Pt.PromotionalCodeId
--        INNER JOIN dbo.Users u
--          ON pt.UserUsedId = u.UserId
--        WHERE Pt.AgencyUsedId = @AgencyId
--        AND CAST(Pt.UsedDate AS DATE) >= CAST(@FromDate AS DATE)
--        AND CAST(Pt.UsedDate AS DATE) <= CAST(@ToDate AS DATE)
--         ) AS Query) AS QueryFinal;
  SELECT
    *
   ,(SELECT
        SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
      FROM #TempTableDiscounts t2
      WHERE t2.RowNumber <= t1.RowNumber)
    BalanceFinal
  FROM #TempTableDiscounts t1
  ORDER BY RowNumber ASC;
END;




GO