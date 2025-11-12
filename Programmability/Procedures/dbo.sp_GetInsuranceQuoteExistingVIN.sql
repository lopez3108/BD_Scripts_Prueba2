SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-04-24 DJ/6465: Validar que no se dupliquen quotes en estado pending y por número VIN

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuoteExistingVIN] 
@InsuranceQuoteId INT = NULL,
@VinNumber VARCHAR(30) = NULL
AS

BEGIN

SELECT v.[InsuranceQuoteVINId]
      ,v.[InsuranceQuoteId]
      ,v.[VINNumber]
	  ,i.DriverLicenseTypeId
	  ,i.DriverLicenseNumber
	  ,d.Description as DriverLicenseTypeDescription
	  ,i.ClientName
	  ,i.ClientTelephone
  FROM [dbo].[InsuranceQuoteVIN] v INNER JOIN
  dbo.InsuranceQuote i ON i.InsuranceQuoteId = v.InsuranceQuoteId INNER JOIN
  dbo.DriverLicenseType d ON d.DriverLicenseTypeId = i.DriverLicenseTypeId
  WHERE ((@InsuranceQuoteId IS NULL) OR (@InsuranceQuoteId IS NOT NULL AND v.InsuranceQuoteId <> @InsuranceQuoteId)) AND
  v.VinNumber = @VinNumber AND
  i.InsuranceQuoteStatusCode = 'C01' --PENDING








END
GO