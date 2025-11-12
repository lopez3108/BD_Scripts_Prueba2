SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-24 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuoteDriver] 
@InsuranceQuoteDriverId INT = NULL,
@InsuranceQuoteId INT
AS

BEGIN

SELECT i.InsuranceQuoteDriverId
,i.InsuranceQuoteId
      ,i.Name
      ,i.GenderId
	  ,g.Code as GenderCode
	  ,g.Description as Gender
	  ,m.Code as MartialStatusCode
	  ,m.Description as MartialStatus
      ,i.DriverLicenseNumber
      ,i.DriverLicenseTypeId
	  ,d.Description as DriverLicenseDescription
	  ,d.Code as DriverLicenseTypeCode
      ,i.Dob
      ,i.MaritalStatusId
  FROM [dbo].[InsuranceQuoteDriver] i INNER JOIN
  dbo.Gender g ON g.genderId = i.GenderId INNER JOIN
  dbo.DriverLicenseType d ON d.DriverLicenseTypeId = i.DriverLicenseTypeId INNER JOIN
  dbo.MaritalStatus m ON m.MaritalStatusId = i.MaritalStatusId 
  WHERE (@InsuranceQuoteDriverId IS NULL OR i.InsuranceQuoteDriverId = @InsuranceQuoteDriverId) AND
  (@InsuranceQuoteId IS NULL OR i.InsuranceQuoteId = @InsuranceQuoteId) 
  

END
GO