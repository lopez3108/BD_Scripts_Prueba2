SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAvailableDepositByContract]
 (
      @ContractId INT,
	  @Date DATETIME
    )
AS 

BEGIN

SELECT 
(SELECT ContractDeposit FROM [dbo].[FN_GetContractDepositInformation](@ContractId, @Date)) AS Deposit,
(SELECT ContractUsedDeposit FROM [dbo].[FN_GetContractDepositInformation](@ContractId, @Date)) AS UsedDeposit,
(SELECT ContractAvailableDeposit FROM [dbo].[FN_GetContractDepositInformation](@ContractId, @Date)) AS AvailabledDeposit,
((SELECT ContractAvailableRefund FROM [dbo].[FN_GetContractDepositInformation](@ContractId, @Date))) AS RefundAvailable,
(SELECT TOP 1 Name FROM Tenants t INNER JOIN TenantsXcontracts tc ON t.TenantId = tc.TenantId 
WHERE tc.ContractId = @ContractId AND Principal = CAST(1 as BIT)) as Tenant,
(select Top 1 ISNULL(DownPayment,0) from dbo.Contract c WHERE ContractId = @ContractId) as Deposit,
ISNULL((select SUM(DepositUsed) from PropertiesBillLabor WHERE ContractId = @ContractId),0) as BillLabor,
ISNULL((select SUM(Usd) from DepositFinancingPayments WHERE ContractId = @ContractId),0) as DepositPaid,
[dbo].[fn_GetDepositRefundTotal](@ContractId,@Date) AS DepositRefundFeeMoney


	END
GO