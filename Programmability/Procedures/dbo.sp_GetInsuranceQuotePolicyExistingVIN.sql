SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-04-27 CB/6481: Agregar campos VIN a los Insurance policy

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuotePolicyExistingVIN] 
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
  WHERE 
  v.VinNumber = @VinNumber AND
  i.InsuranceQuoteStatusCode = 'C01' --PENDING








END
GO