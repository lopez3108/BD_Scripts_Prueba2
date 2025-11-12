SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportDiscounts]
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

--  IF OBJECT_ID('#TempTableDiscounts') IS NOT NULL
--  BEGIN
--    DROP TABLE #TempTableDiscounts;
--  END;

 -- INITIAL BALANCE

DECLARE @initialBalanceFinalDate datetime
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)


  DECLARE @Balance decimal(18, 2)
  SET @Balance = ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
FROM dbo.FN_GetReportDiscounts(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)

  CREATE TABLE #TempTableDiscounts
  (
              [ID] int IDENTITY (1, 1),
              RowNumber int,
              AgencyId int,
              Date datetime,
              Description varchar(1000),
              Type varchar(1000),
              TypeId int,
              Transactions INT,
              Usd decimal(18, 2),
              Credit decimal(18, 2),
              BalanceDetail decimal(18, 2)
  );

    INSERT INTO #TempTableDiscounts
         SELECT 0 RowNumber,
              NULL AgencyId,
              CAST(@initialBalanceFinalDate AS DATE) Date,
             'INITIAL BALANCE' Description,
             'INITIAL BALANCE'Type,
             0 TypeId,
             0 Transactions,
             0 Usd,
             0 Credit,
          ISNULL(@Balance, 0) BalanceDetail
          

         UNION ALL
     

         SELECT *
         FROM [dbo].FN_GetReportDiscounts(@AgencyId, @FromDate, @ToDate)
         ORDER BY Date,
         RowNumber;


--  INSERT INTO #TempTableDiscounts (RowNumber,
--  AgencyId,
--  Date,
--  Description,
--  Type,
--  TypeId,
--  Usd,
--  Credit,
--  BalanceDetail)


