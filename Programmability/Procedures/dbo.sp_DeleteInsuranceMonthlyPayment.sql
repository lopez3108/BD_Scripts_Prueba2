SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-31 DJ/6016: Deletes an insurance monthly payment
-- 2024-12-02 DJ/6213: Insurance - lógica incorrecta al editar o eliminar un movimiento durante el día de su creación

 CREATE PROCEDURE [dbo].[sp_DeleteInsuranceMonthlyPayment] 
@InsuranceMonthlyPaymentId INT 
AS

BEGIN

DECLARE @currentPaymentStatusCode VARCHAR(5)


		 SET @currentPaymentStatusCode = (SELECT TOP 1 Code FROM dbo.InsurancePolicyStatus i
		WHERE i.InsurancePolicyStatusId = (SELECT TOP 1 p.PaymentStatusId FROM dbo.InsuranceMonthlyPayment p WHERE p.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId))




IF (EXISTS(SELECT TOP 1 *  FROM dbo.InsuranceAchPayment i WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DECLARE @insurancePolicyId INT, @createdInsurancePolicyId INT = NULL, @createdByMonthlyPayment BIT

SELECT @insurancePolicyId = i.InsurancePolicyId, @createdInsurancePolicyId = i.CreatedInsurancePolicyId,
@createdByMonthlyPayment = p.CreatedByMonthlyPayment FROM
dbo.InsuranceMonthlyPayment i INNER JOIN dbo.InsurancePolicy p ON p.InsurancePolicyId = i.InsurancePolicyId
WHERE i.InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

DELETE dbo.InsuranceMonthlyPayment WHERE InsuranceMonthlyPaymentId = @InsuranceMonthlyPaymentId

IF(@createdByMonthlyPayment = CAST(1 as BIT))
BEGIN
IF (NOT EXISTS (SELECT * FROM dbo.InsuranceMonthlyPayment i 
INNER JOIN dbo.InsurancePolicy p ON p.InsurancePolicyId = i.InsurancePolicyId 
WHERE i.InsurancePolicyId = @insurancePolicyId))
BEGIN

DELETE dbo.InsurancePolicy WHERE InsurancePolicyId = @insurancePolicyId



END
END

SELECT @InsuranceMonthlyPaymentId

END








END

GO