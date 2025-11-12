SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 18/06/2024 12:03 p. m.
-- Database:    copiaDevtest
-- Description: task  5894 Error en configuración tipos de pago de comisions a providers
-- =============================================



CREATE PROCEDURE [dbo].[sp_GetProviderCommissionPaymentTypeXProvider] 
@ProviderId INT,
@IsCommissionForex INT = NULL
AS
     BEGIN

IF @IsCommissionForex IS NULL OR @IsCommissionForex = 0 BEGIN  
SELECT dbo.CommissionPaymentTypesXProviders.CommissionPaymentTypesXProviderId,
                dbo.CommissionPaymentTypesXProviders.ProviderId,
                dbo.CommissionPaymentTypesXProviders.ProviderCommissionPaymentTypeId,
                dbo.ProviderCommissionPaymentTypes.Code,
                dbo.ProviderCommissionPaymentTypes.Description 
         FROM dbo.CommissionPaymentTypesXProviders
              INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.CommissionPaymentTypesXProviders.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
         WHERE ProviderId = @ProviderId
         AND ( IsCommissionForex = 0 OR IsCommissionForex IS NULL)
	
END ELSE
IF @IsCommissionForex = 1 BEGIN  SELECT dbo.CommissionPaymentTypesXProviders.CommissionPaymentTypesXProviderId,
                dbo.CommissionPaymentTypesXProviders.ProviderId,
                dbo.CommissionPaymentTypesXProviders.ProviderCommissionPaymentTypeId,
                dbo.ProviderCommissionPaymentTypes.Code,
                dbo.ProviderCommissionPaymentTypes.Description
         FROM dbo.CommissionPaymentTypesXProviders
              INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.CommissionPaymentTypesXProviders.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
         WHERE ProviderId = @ProviderId
         AND (IsCommissionForex = @IsCommissionForex )
	
END



         
     END;
GO