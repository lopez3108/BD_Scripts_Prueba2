SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-26 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuotePendingNumber] 
@AgencyId INT = NULL
AS

BEGIN


SELECT COUNT( i.InsuranceQuoteId)
  FROM [dbo].[InsuranceQuote] i 
  WHERE i.InsuranceQuoteStatusCode = 'C01'  -- PENDING 
  AND (@AgencyId IS NULL OR @AgencyId = i.CreatedInAgencyId)

END
GO