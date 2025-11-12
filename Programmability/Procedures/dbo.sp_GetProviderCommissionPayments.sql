SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-03-06 DJ/6384: Comisión pagada debe sumar todos los conceptos

CREATE PROCEDURE [dbo].[sp_GetProviderCommissionPayments] (@ProviderId INT = NULL,
@AgencyId INT,
@Year INT,
@Month INT,
@Date DATETIME,
@IsForex BIT = NULL)
AS
BEGIN
  SELECT
    dbo.ProviderCommissionPayments.ProviderCommissionPaymentId
   ,dbo.ProviderCommissionPayments.ProviderId
   ,dbo.ProviderCommissionPayments.Month
   ,dbo.ProviderCommissionPayments.Year
   ,dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
   ,CASE
      WHEN dbo.ProviderTypes.Code = 'C14' THEN (SELECT
            SUM(dbo.OtherCommissions.Usd)
          FROM dbo.OtherCommissions
          WHERE OtherCommissions.ProviderCommissionPaymentId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentId)
      WHEN dbo.ProviderTypes.Code = 'C26' AND
        @ProviderId IS NULL THEN ISNULL((SELECT
            (ISNULL(i.NewPolicyAmount, 0) + ISNULL(i.MonthlyPaymentAmount, 0) + ISNULL(i.EndorsementAmount, 0) + ISNULL(i.PolicyRenewalAmount, 0) +
            ISNULL(i.RegistrationReleaseAmount, 0))
          FROM dbo.InsuranceProviderCommissionPayment i
          WHERE i.ProviderCommissionPaymentId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentId)
        , 0) +
        dbo.ProviderCommissionPayments.Usd
      ELSE dbo.ProviderCommissionPayments.Usd
    END AS Usd
   ,ISNULL(dbo.ProviderCommissionPayments.UsdMoneyOrders, 0) UsdMoneyOrders
   ,dbo.ProviderCommissionPayments.CheckNumber
   ,CAST(dbo.ProviderCommissionPayments.CheckDate AS DATE) AS CheckDate
   ,dbo.ProviderCommissionPayments.BankId
   ,dbo.ProviderCommissionPayments.Account
   ,dbo.ProviderCommissionPayments.AgencyId
   ,dbo.ProviderCommissionPayments.CreationDate
   ,dbo.ProviderCommissionPayments.CreatedBy
   ,dbo.ProviderCommissionPayments.LastUpdatedDate
   ,dbo.ProviderCommissionPayments.LastUpdatedBy
   ,CASE
      WHEN dbo.ProviderCommissionPayments.IsForex = CAST(0 AS BIT) OR
        dbo.ProviderCommissionPayments.IsForex IS NULL THEN dbo.Providers.Name
      ELSE dbo.Providers.Name + ' (FOREX)'
    END AS [Name]
   ,dbo.Providers.MoneyOrderService
   ,dbo.Bank.Name AS Expr1
   ,dbo.ProviderCommissionPaymentTypes.Code AS PaymentTypeCode
   ,dbo.ProviderCommissionPaymentTypes.Description
   ,dbo.Agencies.Name AS Expr2
   ,DATENAME(MONTH, DATEADD(MONTH, dbo.ProviderCommissionPayments.Month, 0) - 1) AS 'MonthName'
   ,CAST(dbo.ProviderCommissionPayments.AchDate AS DATE) AS AchDate
   ,CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) AS AdjustmentDate
   ,dbo.ProviderTypes.Code
   ,dbo.ProviderCommissionPayments.BankAccountId
   ,dbo.ProviderCommissionPayments.PaymentChecksAgentToAgentId
   ,CASE
      WHEN CAST(@Date AS DATE) <> CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) THEN CAST(0 AS BIT)
      ELSE CAST(1 AS BIT)
    END AS CanUpdate
   ,dbo.ProviderCommissionPaymentTypes.Description AS PaymentTypeDescription
   ,ISNULL(dbo.ProviderCommissionPayments.IsForex, 0) AS IsForex
   ,dbo.ProviderCommissionPayments.Usd UsdPaid
  FROM dbo.ProviderCommissionPayments
  INNER JOIN dbo.Providers
    ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
  INNER JOIN dbo.ProviderCommissionPaymentTypes
    ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
  INNER JOIN dbo.Agencies
    ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
  LEFT OUTER JOIN dbo.Bank
    ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
  LEFT OUTER JOIN dbo.BankAccounts
    ON dbo.ProviderCommissionPayments.BankAccountId = dbo.BankAccounts.BankAccountId
  INNER JOIN dbo.ProviderTypes
    ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
  WHERE ProviderCommissionPayments.AgencyId = @AgencyId
  AND ProviderCommissionPayments.Month = @Month
  AND ProviderCommissionPayments.Year = @Year
  AND ProviderCommissionPayments.ProviderId = CASE
    WHEN @ProviderId IS NULL THEN ProviderCommissionPayments.ProviderId
    ELSE @ProviderId
  END
  AND (@IsForex IS NULL
  OR ProviderCommissionPayments.IsForex = @IsForex)

END;


GO