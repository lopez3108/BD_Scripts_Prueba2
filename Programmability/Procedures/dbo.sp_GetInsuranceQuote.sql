SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-23 CB/6365: Insurance quote
-- 2025-04-21 DJ/6466: Seleccionar razón de insunrace completada

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuote] 
@InsuranceQuoteId INT = NULL,
@ClientName VARCHAR(70) = NULL,
@ClientTelephone VARCHAR(10) = NULL,
@InsuranceQuoteStatusCode VARCHAR(4) = NULL,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@ListAgencyId VARCHAR(500) = NULL,
@VinNumber VARCHAR(30) = NULL,
@InsuranceQuoteCompleteReasonId INT = NULL
AS

BEGIN



SELECT  i.InsuranceQuoteId
      ,i.ClientName
      ,i.ClientTelephone
      ,i.Address
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
      ,i.PolicyTypeId
	  ,p.Description as PolicyType
      ,i.InsuranceQuoteStatusCode
	  ,i.StateAbre
      , UPPER((SELECT TOP 1 State FROm dbo.ZipCodes z where z.StateAbre = i.StateAbre)) as [State]
      ,i.CreatedBy
	   ,u.Name as CreatedByName
      ,i.CreationDate
      ,i.CreatedInAgencyId
	  ,a.Code + ' - ' + a.Name as AgencyCode
      ,i.ValidatedBy
	  ,uuu.Name as ValidatedByName
      ,i.ValidatedOn
      ,i.ValidatedInAgencyId
	   ,aa.Code + ' - ' + aa.Name as ValidatedInAgencyCode
      ,i.LastUpdatedOn
      ,i.LastUpdatedBy
	  ,uu.Name as LastUpdatedByName
	  ,a.Email AgencyEmail
	  ,ic.Description as StatusReasonText
	  ,ic.InsuranceQuoteCompleteReasonId
  FROM [dbo].[InsuranceQuote] i INNER JOIN
  dbo.Gender g ON g.genderId = i.GenderId INNER JOIN
  dbo.DriverLicenseType d ON d.DriverLicenseTypeId = i.DriverLicenseTypeId INNER JOIN
  dbo.MaritalStatus m ON m.MaritalStatusId = i.MaritalStatusId INNER JOIN
  dbo.PolicyType p ON p.PolicyTypeId = i.PolicyTypeId INNER JOIN
  dbo.Users u ON u.UserId = i.CreatedBy INNER JOIN
  dbo.Users uu ON uu.UserId = i.LastUpdatedBy LEFT JOIN
  dbo.Users uuu ON uuu.UserId = i.ValidatedBy INNER JOIN
  dbo.Agencies a ON a.AgencyId = i.CreatedInAgencyId LEFT JOIN
  dbo.InsuranceQuoteCompleteReason ic ON ic.InsuranceQuoteCompleteReasonId = i.InsuranceQuoteCompleteReasonId LEFT JOIN
  dbo.Agencies aa ON aa.AgencyId = i.ValidatedInAgencyId LEFT JOIN
  (SELECT InsuranceQuoteVINId, InsuranceQuoteId, VINNumber FROM dbo.InsuranceQuoteVIN
  WHERE VINNumber = @VinNumber) v on v.InsuranceQuoteId = i.InsuranceQuoteId
  WHERE (@InsuranceQuoteId IS NULL OR i.InsuranceQuoteId = @InsuranceQuoteId) AND
  (@ClientName IS NULL OR i.ClientName LIKE '%' +  @ClientName + '%') AND
  (@ClientTelephone IS NULL OR i.ClientTelephone = @ClientTelephone) AND
  (@InsuranceQuoteStatusCode IS NULL OR i.InsuranceQuoteStatusCode = @InsuranceQuoteStatusCode) AND
  (@FromDate IS NULL OR CAST(i.CreationDate as DATE) >= CAST(@FromDate as DATE)) AND
  (@ToDate IS NULL OR CAST(i.CreationDate as DATE) <= CAST(@ToDate as DATE)) AND
  (@InsuranceQuoteCompleteReasonId IS NULL OR @InsuranceQuoteCompleteReasonId = i.InsuranceQuoteCompleteReasonId) AND
  (@VinNumber IS NULL OR v.VINNumber = @VinNumber) AND
   (i.CreatedInAgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListAgencyId))
  OR @ListAgencyId IS NULL)
  

END
GO