SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-26 DJ/6016: Get the Insurance providers list
-- 2025-02-28 JF /6359: Ajustes en los Filtros del Módulo Insurance


CREATE PROCEDURE [dbo].[sp_GetInsuranceProviders] ( @Active  BIT = NULL )
AS

BEGIN
 

SELECT p.[ProviderId]
      ,p.[Name]
      ,p.[ProviderTypeId]
      ,p.[AcceptNegative]
      ,p.[Comision]
      ,p.[Active]
      ,p.[ShowInBalance]
      ,p.[CheckCommission]
      ,p.[MoneyOrderCommission]
      ,p.[ReturnedCheckCommission]
      ,p.[CostAndCommission]
      ,p.[DetailedTransaction]
      ,p.[LimitBalance]
      ,p.[MoneyOrderService]
      ,p.[UseSmartSafeDeposit]
      ,p.[SmartSafeDepositVoucherRequired]
      ,p.[UseCashAdvanceOrBack]
      ,p.[CashAdvanceOrBackVoucherRequired]
      ,p.[ForexType]
  FROM [dbo].[Providers] p
  INNER JOIN dbo.ProviderTypes pr ON pr.ProviderTypeId = p.ProviderTypeId
  WHERE ( ( p.Active = CAST(1 as BIT) AND @Active = 1) OR @Active = 0 )  AND pr.Code = 'C26'





END



GO