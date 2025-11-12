SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:5-12-2023
--CAMBIOS EN 5355, agrupa los pagos de missing para que solo esten en un solo registro (Necesario en el daily)


-- =============================================
-- Author:      JF
-- Create date: 11/06/2024 8:51 p. m.
-- Database:    devtest
-- Description: 5895 Nueva alerta QA OTHER PAYMENTS (PENDING)
-- =============================================

-- 2025-07-15 JT/6603: Missing payments managers


CREATE PROCEDURE [dbo].[sp_GetAllOtherPaymentDaily] (@Creationdate DATE = NULL,
@AgencyId INT,
@UserId INT = NULL)
AS
BEGIN
  SELECT
    ---Total de pagos 

    p.OtherPaymentId
   ,p.Description
   ,SUM(ISNULL(p.Usd, 0)) Usd
   ,p.CreationDate
   ,p.CreatedBy
   ,p.AgencyId
   ,p.CardPayment
   ,ISNULL(p.CardPaymentFee, 0) CardPaymentFee
   ,p.LastUpdatedOn
   ,p.LastUpdatedOn AS LastUpdatedOnView
   ,p.LastUpdatedBy
   ,ISNULL(p.Cash, 0) Cash
   ,p.PayMissing
   ,ISNULL(p.UsdMissing, 0) UsdMissing
   ,ISNULL(p.UsdPayMissing, 0) UsdPayMissing
   ,usu.Name LastUpdatedByName
   ,0 AS MissingDaily
   ,COUNT(p.CreationDate) AS Transactions
   ,'' UserDailyName
   ,NULL CashierDailyId
   ,p.completed   
   ,FORMAT(p.CompletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')	CompletedOn  
   ,u.Name CompletedByName
  FROM OtherPayments p
  LEFT JOIN Daily d
    ON p.DailyId = d.DailyId
  LEFT JOIN Cashiers c
    ON d.CashierId = c.CashierId
  LEFT JOIN Users ud
    ON c.UserId = ud.UserId
  LEFT JOIN Users usu
    ON p.LastUpdatedBy = usu.UserId
    LEFT JOIN Users u ON p.CompletedBy = u.UserId
  WHERE (CAST(p.CreationDate AS DATE) = CAST(@Creationdate AS DATE)
  OR @Creationdate IS NULL)
  AND p.AgencyId = @AgencyId
  AND (p.CreatedBy = @UserId
  OR @UserId IS NULL)
  AND p.PayMissing = CAST(0 AS BIT)
  GROUP BY p.OtherPaymentId
          ,p.Description
          ,p.Usd
          ,p.CreationDate
          ,p.CreatedBy
          ,p.AgencyId
          ,p.CardPayment
          ,p.CardPaymentFee
          ,p.LastUpdatedOn
          ,p.LastUpdatedBy
          ,p.Cash
          ,p.PayMissing
          ,p.UsdMissing
          ,p.UsdPayMissing
          ,usu.Name
          ,p.completed
          ,p.CompletedOn
          ,u.Name


  UNION ALL


  --Balance total de lo que debe el missing
  SELECT
    OtherPaymentId
   ,Description
   ,SUM(Usd) Usd
   ,CreationDate
   ,CreatedBy
   ,AgencyId
   ,CardPayment
   ,CardPaymentFee
   ,LastUpdatedOn
   ,LastUpdatedOnView AS LastUpdatedOnView
   ,LastUpdatedBy
   ,Cash
   ,PayMissing
   ,SUM(UsdMissing) UsdMissing
   ,SUM(UsdPayMissing) UsdPayMissing
   ,(SELECT
        u.Name
      FROM Users u
      WHERE u.UserId = Query.LastUpdatedBy)
    AS LastUpdatedByName
   ,

 
  (SELECT
            [dbo].FN_GenerateBalanceMissing(AgencyId, CashierDailyId, CreationDate, NULL, NULL)) MissingDaily

--    MissingDaily
   ,SUM(Query.Transactions) Transactions
   ,ISNULL(UserDailyName, '') UserDailyName
   ,ISNULL(CashierDailyId, 0) CashierDailyId
   , completed 
   ,'' CompletedOn
   ,'' CompletedByName
  FROM (SELECT

      0 OtherPaymentId
     ,'' Description
     ,(ISNULL(p.UsdPayMissing, 0)) Usd
     ,CAST(p.CreationDate AS DATE) CreationDate
     ,p.CreatedBy
     ,p.AgencyId
     ,CAST(0 AS BIT) AS CardPayment
     ,0 CardPaymentFee
      --     ,CAST(p.LastUpdatedOn AS DATE) LastUpdatedOn
     ,(SELECT TOP 1
          CAST(os.LastUpdatedOn AS DATE)
        FROM OtherPayments os
        WHERE PayMissing = 1
        AND (CAST(os.CreationDate AS DATE) = CAST(@Creationdate AS DATE))
        AND os.AgencyId = @AgencyId
        ORDER BY os.OtherPaymentId DESC)
      AS LastUpdatedOn
     ,(SELECT TOP 1
          CAST(os.LastUpdatedOn AS DATETIME)
        FROM OtherPayments os
        WHERE PayMissing = 1
        AND (CAST(os.CreationDate AS DATE) = CAST(@Creationdate AS DATE))
        AND os.AgencyId = @AgencyId
        ORDER BY os.OtherPaymentId DESC)
      AS LastUpdatedOnView
      --   ,p.LastUpdatedBy
     ,(SELECT TOP 1
          os.LastUpdatedBy
        FROM OtherPayments os
        WHERE PayMissing = 1
        AND (CAST(os.CreationDate AS DATE) = CAST(@Creationdate AS DATE))
        AND os.AgencyId = @AgencyId
        ORDER BY os.OtherPaymentId DESC)
      AS LastUpdatedBy

     ,0 Cash
     ,CAST(p.PayMissing AS BIT) PayMissing
     ,(ISNULL(UsdMissing, 0)) UsdMissing
     ,(ISNULL(p.UsdPayMissing, 0)) UsdPayMissing
      --   ,usu.Name LastUpdatedByName
     ,(SELECT DISTINCT
          SUM(op.UsdPayMissing)
        FROM OtherPayments op
        INNER JOIN Daily dp
          ON op.DailyId = dp.DailyId
        INNER JOIN Cashiers Cp
          ON dp.CashierId = Cp.CashierId
        WHERE 
        op.AgencyId = p.AgencyId
        AND (Cp.UserId = ud.UserId)
        AND 
        p.PayMissing = CAST(1 AS BIT)
      AND     op.DailyId = d.DailyId
      )
      TotalPaysMissing
   
     ,1 Transactions
     ,ud.Name UserDailyName
     ,d.CashierId CashierDailyId
     ,CAST(0 AS BIT) AS completed
    FROM OtherPayments p
    LEFT JOIN Daily d
      ON p.DailyId = d.DailyId
    LEFT JOIN Cashiers c
      ON d.CashierId = c.CashierId
    LEFT JOIN Users ud
      ON c.UserId = ud.UserId
    --  LEFT JOIN Users usu
    --    ON p.LastUpdatedBy = usu.UserId
    WHERE (CAST(p.CreationDate AS DATE) = CAST(@Creationdate AS DATE)
    OR @Creationdate IS NULL)
    AND p.AgencyId = @AgencyId
    AND (p.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND p.PayMissing = CAST(1 AS BIT)


  ) AS Query

  GROUP BY Query.OtherPaymentId
          ,Description
          ,CAST(CreationDate AS DATE)
          ,CreatedBy
          ,AgencyId
          ,CAST(CardPayment AS BIT)
          ,CardPaymentFee
          ,CAST(LastUpdatedOn AS DATE)
          ,CAST(LastUpdatedOnView AS DATETIME)
          ,LastUpdatedBy
          ,Cash
          ,CAST(PayMissing AS BIT)
           --          ,Query.Usd
           --          ,Query.UsdMissing
           --          ,Query.UsdPayMissing
           --          ,Query.MissingDaily
           --          ,Query.Transactions
          ,Query.UserDailyName
          ,Query.CashierDailyId
          ,CAST(completed AS BIT)




END;

GO