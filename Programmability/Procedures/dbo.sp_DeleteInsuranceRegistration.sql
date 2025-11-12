SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-31 DJ/6016: Deletes an insurance registration
-- 2024-12-02 DJ/6213: Insurance - lógica incorrecta al editar o eliminar un movimiento durante el día de su creación

 CREATE PROCEDURE [dbo].[sp_DeleteInsuranceRegistration] 
@InsuranceRegistrationId INT 
AS

BEGIN

DECLARE @currentPaymentStatusCode VARCHAR(5)


		 SET @currentPaymentStatusCode = (SELECT TOP 1 Code FROM dbo.InsurancePolicyStatus i
		WHERE i.InsurancePolicyStatusId = (SELECT TOP 1 p.PaymentStatusId FROM dbo.InsuranceRegistration p WHERE p.InsuranceRegistrationId = @InsuranceRegistrationId))




IF (EXISTS(SELECT TOP 1 *  FROM dbo.InsuranceAchPayment i WHERE i.InsuranceRegistrationId = @InsuranceRegistrationId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE dbo.InsuranceRegistration WHERE InsuranceRegistrationId = @InsuranceRegistrationId
SELECT @InsuranceRegistrationId

END


END
GO