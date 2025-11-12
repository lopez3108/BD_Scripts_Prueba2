SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-03-02 JF/6348: Restringir providers INSURANCE luego de pagada la comisión provider

CREATE PROCEDURE [dbo].[sp_GetInsurancePaidStatus] (@InsuranceId INT, @InsuranceType VARCHAR(5))
AS
BEGIN
  IF (@InsuranceType = 'C01')
  BEGIN
    SELECT
      ip.InsurancePolicyId
     ,ips.Code
    FROM dbo.InsurancePolicy ip
    INNER JOIN InsurancePolicyStatus ips
      ON ip.PaymentStatusId = ips.InsurancePolicyStatusId
    WHERE ip.InsurancePolicyId = @InsuranceId
  END
  ELSE
  IF (@InsuranceType = 'C02')
  BEGIN
    SELECT
      imp.InsuranceMonthlyPaymentId
     ,ips.Code
    FROM dbo.InsuranceMonthlyPayment imp
    INNER JOIN InsurancePolicyStatus ips
      ON imp.PaymentStatusId = ips.InsurancePolicyStatusId
    WHERE imp.InsuranceMonthlyPaymentId = @InsuranceId
  END
  ELSE
  BEGIN
    SELECT
      ir.InsuranceRegistrationId
     ,ips.Code
    FROM dbo.InsuranceRegistration ir 
    INNER JOIN InsurancePolicyStatus ips
      ON ir.PaymentStatusId = ips.InsurancePolicyStatusId
    WHERE ir.InsuranceRegistrationId = @InsuranceId
  END
END
GO