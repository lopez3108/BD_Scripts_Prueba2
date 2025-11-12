SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-03-02 JF/6348: Restringir providers INSURANCE luego de pagada la comisión provider

CREATE PROCEDURE [dbo].[sp_GetInsuranceById](@InsuranceId INT, @InsuranceType VARCHAR(5))
AS
BEGIN
  IF (@InsuranceType = 'C01')
  BEGIN
    SELECT
      ip.InsurancePolicyId
     ,ip.ProviderId
     ,ip.InsuranceCompaniesId
     ,ip.PolicyTypeId
     ,ip.PaymentType
     ,ip.USD
     ,ISNULL(ip.CardFee,0) CardFee

    FROM dbo.InsurancePolicy ip  
    WHERE ip.InsurancePolicyId = @InsuranceId
  END
  ELSE
  IF (@InsuranceType = 'C02')
  BEGIN
    SELECT
      imp.InsuranceMonthlyPaymentId
     ,ii.ProviderId
     ,ii.InsuranceCompaniesId
     ,ii.PolicyTypeId
     ,imp.PaymentType
     ,imp.USD
     ,ISNULL(imp.CardFee,0) CardFee
    FROM dbo.InsuranceMonthlyPayment imp
    	INNER JOIN dbo.InsurancePolicy ii ON ii.InsurancePolicyId = imp.InsurancePolicyId
    WHERE imp.InsuranceMonthlyPaymentId = @InsuranceId
  END
  ELSE
  BEGIN
    SELECT
      ir.InsuranceRegistrationId
     ,ir.ProviderId
     ,ir.PaymentType
     ,ir.USD  
     ,ISNULL(ir.CardFee,0) CardFee
    FROM dbo.InsuranceRegistration ir 
    WHERE ir.InsuranceRegistrationId = @InsuranceId
  END
END

GO