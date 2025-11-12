SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllProviders] @AgencyId INT = NULL,
@Active BIT = NULL
AS
BEGIN
  SELECT
    p.ProviderId
   ,UPPER(p.Name) + ISNULL(CASE
      WHEN @AgencyId IS NOT NULL AND
        pt.Code = 'C02' THEN (SELECT TOP 1
            CASE
              WHEN mn.Number IS NULL THEN ''
              ELSE ' - ' + mn.Number
            END
          FROM dbo.MoneyTransferxAgencyNumbers mn
          WHERE mn.AgencyId = @AgencyId
          AND mn.ProviderId = p.ProviderId)
      ELSE ''
    END, '') AS Name
   ,p.Active
   ,CASE
      WHEN p.Active = 1 THEN 'ACTIVE'
      ELSE 'INACTIVE'
    END AS [ActiveFormat]
   ,p.ProviderTypeId
   ,p.AcceptNegative
   ,CASE
      WHEN p.AcceptNegative = 1 THEN 'YES'
      ELSE 'NO'
    END AS [AcceptNegativeFormat]
   ,p.Comision
   ,p.ShowInBalance
   ,p.CostAndCommission
   ,p.MoneyOrderCommission
   ,p.DetailedTransaction
   ,p.ReturnedCheckCommission
   ,p.CheckCommission
   ,p.MoneyOrderService
   ,CASE
      WHEN p.CostAndCommission = 1 AND
        pt.Code = 'C01' THEN 'COST AND COMMISSION'
      WHEN p.CostAndCommission = 0 AND
        pt.Code = 'C01' THEN 'TOTAL'
      ELSE NULL
    END ConciliationType
   ,UPPER(pt.Description) AS ProviderType
   ,pt.Code AS ProviderTypeCode
   ,ISNULL(LimitBalance, CAST(0 AS BIT)) AS LimitBalance
   ,ISNULL(p.UseSmartSafeDeposit, 0) UseSmartSafeDeposit
   ,ISNULL(p.SmartSafeDepositVoucherRequired, 0) SmartSafeDepositVoucherRequired
   ,ISNULL(p.UseCashAdvanceOrBack, 0) UseCashAdvanceOrBack
   ,ISNULL(p.CashAdvanceOrBackVoucherRequired, 0) CashAdvanceOrBackVoucherRequired
   ,p.ForexType
   ,CASE
      WHEN p.ForexType IS NULL THEN CAST(0 AS BIT)
      ELSE CAST(1 AS BIT)
    END AS UseForex
   ,CASE
      WHEN p.ForexType IS NULL THEN CAST(0 AS BIT)
      ELSE CAST(1 AS BIT)
    END AS UseForexSaved
  FROM Providers p
  INNER JOIN ProviderTypes pt
    ON p.ProviderTypeId = pt.ProviderTypeId
  WHERE p.Active = @Active
  OR @Active IS NULL
  ORDER BY Name;
END;

GO