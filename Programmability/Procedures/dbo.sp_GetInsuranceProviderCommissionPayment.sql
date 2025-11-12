SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-02-18 DJ/6344: Pago de Comisiones a Proveedores de Tipo INSURANCE

CREATE PROCEDURE [dbo].[sp_GetInsuranceProviderCommissionPayment](
@ProviderCommissionPaymentId INT

)
AS
     BEGIN


SELECT [InsuranceProviderCommissionPaymentId]
      ,[ProviderCommissionPaymentId]
      ,[NewPolicyQuantity]
      ,[NewPolicyAmount]
      ,[MonthlyPaymentQuantity]
      ,[MonthlyPaymentAmount]
      ,[EndorsementQuantity]
      ,[EndorsementAmount]
      ,[PolicyRenewalQuantity]
      ,[PolicyRenewalAmount]
      ,[RegistrationReleaseQuantity]
      ,[RegistrationReleaseAmount]
  FROM [dbo].[InsuranceProviderCommissionPayment]
  WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId



     END;
GO