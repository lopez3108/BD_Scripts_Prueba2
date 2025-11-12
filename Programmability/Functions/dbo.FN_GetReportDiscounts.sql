SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: Felipe
--LASTUPDATEDON:02-11-2023
--date 04-06-2025 task 6559 Ajustes discounts JF
--date 20-06-2025 task 6607 Reporte DISCOUNTS - Debe aparecer Agrupado por:Fecha + Type + Description en el TAB de DISCOUNTS JF

CREATE FUNCTION [dbo].[FN_GetReportDiscounts] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL)
RETURNS @result TABLE (
  RowNumber INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,Transactions INT
 ,Usd DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
)


AS
BEGIN

  INSERT INTO @result

    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC, CAST(Query.Date AS Date) ASC) RowNumber
       ,*
      FROM (SELECT
          S.AgencyId
         , ---MONEY TRANSFER
          CAST(S.CreationDate AS date) AS DATE
         ,'CLOSING DAILY' Description
         ,'MONEY TRANSFER' Type
         ,1 TypeId
         ,ISNULL(COUNT(*), 0) Transactions
         ,SUM(ABS(ISNULL(S.Discount , 0))) AS Usd
         ,0 Credit
         ,SUM(ABS(ISNULL(S.Discount , 0))) AS BalanceDetail
        FROM DiscountMoneyTransfers S
        INNER JOIN Agencies A
          ON A.AgencyId = S.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(S.CreationDate AS date) >= CAST(@FromDate AS date)
        AND CAST(S.CreationDate AS date) <= CAST(@ToDate AS date)
        GROUP BY S.AgencyId
                ,CAST(S.CreationDate AS date)
        UNION ALL
        SELECT
          C.AgencyId
         , ---CHECK
          CAST(C.CreationDate AS date) AS DATE
         ,'CLOSING DAILY' Description
         ,'CHECKS' Type
         ,1 TypeId
         ,ISNULL(COUNT(*), 0) Transactions
         ,SUM(ABS(ISNULL(C.Discount , 0))) AS Usd
         ,0 Credit
         ,SUM(ABS(ISNULL(C.Discount , 0))) AS BalanceDetail
        FROM DiscountChecks C
        INNER JOIN Agencies A
          ON A.AgencyId = C.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(C.CreationDate AS date) >= CAST(@FromDate AS date)
        AND CAST(C.CreationDate AS date) <= CAST(@ToDate AS date)
        GROUP BY C.AgencyId
                ,CAST(C.CreationDate AS date)
        UNION ALL
        SELECT
          P.AgencyId
         , ---PHONES
          CAST(P.CreationDate AS date) AS DATE
         ,'CLOSING DAILY' Description
         ,'PHONES' Type
         ,1 TypeId
         ,ISNULL(COUNT(*), 0) Transactions
         ,SUM(ABS(ISNULL(P.Discount , 0))) AS Usd
         ,0 Credit
         ,SUM(ABS(ISNULL(p.Discount , 0))) AS BalanceDetail
        FROM DiscountPhones P
        INNER JOIN Agencies A
          ON A.AgencyId = P.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(P.CreationDate AS date) >= CAST(@FromDate AS date)
        AND CAST(P.CreationDate AS date) <= CAST(@ToDate AS date)
        GROUP BY P.AgencyId
                ,CAST(P.CreationDate AS date)
        UNION ALL
        SELECT
          T.AgencyId
         , ---TITLES
          CAST(T.CreationDate AS date) AS DATE
         ,'CLOSING DAILY' Description
         ,'TITLES AND PLATE' Type
         ,1 TypeId
         ,ISNULL(COUNT(*), 0) Transactions
         ,SUM(ABS(ISNULL(t.Discount , 0))) AS Usd
         ,0 Credit
         ,SUM(ABS(ISNULL(t.Discount , 0))) AS BalanceDetail
        FROM DiscountTitles T
        INNER JOIN Agencies A
          ON A.AgencyId = T.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(T.CreationDate AS date) >= CAST(@FromDate AS date)
        AND CAST(T.CreationDate AS date) <= CAST(@ToDate AS date)
        GROUP BY T.AgencyId
                ,CAST(T.CreationDate AS date)
        UNION ALL
        SELECT
          C.AgencyId
         , ---CITY
          CAST(C.CreationDate AS date) AS DATE
         ,'CLOSING DAILY' Description
         ,'CITY STICKER' Type
         ,1 TypeId
         ,ISNULL(COUNT(*), 0) Transactions
         ,SUM(ABS(ISNULL(c.Discount , 0))) AS Usd
         ,0 Credit
         ,SUM(ABS(ISNULL(c.Discount , 0))) AS BalanceDetail
        FROM DiscountCityStickers C
        INNER JOIN Agencies A
          ON A.AgencyId = C.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(C.CreationDate AS date) >= CAST(@FromDate AS date)
        AND CAST(C.CreationDate AS date) <= CAST(@ToDate AS date)
        GROUP BY C.AgencyId
                ,CAST(C.CreationDate AS date)
        UNION ALL
        SELECT
          L.AgencyId
         , ---PLATE
          CAST(L.CreationDate AS date) AS DATE
         ,'CLOSING DAILY' Description
         ,'REGISTRATION RENEWALS' Type
         ,1 TypeId
         ,ISNULL(COUNT(*), 0) Transactions
         ,SUM(ABS(ISNULL(l.Discount , 0))) AS Usd
         ,0 Credit
         ,SUM(ABS(ISNULL(l.Discount , 0))) AS BalanceDetail
        FROM DiscountPlateStickers L
        INNER JOIN Agencies A
          ON A.AgencyId = L.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(L.CreationDate AS date) >= CAST(@FromDate AS date)
        AND CAST(L.CreationDate AS date) <= CAST(@ToDate AS date)
        GROUP BY L.AgencyId
                ,CAST(L.CreationDate AS date)
        UNION ALL
        SELECT
          Pt.AgencyUsedId AgencyId
         ,CAST(Pt.UsedDate AS date) AS DATE
         ,pc.Description as Description
         ,'PROMOTIONAL CODES' Type
         ,2 TypeId 
         ,ISNULL(COUNT(*), 0) Transactions      
         ,SUM(isnull(Pt.Usd,0)) AS Usd
         ,0 Credit
         ,SUM(isnull(Pt.Usd,0)) AS Balance
        FROM PromotionalCodes pc
        INNER JOIN PromotionalCodesStatus Pt
          ON pc.PromotionalCodeId = Pt.PromotionalCodeId
          INNER JOIN dbo.Users u
          ON pt.UserUsedId = u.UserId
        WHERE Pt.AgencyUsedId = @AgencyId
        AND CAST(Pt.UsedDate AS date) >= CAST(@FromDate AS date)
        AND CAST(Pt.UsedDate AS date) <= CAST(@ToDate AS date)
        GROUP BY Pt.AgencyUsedId ,pc.PromotionalCodeId, cast (pt.UsedDate AS date)
                ,pc.Description) AS Query) AS QueryFinal;


  RETURN;
END;








GO