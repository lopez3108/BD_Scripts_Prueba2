SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-12-23 DJ/6250: Nueva comisión para config de los providers tipo INSURANCE

CREATE PROCEDURE [dbo].[sp_DeleteInsuranceProviderCommissionType] 
@ProviderId INT 
AS

BEGIN


DELETE FROM [dbo].[InsuranceCommissionTypeXProvider]
      WHERE ProviderId = @ProviderId

	  SELECT @ProviderId

END
GO