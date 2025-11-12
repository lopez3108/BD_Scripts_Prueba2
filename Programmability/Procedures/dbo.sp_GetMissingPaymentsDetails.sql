SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATION DATE: 28-11-2024
--CREATED BY: JOHAN
--USO: CONSULTA LOS DETALLES DE PAGOS HECHOS A MISSING POR FECHA Y CUANDO NO VIENE LA FECHA POR DAILYID #5355

--UPDATE DATE: 29-04-2024
--UPDATE BY: JT
--USO: REFACTORING QUERY PAYMENTS DETAILS MAKE BY DATE, DAILY, CASHIER, CASHIER OWNER OF  MISSING , #5785
CREATE PROCEDURE [dbo].[sp_GetMissingPaymentsDetails] @AgencyId INT,
@CashierId INT = NULL,
@DailyId INT = NULL,
@CurrentDate DATETIME = NULL,
@CashierDailyId INT = NULL
AS
  SET NOCOUNT ON;
  BEGIN

    SELECT
      CAST(op.UsdPayMissing AS DECIMAL(18, 2)) AS UsdPayMissing
     ,CAST(op.UsdPayMissing AS DECIMAL(18, 2)) AS UsdPayMissingSaved
     ,op.LastUpdatedOn
     ,u.Name AS LastUpdatedByName
     ,op.DailyId
     ,op.OtherPaymentId
     ,(SELECT
          CAST(d.CreationDate AS DATE) CreationDate
        FROM Daily d
        WHERE d.DailyId = op.DailyId)
      AS CreationDateDaily
     ,op.CreationDate
     ,op.LastUpdatedBy
     ,c1.CashierId CashierOwnerPay
     ,cd.CashierId CashierOwnerMissing
    FROM OtherPayments op
    INNER JOIN Users u
      ON op.LastUpdatedBy = u.UserId
    INNER JOIN Cashiers c1--Cashier owner of pay
      ON c1.UserId = op.CreatedBy
    LEFT JOIN Daily d
      ON op.DailyId = d.DailyId
    LEFT JOIN Cashiers cd --Cashier owner of missing
      ON d.CashierId = cd.CashierId
    LEFT JOIN Users ud
      ON cd.UserId = ud.UserId
    WHERE (CAST(op.CreationDate AS DATE) = CAST(@CurrentDate AS DATE)
    OR @CurrentDate IS NULL)
    AND (op.DailyId = @DailyId
    OR @DailyId IS NULL)
    AND op.AgencyId = @AgencyId
    AND op.PayMissing = CAST(1 AS BIT)
    --    AND c1.CashierId = @CashierId
    AND (cd.CashierId = @CashierDailyId
    OR @CashierDailyId IS NULL)
    AND (c1.CashierId = @CashierId
    OR @CashierId IS NULL)
    ORDER BY op.CreationDate
  END;



GO