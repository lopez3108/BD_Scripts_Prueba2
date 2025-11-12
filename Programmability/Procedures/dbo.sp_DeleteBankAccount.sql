SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteBankAccount] 
@BankAccountId INT
AS
     BEGIN

	IF(
	EXISTS(SELECT 1 FROM PaymentBanks WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM PaymentBanksToBanks WHERE (FromBankAccountId = @BankAccountId) OR (ToBankAccountId = @BankAccountId)) OR
	EXISTS(SELECT 1 FROM ConciliationBillPayments WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM ConciliationVentras WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM ConciliationELS WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM ConciliationCardPayments WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM ConciliationOthers WHERE BankAccountId = @BankAccountId)) OR
	EXISTS(SELECT 1 FROM PropertiesBillInsurance WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM PropertiesBillLabor WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM PropertiesBillOthers WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM PropertiesBillWater WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM LawyerPayments WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM CourtPayment WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM MoneyDistribution WHERE BankAccountId = @BankAccountId) OR
	EXISTS(SELECT 1 FROM PaymentOthersAgentToAgent WHERE BankAccountId = @BankAccountId ) OR
	EXISTS(SELECT 1 FROM PropertiesBillTaxes WHERE BankAccountId = @BankAccountId) OR
 	EXISTS(SELECT 1 FROM Contract c WHERE c.DepositBankAccountId = @BankAccountId) OR  
  EXISTS(SELECT 1 FROM Properties  WHERE BankAccountId= @BankAccountId) OR
  EXISTS(SELECT 1 FROM ProviderCommissionPayments  WHERE BankAccountId= @BankAccountId) OR
  EXISTS(SELECT 1 FROM dbo.DailyDistribution  WHERE BankAccountId= @BankAccountId) OR
  EXISTS(SELECT 1 FROM dbo.ConciliationMoneyTransfers  WHERE BankAccountId= @BankAccountId) OR
  EXISTS(SELECT 1 FROM dbo.ConciliationSalesTaxes  WHERE BankAccountId= @BankAccountId) OR
  EXISTS(SELECT 1 FROM dbo.RentPayments  WHERE BankAccountId= @BankAccountId) OR
  EXISTS(SELECT 1 FROM dbo.DepositFinancingPayments  WHERE BankAccountId= @BankAccountId)

	
	BEGIN

	SELECT -1

	END
	ELSE IF (EXISTS(SELECT 1 FROM dbo.BankStatements WHERE Account = @BankAccountId))
	BEGIN
		SELECT -2
	END
	ELSE
	BEGIN

	DECLARE @TCardBanks TABLE (
id int
)

INSERT INTO @TCardBanks
SELECT CardBankId FROM CardBanksXBankAccounts WHERE BankAccountId = @BankAccountId

  DELETE CardBanksXBankAccounts WHERE BankAccountId = @BankAccountId

	DELETE CardBanks WHERE CardBankId IN (SELECT id FROM @TCardBanks)

	DELETE BankAccountsXProviderBanks WHERE BankAccountId = @BankAccountId

	DELETE BankAccounts WHERE BankAccountId = @BankAccountId

	SELECT @BankAccountId

	END






END


GO