SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllProvidersMoneyTransferByAgency] @UserId INT = NULL,
@AgencyId INT = NULL,
@CreationDate DATETIME = NULL,
@Active BIT = NULL


AS
BEGIN
  DECLARE @MonthDate INT = CAST(MONTH(@CreationDate) AS INT);
  DECLARE @YearDate INT = CAST(YEAR(@CreationDate) AS INT);
  SELECT
    p.ProviderId
   ,p.Active
   ,p.ProviderTypeId
   ,p.AcceptNegative
   ,0 AS 'Disabled'
   ,0 Comision
   ,p.MoneyOrderService
   ,pt.Code AS ProviderTypeCode
   ,pt.Description AS ProviderType
   ,p.Name + ' - ' + mt.Number AS Name
   ,p.DetailedTransaction
   ,ISNULL(p.MoneyOrderCommission, 0) MoneyOrderCommission

--   ,ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId  

   ,ISNULL((SELECT top 1 pc.ProviderCommissionPaymentId   FROM ProviderCommissionPayments pc
--   INNER JOIN Providers p1 ON pc.ProviderId = p1.ProviderId
   WHERE pc.ProviderId = p.ProviderId AND  (pc.IsForex = 0 OR pc.IsForex IS NULL)
        AND (pc.Year = @YearDate
        AND pc.Month = @MonthDate)
      AND pc.AgencyId = @AgencyId ),0) AS ProviderCommissionPaymentId

   ,ISNULL(p.UseSmartSafeDeposit, 0) UseSmartSafeDeposit
   ,p.SmartSafeDepositVoucherRequired
   ,ISNULL(p.UseCashAdvanceOrBack, 0) UseCashAdvanceOrBack
   ,ISNULL(p.CashAdvanceOrBackVoucherRequired, 0) CashAdvanceOrBackVoucherRequired

  FROM Providers p
  INNER JOIN ProviderTypes pt
    ON p.ProviderTypeId = pt.ProviderTypeId
  --AND P.Active = 1
  INNER JOIN MoneyTransferxAgencyNumbers mt
    ON p.ProviderId = mt.ProviderId
      AND mt.AgencyId = @AgencyId
--  LEFT JOIN ProviderCommissionPayments pc
--    ON pc.ProviderId = p.ProviderId
--      AND (pc.Year = @YearDate
--        AND pc.Month = @MonthDate)
--      AND pc.AgencyId = @AgencyId
  WHERE 
--  (p.UseCashAdvanceOrBack = @UseCashAdvanceOrBack
--  OR @UseCashAdvanceOrBack IS NULL)
--  AND 
  pt.Code = 'C02'--Money transfer
  AND ((p.ProviderId IN (SELECT
      mtq.ProviderId
    FROM MoneyTransfers mtq
    WHERE mtq.AgencyId = @AgencyId
    AND mtq.CreatedBy = @UserId
    AND CAST(mtq.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
  )
  OR (p.Active = @Active
  OR @Active IS NULL))


  ORDER BY Name;
END;






GO