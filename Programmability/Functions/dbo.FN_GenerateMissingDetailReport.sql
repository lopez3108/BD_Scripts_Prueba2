SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Update: JT
--Date:04-23-2024
--CAMBIOS EN 5785 , Permitir a un manager pagar los missings de otros cajeros

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5397,Refactorizacion de reporte missing

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:30-11-2023
--CAMBIOS EN 5355, Los pagos de missing deben de llevar fecha del daily y en descripcion llevar la fecha del pago. 

--LASTUPDATEDBY: JT
--LASTUPDATEDON:27-03-2024
--CAMBIOS EN 5748, En el reporte de missing el faltante y missing deben salir juntos

-- 2025-07-16 JT/6603: Missing payments managers


CREATE FUNCTION [dbo].[FN_GenerateMissingDetailReport] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL, @CodeFilter VARCHAR(3) = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,AgencyId INT
 ,Date DATETIME
 ,Employee VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,UserBeneficaryId INT
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
        ORDER BY Query.Date,
        Query.TypeId ASC,
        Query.UserBeneficaryId ASC
        ) [Index]
       ,Query.AgencyId
       ,Query.Date Date
       ,Query.Employee
       ,Query.Type
       ,Query.TypeId
       ,Query.UserBeneficaryId
       ,(Query.Usd) Usd
       ,Query.Credit
       ,Query.BalanceDetail
      FROM (SELECT
          D.AgencyId
         ,CAST(D.CreationDate AS date) AS DATE
         ,u.Name Employee
         ,'DAILY' Type
         ,1 TypeId
         ,u.UserId UserBeneficaryId
         ,ABS((D.Missing)) AS Usd
         ,0 Credit
         ,ABS((D.Missing)) BalanceDetail
        FROM Daily D
        INNER JOIN Agencies A
          ON A.AgencyId = D.AgencyId
        INNER JOIN Cashiers c
          ON c.CashierId = D.CashierId
        INNER JOIN Users u
          ON u.UserId = c.UserId
        WHERE A.AgencyId = @AgencyId
        AND D.Surplus = 0
        AND D.Missing < 0
        AND ((SELECT
            [dbo].FN_GenerateBalanceMissing(A.AgencyId, D.CashierId, @ToDate, D.DailyId, NULL))
        <> 0)


        UNION ALL
        SELECT
          o.AgencyId
         ,CAST(d.CreationDate AS date) AS DATE
         ,
          -- CAST(o.CreationDate AS DATE) AS DATE, 
          U.Name Employee
         ,'PAYMENT-' + FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US') Type
         ,2 TypeId
         ,U.UserId UserBeneficaryId
         ,0 Usd
         ,((ISNULL(o.UsdPayMissing, 0))) Credit
         ,-((ISNULL(o.UsdPayMissing, 0))) BalanceDetail
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
        <> 0)) AS Query
  END

  IF (@CodeFilter = 'C02')--Ranges dates
  BEGIN
    INSERT INTO @result
      SELECT
        ROW_NUMBER() OVER (
        ORDER BY
        Query.Date ASC,
        Query.UserBeneficaryId ASC,

        Query.TypeId ASC


        ) [Index]
       ,Query.AgencyId
       ,Query.Date Date
       ,Query.Employee
       ,Query.Type
       ,Query.TypeId
       ,Query.UserBeneficaryId
       ,(Query.Usd) Usd
       ,Query.Credit
       ,(Query.BalanceDetail) BalanceDetail
      FROM (SELECT
          D.AgencyId
         ,CAST(D.CreationDate AS date) AS DATE
         ,u.Name Employee
         ,'DAILY' Type
         ,1 TypeId
         ,u.UserId UserBeneficaryId
         ,ABS((D.Missing)) AS Usd
         ,0 Credit
         ,ABS((D.Missing)) BalanceDetail
        FROM Daily D
        INNER JOIN Agencies A
          ON A.AgencyId = D.AgencyId
        INNER JOIN Cashiers c
          ON c.CashierId = D.CashierId
        INNER JOIN Users u
          ON u.UserId = c.UserId
        WHERE A.AgencyId = @AgencyId
        AND D.Surplus = 0
        AND D.Missing < 0
        AND ((CAST(D.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(D.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL))

        UNION ALL
        SELECT
          o.AgencyId
         ,CAST(d.CreationDate AS date) AS DATE
         ,
          --CAST(o.CreationDate AS DATE) AS DATE, 
          --          U.Name Employee
          CASE
            WHEN UPPER(umissing.Name) <> UPPER(userPayment.Name) THEN umissing.Name + ' PAID BY: ' + userPayment.Name
            ELSE umissing.Name
          END [Employee]

         ,'PAYMENT-' + FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US') Type
         ,2 TypeId
         ,userPayment.UserId UserBeneficaryId
         ,0 Usd
         ,ABS((ISNULL(o.UsdPayMissing, 0))) Credit
         ,-ABS((ISNULL(o.UsdPayMissing, 0))) BalanceDetail
        FROM OtherPayments o
        INNER JOIN Agencies A
          ON A.AgencyId = o.AgencyId
        INNER JOIN Daily d
          ON o.DailyId = d.DailyId
        INNER JOIN Cashiers C
          ON d.CashierId = C.CashierId
        INNER JOIN Users umissing
          ON umissing.UserId = C.UserId
        INNER JOIN Users userPayment
          ON userPayment.UserId = o.CreatedBy
        WHERE A.AgencyId = @AgencyId
        AND CAST(o.PayMissing AS BIT) = 1
        AND ((CAST(d.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(d.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL))
        ) AS Query
  END

  RETURN;
END;








GO