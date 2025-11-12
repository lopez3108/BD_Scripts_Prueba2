SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Update by JT/10-07-2024 TASK 5936 ADD new fields
--Update by JT/27-08-2025 TASK 6689 Daily report nueva columna TOTAL CASH DAILY y TOTAL CASH DISTRIBUTED
CREATE PROCEDURE [dbo].[sp_GetAllDailyTotalsByDate] (@From DATE,
@To DATE,
@AgencyId INT,
@CreatedBy INT,
@CurrentDate DATE)
AS
BEGIN
  SET NOCOUNT ON;
  SET ANSI_WARNINGS ON;
  SET ARITHABORT ON;  -- mejora planes en algunas versiones

  DECLARE @cashierId INT;

  SET @cashierId = (SELECT
      c.CashierId
    FROM dbo.Cashiers AS c
    INNER JOIN dbo.Users AS u
      ON c.UserId = u.UserId
    WHERE u.UserId = @CreatedBy);

  ;
  WITH DailyFiltered
  AS
  (SELECT
      d.DailyId
     ,d.CreationDate
     ,d.Total
     ,d.Cash
     ,d.CashAdmin
     ,d.CardPayments
     ,d.CardPaymentsAdmin
     ,d.TotalFree
     ,d.ClosedByCashAdmin
     ,d.ClosedByCardPaymentsAdmin
     ,d.ClosedOnCashAdmin
     ,d.ClosedOnCardPaymentsAdmin
     ,d.CashierId
     ,d.AgencyId
    FROM dbo.Daily AS d
    WHERE CAST(d.CreationDate AS DATE) >= CAST(@From AS DATE)
    AND CAST(d.CreationDate AS DATE) <= CAST(@To AS DATE)
    AND d.CashierId = @cashierId
    AND d.AgencyId = @AgencyId),
  Dist
  AS
  (SELECT
      dd.DailyId
     ,SUM(CONVERT(DECIMAL(19, 4), dd.Usd)) AS DistUsd
    FROM dbo.DailyDistribution AS dd
    INNER JOIN DailyFiltered AS df
      ON df.DailyId = dd.DailyId
    GROUP BY dd.DailyId),
  Calc
  AS
  (SELECT
      df.DailyId
     ,df.CreationDate
     ,df.Total
     ,df.Cash
     ,df.CashAdmin
     ,df.CardPayments
     ,df.CardPaymentsAdmin
     ,df.TotalFree
     ,df.ClosedByCashAdmin
     ,df.ClosedByCardPaymentsAdmin
     ,df.ClosedOnCashAdmin
     ,df.ClosedOnCardPaymentsAdmin
     ,df.CashierId
     ,df.AgencyId
     ,ISNULL(ds.DistUsd, 0) AS DistUsd
     ,(
      (CASE
        WHEN df.ClosedByCashAdmin > 0 THEN CONVERT(DECIMAL(19, 4), df.CashAdmin) + ISNULL(CONVERT(DECIMAL(19, 4), ds.DistUsd), 0)
        ELSE CONVERT(DECIMAL(19, 4), df.Cash)
      END)
      +
      (CASE
        WHEN df.CardPaymentsAdmin > 0 THEN CONVERT(DECIMAL(19, 4), df.CardPaymentsAdmin)
        ELSE CONVERT(DECIMAL(19, 4), df.CardPayments)
      END)
      - CONVERT(DECIMAL(19, 4), df.Total)
      ) AS ExprLegacy
    FROM DailyFiltered AS df
    LEFT JOIN Dist AS ds
      ON ds.DailyId = df.DailyId)
  SELECT
    QUERY.DailyId
   ,QUERY.[Date]
   ,QUERY.Usd
   ,QUERY.[Name]
   ,usrcash.Name AS ClosedByCashAdminName
   ,usrcard.Name AS ClosedByCardPaymentsAdminName
   ,CASE
      WHEN @CurrentDate = CAST(d.ClosedOnCashAdmin AS DATE) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS AllowRemoveCash
   ,ISNULL(d.ClosedByCardPaymentsAdmin, 0) AS ClosedByCardPaymentsAdmin
   ,ISNULL(d.ClosedByCashAdmin, 0) AS ClosedByCashAdmin
   ,ISNULL(d.ClosedByCardPaymentsAdmin, 0) AS ClosedByCardPaymentsAdmin
   ,ISNULL(d.ClosedByCashAdmin, 0) AS ClosedByCashAdmin
   ,ISNULL(d.ClosedOnCashAdmin, 0) AS ClosedOnCashAdmin
   ,ISNULL(d.ClosedOnCardPaymentsAdmin, 0) AS ClosedOnCardPaymentsAdmin,
    CASE 
            WHEN EXISTS (SELECT 1 FROM Dist ds WHERE ds.DailyId = QUERY.DailyId) 
                THEN CAST(1 AS BIT) 
            ELSE CAST(0 AS BIT) 
        END AS HasDistribution
  FROM (
    -- TOTALS DAILY
    SELECT
      c.DailyId AS DailyId
     ,c.CreationDate AS [Date]
     ,c.Total AS USD
     ,'TOTALS DAILY' AS [Name]
    FROM Calc AS c

    UNION ALL

    -- TOTALS CASH DAILY
    SELECT
      c.DailyId
     ,c.CreationDate
     ,c.Cash
     ,'TOTALS CASH DAILY'
    FROM Calc AS c

    UNION ALL

    -- TOTALS CASH DISTRIBUTED (agregado por DailyId y fecha)
    SELECT
      df.DailyId
     ,df.CreationDate
     ,SUM(ds.DistUsd) AS USD
     ,'TOTALS CASH DISTRIBUTED' AS [Name]
    FROM DailyFiltered AS df
    INNER JOIN Dist AS ds
      ON ds.DailyId = df.DailyId
    GROUP BY df.DailyId
            ,df.CreationDate

    UNION ALL

    -- TOTALS CASH REMAINING (Cash - Dist)
    SELECT
      c.DailyId
     ,c.CreationDate
     ,(c.Cash - c.DistUsd) AS USD
     ,'TOTALS CASH REMAINING'
    FROM Calc AS c

    UNION ALL

    -- TOTALS CASH
    SELECT
      c.DailyId
     ,c.CreationDate
     ,c.Cash
     ,'TOTALS CASH'
    FROM Calc AS c

    UNION ALL

    -- TOTALS CASH ADMIN
    SELECT
      c.DailyId
     ,c.CreationDate
     ,c.CashAdmin
     ,'TOTALS CASH ADMIN'
    FROM Calc AS c

    UNION ALL

    -- TOTALS CARD PAYMENTS
    SELECT
      c.DailyId
     ,c.CreationDate
     ,c.CardPayments
     ,'TOTALS CARD PAYMENTS'
    FROM Calc AS c

    UNION ALL

    -- TOTALS CARD PAYMENTS ADMIN
    SELECT
      c.DailyId
     ,c.CreationDate
     ,c.CardPaymentsAdmin
     ,'TOTALS CARD PAYMENTS ADMIN'
    FROM Calc AS c

    UNION ALL

    -- TOTALS MISSING
    SELECT
      c.DailyId
     ,c.CreationDate
     ,CASE
        WHEN c.ExprLegacy < 0 THEN c.ExprLegacy
        ELSE 0
      END AS USD
     ,'TOTALS MISSING'
    FROM Calc AS c

    UNION ALL

    -- TOTALS SURPLUS
    SELECT
      c.DailyId
     ,c.CreationDate
     ,CASE
        WHEN c.ExprLegacy > 0 THEN c.ExprLegacy
        ELSE 0
      END AS USD
     ,'TOTALS SURPLUS'
    FROM Calc AS c

    UNION ALL

    -- TOTALS FREE
    SELECT
      c.DailyId
     ,c.CreationDate
     ,c.TotalFree
     ,'TOTALS FREE'
    FROM Calc AS c) AS QUERY
  INNER JOIN dbo.Daily AS d
    ON QUERY.[Date] = d.CreationDate
  LEFT JOIN dbo.Users AS usrcash
    ON usrcash.UserId = d.ClosedByCashAdmin
  LEFT JOIN dbo.Users AS usrcard
    ON usrcard.UserId = d.ClosedByCardPaymentsAdmin
  WHERE d.CashierId = @cashierId
  AND d.AgencyId = @AgencyId
  OPTION (OPTIMIZE FOR UNKNOWN);
END;

GO