--         SELECT *
--         FROM (SELECT ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC, CAST(Query.Date AS date) ASC) RowNumber, *
--       FROM (SELECT S.AgencyId, ---MONEY TRANSFER
--       CAST(S.CreationDate AS date) AS DATE, 'CLOSING DAILY' Description, 'MONEY TRANSFER' Type, 1 TypeId, SUM(ABS(S.Discount)) AS Usd, 0 Credit, SUM(ABS(S.Discount)) AS BalanceDetail
--     FROM DiscountMoneyTransfers S
--          INNER JOIN
--          Agencies A
--          ON A.AgencyId = S.AgencyId
--     WHERE A.AgencyId = @AgencyId AND
--           CAST(S.CreationDate AS date) >= CAST(@FromDate AS date) AND
--           CAST(S.CreationDate AS date) <= CAST(@ToDate AS date)
--     GROUP BY S.AgencyId, CAST(S.CreationDate AS date)
--     UNION ALL
--     SELECT C.AgencyId, ---CHECK
--       CAST(C.CreationDate AS date) AS DATE, 'CLOSING DAILY' Description, 'CHECKS' Type, 1 TypeId, SUM(ABS(C.Discount)) AS Usd, 0 Credit, SUM(ABS(C.Discount)) AS BalanceDetail
--     FROM DiscountChecks C
--          INNER JOIN
--          Agencies A
--          ON A.AgencyId = C.AgencyId
--     WHERE A.AgencyId = @AgencyId AND
--           CAST(C.CreationDate AS date) >= CAST(@FromDate AS date) AND
--           CAST(C.CreationDate AS date) <= CAST(@ToDate AS date)
--     GROUP BY C.AgencyId, CAST(C.CreationDate AS date)
--     UNION ALL
--     SELECT P.AgencyId, ---PHONES
--       CAST(P.CreationDate AS date) AS DATE, 'CLOSING DAILY' Description, 'PHONES' Type, 1 TypeId, SUM(ABS(P.Discount)) AS Usd, 0 Credit, SUM(ABS(P.Discount)) AS BalanceDetail
--     FROM DiscountPhones P
--          INNER JOIN
--          Agencies A
--          ON A.AgencyId = P.AgencyId
--     WHERE A.AgencyId = @AgencyId AND
--           CAST(P.CreationDate AS date) >= CAST(@FromDate AS date) AND
--           CAST(P.CreationDate AS date) <= CAST(@ToDate AS date)
--     GROUP BY P.AgencyId, CAST(P.CreationDate AS date)
--     UNION ALL
--     SELECT T.AgencyId, ---TITLES
--       CAST(T.CreationDate AS date) AS DATE, 'CLOSING DAILY' Description, 'TITLES AND PLATE' Type, 1 TypeId, SUM(ABS(T.Discount)) AS Usd, 0 Credit, SUM(ABS(T.Discount)) AS BalanceDetail
--     FROM DiscountTitles T
--          INNER JOIN
--          Agencies A
--          ON A.AgencyId = T.AgencyId
--     WHERE A.AgencyId = @AgencyId AND
--           CAST(T.CreationDate AS date) >= CAST(@FromDate AS date) AND
--           CAST(T.CreationDate AS date) <= CAST(@ToDate AS date)
--     GROUP BY T.AgencyId, CAST(T.CreationDate AS date)
--     UNION ALL
--     SELECT C.AgencyId, ---CITY
--       CAST(C.CreationDate AS date) AS DATE, 'CLOSING DAILY' Description, 'CITY STICKER' Type, 1 TypeId, SUM(ABS(C.Usd)) AS Usd, 0 Credit, SUM(ABS(C.Usd)) AS BalanceDetail
--     FROM DiscountCityStickers C
--          INNER JOIN
--          Agencies A
--          ON A.AgencyId = C.AgencyId
--     WHERE A.AgencyId = @AgencyId AND
--           CAST(C.CreationDate AS date) >= CAST(@FromDate AS date) AND
--           CAST(C.CreationDate AS date) <= CAST(@ToDate AS date)
--     GROUP BY C.AgencyId, CAST(C.CreationDate AS date)
--     UNION ALL
--     SELECT L.AgencyId, ---PLATE
--       CAST(L.CreationDate AS date) AS DATE, 'CLOSING DAILY' Description, 'REGISTRATION RENEWALS' Type, 1 TypeId, SUM(ABS(L.Usd)) AS Usd, 0 Credit, SUM(ABS(L.Usd)) AS BalanceDetail
--     FROM DiscountPlateStickers L
--          INNER JOIN
--          Agencies A
--          ON A.AgencyId = L.AgencyId
--     WHERE A.AgencyId = @AgencyId AND
--           CAST(L.CreationDate AS date) >= CAST(@FromDate AS date) AND
--           CAST(L.CreationDate AS date) <= CAST(@ToDate AS date)
--     GROUP BY L.AgencyId, CAST(L.CreationDate AS date)
--     UNION ALL
--     SELECT Pt.AgencyUsedId AgencyId, CAST(@ToDate AS date) AS DATE, 'CLOSING DAILY' Description, 'PROMOTIONAL CODES' Type, 2 TypeId, SUM(pc.Usd) AS Usd, 0 Credit, SUM(pc.Usd) AS Balance
--     FROM PromotionalCodes pc
--          INNER JOIN
--          PromotionalCodesStatus Pt
--          ON pc.PromotionalCodeId = Pt.PromotionalCodeId
--     WHERE Pt.AgencyUsedId = @AgencyId AND
--           CAST(Pt.UsedDate AS date) >= CAST(@FromDate AS date) AND
--           CAST(Pt.UsedDate AS date) <= CAST(@ToDate AS date)
--     GROUP BY Pt.AgencyUsedId) AS Query) AS QueryFinal;


--  SELECT *, (SELECT SUM(t2.BalanceDetail)
--FROM #TempTableDiscounts t2
--WHERE t2.RowNumber <= t1.RowNumber) BalanceFinal
--  FROM #TempTableDiscounts t1
--  ORDER BY RowNumber ASC;
	SELECT 
  				 *,
  				 (
              SELECT ISNULL( SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
              FROM #TempTableDiscounts t2
              WHERE t2.RowNumber <= t1.RowNumber
          ) BalanceFinal
          	
  				 FROM #TempTableDiscounts T1


END;


GO