SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-22 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_CreateInsuranceQuote] 
@InsuranceQuoteId INT = NULL,
@ClientName VARCHAR(70),
@ClientTelephone VARCHAR(10),
@PolicyTypeId INT,
@DOB DATETIME,
@Address VARCHAR(100),
@GenderId INT,
@MaritalStatusId INT,
@StateAbre VARCHAR(4),
@DriverLicenseNumber VARCHAR(30) = NULL,
@DriverLicenseTypeId INT = NULL,
@CreatedBy INT,
@CreationDate DATETIME,
@CreatedInAgencyId INT,
@LastUpdatedOn DATETIME,
@LastUpdatedBy INT,
@ValidatedBy INT = NULL,
@ValidatedInAgencyId INT = NULL,
@ValidatedOn DATETIME = NULL,
@InsuranceQuoteStatusCode VARCHAR(4)
AS
BEGIN

IF(@InsuranceQuoteId IS NULL)
BEGIN

INSERT INTO [dbo].[InsuranceQuote]
           ([ClientName]
           ,[ClientTelephone]
           ,[Address]
           ,[GenderId]
           ,[DriverLicenseNumber]
           ,[DriverLicenseTypeId]
           ,[Dob]
           ,[MaritalStatusId]
           ,[PolicyTypeId]
           ,[StateAbre]
           ,[CreatedBy]
           ,[CreationDate]
           ,[CreatedInAgencyId]
           ,[LastUpdatedOn]
           ,[LastUpdatedBy]
		   ,[InsuranceQuoteStatusCode])
     VALUES
           (@ClientName
           ,@ClientTelephone
           ,@Address
           ,@GenderId
           ,@DriverLicenseNumber
           ,@DriverLicenseTypeId
           ,@DOB
           ,@MaritalStatusId
           ,@PolicyTypeId
           ,@StateAbre
           ,@CreatedBy
           ,@CreationDate
           ,@CreatedInAgencyId
           ,@LastUpdatedOn
           ,@LastUpdatedBy
		   ,@InsuranceQuoteStatusCode)

		   SELECT @@IDENTITY

		   END
		   ELSE
		   BEGIN

		   IF (EXISTS(SELECT TOP 1 i.InsuranceQuoteId FROM dbo.InsuranceQuote i WHERE i.InsuranceQuoteStatusCode = 'C02'
		   AND i.InsuranceQuoteId = @InsuranceQuoteId)) -- CANNOT UPDATE REGISTERS IN STATUS COMPLETED
		   BEGIN

		   SELECT -1

		   END
		   ELSE IF(NOT EXISTS(SELECT * FROM dbo.InsuranceQuote q WHERE q.InsuranceQuoteId = @InsuranceQuoteId))
BEGIN

SELECT -2

END
		   ELSE
		   BEGIN
		 
UPDATE [dbo].[InsuranceQuote]
   SET [ClientName] = @ClientName
      ,[ClientTelephone] = @ClientTelephone
      ,[Address] = @Address
      ,[GenderId] = @GenderId
      ,[DriverLicenseNumber] = @DriverLicenseNumber
      ,[DriverLicenseTypeId] = @DriverLicenseTypeId
      ,[Dob] = @Dob
      ,[MaritalStatusId] = @MaritalStatusId
      ,[PolicyTypeId] = @PolicyTypeId
      ,[InsuranceQuoteStatusCode] = @InsuranceQuoteStatusCode
      ,[StateAbre] = @StateAbre
      ,[LastUpdatedOn] = @LastUpdatedOn
      ,[LastUpdatedBy] = @LastUpdatedBy
	  WHERE InsuranceQuoteId = @InsuranceQuoteId


	  SELECT @InsuranceQuoteId


	  END

		   END
 

END
GO