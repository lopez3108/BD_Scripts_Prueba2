SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-12-23 DJ/6250: Nueva comisión para config de los providers tipo INSURANCE

CREATE PROCEDURE [dbo].[sp_CreateInsuranceProviderCommissionType] 
@ProviderId INT,
@InsuranceCommissionTypeId INT,
@Usd DECIMAL(18,2),
@FeeService DECIMAL(18,2)
AS

BEGIN



INSERT INTO [dbo].[InsuranceCommissionTypeXProvider]
           ([ProviderId]
           ,[InsuranceCommissionTypeId]
           ,[USD]
		   ,[FeeService])
     VALUES
           (@ProviderId
           ,@InsuranceCommissionTypeId
           ,@Usd
		   ,@FeeService)

		   SELECT @ProviderId






END
GO