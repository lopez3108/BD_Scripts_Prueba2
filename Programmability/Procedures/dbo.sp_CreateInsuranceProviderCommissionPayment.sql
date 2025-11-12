SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-02-18 DJ/6344: Pago de Comisiones a Proveedores de Tipo INSURANCE

CREATE PROCEDURE [dbo].[sp_CreateInsuranceProviderCommissionPayment](
@ProviderCommissionPaymentId INT, 
@NewPolicyQuantity INT,
@MonthlyPaymentQuantity INT,
@EndorsementQuantity INT,
@PolicyRenewalQuantity INT,
@RegistrationReleaseQuantity INT,
@NewPolicyAmount DECIMAL(18,2),
@MonthlyPaymentAmount DECIMAL(18,2),
@EndorsementAmount DECIMAL(18,2),
@PolicyRenewalAmount DECIMAL(18,2),
@RegistrationReleaseAmount DECIMAL(18,2)

)
AS
     BEGIN

	 DELETE dbo.InsuranceProviderCommissionPayment WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId



INSERT INTO [dbo].[InsuranceProviderCommissionPayment]
           ([ProviderCommissionPaymentId]
           ,[NewPolicyQuantity]
           ,[NewPolicyAmount]
           ,[MonthlyPaymentQuantity]
           ,[MonthlyPaymentAmount]
           ,[EndorsementQuantity]
           ,[EndorsementAmount]
           ,[PolicyRenewalQuantity]
           ,[PolicyRenewalAmount]
           ,[RegistrationReleaseQuantity]
           ,[RegistrationReleaseAmount])
     VALUES
           (@ProviderCommissionPaymentId
           ,@NewPolicyQuantity
           ,@NewPolicyAmount
           ,@MonthlyPaymentQuantity
           ,@MonthlyPaymentAmount
           ,@EndorsementQuantity
           ,@EndorsementAmount
           ,@PolicyRenewalQuantity
           ,@PolicyRenewalAmount
           ,@RegistrationReleaseQuantity
           ,@RegistrationReleaseAmount)

		   SELECT @@IDENTITY



     END;
GO