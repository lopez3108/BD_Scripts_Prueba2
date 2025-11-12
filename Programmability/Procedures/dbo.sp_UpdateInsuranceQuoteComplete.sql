SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-26 CB/6365: Insurance quot
-- 2025-04-21 DJ/6466: Seleccionar razón de insunrace completada

CREATE PROCEDURE [dbo].[sp_UpdateInsuranceQuoteComplete] 
@InsuranceQuoteId INT,
@ValidatedBy INT,
@ValidatedOn DATETIME,
@ValidatedInAgencyId INT,
@InsuranceQuoteStatusCode VARCHAR(4),
@InsuranceQuoteCompleteReasonId INT,
@Result INT OUTPUT
AS
BEGIN

DECLARE @currentStatusCode VARCHAR(4)
SET @currentStatusCode = (SELECT TOP 1 InsuranceQuoteStatusCode FROm dbo.InsuranceQuote q WHERE
q.InsuranceQuoteId = @InsuranceQuoteId)

IF(@currentStatusCode = 'C02') -- COMPLETED
BEGIN

SET @Result = -1

END
ELSE IF(NOT EXISTS(SELECT * FROM dbo.InsuranceQuote q WHERE q.InsuranceQuoteId = @InsuranceQuoteId))
BEGIN

SET @Result = -2

END
ELSE
BEGIN

UPDATE InsuranceQuote
SET InsuranceQuoteStatusCode = @InsuranceQuoteStatusCode, ValidatedBy = @ValidatedBy, 
ValidatedOn = @ValidatedOn, ValidatedInAgencyId = @ValidatedInAgencyId, LastUpdatedBy = @ValidatedBy,
LastUpdatedOn = @ValidatedOn, InsuranceQuoteCompleteReasonId = @InsuranceQuoteCompleteReasonId
WHERE InsuranceQuoteId = @InsuranceQuoteId

SET @Result = @InsuranceQuoteId


END




END
GO