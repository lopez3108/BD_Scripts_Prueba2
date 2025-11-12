SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-23 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_DeleteInsuranceQuoteVIN] 
@InsuranceQuoteId INT
AS
BEGIN


DELETE InsuranceQuoteVIN WHERE InsuranceQuoteId = @InsuranceQuoteId


SELECT @InsuranceQuoteId
 

END
GO