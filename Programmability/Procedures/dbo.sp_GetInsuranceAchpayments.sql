SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-23 DJ/6020: Gets the list of ach payments made to a insurance
-- 2025-01-05 DJ/6329: Ajuste pagos ACH

CREATE PROCEDURE [dbo].[sp_GetInsuranceAchpayments] 
@InsurancePolicyId INT = null,
@InsuranceMonthlyPaymentId INT = null,
@InsuranceRegistrationId INT = null
AS
     BEGIN

	 SELECT 
	 i.InsuranceAchPaymentId,
	 i.BankAccountId,
	 i.AchDate,
	 i.USD,
	 i.CreationDate,
	 i.CreatedBy,
	 i.InsurancePolicyId,
	 i.InsuranceMonthlyPaymentId,
	 i.InsuranceRegistrationId,
	 '**** ' + b.AccountNumber + ' (' + bk.Name + ')'  as BankAccountName,
	 u.Name as CreatedByName,
	 i.LastUpdatedOn,
	 i.LastUpdatedBy,
	 uu.Name as LastUpdatedByName,
	 i.TypeId,
	 CASE WHEN i.TypeId = 1 THEN 'DEBIT' 
	 WHEN i.TypeId = 2 THEN 'CREDIT' 
	 WHEN i.TypeId = 3 THEN 'COMMISSION PAYMENTS' END as TypeName
	 FROM dbo.InsuranceAchPayment i
	 INNER JOIN dbo.users u ON u.UserId = i.CreatedBy
	 INNER JOIN dbo.BankAccounts b ON b.BankAccountId = i.BankAccountId
	 INNER JOIN dbo.Bank bk ON bk.BankId = b.BankId
	 LEFT JOIN dbo.users uu ON uu.UserId = i.LastUpdatedBy
	 WHERE 
	 (@InsurancePolicyId IS NOT NULL AND i.InsurancePolicyId = @InsurancePolicyId) OR
	 (@InsuranceMonthlyPaymentId IS NOT NULL AND i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId) OR
	(@InsuranceRegistrationId IS NOT NULL AND i.InsuranceRegistrationId = @InsuranceRegistrationId)


	END
GO