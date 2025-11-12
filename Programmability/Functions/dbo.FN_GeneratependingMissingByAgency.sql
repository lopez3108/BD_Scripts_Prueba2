SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: Romario
--LASTUPDATEDON:18-01-2024
CREATE FUNCTION [dbo].[FN_GeneratependingMissingByAgency] (@AgencyId INT = NULL,
@StartingDate DATETIME = NULL, 
@CashierId INT = NULL)

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
    WHERE (c.CashierId = @CashierId OR @CashierId is null)
--    AND c.IsActive = 1 
    AND ((D.AgencyId = @AgencyId OR @AgencyId IS NULL) 
    AND (CAST(D.CreationDate AS DATE) < CAST(@StartingDate AS DATE) OR  @StartingDate IS NULL))
    GROUP BY D.AgencyId)

  SET @BalancePayments = (SELECT
      ISNULL(SUM(o.UsdPayMissing), 0)
    FROM OtherPayments o
    LEFT JOIN dbo.Daily d ON D.DailyId = o.DailyId
    INNER JOIN Cashiers c
      ON c.UserId = o.CreatedBy
    INNER JOIN dbo.Agencies a ON o.AgencyId = a.AgencyId
    WHERE CAST(o.PayMissing AS BIT) = 1
--    AND c.IsActive = 1
    AND (c.CashierId = @CashierId OR @CashierId is null)
    AND ((a.AgencyId = @AgencyId OR @AgencyId IS NULL) 
    AND (CAST(D.CreationDate AS DATE) < CAST(@StartingDate AS DATE) OR  @StartingDate IS NULL))
    )


  SET @Balance = (SELECT
      SUM(@BalanceMissing - @BalancePayments) AS Missing)


  RETURN @Balance

END




GO