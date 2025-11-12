SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- 2024-04-23 JF/5738: Error with forex configuration add select(UseCashAdvanceOrBack,CashAdvanceOrBackVoucherRequired,ForexType)
CREATE PROCEDURE [dbo].[sp_GetMoneyBillProvidersCheckCommission] @State BIT = NULL
AS
     BEGIN
         SELECT p.ProviderId,
                p.Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
                0 AS 'Disabled',
                0 Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType,
                0 transactions,
                p.CheckCommission AS 'moneyvalue',
                p.MoneyOrderCommission,
                P.ReturnedCheckCommission,
                'true' AS 'Set',
                P.LimitBalance,
                p.MoneyOrderService,
                p.UseSmartSafeDeposit,
                p.SmartSafeDepositVoucherRequired,
                p.DetailedTransaction,
                p.ShowInBalance,
                p.UseCashAdvanceOrBack,
                p.CashAdvanceOrBackVoucherRequired,
                p.ForexType,
                p.CostAndCommission
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
         WHERE(pt.Code = 'C02'
               OR pt.Code = 'C01')
              AND (p.Active = 1)
         ORDER BY Name;
     END;




GO