SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-04-26 CB/6481: Agregar campos VIN a los Insurance policy

CREATE PROCEDURE [dbo].[sp_CreateInsurancePolicyVIN] 
@InsurancePolicyId INT,
@InsurancePolicyVINId INT = NULL,
@VinNumber VARCHAR(30)
AS
BEGIN



INSERT INTO [dbo].[InsurancepolicyVIN]
           ([InsurancePolicyId]
           ,[VinNumber])
     VALUES
           (@InsurancePolicyId
           ,@VinNumber)

		   SELECT @@IDENTITY




 

END
GO