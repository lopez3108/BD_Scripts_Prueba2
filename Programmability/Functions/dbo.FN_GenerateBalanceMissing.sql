SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:5-12-2023
--CAMBIOS EN 5355, Balance de missing menos pagos

--LASTUPDATEDBY: FELIPE
--LASTUPDATEDON:20-12-2023
--Cuando el daily esta abiero trae fechas menores, si está cerrado menores o iguales

-- 2025-07-16 JT/6603: Missing payments managers

CREATE FUNCTION [dbo].[FN_GenerateBalanceMissing] (@AgencyId INT,
@CashierId INT = NULL,
@Date DATETIME = NULL,
@DailyId INT = NULL,
@UserManagerId INT = NULL)
RETURNS DECIMAL(18, 2)

AS
BEGIN

  DECLARE @Balance DECIMAL(18, 2);
  --balance missing

  --------------------------------
  SET @Balance = ISNULL((SELECT
      ISNULL(ABS(SUM(D.Missing)), 0)
    FROM Daily D
    LEFT JOIN Agencies A
      ON A.AgencyId = D.AgencyId
    INNER JOIN Cashiers c
      ON c.CashierId = D.CashierId
    WHERE D.Missing < 0
    AND ((A.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND (D.AgencyId IN ((SELECT
        axm.AgencyId
      FROM Users um
      INNER JOIN dbo.AgenciesxUser axm
        ON axm.UserId = um.UserId
      WHERE um.UserId = @UserManagerId))
    OR @UserManagerId IS NULL)
    AND (c.CashierId = @CashierId
    OR @CashierId IS NULL)
    --Cuando el daily esta abiero trae fechas menores, si está cerrado menores o iguales
    AND (((CAST(D.CreationDate AS DATE) < CAST(@Date AS DATE)
    OR @Date IS NULL)
    AND D.ClosedBy IS NULL)
    OR ((CAST(D.CreationDate AS DATE) <= CAST(@Date AS DATE)
    OR @Date IS NULL)
    AND D.ClosedBy IS NOT NULL))
    AND (D.DailyId = @DailyId
    OR @DailyId IS NULL))
    GROUP BY D.AgencyId
            ,c.CashierId
            ,D.CashierId)
  , 0)

  --Missing payments
  - ISNULL((SELECT
      ISNULL(SUM(o.UsdPayMissing), 0)
    FROM OtherPayments o
    INNER JOIN Agencies A
      ON A.AgencyId = o.AgencyId
    INNER JOIN Daily d
      ON o.DailyId = d.DailyId
    INNER JOIN Cashiers C
      ON d.CashierId = C.CashierId
    WHERE CAST(o.PayMissing AS BIT) = 1
    AND (o.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND (o.AgencyId IN ((SELECT
        axm.AgencyId
      FROM Users um
      INNER JOIN dbo.AgenciesxUser axm
        ON axm.UserId = um.UserId
      WHERE um.UserId = @UserManagerId))
    OR @UserManagerId IS NULL)
    AND (C.CashierId = @CashierId
    OR @CashierId IS NULL)
    --    AND (CAST(o.CreationDate AS DATE) <= CAST(@Date AS DATE)
    --    OR @Date IS NULL)
    AND (o.DailyId = @DailyId
    OR @DailyId IS NULL))
  , 0)


  RETURN @Balance

END











GO