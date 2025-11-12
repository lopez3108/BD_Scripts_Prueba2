SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-22 CB/6365: Insurance quot
-- 2025-04-30 DJ/6465: Validar que no se dupliquen quotes en estado pending y por número VIN

CREATE PROCEDURE [dbo].[sp_CreateInsuranceQuoteVIN] 
@InsuranceQuoteId INT,
@InsuranceQuoteVINId INT = NULL,
@VinNumber VARCHAR(30)
AS
BEGIN

IF (EXISTS(SELECT * FROM dbo.InsuranceQuoteVIN v INNER JOIN dbo.InsuranceQuote q ON q.InsuranceQuoteId = v.InsuranceQuoteId 
WHERE v.VINNumber = @VinNumber AND v.InsuranceQuoteId <> @InsuranceQuoteId AND q.InsuranceQuoteStatusCode = 'C01')) --PENDING
BEGIN

SELECT -4

END
ELSE
BEGIN

INSERT INTO [dbo].[InsuranceQuoteVIN]
           ([InsuranceQuoteId]
           ,[VinNumber])
     VALUES
           (@InsuranceQuoteId
           ,@VinNumber)

		   SELECT @@IDENTITY

END


 

END
GO