SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:10-12-2023
--CAMBIOS EN 5355, Balance de missing menos pagos

-- 2024-11-25 DJ/6089: Error con los missings al inactivar un cashier
-- 2025-07-15 JT/6603: Missing payments managers

CREATE FUNCTION [dbo].[FN_GeneratependingMissing] (@AgencyId INT = NULL,
@StartingDate DATETIME = NULL,
@CashierId INT = NULL,
@UserManagerId INT = NULL)

RETURNS DECIMAL(18, 2)

AS
BEGIN

  DECLARE @Balance DECIMAL(18, 2);
  DECLARE @BalanceMissing DECIMAL(18, 2);
  DECLARE @BalancePayments DECIMAL(18, 2);
  SET @BalanceMissing = (SELECT
      ABS(SUM(D.Missing))
    FROM Daily D
    INNER JOIN Cashiers c
      ON c.CashierId = D.CashierId
    WHERE (c.CashierId = @CashierId
    OR @CashierId IS NULL)
    --    AND c.IsActive = 1 
    AND ((D.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND (D.AgencyId IN ((SELECT
        axm.AgencyId
      FROM Users um
      INNER JOIN dbo.AgenciesxUser axm
        ON axm.UserId = um.UserId
      WHERE um.UserId = @UserManagerId))
    OR @UserManagerId IS NULL)
    AND (CAST(D.CreationDate AS DATE) < CAST(@StartingDate AS DATE)
    OR @StartingDate IS NULL))
    GROUP BY c.CashierId)

  SET @BalancePayments = (SELECT
      ISNULL(SUM(o.UsdPayMissing), 0)
    FROM OtherPayments o
    LEFT JOIN dbo.Daily d
      ON d.DailyId = o.DailyId
    INNER JOIN Cashiers c
      ON d.CashierId = c.CashierId --6089
    INNER JOIN dbo.Agencies a
      ON o.AgencyId = a.AgencyId
    WHERE CAST(o.PayMissing AS BIT) = 1
    --    AND c.IsActive = 1
    AND (d.CashierId = @CashierId
    OR @CashierId IS NULL)
    AND ((a.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND (o.AgencyId IN ((SELECT
        axm.AgencyId
      FROM Users um
      INNER JOIN dbo.AgenciesxUser axm
        ON axm.UserId = um.UserId
      WHERE um.UserId = @UserManagerId))
    OR @UserManagerId IS NULL)
    AND (CAST(d.CreationDate AS DATE) < CAST(@StartingDate AS DATE)
    OR @StartingDate IS NULL)))


  SET @Balance = (SELECT
      SUM(@BalanceMissing - @BalancePayments) AS Missing)


  RETURN @Balance

END

GO