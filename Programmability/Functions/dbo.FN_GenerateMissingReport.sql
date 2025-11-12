SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5397,Refactorizacion de reporte missing

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:30-11-2023
--CAMBIOS EN 5355, Los pagos de missing deben de llevar fecha del daily y en descripcion llevar la fecha del pago. 

-- 2025-07-16 JT/6603: Missing payments managers

CREATE FUNCTION [dbo].[FN_GenerateMissingReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@CodeFilter VARCHAR(3) = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,Usd DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)

)


AS
BEGIN


  -- Daily
  IF (@CodeFilter = 'C01')
  BEGIN
    INSERT INTO @result
      SELECT
        ROW_NUMBER() OVER (
        ORDER BY CAST(Query.Date AS Date),
        Query.TypeId ASC) [Index]
       ,Query.AgencyId
       ,Query.[Date]
       ,Query.Description
       ,Query.Type
       ,Query.TypeId
       ,ABS(Query.Usd) Usd
       ,Query.Credit
       ,(Query.BalanceDetail) BalanceDetail
      FROM (SELECT
          D.AgencyId
         ,CAST(D.CreationDate AS Date) AS Date
         ,'CLOSING DAILY' Description
         ,'DAILY' Type
         ,1 TypeId
         ,ABS(SUM(D.Missing)) AS Usd
         ,0 Credit
         ,ABS(SUM(D.Missing)) BalanceDetail
        FROM Daily D
        INNER JOIN Agencies A
          ON A.AgencyId = D.AgencyId
        INNER JOIN Cashiers c
          ON c.CashierId = D.CashierId
        INNER JOIN Users u
          ON u.UserId = c.UserId
        WHERE A.AgencyId = @AgencyId
        --          AND D.Surplus = 0
        AND D.Missing < 0
        AND ((SELECT
            [dbo].FN_GenerateBalanceMissing(A.AgencyId, D.CashierId, @ToDate, D.DailyId, NULL))
        <> 0)
        --      ((select [dbo].FN_GenerateBalanceMissing(@AgencyId, @CashierId, @Date, d.DailyId)) = 0)
        --                              OR (d.DailyId IN (SELECT op.DailyId
        --                            FROM OtherPayments op
        --                                 INNER JOIN
        --                                 Cashiers c
        --                                 ON c.UserId = op.CreatedBy
        --                            WHERE CAST(op.PayMissing AS bit) = 1 AND
        --                                  (op.AgencyId = @AgencyId OR
        --                                  @AgencyId IS NULL) AND
        ----                                  (c.CashierId = @CashierId OR @CashierId is null)  AND
        --                                  (CAST(op.CreationDate AS date) = CAST(@ToDate AS date))))                           






        GROUP BY D.AgencyId
                ,CAST(D.CreationDate AS Date)



        --MISSING PAY

        UNION ALL
        SELECT
          o.AgencyId
         ,CAST(d.CreationDate AS Date) AS Date
         ,
          -- ,CAST(o.CreationDate AS DATE) AS DATE
          'CLOSING DAILY' Description
         ,'PAYMENT-' + FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US') Type
         ,2 TypeId
         ,0 Usd
         ,SUM(ISNULL(o.UsdPayMissing, 0)) Credit
         ,-SUM(ISNULL(o.UsdPayMissing, 0)) BalanceDetail
        FROM OtherPayments o
        INNER JOIN Agencies A
          ON A.AgencyId = o.AgencyId
        INNER JOIN Daily d
          ON o.DailyId = d.DailyId
        INNER JOIN Cashiers C
          ON d.CashierId = C.CashierId
        INNER JOIN Users U
          ON U.UserId = C.UserId
        WHERE A.AgencyId = @AgencyId

        AND ((SELECT
            [dbo].FN_GenerateBalanceMissing(A.AgencyId, C.CashierId, @ToDate, o.DailyId, NULL))
        <> 0)
        --      ((select [dbo].FN_GenerateBalanceMissing(@AgencyId, @CashierId, @Date, d.DailyId)) = 0)
        --                              OR (o.DailyId IN (SELECT op.DailyId
        --                            FROM OtherPayments op
        --                                 INNER JOIN
        --                                 Cashiers c
        --                                 ON c.UserId = op.CreatedBy
        --                            WHERE CAST(op.PayMissing AS bit) = 1 AND
        --                                  (op.AgencyId = @AgencyId OR
        --                                  @AgencyId IS NULL) AND
        ----                                  (c.CashierId = @CashierId OR @CashierId is null)  AND
        --                                  (CAST(op.CreationDate AS date) = CAST(@ToDate AS date))))                           





        GROUP BY o.AgencyId
                ,CAST(o.CreationDate AS Date)
                ,FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US')
                ,CAST(d.CreationDate AS Date)
                ,o.DailyId) AS Query
  END
  IF (@CodeFilter = 'C02')
  BEGIN
    INSERT INTO @result
      SELECT
        ROW_NUMBER() OVER (
        ORDER BY CAST(Query.Date AS Date),
        Query.TypeId ASC) RowNumber
       ,Query.AgencyId
       ,Query.[Date]
       ,Query.Description
       ,Query.Type
       ,Query.TypeId
       ,Query.Usd Usd
       ,Query.Credit
       ,Query.BalanceDetail BalanceDetail
      FROM (SELECT
          D.AgencyId
         ,CAST(D.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'DAILY' Type
         ,1 TypeId
         ,ABS(SUM(D.Missing)) AS Usd
         ,0 Credit
         ,ABS(SUM(D.Missing)) BalanceDetail
        FROM Daily D
        --          LEFT JOIN DailyAdjustments DA
        --            ON DA.DailyId = D.DailyId
        INNER JOIN Agencies A
          ON A.AgencyId = D.AgencyId
        INNER JOIN Cashiers c
          ON c.CashierId = D.CashierId
        INNER JOIN Users u
          ON u.UserId = c.UserId
        WHERE A.AgencyId = @AgencyId
        AND D.Missing < 0
        --          AND D.Surplus = 0
        AND (CAST(D.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(D.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
        GROUP BY D.AgencyId
                ,CAST(D.CreationDate AS DATE)

        --D.Missing
        UNION ALL
        SELECT
          o.AgencyId
         ,CAST(d.CreationDate AS DATE) AS DATE
         ,
          -- ,CAST(o.CreationDate AS DATE) AS DATE
          'CLOSING DAILY' Description
         ,'PAYMENT-' + FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US') Type
         ,2 TypeId
         ,0 Usd
         ,ABS(SUM(ISNULL(o.UsdPayMissing, 0))) Credit
         ,-ABS(SUM(ISNULL(o.UsdPayMissing, 0))) BalanceDetail
        FROM OtherPayments o
        INNER JOIN Agencies A
          ON A.AgencyId = o.AgencyId
        INNER JOIN Daily d
          ON o.DailyId = d.DailyId
        INNER JOIN Cashiers C
          ON d.CashierId = C.CashierId
        INNER JOIN Users u
          ON u.UserId = C.UserId
        WHERE A.AgencyId = @AgencyId
        AND CAST(o.PayMissing AS BIT) = 1
        AND (CAST(d.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(d.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
        GROUP BY o.AgencyId
                ,CAST(o.CreationDate AS DATE)
                ,FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US')
                ,CAST(d.CreationDate AS DATE)
                ,o.DailyId) AS Query
  END


  RETURN;
END;









GO