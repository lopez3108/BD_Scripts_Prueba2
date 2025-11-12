SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-04-26 CB/6481: Agregar campos VIN a los Insurance policy

CREATE PROCEDURE [dbo].[sp_DeleteInsurancePolicyVIN] 
@InsurancePolicyId INT
AS
BEGIN


DELETE InsurancePolicyVIN WHERE InsurancePolicyId = @InsurancePolicyId


SELECT @InsurancePolicyId
 

END
GO