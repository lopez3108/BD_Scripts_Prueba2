SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-12-23 DJ/6250: Nueva comisión para config de los providers tipo INSURANCE

CREATE PROCEDURE [dbo].[sp_CreateInsuranceCommissionPolicyTypeMovement]
@ProviderId INT,
@PolicyTypeId INT,
@InsuranceCommissionTypeId INT,
@Usd DECIMAL(18,2)

AS

BEGIN



INSERT INTO [dbo].[InsuranceCommissionPolicyTypeMovement]
           ([ProviderId]
           ,[PolicyTypeId]
           ,[InsuranceCommissionTypeId]
           ,[USD])
     VALUES
           (@ProviderId
           ,@PolicyTypeId
           ,@InsuranceCommissionTypeId
           ,@Usd)

		   SELECT @ProviderId






END
GO