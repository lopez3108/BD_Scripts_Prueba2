SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


-- 2025-02-12 DJ/6390: Permitir conciliar insurance

CREATE PROCEDURE [dbo].[sp_GetInsurancePolicyMonthlyPaymentByTransactionId] 
@TransactionId VARCHAR(36)
AS

BEGIN

DECLARE @insurancePaymentStatusId INT
	 SET @insurancePaymentStatusId = (SELECT TOP 1 i.InsurancePaymentTypeId FROM dbo.InsurancePaymentType i WHERE i.Code = 'C04')

  SELECT
    i.[InsurancePolicyId] as InsurancePolicyId,
	NULL as InsuranceMonthlyPaymentId,
	i.CreationDate
  FROM [dbo].[InsurancePolicy] i INNER JOIN
  dbo.InsurancePolicyStatus s ON s.InsurancePolicyStatusId = i.PaymentStatusId
  WHERE i.TransactionId = @TransactionId AND 
  s.Code = 'C01' -- PENDING

  UNION ALL

    SELECT
    NULL as InsurancePolicyId,
	[InsuranceMonthlyPaymentId] as InsuranceMonthlyPaymentId,
	i.CreationDate
  FROM [dbo].[InsuranceMonthlyPayment] i INNER JOIN
  dbo.InsurancePolicyStatus s ON s.InsurancePolicyStatusId = i.PaymentStatusId
  WHERE i.TransactionId = @TransactionId AND
  s.Code = 'C01' -- PENDING

END

GO