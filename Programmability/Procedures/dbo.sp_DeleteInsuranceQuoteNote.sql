SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-23 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_DeleteInsuranceQuoteNote] 
@InsuranceQuoteId INT
AS
BEGIN


DELETE InsuranceQuoteNote WHERE InsuranceQuoteId = @InsuranceQuoteId


SELECT @InsuranceQuoteId
 

END
GO