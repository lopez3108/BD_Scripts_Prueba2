SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5397,Refactorizacion de reporte missing
-- 2025-07-16 JT/6603: Missing payments managers

CREATE FUNCTION [dbo].[FN_GenerateMissingPendingEmployee]
(
                 @AgencyId int = NULL, @FromDate datetime = NULL, @ToDate datetime = NULL, @CodeFilter varchar(3) = NULL, @CashierId int = NULL
)
RETURNS @result TABLE
(
            [Index] int
            , AgencyId int
            , Type varchar(1000)
            , TypeId int
            , Employee varchar(1000)
            , CashierId int
            , TotalDays int
            , Usd decimal(18, 2)
            , BalanceDetail decimal(18, 2)

)


AS
BEGIN


  -- DAILY
  IF (@CodeFilter = 'C01') -- PENDING
  BEGIN
    INSERT INTO @result
           SELECT *
           FROM (
           SELECT ROW_NUMBER() OVER (ORDER BY Query.Employee ASC) [Index], Query.AgencyId, Query.Type, Query.TypeId, Query.Employee, Query.CashierId, TotalDays, ABS(Query.Usd) Usd, ABS(Query.Usd) BalanceDetail


         FROM (
         SELECT D.AgencyId, 
         'MISSING' AS Type, 
         1 TypeId, 
         u.Name Employee, 
         c.CashierId CashierId, 
         COUNT(D.CreationDate) TotalDays, 
         ABS(SUM(D.Missing)) - 
         (SELECT ISNULL(SUM(o.UsdPayMissing), 0) 
         FROM OtherPayments o INNER JOIN Cashiers c ON c.UserId = o.CreatedBy 
                              INNER JOIN Agencies A ON A.AgencyId = o.AgencyId
         WHERE CAST(o.PayMissing AS bit) = 1 AND 
         (o.AgencyId = D.AgencyId) AND         
         (c.CashierId = @CashierId OR @CashierId IS NULL)
          AND   ((SELECT [dbo].FN_GenerateBalanceMissing(A.AgencyId, c.CashierId, @ToDate, o.DailyId, NULL  )) <> 0)
                              --      ((select [dbo].FN_GenerateBalanceMissing(@AgencyId, @CashierId, @Date, d.DailyId)) = 0)
--                              OR (o.DailyId IN (SELECT op.DailyId
--                            FROM OtherPayments op
--                                 INNER JOIN
--                                 Cashiers c
--                                 ON c.UserId = op.CreatedBy
--                            WHERE CAST(op.PayMissing AS bit) = 1 AND
--                                  (op.AgencyId = @AgencyId OR
--                                  @AgencyId IS NULL) AND
--                                  (c.CashierId = @CashierId OR @CashierId is null)  AND
--                                  (CAST(op.CreationDate AS date) = CAST(@ToDate AS date))))
                      
          
         AND c.CashierId = D.CashierId) Usd, 
         0 BalanceDetail

       FROM Daily D
            --            LEFT JOIN Cometado por decision de Jorge
            --            DailyAdjustments DA
            --            ON DA.DailyId = D.DailyId
            INNER JOIN
            Agencies A
            ON A.AgencyId = D.AgencyId
            INNER JOIN
            Cashiers c
            ON c.CashierId = D.CashierId
            INNER JOIN
            Users u
            ON u.UserId = c.UserId
       WHERE (A.AgencyId = @AgencyId OR
             @AgencyId IS NULL) AND
             (D.CashierId = @CashierId OR
             @CashierId IS NULL)
                       AND   ((SELECT [dbo].FN_GenerateBalanceMissing(A.AgencyId, D.CashierId, @ToDate, d.DailyId, NULL)) <> 0)
                              --      ((select [dbo].FN_GenerateBalanceMissing(@AgencyId, @CashierId, @Date, d.DailyId)) = 0)
--                              OR (d.DailyId IN (SELECT op.DailyId
--                            FROM OtherPayments op
--                                 INNER JOIN
--                                 Cashiers c
--                                 ON c.UserId = op.CreatedBy
--                            WHERE CAST(op.PayMissing AS bit) = 1 AND
--                                  (op.AgencyId = @AgencyId OR
--                                  @AgencyId IS NULL) AND
--                                  (c.CashierId = @CashierId OR @CashierId is null)  AND
--                                  (CAST(op.CreationDate AS date) = CAST(@ToDate AS date))))
                      
             --          AND D.Surplus = 0
             AND D.Missing < 0

       GROUP BY D.AgencyId, u.Name, c.CashierId, D.CashierId) AS Query) AS QueryFinal
           GROUP BY QueryFinal.AgencyId, QueryFinal.Employee, QueryFinal.CashierId, QueryFinal.CashierId, QueryFinal.Usd, QueryFinal.[Index], QueryFinal.AgencyId, QueryFinal.Type, QueryFinal.TypeId, QueryFinal.BalanceDetail, TotalDays
           HAVING ABS(QueryFinal.Usd) <> 0;

  END

  IF (@CodeFilter = 'C02')-- FECHAS
  BEGIN
    INSERT INTO @result
           SELECT *
           FROM (SELECT ROW_NUMBER() OVER (ORDER BY Query.Employee ASC) [Index], Query.AgencyId, Query.Type, Query.TypeId, Query.Employee, Query.CashierId, TotalDays, ABS(Query.Usd) Usd, ABS(Query.Usd) BalanceDetail

         FROM (SELECT D.AgencyId, 'MISSING' AS Type, 1 TypeId, u.Name Employee, c.CashierId CashierId, COUNT(D.CreationDate) TotalDays, ABS(SUM(D.Missing)) Usd, 0 BalanceDetail
       FROM Daily D
            --            LEFT JOIN -- Cometado por decision de Jorge
            --            DailyAdjustments DA
            --            ON DA.DailyId = D.DailyId
            INNER JOIN
            Agencies A
            ON A.AgencyId = D.AgencyId
            INNER JOIN
            Cashiers c
            ON c.CashierId = D.CashierId
            INNER JOIN
            Users u
            ON u.UserId = c.UserId
       WHERE (A.AgencyId = @AgencyId OR
             @AgencyId IS NULL) AND
             ((CAST(D.CreationDate AS date) >= CAST(@FromDate AS date) OR
             @FromDate IS NULL) AND
             (CAST(D.CreationDate AS date) <= CAST(@ToDate AS date) OR
             @ToDate IS NULL)) AND
             (D.CashierId = @CashierId OR
             @CashierId IS NULL) AND
             D.Missing < 0

       GROUP BY D.AgencyId, u.Name, c.CashierId, D.CashierId
       UNION ALL
       SELECT o.AgencyId, 'PAYMENT' Type, 2 TypeId, U.Name Employee, c.CashierId CashierId, 0 TotalDays, -SUM((ISNULL(o.UsdPayMissing, 0))) Usd, 0 BalanceDetail
       FROM OtherPayments o
            INNER JOIN
            Agencies A
            ON A.AgencyId = o.AgencyId
            INNER JOIN
            Users U
            ON U.UserId = o.CreatedBy
            INNER JOIN
            Cashiers c
            ON c.UserId = o.CreatedBy
       WHERE (A.AgencyId = @AgencyId OR
             @AgencyId IS NULL) AND
             CAST(o.PayMissing AS bit) = 1 AND
             ((CAST(o.CreationDate AS date) >= CAST(@FromDate AS date) OR
             @FromDate IS NULL) AND
             (CAST(o.CreationDate AS date) <= CAST(@ToDate AS date) OR
             @ToDate IS NULL)) AND
             (c.CashierId = @CashierId OR
             @CashierId IS NULL)

       GROUP BY o.AgencyId, c.CashierId, U.Name) AS Query) AS QueryFinal
           GROUP BY QueryFinal.AgencyId, QueryFinal.Employee, QueryFinal.CashierId, QueryFinal.CashierId, QueryFinal.Usd, QueryFinal.[Index], QueryFinal.AgencyId, QueryFinal.Type, QueryFinal.TypeId, QueryFinal.BalanceDetail, TotalDays
           HAVING ABS(QueryFinal.Usd) > 0;



  END;

  RETURN;
END











GO