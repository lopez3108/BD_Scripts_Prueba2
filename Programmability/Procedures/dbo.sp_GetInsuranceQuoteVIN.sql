SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-24 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuoteVIN] 
@InsuranceQuoteId INT
AS

BEGIN

SELECT i.InsuranceQuoteVINId
,i.InsuranceQuoteId
,i.VINNumber
      
  FROM [dbo].[InsuranceQuoteVIN] i 
  WHERE 
  (i.InsuranceQuoteId = @InsuranceQuoteId) 
  

END
GO