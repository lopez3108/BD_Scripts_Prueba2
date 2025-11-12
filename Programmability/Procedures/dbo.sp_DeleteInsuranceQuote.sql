SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-28 CB/6365: Insurance quote

CREATE PROCEDURE [dbo].[sp_DeleteInsuranceQuote] 
@InsuranceQuoteId INT,
@Date DATETIME,
@UserId INT
AS
BEGIN

DECLARE @creationDate DATETIME, @createdBy INT

SELECT @creationDate = i.CreationDate, @createdBy = i.CreatedBy FROM dbo.InsuranceQuote i 
WHERE i.InsuranceQuoteId = @InsuranceQuoteId


IF(EXISTS(SELECT * FROM dbo.InsurancePolicy p WHERE p.InsuranceQuoteId = @InsuranceQuoteId))
BEGIN

SELECT -1 -- Insurance policy relationship


END
ELSE IF (CAST(@creationDate as DATE) <> CAST(@Date as DATE) OR @UserId <> @createdBy)
BEGIN

SELECT -2 -- Only the same user in the same creation date can delete

END
ELSE IF ((SELECT TOP 1 q.InsuranceQuoteStatusCode FROM dbo.InsuranceQuote q WHERE q.InsuranceQuoteId = @InsuranceQuoteId) = 'C02' )
BEGIN

SELECT -3 -- Quote COMPLETED cannot be deleted

END
ELSE IF (NOT EXISTS(SELECT TOP 1 * FROM dbo.InsuranceQuote q WHERE q.InsuranceQuoteId = @InsuranceQuoteId) )
BEGIN

SELECT -4 -- Quote COMPLETED cannot be deleted

END
ELSE
BEGIN

DELETE InsuranceQuoteDriver WHERE InsuranceQuoteId = @InsuranceQuoteId
DELETE InsuranceQuoteVIN WHERE InsuranceQuoteId = @InsuranceQuoteId
DELETE InsuranceQuoteNote WHERE InsuranceQuoteId = @InsuranceQuoteId

DELETE InsuranceQuote WHERE InsuranceQuoteId = @InsuranceQuoteId

SELECT @InsuranceQuoteId


END


SELECT @InsuranceQuoteId
 

END
GO