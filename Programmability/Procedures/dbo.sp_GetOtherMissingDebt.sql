SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON: 05-12-2023
--CAMBIOS EN 5355, trae lista de dailys con missing mas el balance para dailys con missing no cancelado

--LASTUPDATEDBY: FELIPE
--LASTUPDATEDON:20-12-2023
--Cuando el daily esta abiero trae fechas menores, si está cerrado menores o iguales

--LASTUPDATEDBY: FELIPE
--LASTUPDATEDON: 9 Enero 2024
--2- Mejoras Daily concilliation > MISSING task 5355

--UPDATE DATE: 29-04-2024
--UPDATE BY: JT
--USO: REFACTORING QUERY PAYMENTS DETAILS MAKE BY DATE,  CASHIER,  #5785
-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_GetOtherMissingDebt] @AgencyId INT = NULL, @CashierId INT = NULL, @Date DATETIME = NULL

AS
  SET NOCOUNT ON;

  BEGIN

    CREATE TABLE #Temp (
      [ID] INT IDENTITY (1, 1)
     ,[Index] INT
     ,DailyId INT
     ,OtherPaymentId INT
     ,PayMissing BIT
     ,Missing DECIMAL(18, 2)
     ,MissingPaid DECIMAL(18, 2)
     ,CreationDateFormat DATETIME
     ,CreationDate DATETIME
     ,MissingDetail DECIMAL(18, 2)
     ,CashierDailyId INT
    )

--Missings generated
    INSERT INTO #Temp
      SELECT
        1 AS [Index]
       ,d.DailyId
       ,0 OtherPaymentId
       ,CAST(0 AS BIT) AS PayMissing
       ,ABS(d.Missing) AS Missing
       ,0 AS MissingPaid
       ,FORMAT(d.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
       ,d.CreationDate
       ,ABS(d.Missing) AS MissingDetail
       ,ISNULL(d.CashierId, 0) CashierDailyId
      FROM Daily d
      INNER JOIN Cashiers c
        ON c.CashierId = d.CashierId
      WHERE d.Missing IS NOT NULL
      AND d.Missing < 0
      AND (d.CashierId = @CashierId
      AND d.AgencyId = @AgencyId)
      --Cuando el daily esta abiero trae fechas menores, si está cerrado menores o iguales
      AND (((CAST(d.CreationDate AS DATE) < CAST(@Date AS DATE)
      OR @Date IS NULL)
      AND d.ClosedBy IS NULL)
      OR ((CAST(d.CreationDate AS DATE) <= CAST(@Date AS DATE)
      OR @Date IS NULL)
      AND d.ClosedBy IS NOT NULL))
      AND
      --Se verifica solo los pagos que estan pendientes donde el (missing - pago) <> 0 
      ((((SELECT
          [dbo].FN_GenerateBalanceMissing(d.AgencyId, d.CashierId, @Date, d.DailyId, NULL))
      <> 0)
      --      ((select [dbo].FN_GenerateBalanceMissing(@AgencyId, @CashierId, @Date, d.DailyId)) = 0)
      OR (d.DailyId IN (SELECT
          op.DailyId
        FROM OtherPayments op
        INNER JOIN Cashiers c
          ON c.UserId = op.CreatedBy
        WHERE CAST(op.PayMissing AS BIT) = 1
        AND (op.AgencyId = @AgencyId
        OR @AgencyId IS NULL)
        AND (c.CashierId = @CashierId)
        AND (CAST(op.CreationDate AS DATE) = CAST(@Date AS DATE)))
      )))
      ORDER BY d.CreationDate,
      [Index];

--Payments missings
    INSERT INTO #Temp
      SELECT
        2 AS [Index]
       ,op.DailyId
       ,op.OtherPaymentId
       ,CAST(op.PayMissing AS BIT) AS PayMissing
       ,0 Missing
       ,ISNULL(op.UsdPayMissing, 0) AS MissingPaid
       ,FORMAT(op.CreationDate, 'MM-dd-yyyy', 'en-US') CreationDateFormat
       ,op.CreationDate
       ,-ISNULL(op.UsdPayMissing, 0) AS MissingDetail
       ,ISNULL(d.CashierId, 0) CashierDailyId
      FROM OtherPayments op
      --      INNER JOIN Cashiers c
      --        ON c.UserId = op.CreatedBy
      INNER JOIN Agencies A
        ON A.AgencyId = op.AgencyId
      INNER JOIN Daily d
        ON op.DailyId = d.DailyId
      INNER JOIN Cashiers C
        ON d.CashierId = C.CashierId
      WHERE CAST(op.PayMissing AS BIT) = 1
      AND (op.AgencyId = @AgencyId
      AND C.CashierId = @CashierId)
      --Se verifica solo los pagos pertenecientes a missings que estan pendientes es decir donde el (missing - pago) <> 0 ,
     
      AND (((SELECT
          [dbo].FN_GenerateBalanceMissing(d.AgencyId, d.CashierId, @Date, op.DailyId, NULL))
      <> 0) 
      --o que sea un pago de la fecha del daily que estamos consultado
--      OR (CAST(op.CreationDate AS DATE) = CAST(@Date AS DATE)
--      OR @Date IS NULL)
 OR (d.DailyId IN (SELECT
          op.DailyId
        FROM OtherPayments op
        INNER JOIN Cashiers c
          ON c.UserId = op.CreatedBy
        WHERE CAST(op.PayMissing AS BIT) = 1
        AND (op.AgencyId = @AgencyId
        OR @AgencyId IS NULL)
        AND (c.CashierId = @CashierId)
        AND (CAST(op.CreationDate AS DATE) = CAST(@Date AS DATE)))
      )
      )

    SELECT
      *
     ,((SELECT
          SUM((t2.MissingDetail))
        FROM #Temp t2
        WHERE t2.ID <= t1.ID
        AND (t2.MissingDetail < 0
        OR t2.MissingDetail > 0))
      ) MissingTotalBalance
    FROM #Temp t1
    WHERE (t1.MissingDetail < 0
    OR t1.MissingDetail > 0)
    ORDER BY ID ASC;
  END;



GO