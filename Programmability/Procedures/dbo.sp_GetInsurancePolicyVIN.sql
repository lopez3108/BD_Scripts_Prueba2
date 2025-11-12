SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-04-26 CB/6481: Agregar campos VIN a los Insurance policy

CREATE PROCEDURE [dbo].[sp_GetInsurancePolicyVIN] 
@InsurancePolicyId INT
AS

BEGIN

SELECT i.InsurancePolicyVINId
,i.InsurancePolicyId
,i.VINNumber
      
  FROM [dbo].[InsurancePolicyVIN] i 
  WHERE 
  (i.InsurancePolicyId = @InsurancePolicyId) 
  

END
GO