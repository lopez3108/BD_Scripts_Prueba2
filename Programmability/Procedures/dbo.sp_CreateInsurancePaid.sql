SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-20 DJ/6016: Updated insurance payment status to paid

CREATE PROCEDURE [dbo].[sp_CreateInsurancePaid] 
@InsurancePolicyId INT = NULL,
@InsuranceMonthlyPaymentId INT = NULL,
@InsuranceRegistrationId INT = NULL,
@ValidatedUSD DECIMAL(18,2),
@ValidatedAgencyId INT = NULL,
@ValidatedBy INT,
@ValidatedOn DATETIME,
@PaymentTypeCode VARCHAR(5)
AS
     BEGIN

	 DECLARE @paymentTypeId INT, @policyStatusPaid INT, @currentStatusPaid INT
	 SET @paymentTypeId = (SELECT TOP 1 InsurancePaymentTypeId FROM dbo.InsurancePaymentType WHERE Code = @PaymentTypeCode)

	 SET @policyStatusPaid = (SELECT TOP 1 InsurancePolicyStatusId FROm InsurancePolicyStatus i WHERE i.Code = 'C02')
	

	IF(@InsurancePolicyId IS NOT NULL)
	 BEGIN

	 SET @currentStatusPaid = (SELECT TOP 1 i.PaymentStatusId FROm dbo.InsurancePolicy i WHERE i.InsurancePolicyId = @InsurancePolicyId)

	 IF(@currentStatusPaid = @policyStatusPaid)
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

UPDATE [dbo].[InsurancePolicy]
   SET 
      [ValidatedOn] = @ValidatedOn
      ,[ValidatedBy] = @ValidatedBy
      ,[ValidatedAgencyId] = @ValidatedAgencyId
      ,[ValidatedUSD] = @ValidatedUSD
	  ,[InsurancePaymentTypeId] = @paymentTypeId
	  ,[PaymentStatusId] = @policyStatusPaid
	  ,[LastUpdatedBy] = @ValidatedBy
	  ,[LastUpdatedOn] = @ValidatedOn
 WHERE InsurancePolicyId = @InsurancePolicyId

 SELECT @InsurancePolicyId

 END

	 END
	 ELSE IF(@InsuranceMonthlyPaymentId IS NOT NULL)
	 BEGIN

	 SET @currentStatusPaid = (SELECT TOP 1 i.PaymentStatusId FROm dbo.InsuranceMonthlyPayment i WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId)

	 IF(@currentStatusPaid = @policyStatusPaid)
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

UPDATE [dbo].[InsuranceMonthlyPayment]
   SET [ValidatedOn] = @ValidatedOn
      ,[ValidatedBy] = @ValidatedBy
      ,[ValidatedAgencyId] = @ValidatedAgencyId
      ,[ValidatedUSD] = @ValidatedUSD
	  ,[InsurancePaymentTypeId] = @paymentTypeId
	  ,[PaymentStatusId] = @policyStatusPaid
	  ,[LastUpdatedBy] = @ValidatedBy
	  ,[LastUpdatedOn] = @ValidatedOn
 WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

 SELECT @InsuranceMonthlyPaymentId

 END


	 END
	 ELSE IF(@InsuranceRegistrationId IS NOT NULL)
	 BEGIN

	 SET @currentStatusPaid = (SELECT TOP 1 i.PaymentStatusId FROm dbo.InsuranceRegistration i WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId)

	 IF(@currentStatusPaid = @policyStatusPaid)
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

UPDATE [dbo].[InsuranceRegistration]
   SET [ValidatedOn] = @ValidatedOn
      ,[ValidatedBy] = @ValidatedBy
      ,[ValidatedAgencyId] = @ValidatedAgencyId
      ,[ValidatedUSD] = @ValidatedUSD
	  ,[InsurancePaymentTypeId] = @paymentTypeId
	  ,[PaymentStatusId] = @policyStatusPaid
	  ,[LastUpdatedBy] = @ValidatedBy
	  ,[LastUpdatedOn] = @ValidatedOn
 WHERE InsuranceRegistrationId = @InsuranceRegistrationId

 SELECT @InsuranceRegistrationId

 END


	 END
	 

		 END
GO