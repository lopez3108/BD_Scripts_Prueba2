SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-08-28 DJ/6016: Deletes an insurance policy
-- 2024-12-02 DJ/6213: Insurance - lógica incorrecta al editar o eliminar un movimiento durante el día de su creación
-- 2025-02-27 DJ/6365: Insurance quot
-- 2025-04-30 DJ/6481: Agregar campos VIN a los Insurance policy

CREATE PROCEDURE [dbo].[sp_DeleteInsurancePolicy] 
@InsurancePolicyId INT ,
@Date DATETIME
AS

BEGIN

DECLARE @currentPaymentStatusCode VARCHAR(5)

		 SET @currentPaymentStatusCode = (SELECT TOP 1 Code FROM dbo.InsurancePolicyStatus i
		WHERE i.InsurancePolicyStatusId = (SELECT TOP 1 p.PaymentStatusId FROM dbo.InsurancePolicy p WHERE p.InsurancePolicyId = @InsurancePolicyId))

IF (EXISTS(SELECT TOP 1 *  FROM dbo.InsuranceMonthlyPayment i WHERE i.InsurancePolicyId = @InsurancePolicyId) OR
EXISTS(SELECT TOP 1 *  FROM dbo.InsuranceAchPayment i WHERE i.InsurancePolicyId = @InsurancePolicyId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DECLARE @insuranceQuoteId INT = NULL
SET @insuranceQuoteId = (SELECT TOP 1 i.InsuranceQuoteId FROM dbo.InsurancePolicy i WHERE i.InsurancePolicyId = @InsurancePolicyId)

DECLARE @userId INT
SET @userId = (SELECT TOP 1 CreatedBy FROM  dbo.InsurancePolicy i WHERE i.InsurancePolicyId = @InsurancePolicyId)

DELETE dbo.InsurancePolicyVIN WHERE InsurancePolicyId = @InsurancePolicyId

DELETE dbo.InsurancePolicy WHERE InsurancePolicyId = @InsurancePolicyId

IF(@insuranceQuoteId IS NOT NULL)
BEGIN

UPDATE InsuranceQuote
SET InsuranceQuoteStatusCode = 'C01', -- PENDING
ValidatedBy = NULL, 
ValidatedOn = NULL, ValidatedInAgencyId = NULL, LastUpdatedBy = @userId,
LastUpdatedOn = @Date
WHERE InsuranceQuoteId = @InsuranceQuoteId

END

SELECT @InsurancePolicyId

END

END
GO